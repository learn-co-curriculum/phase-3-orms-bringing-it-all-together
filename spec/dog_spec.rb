describe Dog do
  before do
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  describe "attributes" do
    it 'has a name and a breed' do
      dog = Dog.new(name: "Fido", breed: "lab")
      expect(dog).to have_attributes(name: "Fido", breed: "lab")
    end

    it 'has an id that defaults to `nil` on initialization' do
      dog = Dog.new(name: "Fido", breed: "lab")
      expect(dog.id).to eq(nil)
    end
  end

  describe ".create_table" do
    it 'creates the dogs table in the database' do
      DB[:conn].execute("DROP TABLE IF EXISTS dogs")
      Dog.create_table
      table_check_sql = "SELECT tbl_name FROM sqlite_master WHERE type='table' AND tbl_name='dogs';"
      expect(DB[:conn].execute(table_check_sql)[0]).to eq(['dogs'])
    end
  end

  describe ".drop_table" do
    it 'drops the dogs table from the database' do
      Dog.drop_table
      table_check_sql = "SELECT tbl_name FROM sqlite_master WHERE type='table' AND tbl_name='dogs';"
      expect(DB[:conn].execute(table_check_sql)[0]).to eq(nil)
    end
  end

  describe "#save" do
    it 'returns an instance of the dog class' do
      dog = Dog.new(name: "Teddy", breed: "cockapoo") 
      dog.save

      expect(dog).to have_attributes(
        class: Dog,
        id: 1,
        name: "Teddy",
        breed: "cockapoo"
      )
    end

    it 'saves an instance of the dog class to the database and then sets the given dogs `id` attribute' do
      dog = Dog.new(name: "Teddy", breed: "cockapoo") 
      dog.save

      expect(DB[:conn].execute("SELECT * FROM dogs WHERE id = 1")).to eq([[1, "Teddy", "cockapoo"]])
    end
  end

  describe ".create" do
    it 'create a new dog object and uses the #save method to save that dog to the database'do
      Dog.create(name: "Ralph", breed: "lab")
      expect(DB[:conn].execute("SELECT * FROM dogs")).to eq([[1, "Ralph", "lab"]])
    end

    it 'returns a new dog object' do
      dog = Dog.create(name: "Dave", breed: "poodle")

      expect(dog).to have_attributes(
        class: Dog, 
        id: 1,
        name: "Dave", 
        breed: "poodle"
      )
    end
  end

  describe '.new_from_db' do
    it 'creates an instance with corresponding attribute values' do
      row = [1, "Pat", "poodle"]
      pat = Dog.new_from_db(row)

      expect(pat).to have_attributes(
        class: Dog,
        id: 1,
        name: "Pat",
        breed: "poodle"
      )
    end
  end

  describe '.all' do
    it 'returns an array of Dog instances for all records in the dogs table' do
      Dog.create(name: "Dave", breed: "poodle")
      Dog.create(name: "Kevin", breed: "shepard")

      expect(Dog.all).to match_array([
        have_attributes(class: Dog, id: 1, name: "Dave", breed: "poodle"),
        have_attributes(class: Dog, id: 2, name: "Kevin", breed: "shepard")
      ])
    end
  end
  
  describe '.find_by_name' do
    it 'returns an instance of dog that matches the name from the DB' do
      Dog.create(name: "Kevin", breed: "shepard")
      Dog.create(name: "Dave", breed: "poodle")

      dog_from_db = Dog.find_by_name("Kevin") 

      expect(dog_from_db).to have_attributes(
        class: Dog,
        id: 1,
        name: "Kevin",
        breed: "shepard"
      )
    end
  end

  describe '.find' do
    it 'returns a new dog object by id' do
      Dog.create(name: "Kevin", breed: "shepard")
      Dog.create(name: "Dave", breed: "poodle")

      dog_from_db = Dog.find(2)

      expect(dog_from_db).to have_attributes(
        class: Dog,
        id: 2,
        name: "Dave",
        breed: "poodle"
      )
    end
  end

  # BONUS! uncomment the tests below for an extra challenge
  describe '.find_or_create_by' do
    it 'creates an instance of a dog if it does not already exist' do
      dog1 = Dog.create(name: 'teddy', breed: 'cockapoo')
      dog2 = Dog.find_or_create_by(name: 'teddy', breed: 'cockapoo')

      expect(dog2.id).to eq(dog1.id)
    end

    it 'when two dogs have the same name and different breed, it returns the correct dog' do
      dog1 = Dog.create(name: 'teddy', breed: 'cockapoo')
      Dog.create(name: 'teddy', breed: 'pug')

      dog_from_db = Dog.find_or_create_by(name: 'teddy', breed: 'cockapoo')

      expect(dog_from_db.id).to eq(1)
      expect(dog_from_db.id).to eq(dog1.id)
    end

    it 'when creating a new dog with the same name as persisted dogs, it returns the correct dog' do
      Dog.create(name: 'teddy', breed: 'cockapoo')
      Dog.create(name: 'teddy', breed: 'pug')

      new_dog = Dog.find_or_create_by(name: 'teddy', breed: 'irish setter')

      expect(new_dog.id).to eq(3)
    end
  end

  describe '#update' do
    it 'updates the record associated with a given instance' do
      teddy = Dog.create(name: "Teddy", breed: "cockapoo")
      teddy.name = "Teddy Jr."
      teddy.update
      also_teddy = Dog.find_by_name("Teddy Jr.")
      expect(also_teddy.id).to eq(teddy.id)
    end
  end

  context 'when called on a record with an ID' do
    describe '#save' do
      it 'updates the record associated with a given instance' do
        teddy = Dog.create(name: 'teddy', breed: 'cockapoo')
        teddy.name = "Teddy Jr."
        teddy.save
        also_teddy = Dog.find_by_name("Teddy Jr.")
        expect(also_teddy.id).to eq(teddy.id)
      end
    end
  end

end
