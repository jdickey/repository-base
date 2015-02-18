
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
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'repository-support', '>= 0.0.2'

  spec.add_development_dependency 'activemodel', '>= 3.2'
  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop', '>= 0.28.0'
  spec.add_development_dependency 'simplecov', '>= 0.9.1'
  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'fancy-open-struct'
end
