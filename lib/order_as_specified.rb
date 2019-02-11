# frozen_string_literal: true

require "order_as_specified/version"
require "order_as_specified/error"

# This module adds the ability to query an ActiveRecord class for results from
# the database in an arbitrary order, without having to store anything extra
# in the database. Simply `extend` it into your class and then you can use the
# `order_as_specified` class method.
module OrderAsSpecified
  # @param hash [Hash] the ActiveRecord arguments hash
  # @return [ActiveRecord::Relation] the objects, ordered as specified
  def order_as_specified(hash)
    distinct_on = hash.delete(:distinct_on)
    params = extract_params(hash)
    return all if params[:values].empty?

    table = connection.quote_table_name(params[:table])
    attribute = connection.quote_column_name(params[:attribute])

    conditions = params[:values].map do |value|
      raise OrderAsSpecified::Error, "Cannot order by `nil`" if value.nil?

      if value.is_a? Range
        range_clause("#{table}.#{attribute}", value)
      else
        # Sanitize each value to reduce the risk of SQL injection.
        "#{table}.#{attribute}=#{quote(value)}"
      end
    end

    when_queries = conditions.map.with_index do |cond, index|
      "WHEN #{cond} THEN #{index}"
    end
    case_query = "CASE #{when_queries.join(' ')} ELSE #{conditions.size} END"
    scope = order(Arel.sql("#{case_query} ASC"))

    if distinct_on
      scope = scope.select(
        Arel.sql("DISTINCT ON (#{case_query}) #{table}.*")
      )
    end

    scope
  end

  private

  # Recursively search through the hash to find the last elements, which
  # indicate the name of the table we want to condition on, the attribute name,
  # and the attribute values for ordering by.
  # @param table [String/Symbol] the name of the table, default: the class table
  # @param hash [Hash] the ActiveRecord-style arguments, such as:
  #   { other_objects: { id: [1, 5, 3] } }
  def extract_params(hash, table = table_name)
    unless hash.size == 1
      raise OrderAsSpecified::Error, "Could not parse params"
    end

    key, val = hash.first

    if val.is_a? Hash
      extract_params(hash[key], key)
    else
      {
        table: table,
        attribute: key,
        values: val
      }
    end
  end

  def range_clause(col, range)
    if range.first >= range.last
      raise OrderAsSpecified::Error, "Range needs to be increasing"
    end

    op = range.exclude_end? ? "<" : "<="
    "#{col} >= #{quote(range.first)} AND #{col} #{op} #{quote(range.last)}"
  end

  def quote(value)
    # We have to explicitly quote for now because SQL sanitization for ORDER BY
    # queries isn't in less current versions of Rails.
    # See: https://github.com/rails/rails/pull/13008
    ActiveRecord::Base.connection.quote(value)
  end
end
