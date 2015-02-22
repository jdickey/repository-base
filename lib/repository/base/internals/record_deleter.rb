
require 'repository/support/store_result'
require_relative 'slug_finder'

module Repository
  # Base class for Repository in Data Mapper pattern.
  class Base
    # Internal support code exclusively used by Repository::Base
    module Internals
      # Stows away details of reporting update success/failure.
      # @since 0.0.5
      class RecordDeleter
        include Repository::Support

        # Initializes a new instance of `SlugFinder`.
        # @param identifier [String] [Slug](http://en.wikipedia.org/wiki/Semantic_URL#Slug)
        #                   for record to be deleted.
        # @param dao Data Access Object implements persistence without business
        #            logic.
        # @param factory Factory-pattern class to build an entity from an
        #                existing DAO record.
        def initialize(identifier:, dao:, factory:)
          @identifier = identifier
          @dao = dao
          @factory = factory
        end

        # Command-pattern method returning indication of success or failure of
        # attempt to delete identified record.
        # @return Repository::Support::StoreResult
        def delete
          finder = SlugFinder.new slug: identifier, dao: dao, factory: factory
          result = finder.find
          return result unless result.success
          dao.delete identifier
          result
        end

        private

        attr_reader :dao, :factory, :identifier
      end # class Repository::Base::Internals::RecordDeleter
    end
  end
end
