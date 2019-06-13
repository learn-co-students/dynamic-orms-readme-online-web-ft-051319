require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class Song


  def self.table_name
    self.to_s.downcase.pluralize #converts class name to lower case plural string
  end #pluralize uses active_support/inflector

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')" #queries the table for the name of it's columns

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row| #iterates through results of table info hash for name
      column_names << row["name"] #adds each row name to column names array
    end
    column_names.compact #returns column names
  end

  self.column_names.each do |col_name| #creates attr_accessor for each column name and converts to symbol
    attr_accessor col_name.to_sym
  end

  def initialize(options={}) #take in an argument of options, which defaults to an empty hash. New should be called with a hash
    options.each do |property, value| #iterating through hash that was passed in
      self.send("#{property}=", value)#interpolate the name of each hash key as a method that we set equal to that key's value
      #self before send: #<Song:0x00007ff40511df40>
      #self after send: #<Song:0x00007ff40511df40 @name="Hello">
    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    self.class.table_name #evaluates to songs
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end
   #iterates over the column names stored in #column_names and use the #send method with each individual column name to invoke the method by that same name and capture the return value:

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")#id is not created until after we retrieve it from the db and returns the rest as a comma separated list rather than an array
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end
  #uses the #table_name class method we built that will return the table name associated with any given class.

end
