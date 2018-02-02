
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

require 'kramdown'
require 'yard'
require 'yard/rake/yardoc_task'


RuboCop::RakeTask.new(:rubocop) do |task|
  task.patterns = [
    'lib/**/*.rb',
    'spec/spec_helper.rb',
    'spec/**/*_spec.rb'
  ]
  task.formatters = ['simple', 'd']
  task.fail_on_error = true
  task.options << '--rails'
end

RSpec::Core::RakeTask.new :spec

YARD::Rake::YardocTask.new

# YARD::Rake::YardocTask.new do |t|
#   OTHER_PATHS = %w(CHANGELOG.md README.md)
#   t.files   = ['lib/**/*.rb', OTHER_PATHS]
#   t.options = %w(--private --protected -m markdown --main=README.md)
# end

task(:default).clear
task default: [:spec, :rubocop]
