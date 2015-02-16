
require 'repository/support/error_factory'
require 'repository/support/store_result'

module Repository
  # Base class for Repository in Data Mapper pattern.
  class Base
    # Internal support code exclusively used by Repository::Base
    module Internals
      # Stows away details of reporting save success/failure.
      class RecordSaver
        include Repository::Support

        def initialize(record)
          @record = record
        end

        def result
          if record.save
            successful_result
          else
            failed_result
          end
        end

        private

        attr_reader :record

        def error_hashes
          ErrorFactory.create record.errors
        end

        def failed_result
          StoreResult::Failure.new error_hashes
        end

        def successful_result
          StoreResult::Success.new record
        end
      end # class Internals::RecordSaver
    end # module Repository::Base::Internals
  end # class Repository::Base
end
