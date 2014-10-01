# PermanentRecord #

An `ActiveRecord` substitute for small amounts of persistent data.

## About ##

Have you ever had a small amount of data that changed infrequently and didn't seem worth the hassle of persisting in a database? Maybe you're thinking "no, I have not" and that would be a reasonable answer. More than likely, most of the time a database will be the right choice. In the off chance you though "yes!", you can use `PermanentRecord` as a simple way to turn Plain Old Ruby Objects into Rails friendly, READ ONLY `ActiveRecord` like objects.

## When might this be useful? ##

An example: Let's pretend you're writing a book. Let's pretend it happens to be a book about Rails so you're setting it up as a Rails web application. The only persisted data you'll need to save are the chapter titles and the actual text content for the book. Obviously saving the text content of each chapter in a database would be silly - we can just write that directly into a view (ERB/HAML) file. That leaves only the names of our chapters... where should we put those? You could set up a database to store this small amount of unchanging data, or you could save the data in a CHAPTERS constant like:

```ruby
# chapters.rb
CHAPTERS = [
  {title: 'Introduction', subtitle: nil},
  {title: 'Chapter 1', subtitle: 'What is Ruby?'},
  {title: 'Chapter 2', subtitle: 'What is Ruby on Rails?'},
  {title: 'Chapter 3', subtitle: 'System Setup'},
  ...
  {title: 'Apendix Z', subtitle: 'Expert Rails Stuff'}
]
```

But since we're using a Rails backend, it would nice if we could pretend the Chapter information stored in this constant was actually stored in a database. That way we could use all the goodies that Rails provides - like finders and path helpers. Here is where PermanentRecord comes in. Continue our story below in the Usage section. 


## Install ##

Add the gem the standard Gemfile way:

```ruby
# Gemfile
gem 'permanent_record'
```

## Usage ##

### Storing the Data ###

Our story ended off with you deciding to store a small amount of data in a constant in `chapters.rb`. That data was an array of hashes that represented the titles and subtitles of your new book:

```ruby
# chapters.rb
CHAPTERS = [
  {title: 'Introduction', subtitle: nil},
  {title: 'Chapter 1', subtitle: 'What is Ruby?'},
  {title: 'Chapter 2', subtitle: 'What is Ruby on Rails?'},
  {title: 'Chapter 3', subtitle: 'System Setup'},
  ...
  {title: 'Apendix Z', subtitle: nil}
]
```

### Setting up a Model ###

Now let's set up your Chapter model that'll use this data:

```ruby
# chapter.rb
class Chapter < PermanentRecord
end
```

That's it. `PermanentRecord` will automatically look for your previously defined `CHAPTERS` constant and use the data stored there to create each Chapter object. Since we're using Rails, we can now set up our routes just like any old `ActiveRecord` resource and access our Chapters like we expect. Even if we *weren't* using Rails, PermanentRecord still provides some benefits that might be handy for your project: continue to the Retrieving Data section.

### Retrieving Data ###

There are a few options for retrieving data which should all look pretty familiar if you're used to working with `ActiveRecord`:

Find everything in one fell swoop:
```ruby
Chapter.all
# => [#<Chapter id: 1, title: 'Introduction', ...>, #<Chapter id: 2, title: 'Chapter 1', ...>, ...]
```

Find a single record by id:
```ruby
Chapter.find(2)
# => #<Chapter id: 2, title: 'Chapter 1', ...>
```

Find many records by a specific attribute or attributes:
```ruby
Chapter.where(title: 'Chapter 1', subtitle: 'What is Ruby?')
# => [#<Chapter id: 2, title: 'Chapter 1', ...>]
```

Or use the `find_by_<attribute>` syntax to find a single record by a single attribute:
```ruby
Chapter.find_by_subtitle('What is Ruby?')
# => #<Chapter id: 2, title: 'Chapter 1', ...>
```

## CRUD-ing ##

Note that PermanentRecord is a READ ONLY system - meaning you're only getting the R part of CRUD. If you need to create/update/delete your data, you'll need to do it the old fashioned way by manually changing the chapters.rb file, saving and re-deploying your application. `PermanentRecord` is for *permanent* data. It shouldn't be changing very often, and there shouldn't be very much of it. If you find yourself wanting to CRUD often, you should probably just set up a database. 

## Data options ##

### Explicitly Declaring a Data Source ###

If you have a specific constant you'd like to use other than `CHAPTERS`, you can declare it in your model explicitly: 

```ruby
class Chapter < PermanentRecord
  source MY_CHAPTERS
end
```

You could even do something as daft as supplying the data directly: 

```ruby
class Chapter < PermanentRecord
  # NOTE: You probably shouldn't actually do this.
  source [{title: 'Intro'}, {title: 'Chapter 1'}, ...]
end
```

Or maybe you'd prefer to save your data in a YAML file instead of a constant:

```yaml
# config/data/chapters.yml
- title: 'Introduction'
  subtitle: ''
- title: 'Chapter 1'
  subtitle: 'What is Ruby?'
- title: 'Chapter 2'
  subtitle: 'What is Ruby on Rails?'
  ...
```

Now just load the data that standard YAML way and let your `PermanentRecord` class know about it:

```ruby
  class Chapter < PermanentRecord
    source YAML.load(File.read('config/data/chapters.yml'))
  end
```

Personally I like using Ruby where possible, which is why I prefer saving data in constants. But not everyone feels the same way as me, which is why you're free to store your data wherever you want ... just make sure the data is a well formed array of hashes and `PermanentRecord` will be happy.

## Compatibility ##

This gem was created for Rails 4 && Ruby 2. It's very possible it could work with older releases. You'll have to test to determine compatibility!

## Other Projects ##

If you'd like to store data in a YAML file and you also want to CRUD it, you should check out [YAML Record](https://github.com/nicotaing/yaml_record) by Nico Taing. I took a few ideas from there when creating `PermanentRecord`, thanks guys! Some other folks have also created gems that attempt to solve the same problem as `PermanentRecord`. For example, [ConstantRecord](https://github.com/cpetschnig/constantrecord) by Christoph Petschnig (maybe out of date) and [Constant Record](https://github.com/nateware/constant_record) by Nate Wiger. Their gems might even be better than mine, have a look!

## License, etc ##

`PermanentRecord` is open and free for all. Please use, fork, update, critique, send pull requests, etc. This gem was created because it was useful for my project, so maybe you'll find it useful too. If not, no worries! I can't believe you read this far though.