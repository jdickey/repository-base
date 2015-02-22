
require 'spec_helper'
require 'active_model'

require 'repository/support'

# FIXME: Periodically try disabling this after updating to new release of
#        ActiveModel and see if they've fixed the conflict w/stdlib Forwardable.
#        This is per https://github.com/cequel/cequel/issues/193 - another epic
#        ActiveFail.
module Forwardable
  remove_method :delegate
end

# Test entity class; simply a wrapper around attributes and comparison of same.
class BaseEntityClass
  include Comparable
  extend Repository::Support::TestAttributeContainer

  init_empty_attribute_container

  def initialize(attributes_in = {})
    @attributes = attributes_in
  end

  def <=>(other)
    attributes <=> other.attributes
  end
end

describe Repository::Base do
  let(:all_dao_records) { [] }
  let(:save_successful) { true }
  let(:test_dao) do
    ret = Class.new do
      attr_reader :attributes
      include ActiveModel::Validations

      def initialize(attribs = {})
        @attributes = attribs
      end

      def self.all
        @all_records.to_a # silence RuboCop Style/TrivialAccessors cop
      end

      def self.delete(identifier)
        record = @all_records.detect { |r| r.attributes[:slug] == identifier }
        if record
          @all_records.delete record
          1
        else
          errors.add :slug, "not found: '#{identifier}'"
          0
        end
      end

      def self.where(conditions = {})
        ret = @all_records.to_a.select do |record|
          conditions.delete_if do |field, value|
            record.attributes[field.to_sym] == value
          end.empty?
        end
        ret
      end

      def save
        self.class.instance_variable_get(:@save_flag).tap do |flag|
          unless flag
            errors.add :foo, 'is foo'
            errors.add :something, 'is broken'
          end
        end
      end

      def update
        StoreResult::Success.new 'succeeded'
      end
    end
    ret.instance_variable_set :@save_flag, save_successful
    ret.instance_variable_set :@all_records, all_dao_records
    ret
  end
  let(:test_factory) do
    Class.new do
      def self.create(record)
        BaseEntityClass.new record.attributes
      end
    end
  end
  let(:obj) { described_class.new dao: test_dao, factory: test_factory }

  it 'has a version number' do
    expect(Repository::Base::VERSION).not_to be nil
  end

  describe 'instantiation' do
    it 'requires two keyword arguments, :factory and :dao' do
      message = 'missing keywords: factory, dao'
      expect { described_class.new }.to raise_error ArgumentError, message
    end

    it 'requires the :dao argument to be a class' do
      expect { described_class.new dao: nil, factory: nil }.to \
        raise_error ArgumentError, 'the :dao argument must be a Class'
    end

    describe 'requires the :factory argument to' do
      it 'be a class' do
        expect { described_class.new dao: test_dao, factory: nil }.to \
          raise_error ArgumentError, 'the :factory argument must be a Class'
      end
    end # describe 'requires the :factory argument to'
  end # describe 'instantiation'

  describe 'has an #add method that' do
    describe 'takes one argument' do
      it 'that is required' do
        method = obj.method :add
        expect(method.arity).to eq 1
      end

      it 'with an #attributes method returning an Enumerable' do
        arg = 'q'
        message = %(undefined method `attributes' for "#{arg}":String)
        expect { obj.add arg }.to raise_error NoMethodError, message
        entity = Struct.new(:attributes).new arg
        message = %(undefined method `reject' for "#{arg}":String)
        expect { obj.add entity }.to raise_error NoMethodError, message
      end
    end # describe 'takes one argument'

    describe 'returns a StoreResult' do
      let(:entity) { BaseEntityClass.new foo: true }
      let(:result) { obj.add entity }

      context 'for a successful save' do
        let(:save_successful) { true }

        it 'a #success method returning true' do
          expect(result).to be_success
        end

        describe 'an #entity method which returns an entity that' do
          it 'is an entity, not a record' do
            expect(result.entity).not_to respond_to :save
          end

          it 'has the correct attributes' do
            expect(result.entity.attributes).to eq entity.attributes
          end
        end # describe 'an #entity method which returns an entity that'
      end # context 'for a successful save'

      context 'for an unsuccessful save' do
        let(:save_successful) { false }

        it 'a #success method returning false' do
          expect(result).not_to be_success
        end

        it 'an #entity method returning nil' do
          expect(result.entity).to be nil
        end

        it 'an #errors method returning the expected error-pair hashes' do
          expected = [
            { field: 'foo', message: 'is foo' },
            { field: 'something', message: 'is broken' }
          ]
          expect(result.errors.count).to eq expected.count
          expected.each { |item| expect(result.errors).to include item }
        end
      end # context 'for an unsuccessful save'
    end # describe 'returns a StoreResult with'
  end # describe 'has an #add method that'

  describe 'has an #all method that' do
    context 'for a repository without records' do
      it 'returns an empty array' do
        actual = obj.all
        expect(actual).to respond_to :to_ary
        expect(actual).to be_empty
      end
    end # context 'for a repository without records'

    context 'for a repository with records' do
      let(:all_dao_records) do
        [
          BaseEntityClass.new(attr1: 'value1'),
          BaseEntityClass.new(attr1: 'value2')
        ]
      end

      it 'returns an Array with one entry for each record in the Repository' do
        actual = obj.all
        expect(actual).to respond_to :to_ary
        expect(actual).to eq all_dao_records
      end
    end # context 'for a repository with records'
  end # describe 'has an #all method that'

  describe 'has a #delete method that' do
    let(:entity) { BaseEntityClass.new entity_attributes }
    let(:entity_attributes) { { foo: 'bar', slug: 'the-slug' } }
    let(:result) { obj.delete entity.attributes[:slug] }

    before :each do
      obj.add entity
    end

    context 'for an existing record, returns a StoreResult that' do
      let(:all_dao_records) { [entity] }
      let(:save_successful) { true }

      it 'is successful' do
        expect(result).to be_success
      end

      it 'has an entity matching the target' do
        expect(result.entity.attributes.to_h).to eq entity.attributes
      end

      it 'reports no errors' do
        expect(result.errors).to be_empty
      end
    end # context 'for an existing record, returns a StoreResult that'

    context 'for a nonexistent record, returns a StoreResult that' do
      let(:all_dao_records) { [] }
      let(:save_successful) { false }

      it 'is not successful' do
        expect(result).not_to be_success
      end

      it 'has an #entity method returning nil' do
        expect(result.entity).to be nil
      end

      it 'reports one error: that the target slug was not found' do
        expect(result.errors.count).to eq 1
        error = result.errors.first
        expect(error[:field].to_s).to eq 'slug'
        expect(error[:message]).to eq "not found: '#{entity.attributes[:slug]}'"
      end
    end # context 'for a nonexistent record, returns a StoreResult that'
  end # describe 'has a #delete method that'

  describe 'has a #find_by_slug method' do
    let(:entity) { BaseEntityClass.new entity_attributes }
    let(:entity_attributes) { { foo: 'bar', slug: 'the-slug' } }
    let(:result) { obj.find_by_slug entity.attributes[:slug] }

    context 'when called using the slug for an existing record' do
      describe 'returns a result that' do
        let(:all_dao_records) { [entity] }

        it 'has no errors' do
          expect(result.errors).to be_empty
        end

        it 'is successful' do
          expect(result).to be_success
        end

        it 'has an entity field matching the original entity attributes' do
          expect(result.entity.attributes).to eq entity_attributes
        end
      end # describe 'returns a result that'
    end # context 'when called using the slug for an existing record'

    context 'when called using a slug that matches no existing record' do
      describe 'returns a result that' do
        it 'is not successful' do
          expect(result).not_to be_success
        end

        it 'has an entity field with a nil value' do
          expect(result.entity).to be nil
        end

        it 'reports a single error, stating that the slug was not found' do
          expect(result.errors.count).to eq 1
          message = "not found: '#{entity_attributes[:slug]}'"
          expected = { field: 'slug', message: message }
          expect(result.errors.first).to eq expected
        end
      end # describe 'returns a result that'
    end # context 'when called using a slug that matches no existing record'
  end # describe 'has a #find_by_slug method'

  describe 'has an #update method that' do
    let(:entity) do
      # Class that provides a stubbed `#update` method that quacks enough like
      # ActiveRecord's to be useful for testing, now that `Repository::Support`
      # has this (presently) shiny new `TestAttributeContainer` module that
      # makes the attribute-management finagling we need easier.
      class EntityClass < BaseEntityClass
        attr_accessor :update_successful
        attr_reader :errors

        def initialize(attributes_in = {})
          super attributes_in
          @update_successful = true
          @errors = {}
        end

        def update(new_attributes)
          if update_successful
            new_hash = attributes.merge new_attributes.to_h.symbolize_keys
            @attributes = new_hash
          else
            @errors = {
              new_attributes.keys.first.to_sym => 'is invalid'
            }
          end
          update_successful
        end
      end
      EntityClass.new(entity_attributes).tap do |ret|
        ret.update_successful = update_success
      end
    end
    let(:entity_attributes) { { foo: 'bar', slug: 'the-slug' } }
    let(:new_attrs) { { foo: 'quux' } }
    let(:result) do
      obj.update identifier: entity.attributes[:slug], updated_attrs: new_attrs
    end

    context 'for a valid update' do
      let(:all_dao_records) { [entity] }
      let(:update_success) { true }

      describe 'it returns a result that' do
        it 'is successful' do
          expect(result).to be_success
        end

        it 'has no errors' do
          expect(result.errors).to be_empty
        end

        describe 'an #entity method which returns an entity that' do
          it 'is an entity, not a record' do
            expect(result.entity).not_to respond_to :save
          end

          it 'has the correct attributes' do
            expected = entity_attributes.merge(new_attrs)
            expect(result.entity.attributes).to eq expected
          end
        end # describe 'an #entity method which returns an entity that'
      end # describe 'it returns a result that'
    end # context 'for a valid update'

    context 'for a failed update' do
      let(:all_dao_records) { [entity] }
      let(:update_success) { false }

      describe 'it returns a result that' do
        it 'is not successful' do
          expect(result).not_to be_success
        end

        it 'has an #entity method that returns nil' do
          expect(result.entity).to be nil
        end

        it 'an #errors method that returns the expected error-pair hashes' do
          # from entity#update; see above
          expect(result.errors).to respond_to :to_hash
          expect(result.errors.keys.count).to eq 1
          expect(result.errors[entity_attributes.keys.first]).to eq 'is invalid'
        end
      end # describe 'it returns a result that'
    end # context 'for a failed update'
  end # describe 'has an #update method that'
end
