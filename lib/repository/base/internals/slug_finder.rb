
require 'repository/support/result_builder'

module Repository
  # Base class for Repository in Data Mapper pattern.
  class Base
    # Internal support code exclusively used by Repository::Base
    module Internals
      # Find a slug in the DAO, reporting errors if not successful.
      # @since 0.0.3
      class SlugFinder
        include Repository::Support

        # Initializes a new instance of `SlugFinder`.
        # @param slug [String] [Slug](http://en.wikipedia.org/wiki/Semantic_URL#Slug)
        #                      for record to be deleted.
        # @param dao Data Access Object implements persistence without business
        #            logic.
        def initialize(slug, dao)
          @slug = slug
          @dao = dao
        end

        # Command-pattern method to search underlying DAO for record matching
        # slug. Returns a `Repository::Support::StoreResult` instance with the
        # corresponding entity on success, or with the error hash built by
        # `Repository::Support::ErrorFactory.create` on failure.
        # @return [Repository::Support::StoreResult]
        # @see #errors_for_slug
        # @see #result_builder
        def find
          record = dao.where(slug: slug).first
          result_builder(record).build do |_failed_record|
            ErrorFactory.create errors_for_slug
          end
        end

        private

        attr_reader :dao, :slug

        # Builds an [`ActiveModel::Errors`](http://api.rubyonrails.org/classes/ActiveModel/Errors.html)
        # instance and adds a slug-not-found message to it.
        # @return [ActiveModel::Errors]
        # @see #find
        def errors_for_slug
          errors = ActiveModel::Errors.new dao
          errors.add :slug,  "not found: '#{slug}'"
          errors
        end

        # Returns a new `Repository::Support::ResultBuilder` instance, passing
        # the parameter specified to this method as its `#initialize` parameter.
        # @param record DAO record to pass to `ResultBuilder#initialize`.
        def result_builder(record)
          ResultBuilder.new record
        end
      end # class Repository::Base::Internals::SlugFinder
    end
  end
end
