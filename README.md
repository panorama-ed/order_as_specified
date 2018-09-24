[![Code Climate](https://codeclimate.com/github/panorama-ed/order_as_specified/badges/gpa.svg)](https://codeclimate.com/github/panorama-ed/order_as_specified) [![Test Coverage](https://codeclimate.com/github/panorama-ed/order_as_specified/badges/coverage.svg)](https://codeclimate.com/github/panorama-ed/order_as_specified) [![Build Status](https://travis-ci.org/panorama-ed/order_as_specified.svg)](https://travis-ci.org/panorama-ed/order_as_specified) [![Inline docs](http://inch-ci.org/github/panorama-ed/order_as_specified.png)](http://inch-ci.org/github/panorama-ed/order_as_specified) [![Gem Version](https://badge.fury.io/rb/order_as_specified.svg)](http://badge.fury.io/rb/order_as_specified)

# OrderAsSpecified

`OrderAsSpecified` adds the ability to query an `ActiveRecord` class for results
from the database in an arbitrary order, without having to store anything extra
in the database.

It's as easy as:

```ruby
class TestObject
  extend OrderAsSpecified
end

TestObject.order_as_specified(language: ["es", "en", "fr"])
=> #<ActiveRecord::Relation [
     #<TestObject id: 3, language: "es">,
     #<TestObject id: 1, language: "en">,
     #<TestObject id: 4, language: "en">,
     #<TestObject id: 2, language: "fr">
   ]>
```

### Is this like ranked-model?

Other gems like `ranked-model`, `acts_as_sortable`, etc. assume you want the
same ordering each time, and store data to keep track of this in the database.
They're great at what they do, but if you desired ordering changes, or if you
don't always want an ordering, this gem is your friend.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'order_as_specified'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install order_as_specified

## Usage

Basic usage is simple:

```ruby
class TestObject
  extend OrderAsSpecified
end

TestObject.order_as_specified(language: ["es", "en", "fr"])
=> #<ActiveRecord::Relation [
     #<TestObject id: 3, language: "es">,
     #<TestObject id: 1, language: "en">,
     #<TestObject id: 4, language: "en">,
     #<TestObject id: 2, language: "fr">
   ]>
```

This returns all `TestObject`s in the given language order. Note that this
ordering is not possible with a simple `ORDER BY`. Magic!

Like any other `ActiveRecord` relation, it can be chained:

```ruby
TestObject.
  where(language: ["es", "en", "fr"]).
  order_as_specified(language: ["es", "en", "fr"]).
  limit(3)
=> #<ActiveRecord::Relation [
     #<TestObject id: 3, language: "es">,
     #<TestObject id: 1, language: "en">,
     #<TestObject id: 4, language: "en">
   ]>
```

We can use chaining in this way to order by multiple attributes as well:

```ruby
TestObject.
  order_as_specified(language: ["es", "en"]).
  order_as_specified(id: [4, 3, 5]).
  order(:updated_at)
=> #<ActiveRecord::Relation [

  # First is language "es"...
     #<TestObject id: 1, language: "es", updated_at: "2016-08-01 02:22:00">,

    # Within the language, we order by :updated_at...
     #<TestObject id: 2, language: "es", updated_at: "2016-08-01 07:29:07">,

  # Then language "en"...
     #<TestObject id: 9, language: "en", updated_at: "2016-08-03 04:11:26">,

    # Within the language, we order by :updated_at...
     #<TestObject id: 8, language: "en", updated_at: "2016-08-04 18:52:14">,

  # Then id 4...
     #<TestObject id: 4, language: "fr", updated_at: "2016-08-01 12:59:33">,

  # Then id 3...
     #<TestObject id: 3, language: "ar", updated_at: "2016-08-02 19:41:44">,

  # Then id 5...
     #<TestObject id: 5, language: "ar", updated_at: "2016-08-02 22:12:52">,

  # Then we order by :updated_at...
     #<TestObject id: 7, language: "fr", updated_at: "2016-08-02 14:27:16">,
     #<TestObject id: 6, language: "ar", updated_at: "2016-08-03 14:26:06">,
   ]>
```

We can also use this when we want to sort by an attribute in another model:

```ruby
TestObject.
  joins(:other_object).
  order_as_specified(other_objects: { id: [other1.id, other3.id, other2.id] })
```

Neat, huh?

In all cases, results with attribute values not in the given list will be
sorted as though the attribute is `NULL` in a typical `ORDER BY`:

```ruby
TestObject.order_as_specified(language: ["fr", "es"])
=> #<ActiveRecord::Relation [
     #<TestObject id: 2, language: "fr">,
     #<TestObject id: 3, language: "es">,
     #<TestObject id: 1, language: "en">,
     #<TestObject id: 4, language: "en">
   ]>
```

In databases that support it (such as PostgreSQL), you can also use an option to
add a `DISTINCT ON` to your query when you would otherwise have duplicates:

```ruby
TestObject.order_as_specified(distinct_on: true, language: ["fr", "en"])
=> #<ActiveRecord::Relation [
     #<TestObject id: 2, language: "fr">,
     #<TestObject id: 3, language: "en">,
     #<TestObject id: 4, language: "es">
   ]>
```

Note that if a `nil` value is passed in the ordering an error is raised, because
databases do not have good or consistent support for ordering with `NULL` values
in an arbitrary order, so we don't permit this behavior instead of allowing an
unexpected result.

## Limitations

Databases may have limitations on the underlying number of fields you can have
in an `ORDER BY` clause. For example, in PostgreSQL if you pass in more than
1664 list elements you'll [receive this error](https://github.com/panorama-ed/order_as_specified/issues/34):

```ruby
PG::ProgramLimitExceeded: ERROR: target lists can have at most 1664 entries
```

That's a database limitation that this gem cannot avoid, unfortunately.

## Documentation

We have documentation on [RubyDoc](http://www.rubydoc.info/github/panorama-ed/order_as_specified/master).

## Contributing

1. Fork it (https://github.com/panorama-ed/order_as_specified/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

**Make sure your changes have appropriate tests (`bundle exec rspec`)
and conform to the Rubocop style specified.**

## License

`OrderAsSpecified` is released under the
[MIT License](https://github.com/panorama-ed/order_as_specified/blob/master/LICENSE.txt).
