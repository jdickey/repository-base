
require 'repository/base/version'

require 'repository/base/internals/record_saver'

module Repository
  # Base class for Repository in Data Mapper pattern.
  class Base
    # Internal support code exclusively used by Repository::Base
    module Internals
    end
    private_constant :Internals

    include Internals
    include Repository::Support
    attr_reader :dao, :factory

    def initialize(factory:, dao:)
      validate_initializer_argument(:dao, dao)
      validate_initializer_argument(:factory, factory)
      @factory, @dao = factory, dao
    end

    def add(entity)
      record = dao.new filtered_attributes_for(entity)
      RecordSaver.new(record).result
    end

    private

    # supporting #initialize

    def validate_initializer_argument(arg_sym, value)
      message = "the :#{arg_sym} argument must be a Class"
      fail ArgumentError, message unless value.respond_to? :new
    end

    # supporting #add

    def filtered_attributes_for(entity)
      entity.attributes.reject { |k, _v| k == :errors }
    end
  end # class Repository::Base
end
