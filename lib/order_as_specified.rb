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
    case_insensitive = hash.delete(:case_insensitive)

    params = extract_params(hash)
    return all if params[:values].empty?

    table = Arel::Table.new(params[:table])
    node = Arel::Nodes::Case.new

    params[:values].each_with_index do |value, index|
      attribute = table[params[:attribute]]
      condition =
        if value.is_a?(Range)
          if value.first >= value.last
            raise OrderAsSpecified::Error, "Range needs to be increasing"
          end

          attribute.between(value)
        elsif case_insensitive
          attribute.matches(value)
        else
          attribute.eq(value)
        end

      node.when(condition).then(index)
    end

    node.else(node.conditions.size)
    scope = order(Arel::Nodes::Ascending.new(table.grouping(node)))

    if distinct_on
      distinct = Arel::Nodes::DistinctOn.new(node)
      table_alias = connection.quote_table_name(table.name)
      scope = scope.select(Arel.sql("#{distinct.to_sql} #{table_alias}.*"))
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
end
