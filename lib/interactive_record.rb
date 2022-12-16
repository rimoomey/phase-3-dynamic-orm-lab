require_relative '../config/environment'
require 'active_support/inflector'

class InteractiveRecord
  def initialize(attributes = {})
    attributes.each do |key, value|
      send("#{key}=", value)
    end
  end

  def self.table_name
    name.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "PRAGMA table_info('#{table_name}')"
    DB[:conn].execute(sql).map do |hash|
      hash['name']
    end
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM #{table_name}
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name)
  end

  def self.find_by(attribute)
    key = attribute.keys[0]
    value = attribute.values[0]
    sql = <<-SQL
      SELECT *
      FROM #{table_name}
      WHERE #{key} = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, value)
  end
end
