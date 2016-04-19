require "order_as_specified/version"

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

    table = params[:table]
    attribute = params[:attribute]

    # We have to explicitly quote for now because SQL sanitization for ORDER BY
    # queries hasn't yet merged into Rails.
    # See: https://github.com/rails/rails/pull/13008
    conditions = params[:values].map do |value|
      "#{table}.#{attribute}='#{value}'"
    end

    scope = order(conditions.map { |cond| "#{cond} DESC" }.join(", "))

    if distinct_on
      scope = scope.select("DISTINCT ON (#{conditions.join(', ')}) #{table}.*")
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
  def extract_params(table = table_name, hash)
    raise "Could not parse params" unless hash.size == 1

    key, val = hash.first

    if val.is_a? Hash
      extract_params(key, hash[key])
    else
      {
        table: table,
        attribute: key,
        values: val
      }
    end
  end
end
