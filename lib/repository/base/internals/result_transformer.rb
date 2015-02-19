
module Repository
  # Base class for Repository in Data Mapper pattern.
  class Base
    # Internal support code exclusively used by Repository::Base
    # @since 0.0.1
    module Internals
      # Transforms a `StoreResult` containing a DAO record where its entity
      # should be, into a `StoreResult` with the corresponding entity.
      # @since 0.1.1
      class ResultTransformer
        # Initialise a new `ResultTransformer` instance.
        # @param result [Repository::Support::StoreResult]
        # @param factory Has a .create method to create entities from DAO
        #                records.
        def initialize(result, factory)
          @result, @factory = result, factory
        end

        # Transforms a (successful) `StoreResult` containing a DAO record where
        # its entity should be, into a `StoreResult` with its corresponding
        # entity.
        # @return [Repository::Support::StoreResult]
        #         Returns the original `StoreResult` if either:
        #
        #         1. the `result.success?` attribute is `false`; or
        #         1. the `result.entity` attribute is not a DAO instance (as
        #            assumed by its lack of a `#save` method).
        #
        #         Otherwise, returns a *new* `StoreResult::Success` with its
        #         `entity` set to the return value from `factory.create`.
        def transform
          return result unless entity_is_record?
          entity = factory.create result.entity
          Repository::Support::StoreResult::Success.new entity
        end

        private

        attr_reader :factory, :result

        # Determines if the entity in a `StoreResult` needs to be transformed
        # from a DAO record to an actual entity.
        # @return [boolean] Returns `true` if and only if the `result`
        #                   attribute:
        #
        #                   1. Has a `success?` attribute that is not false; and
        #                   1. Has an `entity` attribute that responds to the
        #                      `#save` message (which entities should not do).
        def entity_is_record?
          result.success? && result.entity.respond_to?(:save)
        end
      end # class Repository::Base::Internals::ResultTransformer
    end
  end
end
