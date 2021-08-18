# ORMs: Bringing it all Together

## Learning Goals

- Understand what an Object Relational Mapper(ORM) is
- Gain ability to implement characteristics of an ORM when using a relational database management system (RDBMS) in a ruby program

## Instructions

This lab involves building a basic ORM for a Dog object. The `Dog` class
defined in `lib/dog.rb` implements behaviors of a basic ORM.

### **Environment**

Our environment is going to be a single point of requires and loads. It is also
going to define a constant, `DB`, whose sole responsibility is setting up and
maintaining connection to our application's database.

- `DB = {:conn => SQLite3::Database.new("db/dogs.db")}` `DB` is set equal to a
  hash, which has a single key, `:conn`. The key, `:conn`, will have a value of
  a connection to a sqlite3 database in the db directory.

However, in our `spec_helper`, which is our testing environment, we're going to
redefine the value of that key (not of the constant) to point to an in-memory
database. This will allow our tests to run in isolation of our production
database. Whenever we want to refer to the application's connection to the
database, we will simply rely on `DB[:conn]`.

## Solving The Lab: The Spec Suite

### Attributes

The first test is concerned solely with making sure that our dogs have all the
required attributes and that they are readable and writable.

The `#initialize` method accepts a hash or keyword argument value with key-value
pairs as an argument. key-value pairs need to contain id, name, and breed.

### `.create_table`

Your task here is to define a class method on Dog that will execute the correct
SQL to create a dogs table.

```ruby
describe ".create_table" do
  it 'creates the dogs table in the database' do
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    Dog.create_table
    table_check_sql = "SELECT tbl_name FROM sqlite_master WHERE type='table' AND tbl_name='dogs';"
    expect(DB[:conn].execute(table_check_sql)[0]).to eq(['dogs'])
  end
end
```

Our test first makes sure that we are starting with a clean database by
executing the SQL command `DROP TABLE IF EXISTS dogs`.

Next we call the soon-to-be defined `.create_table` method, which is responsible
for creating a table called dogs with the appropriate columns.

### `.drop_table`

This method will drop the dogs table from the database.

```ruby
describe ".drop_table" do
  it 'drops the dogs table from the database' do
    Dog.drop_table
    table_check_sql = "SELECT tbl_name FROM sqlite_master WHERE type='table' AND tbl_name='dogs';"
    expect(DB[:conn].execute(table_check_sql)[0]).to eq(nil)
  end
end
```

It is basically the exact opposite of the previous test. Your job is to define a
class method on `Dog` that will execute the correct SQL to drop a dogs table.

### `#save`

This spec ensures that given an instance of a dog, simply calling `save` will
insert a new record into the database and return the instance.

### `.create`

This is a class method that should:

- Create a new row in the database
- Return a new instance of the `Dog` class

Think about how you can re-use the `#save` method to help with this one.

### `.new_from_db`

This is an interesting method. Ultimately, the database is going to return an
array representing a dog's data. We need a way to cast that data into the
appropriate attributes of a dog. This method encapsulates that functionality.
You can even think of it as `new_from_array`. Methods like this, that return
instances of the class, are known as constructors, just like `.new`, except that
they extend the functionality of `.new` without overwriting `initialize`.

### `.all`

This class method should return an array of `Dog` instances for every record in
the `dogs` table.

### `.find_by_name(name)`

The spec for this method will first insert a dog into the database and then
attempt to find it by calling the find_by_name method. The expectations are that
an instance of the dog class that has all the properties of a dog is returned,
not primitive data.

Internally, what will the `.find_by_name` method do to find a dog; which SQL
statement must it run? Additionally, what method might `.find_by_name` use
internally to quickly take a row and create an instance to represent that data?

**Note**: You may be tempted to use the `Dog.all` method to help solve this one.
While we applaud your intuition to try and keep your code DRY, in this case,
reusing that code is actually not the best approach. Why? Remember, with
`Dog.all`, we're loading all the records from the `dogs` table and converting
them to an array of Ruby objects, which are stored in our program's memory. What
if our `dogs` table had 10,000 rows? That's a lot of extra Ruby objects! In
cases like these, it's better to use SQL to only return the dogs we're looking
for, since SQL is extremely well-equipped to work with large sets of data.

### `.find(id)`

This class method takes in an ID, and should return a single `Dog` instance for
the corresponding record in the `dogs` table with that same ID. It behaves
similarly to the `.find_by_name` method above.

## Bonus Methods

In addition to the methods described above, there are a few bonus methods if
you'd like to build out more features. The tests for these methods are commented
out in the spec file. Comment them back in to run the tests for these methods.

### `.find_or_create_by`

This method takes a name and a breed as keyword arguments. If there is already a
dog in the database with the name and breed provided, it returns that dog.
Otherwise, it inserts a new dog into the database, and returns the newly created
dog.

### `#update`

The spec for this method will create and insert a dog, and afterwards, it will
change the name of the dog instance and call update. The expectations are that
after this operation, there is no dog left in the database with the old name. If
we query the database for a dog with the new name, we should find that dog and
the ID of that dog should be the same as the original, signifying this is the
same dog, they just changed their name.

The SQL you'll need to write for this method will involve using the `UPDATE`
keyword.

### `#save` (again)

Wait, didn't we already make a `#save` method? Well, yes, but we're going to expand
its functionality! You should change it so that it handles these two cases:

- If called on a `Dog` instance that doesn't have an ID assigned, insert a new
  row into the database, and return the saved `Dog` instance.
- If called on a `Dog` instance that _does_ have an ID assigned, use the
  `#update` method to update the existing dog in the database, and return the
  updated `Dog` instance.
