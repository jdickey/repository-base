
require 'simplecov'
SimpleCov.start 'rails'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'awesome_print'
require 'fancy-open-struct'
# require 'pry'

require 'repository/base'
