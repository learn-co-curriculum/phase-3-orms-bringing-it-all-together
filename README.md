# Basic Student ORM

## Objectives
* Understand what an Object Relational Mapper(ORM) is
* Gain ability to implement characteristics of an ORM when using a relational database management system (RDBMS) in a ruby program

## Instructions
This lab involves building a basic ORM for a Dog object.  The `Dog` class defined in `lib/dog.rb` implements behaviors of a basic ORM.

We begin by briefly discussing what an ORM is and how the `environment.rb` file in our project's config directory establishes a connection to our application's database.

- **what is an ORM?**
  An ORM is an Object Relational Mapper. It is basically a class that acts  as an analogy for how instances of Objects in an object-oriented program  correspond to rows in a database; meaning that it wraps the functionality of the database into our class.

- **Environment**
  Our environment is going to be a single point of requires and loads.  It is also going to define a constant, `DB`, whose sole responsibility is setting up and maintaining connection to our application's database.
   - `DB = {:conn => SQLite3::Database.new("db/students.db")}`
   `DB` is set equal to a hash, which has a single key, `:conn`. The key, `:conn`,  will have a value of a connection to a sqlite3 database in the db directory.

      However, in our spec_helper, our  testing environment, we're going to redefine the value of that key (not of the constant though) to point to an in-memory database. This will allow our tests to run in isolation of our production database. Whenever we want to refer to the  applications connection to the database, we will simply rely on   `DB[:conn]`.

## Solving The Lab: The Spec Suite
-  **RSpec Test 1: `#attributes`**

  The first test is concerned solely with making sure that our students have all the required attributes and that they are readable and writeable.

-  **RSpec Test 2: `::create_table`**
  Your task  here is to define a class method on Student that will execute  the correct SQL to create a students table.

    ```ruby
    describe '::create_table' do
        it 'creates a student table' do
          DB[:conn].execute('DROP TABLE IF EXISTS students')
          Student.create_table

          table_check_sql = "SELECT tbl_name FROM sqlite_master WHERE type='table' AND tbl_name='students';"
          expect(DB[:conn].execute(table_check_sql)[0]).to eq(['students'])
        end
    end
    ```

  Our test first makes sure that we are starting with a clean database by executing the SQL command `DROP TABLE IF EXISTS students`.

  Next we call the soon to be defined `create_table` method, which is responsible for creating a table called students with the appropriate columns.

  ![sqlite_master](http://dl.dropboxusercontent.com/s/j98mxmd5d4uec9g/2014-02-18%20at%2011.21%20AM.png)

-  **RSpec Test 3: `::drop_table`**
This method will drop the students table from the database.

  ```ruby
  describe '::drop_table' do
    it "drops the student table" do
        Student.drop_table

      table_check_sql = "SELECT tbl_name FROM sqlite_master WHERE type='table' AND tbl_name='students';"
      expect(DB[:conn].execute(table_check_sql)[0]).to be_nil
    end
  end
```

  It is basically the exact opposite of the previous test. Your job is to  define a class method on `Student` that will execute the correct SQL to drop  a students table.

-  **RSpec Test 4: `#insert`**

  This method will do the heavy lifting of inserting a student instance into    the database.

  The test simply instantiates a student and then calls insert. The   expectation is that if we then run a simple SELECT looking for that student   by name (I know, not the best thing to measure, but it'll do), we should find a row with that very data.

  The second test in the insert describe block is a bit more abstract. The  basic premise is that after we insert a student into the database, the  database has assigned it an auto-incrementing primary key. We have to update  the current instance with this ID value otherwise this instance does not  fully mirror the current state in the DB. To implement this behavior, you   will need to know how to ask SQLite3 for the last inserted ID in a table,   which would be: `SELECT last_insert_rowid() FROM students` [law insert rowid()](http://www.sqlite.org/lang_corefunc.html#last_insert_rowid)

- **RSpec Test 5: `::new_from_db`**

  This is an interesting method. Ultimately, the database is going to return an array representing a student's data. We need a way to cast that data into the appropriate attributes of a student. This method  encapsulates that functionality. You can even think of it as  new_from_array. Methods like this, that return instances of the class,  are known as constructors, just like `::new`, except that they extend the   functionality of `::new` without overwriting `initialize`

- **RSpec Test 5: `::find_by_name`**

  This spec will first insert a student into the database and then attempt to   find it by calling the find_by_name method. The expectations are that an  instance of the student class that has all the properties of a student is   returned, not primitive data.

  Internally, what will the find_by_name method do to find a student, which   SQL statement must it run? Additionally, what method might find_by_name use internally to quickly take a row and create an instance to represent that data?

- **RSpec Test 5: `#update`**

  This spec will create and insert a student and after will change the name of  the student instance and call update. The expectations are that after this  operation there is no student left over in the database with the old name.  If we query the database for a student with the new name, we should find  that student and the ID of that student should be the same as the original,   signifying this is the same student, they just changed their name.

- **RSpec Test 5: `#save`**

  This spec ensures that given an instance of a student, simply calling save  will trigger the correct operation. To implement this, you will have to   figure out a way for an instance to determine whether it has been persisted   into the DB.

  In the first test we create an instance, specify, since it has never been   saved before, that the instance will receive a method call to `insert`.

  In the next test, we create an instane, save it, change it's name, and then   specify that a call to the save method should trigger an `update`.

  ## BONUSES

  * **Attributes**
    How can this be refactored, both in the test and within the Student     class? There is a powerful pattern here, see if you can see it.

  * **`.create_table` and `.drop_table`**
    1. Think about removing the duplication from these tests.
    2. Is there a useful method missing from the `Student` class that would       further simplify this test?
    3. How does the order the tests run in impact the results? In fact, this      is a big problem that has actually be solved in this code base - find       the solution.

  * **`#insert`**

    - How many times do you think we'll repeat and collect the various      attributes of a student? How many places does that information live       right now (so if we wanted to add an attribute, how many changes to       our code would we need)? Can you think of a better way?

  * **`::new_from_db`**
    - Why do we build `::new_from_db` and not just use initialize?

  * **`::all`**
    - Implement and test a `Student.all` method that returns all instance.

  *  **`#delete`**
    - Implement and test deleting a student.

  * **`#==`**
    - Teach and test that students coming out of the database are equal to each other even though the objects are different.
