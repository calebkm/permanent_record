require 'minitest/autorun'
require 'permanent_record'

# Our test data ... filled to the brim with books to amaze the senses! 
TEST_BOOKS = [
  {title: "Surely You're Joking, Mr. Feynman!", author: 'Richard P. Feynman'},
  {title: "A Brief History of Time", author: "Stephen Hawking"},
  {title: "The Universe in a Nutshell", author: "Stephen Hawking"},
  {title: "The Fabric of the Cosmos", author: "Brian Greene"}
]

# Some more test data, this time with IDs specified.
MORE_BOOKS = [
  {id: '978-0345539434', title: 'Cosmos', author: 'Carl Sagan'},
  {id: '978-0452288522', title: 'This Is Your Brain on Music', author: 'Daniel J. Levitin'}
]

# Our default test class, without a source defined.
class TestBook < PermanentRecord; end

# Our second test class, with the source data explicitly set.
class TestBookWithSource < PermanentRecord; source MORE_BOOKS; end

# And now let's test!
class PermanentRecordTest < Minitest::Test
  def setup
    @books      = TestBook.all
    @book       = @books.last
    @more_books = TestBookWithSource.all
    @more_book  = @more_books.first
  end

  # First let's test our  - - - - - - - - - - - - - - -
  # Class Methods - - - - - - - - - - - - - - - - - - -
  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  def test_all
    assert_equal TestBook.all.size, TEST_BOOKS.size
  end

  def test_find
    assert_equal TestBook.find(2).class, TestBook
    assert_equal TestBook.find(2).id, 2
    assert_nil TestBook.find(42)
  end

  def test_find_by_attribute
    assert_equal TestBook.find_by_attribute(:author, 'Stephen Hawking'), TestBook.find(2)
    assert_equal TestBook.find_by_attribute('author', 'Brian Greene'), @books.last
    assert_nil TestBook.find_by_attribute(:author, 'Greg Graffin')
  end

  def test_where
    assert_equal TestBook.where(author: 'Stephen Hawking').size, 2
    assert_equal TestBook.where(author: 'Stephen Hawking', title: 'A Brief History of Time').size, 1
    assert_empty TestBook.where(author: 'Weird Al Yankovic')
  end

  def test_find_by_method_missing
    assert_equal TestBook.find_by_author('Richard P. Feynman'), @books.first
    assert_nil TestBook.find_by_author('Michael John Burkett')
    assert_raises(NoMethodError) { TestBook.find_by_coauthor('Werner Heisenberg') }
  end

  def test_source_and_data
    assert_equal TestBook.data, TEST_BOOKS.each_with_index.map{|d, i| d.merge(id: i+1)} # Need to add our indexes!
    assert_equal TestBookWithSource.data, MORE_BOOKS
  end

  def test_attributes
    assert_equal @books.last.instance_variables.map{|v| v.to_s.delete('@').to_sym}, TestBook.attributes
  end

  def test_valid_attribute?
    assert TestBook.valid_attribute?(:title)
    assert !TestBook.valid_attribute?(:void)
  end

  # Now we can test our - - - - - - - - - - - - - -
  # Instance Methods  - - - - - - - - - - - - - - - - -
  # - - - - - - - - - - - - - - - - - - - - - - - - - -
  def test_attributes_are_readable
    assert_equal @book.send(:id), @books.last.id
    assert_equal @more_book.send(:id), @more_books.first.id
    assert_equal @book.send(:title), 'The Fabric of the Cosmos'
    assert_equal @more_book.send(:title), 'Cosmos'
    assert_equal @book.send(:author), 'Brian Greene'
    assert_equal @more_book.send(:author), 'Carl Sagan'
    assert_raises(NoMethodError) { @book.send(:avoid)}
    assert_raises(NoMethodError) { @more_book.send(:noid)}
  end

  def test_to_param
    assert_equal @book.to_param, @book.id
  end

  def test_equals
    assert @book == TestBook.all.last
  end

  # A few other tests - - - - - - - - - - - - - - - - - - -
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  def test_that_ids_are_auto_generated_when_none_are_specified_in_the_source_data
    assert !TEST_BOOKS.first.keys.include?(:id)
    assert TestBook.data.first.include?(:id)
    assert_equal @books.first.id, 1
    assert_equal @books.last.id, TEST_BOOKS.size
  end

  def test_that_ids_are_not_generated_if_specified_explicitly_in_the_source_data
    assert MORE_BOOKS.first.keys.include?(:id)
    assert TestBookWithSource.data.first.include?(:id)
    assert_equal @more_books.first.id, MORE_BOOKS.first[:id]
  end
end