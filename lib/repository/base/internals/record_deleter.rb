
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
        def initialize(identifier, dao)
          @identifier = identifier
          @dao = dao
        end

        # Command-pattern method returning indication of success or failure of
        # attempt to delete identified record.
        # @return Repository::Support::StoreResult
        def delete
          result = SlugFinder.new(identifier, dao).find
          return result unless result.success
          dao.delete identifier
          result
        end

        private

        attr_reader :dao, :identifier
      end # class Repository::Base::Internals::RecordDeleter
    end
  end
end
