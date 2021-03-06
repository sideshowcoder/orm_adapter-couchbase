# OrmAdapterCouchbase

WARNING: This is not finished, and very early stage to see if this can work

## Installation

Add this line to your application's Gemfile:

    gem 'orm_adapter-couchbase'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install orm_adapter-couchbase

## Usage

See the [specs for
details](https://github.com/sideshowcoder/orm_adapter-couchbase/blob/master/spec/couchbase_spec.rb).
The Couchbase ORM adapter relies on at least the `all` view to be present which
should simple return all the object for a given type. This doesn't have great
performance of course, like any full scan, so it's recommended to create
additional views to query by other attributes. If you want to for example query
a user by name, create a view for it.

```ruby
class User < Couchbase::Model
  attribute :name
  view :by_name
end
```

Currently only single attributes are supported, but the idea is to support
others via `by_name_and_rating` in the future.

## Added functionality

This is build ontop of `Couchbase::Model`, but to be compatible with ORM Adapter
it adds some additional features:

### \#has\_many

```ruby
class Note < Couchbase::Model; end

class User < Couchbase::Model
  has_many :notes
end
```

allows you to define a `has_many` relationship, under the hood this is
represented as an array of ids that reference back, and the appropriate setters
and getters to assign to it. The documents are lazily loaded via a multiget for
the ids on access.

### \#==

Equality is defined in terms of `id` since the `id` is the primary key in
Couchbase. Overwrite if needed!

### \#belongs_to

Added a setter method when creating a `belongs_to` relationship.

```ruby
class User < Couchbase::Model; end

class Note < Couchbase::Model
  belongs_to :user
end

note.create!
note.user = User.create!
```

### \#attribute

assigning to undefined attributes fails, while in `Couchbase::Model` it's
ignored. Both approaches are valid, but ORM Adapter defines the behaviour as
`raise` so here we go.

## ORM Adapter

> "Provides a single point of entry for popular ruby ORMs. Its target audience
> is gem authors who want to support more than one ORM."

For more information see the [orm_adapter
project](http://github.com/ianwhite/orm_adapter).

## Development / Testing

This project is tested against `orm_adapter` to make sure it works as
advertised.

To run the tests:

```
$ rake spec
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
