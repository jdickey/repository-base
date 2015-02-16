
module Repository
  module Support
    # Uniform representation of success or failure of a storage-command action.
    class StoreResult
      # Convenience class to instantiate a "successful" StoreResult.
      class Success < StoreResult
        def initialize(entity)
          super entity: entity, errors: [], success: true
        end
      end # class Repository::Support::StoreResult::Success

      # Convenience class to instantiate a "failed" StoreResult.
      class Failure < StoreResult
        def initialize(errors)
          super entity: nil, errors: errors, success: false
        end
      end # class Repository::Support::StoreResult::Failure

      attr_reader :entity, :errors, :success
      alias_method :success?, :success

      def initialize(entity:, success:, errors:)
        @entity, @success, @errors = entity, success, errors
      end
    end # class Repository::Support::StoreResult
  end
end
