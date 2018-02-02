# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/gemset/'
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'awesome_print'
require 'fancy-open-struct'
# require 'pry'

require 'repository/base'
