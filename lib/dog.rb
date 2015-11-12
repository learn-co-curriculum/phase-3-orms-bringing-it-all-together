class Dog
  ATTRIBUTES = {
    :id => "INTEGER PRIMARY KEY",
    :name => "TEXT",
    :color => "TEXT",
    :breed =>  "TEXT",
    :instagram =>  "TEXT"
  }
  # ATTRIBUTES.keys.each do |attribute|
  #   attr_accessor attribute
  # end
  attr_accessor *ATTRIBUTES.keys

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        #{schema_definition}
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.schema_definition
    ATTRIBUTES.collect{|k,v| "#{k} #{v}"}.join(",")
  end

  def sql_for_update
    ATTRIBUTES.keys[1..-1].collect{|k| "#{k} = ?"}.join(",")
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def self.new_from_db(row)
    self.new.tap do |s|
      row.each_with_index do |value, index|
        s.send("#{ATTRIBUTES.keys[index]}=", value)
      end
    end
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    result = DB[:conn].execute(sql,name)[0] #[]
    self.new_from_db(result) if result
  end

  def attribute_values
    ATTRIBUTES.keys[1..-1].collect{|key| self.send(key)}
  end

  def insert
    sql = "INSERT INTO dogs (#{ATTRIBUTES.keys[1..-1].join(",")}) VALUES (?,?,?,?)"
    DB[:conn].execute(sql, *attribute_values)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
  end


  def update
    sql = "UPDATE dogs SET #{sql_for_update} WHERE id = ?"
    DB[:conn].execute(sql, *attribute_values, id)
  end

  def persisted?
    !!self.id
  end

  def save
    persisted? ? update : insert
  end
end
