require_relative '../config/environment'
require 'active_support/inflector'
require 'interactive_record'

class Student < InteractiveRecord
  column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if { |col| col == 'id' }.join(', ')
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(', ')
  end

  def save
    save_sql = <<-SQL
      INSERT INTO #{self.class.table_name} (#{col_names_for_insert}) VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(save_sql)

    id_sql = <<-SQL
      SELECT last_insert_rowid() FROM #{self.class.table_name}
    SQL

    @id = DB[:conn].execute(id_sql)[0][0]
  end
end
