
require_relative 'store_result'

module Repository
  module Support
    # Builds a successful or failed StoreResult depending on a record existing.
    class ResultBuilder
      def initialize(record)
        @record = record
      end

      def build(&_block)
        return successful_result if record
        failed_result yield(record)
      end

      private

      attr_reader :record

      def failed_result(errors)
        StoreResult::Failure.new errors
      end

      def successful_result
        StoreResult::Success.new record
      end
    end # class Repository::Support::ResultBuilder
  end
end
