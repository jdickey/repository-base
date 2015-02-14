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

1. Fork it ( https://github.com/jdickey/repository-base/fork )
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Ensure that your changes are completely covered by *passing* specs, and comply with the [Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide) as enforced by [RuboCop](https://github.com/bbatsov/rubocop). To verify this, run `bundle exec rake`, noting and repairing any lapses in coverage or style violations;
1. Commit your changes (`git commit -a`). Please *do not* use a single-line commit message (`git commit -am "some message"`). A good commit message notes what was changed and why in sufficient detail that a relative newcomer to the code can understand your reasoning and your code;
1. Push to the branch (`git push origin my-new-feature`)
1. Create a new Pull Request. Describe at some length the rationale for your new feature; your implementation strategy at a higher level than each individual commit message; anything future maintainers should be aware of; and so on. *If this is a modification to existing code, reference the open issue being addressed*.
1. Don't be discouraged if the PR generates a discussion that leads to further refinement of your PR through additional commits. These should *generally* be discussed in comments on the PR itself; discussion in the Gitter room (see below) may also be useful;
1. If you've comments, questions, or just want to talk through your ideas, don't hesitate to hang out in the project's [room on Gitter](https://gitter.im/jdickey/repository-base). Ask away!
