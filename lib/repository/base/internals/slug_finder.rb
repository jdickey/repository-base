
require 'repository/support/result_builder'

module Repository
  # Base class for Repository in Data Mapper pattern.
  class Base
    # Internal support code exclusively used by Repository::Base
    module Internals
      # Find a slug in the DAO, reporting errors if not successful.
      class SlugFinder
        include Repository::Support

        def initialize(slug, dao)
          @slug = slug
          @dao = dao
        end

        def find
          record = dao.where(slug: slug).first
          result_builder(record).build do |_failed_record|
            ErrorFactory.create errors_for_slug
          end
        end

        private

        attr_reader :dao, :slug

        def errors_for_slug
          errors = ActiveModel::Errors.new dao
          errors.add :slug,  "not found: '#{slug}'"
          errors
        end

        def result_builder(record)
          ResultBuilder.new record
        end
      end # class Repository::Base::Internals::SlugFinder
    end
  end
end
