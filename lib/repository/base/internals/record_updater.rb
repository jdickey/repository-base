
require 'repository/support/store_result'

module Repository
  # Base class for Repository in Data Mapper pattern.
  class Base
    # Internal support code exclusively used by Repository::Base
    module Internals
      # Stows away details of reporting update success/failure.
      class RecordUpdater
        include Repository::Support

        def initialize(identifier, updated_attrs, dao)
          @identifier = identifier
          @updated_attrs = updated_attrs
          @dao = dao
        end

        def update
          @record = dao.where(slug: identifier).first
          return failed_result unless record.update(updated_attrs.to_h)
          successful_result
        end

        private

        attr_reader :dao, :identifier, :record, :updated_attrs

        def failed_result
          StoreResult::Failure.new record.errors
        end

        def successful_result
          StoreResult::Success.new record
        end
      end # class Repository::Base::Internals::RecordUpdater
    end
  end
end
