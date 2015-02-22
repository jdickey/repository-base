
require 'repository/support/store_result'

module Repository
  # Base class for Repository in Data Mapper pattern.
  class Base
    # Internal support code exclusively used by Repository::Base
    module Internals
      # Stows away details of reporting update success/failure.
      # @since 0.0.4
      class RecordUpdater
        include Repository::Support

        # Initializes a new instance of `RecordUpdater`.
        # @param identifier [String] Slug uniquely identifying the record in the
        #                   DAO to update
        # @param updated_attrs [Hash] Attributes to be updated.
        # @param dao Data Access Object implements persistence without business
        #            logic.
        # @param factory Class whose `#create` method converts a DAO record to
        #                an entity.
        def initialize(identifier:, updated_attrs:, dao:, factory:)
          @identifier = identifier
          @updated_attrs = updated_attrs
          @dao = dao
          @factory = factory
        end

        # Command-pattern method to update a record in the persistence layer,
        # based on the parameters sent to `#initialize`.
        # @return [Repository::Support::StoreResult]
        def update
          @record = dao.where(slug: identifier).first
          return failed_result unless @record.update(updated_attrs.to_h)
          successful_result
        end

        private

        attr_reader :dao, :factory, :identifier, :record, :updated_attrs

        def failed_result # :nodoc:
          StoreResult::Failure.new record.errors
        end

        def successful_result # :nodoc:
          entity = factory.create record
          StoreResult::Success.new entity
        end
      end # class Repository::Base::Internals::RecordUpdater
    end
  end
end
