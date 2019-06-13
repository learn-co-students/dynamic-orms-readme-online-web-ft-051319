require 'sqlite3'
require 'pry'


DB = {:conn => SQLite3::Database.new("db/songs.db")}
DB[:conn].execute("DROP TABLE IF EXISTS songs") #drops the table for testing purposes

sql = <<-SQL
  CREATE TABLE IF NOT EXISTS songs (
  id INTEGER PRIMARY KEY,
  name TEXT,
  album TEXT
  )
SQL

DB[:conn].execute(sql) #exexutes sql above
DB[:conn].results_as_hash = true # returns results as hash rather than array
#returns {"id"=>1, "name"=>"Hello", "album"=>"25", 0 => 1, 1 => "Hello", 2 => "25"}
