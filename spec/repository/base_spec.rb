
require 'spec_helper'
require 'active_model'

# FIXME: Periodically try disabling this after updating to new release of
#        ActiveModel and see if they've fixed the conflict w/stdlib Forwardable.
#        This is per https://github.com/cequel/cequel/issues/193 - another epic
#        ActiveFail.
module Forwardable
  remove_method :delegate
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

      def save
        self.class.instance_variable_get(:@save_flag).tap do |flag|
          unless flag
            errors.add :foo, 'is foo'
            errors.add :something, 'is broken'
          end
        end
      end
    end
    ret.instance_variable_set :@save_flag, save_successful
    ret.instance_variable_set :@all_records, all_dao_records
    ret
  end
  let(:test_factory) do
    Class.new do
      def self.create(record)
        ret = {}
        record.to_h.each { |key, value| ret[key.to_sym] = value }
        FancyOpenStruct.new ret
      end
    end
  end

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
    let(:obj) { described_class.new dao: test_dao, factory: test_factory }

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
      let(:entity) { FancyOpenStruct.new attributes: { foo: true } }
      let(:result) { obj.add entity }

      context 'for a successful save' do
        let(:save_successful) { true }

        it 'a #success method returning true' do
          expect(result).to be_success
        end

        it 'an #entity method returning entity with the expected attributes' do
          expect(result.entity.attributes.to_h).to eq entity.attributes.to_h
        end
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
    let(:obj) { described_class.new dao: test_dao, factory: test_factory }

    context 'for a repository without records' do
      it 'returns an empty array' do
        actual = obj.all
        expect(actual).to respond_to :to_ary
        expect(actual).to be_empty
      end
    end # context 'for a repository without records'

    context 'for a repository with records' do
      let(:all_dao_records) { [{ attr1: 'value1' }, { attr1: 'value2' }] }

      it 'returns an Array with one entry for each record in the Repository' do
        actual = obj.all
        expect(actual).to respond_to :to_ary
        expect(actual.count).to eq all_dao_records.count
        actual.each { |r| expect(all_dao_records).to include r.to_h }
      end
    end # context 'for a repository with records'
  end # describe 'has an #all method that'
end
