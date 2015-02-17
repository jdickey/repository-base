
require 'repository/support/store_result'
require_relative 'slug_finder'

module Repository
  # Base class for Repository in Data Mapper pattern.
  class Base
    # Internal support code exclusively used by Repository::Base
    module Internals
      # Stows away details of reporting update success/failure.
      class RecordDeleter
        include Repository::Support

        def initialize(identifier, dao)
          @identifier = identifier
          @dao = dao
        end

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
