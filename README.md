# Repository::Base

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

As mentioned at the top of this file, `Repository::Base` is intended to serve as
the base class for your app's Repositories; it has methods for several common
operations, including:

* `#add`
* `#all`
* `#delete`
* `#find_by_slug`
* `update`

### More Details

**TBD.**

## Contributing

1. Fork it ( https://github.com/[my-github-username]/repository-base/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

# Newpoc::Action::User::Index

Encapsulates the use case (domain/business logic processing) for acquiring a
list of all users in the system. If filters or dynamic ordering were to be
applied &mdash; say, to have those meeting some criteria depending on the
current user listed first &mdash; this would be the place to do that.

Presently, simply broadcasts a [Wisper](https://github.com/krisleech/wisper)
event, defaulting to `:success`, with a payload consisting of all records
retreived by calling the `#all` method of a `repository` passed in to this
class' `#initialize` method.

## Installation

This was initially developed with the expectation that it would be used as an
[unbuilt dependency](http://pivotallabs.com/unbuilt-rails-dependencies-how-to-design-for-loosely-coupled-highly-cohesive-components-within-a-rails-application/)
of a larger project. To use it in that context, add this line to your
application's Gemfile:

```ruby
gem 'newpoc-action-user-index', path: 'some/path/to/newpoc-action-user-index'
```

(where `some/path/to` will usually be `lib`). If this has been packaged into an
ordinary Gem, of course, you'd install it as any other, by adding this line to
your application's Gemfile:

```ruby
gem 'newpoc-action-user-index'
```

And then execute:

    $ bundle

You probably would never do this for *this* particular code, but you could
install a standalone Gem systemwide as:

    $ gem install newpoc-action-user-index

## Usage

In a Rails app such as [`new_poc`](https://github.com/jdickey/new_poc), you'd
have an `#index` method in your `UsersController` that looked something like:

```ruby
  def index
    action = Newpoc::Action::User::Index.new(UserRepository.new, :success)
    action.subscribe(self, prefix: :on_index).execute
  end
```

(Note the usage of the singular in `Action` and `User` namespace names.)

This would wire up the `action` to broadcast the `:success` event on successful
completion of the action, directing it to be received by the `#on_index_success`
method of this controller. (See the [`wisper`](https://github.com/krisleech/wisper)
documentation for background on events and handlers). The `:success` parameter
to `#new` is redundant as it is the default.

## Contributing

1. Fork the main app ( https://github.com/jdickey/new_poc/fork )
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Ensure that your changes are completely covered by *passing* specs, and comply with the [Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide) as enforced by [RuboCop](https://github.com/bbatsov/rubocop). To verify this, run `bundle exec rake`, noting and repairing any lapses in coverage or style violations;
1. Commit your changes (`git commit -a`). Please *do not* use a single-line commit message (`git commit -am "some message"`). A good commit message notes what was changed and why in sufficient detail that a relative newcomer to the code can understand your reasoning and your code;
1. Push to the branch (`git push origin my-new-feature`)
1. Create a new Pull Request. Describe at some length the rationale for your new feature; your implementation strategy at a higher level than each individual commit message; anything future maintainers should be aware of; and so on. *If this is a modification to existing code, reference the open issue being addressed*.
1. Don't be discouraged if the PR generates a discussion that leads to further refinement of your PR through additional commits. These should *generally* be discussed in comments on the PR itself; discussion in the Gitter room (see below) may also be useful;
1. If you've comments, questions, or just want to talk through your ideas, don't hesitate to hang out in the project's [room on Gitter](https://gitter.im/jdickey/new_poc). Ask away!
