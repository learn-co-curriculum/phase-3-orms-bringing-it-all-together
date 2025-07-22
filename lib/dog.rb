class Dog
  attr_accessor :id, :name, :breed

  def initialize(name:, breed:, id: nil)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs;
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
      INSERT INTO dogs (name, breed) VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, @name, @breed)
    @id = DB[:conn].last_insert_row_id
    self
  end

  def self.create(name:, breed:)
    dog = Dog.new(name: name, breed: breed)
    dog.save
    dog
  end

  def self.new_from_db(data)
    Dog.new(id: data[0], name: data[1], breed: data[2])
  end

  def self.all
    sql = <<-SQL
      SELECT * from dogs;
    SQL
    dogs = DB[:conn].execute(sql)
    dogs.map { |dog| Dog.new_from_db(dog) }
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * from dogs where name = ?;
    SQL
    row = DB[:conn].execute(sql, name).first
    row ? Dog.new_from_db(row) : nil
  end

  def self.find(id)
    sql = <<-SQL
      SELECT * from dogs where id = ?;
    SQL
    row = DB[:conn].execute(sql, id).first
    row ? Dog.new_from_db(row) : nil
  end
end
