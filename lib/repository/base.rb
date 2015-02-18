
require 'repository/base/version'

require 'repository/base/internals/internals'

# The `Repository` module functions as a namespace for implementing the
# repository logic in a [Data Mapper pattern](http://martinfowler.com/eaaCatalog/dataMapper.html)
# implementation.
# The Repository module initially included two names:
#
#  1. `Base`; and
#  1. `Support` (a namespace containing several related classes).
#
module Repository
  # Base class for Repository in Data Mapper pattern.
  class Base
    # Internal support code exclusively used by Repository::Base
    # @since 0.0.1
    module Internals
    end
    private_constant :Internals

    include Internals
    attr_reader :dao, :factory

    # Initialise a new `Repository::Base` instance.
    # @param factory Has a .create method to create entities from DAO records.
    # @param dao Data Access Object implements persistence without business
    #            logic.
    def initialize(factory:, dao:)
      validate_initializer_argument(:dao, dao)
      validate_initializer_argument(:factory, factory)
      @factory, @dao = factory, dao
    end

    # Add a new record with attributes matching the specified entity to the
    # associated DAO.
    # @param entity Entity specifying record to be persisted to new DAO record.
    # @return [Repository::Support::StoreResult] An object containing
    #     information about the success or failure of an action.
    def add(entity)
      record = dao.new filtered_attributes_for(entity)
      RecordSaver.new(record).result
    end

    # Return an array of entities matching all records currently in the
    # associated DAO.
    # @return [Array] Array of entities as supplied by the `factory`.
    # @since 0.0.2
    def all
      dao.all.map { |record| factory.create record }
    end

    # Remove a record from the underlying DAO whose slug matches the passed-in
    # identifier.
    # @param identifier [String] [Slug](http://en.wikipedia.org/wiki/Semantic_URL#Slug)
    #                   for record to be deleted.
    # @return [Repository::Support::StoreResult] An object containing
    #     information about the success or failure of an action.
    # @since 0.0.5
    def delete(identifier)
      RecordDeleter.new(identifier, dao).delete
    end

    # Find a record in the DAO and, on success, return a corresponding entity
    # using the specified [slug](http://en.wikipedia.org/wiki/Semantic_URL#Slug),
    # *not* a numeric record ID, as a search identifier.
    # @param slug [String] [Slug](http://en.wikipedia.org/wiki/Semantic_URL#Slug)
    #                      for record to be deleted.
    # @return [Repository::Support::StoreResult] An object containing
    #     information about the success or failure of an action.
    # @since 0.0.3
    def find_by_slug(slug)
      SlugFinder.new(slug, dao).find
    end

    # Update a record in the DAO corresponding to the specified identifier,
    # using the specified attribute-name/value pairs.
    # @param identifier [String] [Slug](http://en.wikipedia.org/wiki/Semantic_URL#Slug)
    #                      for record to be deleted.
    # @param updated_attrs [Hash] Attributes to be updated.
    # @since 0.0.4
    # @example
    #   result = user_repo.update @user.slug, params[:user_params]
    #   @user = result.entity if result.success?
    def update(identifier, updated_attrs)
      RecordUpdater.new(identifier, updated_attrs, dao).update
    end

    private

    # supporting #initialize

    # Verifies that parameter passed to #initialize is a Class.
    # @param arg_sym [Symbol] Which parameter is being validated, either `:dao`
    #                         or `:factory`.
    # @param value Parameter value being validated. Must be a Class.
    # @return [boolean]
    def validate_initializer_argument(arg_sym, value)
      message = "the :#{arg_sym} argument must be a Class"
      fail ArgumentError, message unless value.respond_to? :new
    end

    # supporting #add

    def filtered_attributes_for(entity) # :nodoc:
      entity.attributes.reject { |k, _v| k == :errors }
    end
  end # class Repository::Base
end
