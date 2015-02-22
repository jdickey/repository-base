
require 'repository/support/error_factory'
require 'repository/support/store_result'

module Repository
  # Base class for Repository in Data Mapper pattern.
  class Base
    # Internal support code exclusively used by Repository::Base
    module Internals
      # Reports on the success or failure of saving a *DAO record*, using the
      # `Repository::Support::StoreResult` instance returned from `#result`.
      # @since 0.0.1
      class RecordSaver
        include Repository::Support

        # Sets instance variable(s) on a new `RecordSaver` instanace.
        # @param record DAO record to attempt to save.
        def initialize(record:, factory:)
          @record = record
          @factory = factory
        end

        # Command-pattern method returning indication of success or failure of
        # attempt to save record.
        # @return Repository::Support::StoreResult
        # @see #failed_result
        # @see #successful_result
        def result
          if record.save
            successful_result
          else
            failed_result
          end
        end

        private

        attr_reader :factory, :record

        # Represent error data sourced from an `ActiveModel::Errors` object as
        # an Array of `{field: 'field', message: 'message'}` hashes.
        def error_hashes
          ErrorFactory.create record.errors
        end

        def failed_result
          StoreResult::Failure.new error_hashes
        end

        def successful_result
          entity = factory.create record
          StoreResult::Success.new entity
        end
      end # class Internals::RecordSaver
    end # module Repository::Base::Internals
  end # class Repository::Base
end
