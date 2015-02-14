# Repository::Base

[![Join the chat at https://gitter.im/jdickey/repository-base](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/jdickey/repository-base?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

This Gem supplies a class, `Repository::Base`, which can be used as a base class
for Repositories in an application that uses the
[Data Mapper pattern](http://martinfowler.com/eaaCatalog/dataMapper.html).
As described by Fowler, Data Mapper "moves data between objects and a database
while keeping them independent of each other and the mapper itself".

This was originally developed within the structure of an R&D test-bed application,
[`new_poc`](https://github.com/jdickey/new_poc). That app has a fairly wide-ranging
history; after browsing its README and
[commit history](https://github.com/jdickey/new_poc/commits), you may find Pull
Requests [#153](https://github.com/jdickey/new_poc/pull/153) and
[#200](https://github.com/jdickey/new_poc/pull/153) informative as to the
historical basis of this code.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'repository-base'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install repository-base

## Usage

### Concepts

As mentioned at the top of this file, `Repository::Base` is intended to serve as
the base class for your app's Repositories. As with most Data Mapper
implementations, it makes use of a database access object, or DAO, which you
specify as one of the two parameters to `#initialize`. The other parameter is an
"entity factory", whose `.create` class method hands back an "entity" reflecting
the content of an individual record in the underlying DAO.

#### Entities

What is an "entity"? It's a domain object in your application, with methods
expressing the business logic applicable to the object represented by the underlying
database record. This is distinct from an ActiveRecord-style *model*, in that
more than one variation of entity may exist in your application for a given DAO.
Most applications have Users, for example; some applications may have distinct
variation of User *entities* (ordinary punters, admins, a "guest user" entity
representing a user who has not authenticated as a more-privileged user, etc),
that all share a common persistence layer (the underlying DAO) and an entity
factory that *knows* how to create the correct type of entity for a given DAO
record.

An entity is uniquely identified by a *slug* rather than a numeric ID. Generally,
a slug encodes textual, relatively SEO-friendly information corresponding to an
individual record (the title of an article, the name of a user, etc) such that
the corresponding record may be uniquely identified by the DAO. This is in
preference to a "traditional" numeric record ID number; `Repository::Base` has
no knowledge of nor direct support for numeric record IDs.

#### Entity Factories

Again, the entity factory, one of the parameters to this class' `#initialize`
method, is responsible for creating an entity from a DAO instance (record). The
`Repository::Base` class knows nothing of the details of how that is done; it
simply calls methods on the DAO and/or entity factory to accomplish the tasks
encapsulated by its own individual methods. 

#### StoreResult

What is a `StoreResult`? It is a simple value object which communicates the
result of a call to a method on the underlying DAO *as reported by the DAO*,
with the following properties:

* `success?` (accessible as `result.success?` or as `result[:success?]`), has the value `true` after a successful operation or `false` after an unsuccessful one;
* `entity` (`result.entity` or `result[:entity]`) is the instance or enumeration of instances of your domain entity resulting from a successful operation. After an unsuccessful operation, this property will be `nil`;
* `errors` (`result.errors` or `result[:errors]`) is an Array-like object which is empty after a successful operation. After an unsuccessful operation, it will contain an Array of Hash instances, with each Hash having a key identifying the field or similar concept for which an individual error is being reported, and a value of the specific error message. For example, to report that a `:name` field was empty or blank, you might have a Hash of `{ name: 'is empty or blank' }. Your application domain logic should then understand how to deal with that convention.

#### `Repository::Base` Instance Methods

* `#add` adds a new record to the underlying *DAO* (data-access object; see above) using the field values specified by the *entity* passed as the only parameter. Returns a `StoreResult` (see above) which indicates the success or failure of the operation. On success, the `StoreResult` contains a *new* entity that represents the state of the record added to the underlying DAO;
* `#all` returns a collection of entities matching all records as reported by the underlying DAO, with entities created by the appropriate entity factory;
* `#delete` instructs the DAO to delete the record corresponding to the specified `slug`. Returns a `StoreResult` with an entity corresponding to the deleted record on success, or with appropriate error message(s) on failure;
* `#find_by_slug` instructs the DAO to retrieve the record whose unique slug value matches the supplied parameter. On success, returns a `StoreResult` with an entity corresponding to the selected record; on failure, the `StoreResult` has an `entity` value of `nil` and appropriate error messages in `errors`;
* `update` causes the DAO to attempt to update the record identified by the passed-in slug using the passed-in field values. On success, returns a `StoreResult` whose `entity` value mirrors the updated DAO record; on failure, has appropriate error indications in the `StoreResult`'s `errors` property.

### More Details

Note that this Gem **requires Ruby 2.0**, with Ruby 2.1 or later recommended. As it makes use of [keyword arguments](http://ruby-doc.org//core-2.1.0/doc/syntax/methods_rdoc.html#label-Keyword+Arguments) for various methods, it is *incompatible* with Ruby 1.9 or earlier.

## Contributing

1. Fork it ( https://github.com/jdickey/repository-base/fork )
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Ensure that your changes are completely covered by *passing* specs, and comply with the [Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide) as enforced by [RuboCop](https://github.com/bbatsov/rubocop). To verify this, run `bundle exec rake`, noting and repairing any lapses in coverage or style violations;
1. Commit your changes (`git commit -a`). Please *do not* use a single-line commit message (`git commit -am "some message"`). A good commit message notes what was changed and why in sufficient detail that a relative newcomer to the code can understand your reasoning and your code;
1. Push to the branch (`git push origin my-new-feature`)
1. Create a new Pull Request. Describe at some length the rationale for your new feature; your implementation strategy at a higher level than each individual commit message; anything future maintainers should be aware of; and so on. *If this is a modification to existing code, reference the open issue being addressed*.
1. Don't be discouraged if the PR generates a discussion that leads to further refinement of your PR through additional commits. These should *generally* be discussed in comments on the PR itself; discussion in the Gitter room (see below) may also be useful;
1. If you've comments, questions, or just want to talk through your ideas, don't hesitate to hang out in the project's [room on Gitter](https://gitter.im/jdickey/repository-base). Ask away!
