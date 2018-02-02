# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'repository/base/version'

Gem::Specification.new do |spec|
  spec.name          = 'repository-base'
  spec.version       = Repository::Base::VERSION
  spec.authors       = ['Jeff Dickey']
  spec.email         = ['jdickey@seven-sigma.com']
  spec.summary       = %q(Base implementation of Repository layer in Data Mapper pattern.)
  spec.description   = %q(Base implementation of Repository layer in Data Mapper pattern. See README for details.)
  spec.homepage      = 'https://github.com/jdickey/repository-base'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  # This Gem installs no executables of its own, and developer stubs for bin/setup will be overwritten
  # spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.metadata["yard.run"] = "yri" # use "yard" to build full HTML docs.

  spec.add_dependency 'repository-support', '>= 0.1.1'

  spec.add_development_dependency 'activemodel', '~> 4.2', '>= 4.2.10'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 12.3', '>= 12.3.0'
  spec.add_development_dependency 'rspec', '~> 3.7'
  spec.add_development_dependency 'rubocop', '~> 0.52', '>= 0.52.1'
  spec.add_development_dependency 'simplecov', '~> 0.15', '>= 0.15.1'
  spec.add_development_dependency 'awesome_print', '>= 1.8.0'

  spec.add_development_dependency 'fancy-open-struct'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'kramdown', '~> 1.16'
end
