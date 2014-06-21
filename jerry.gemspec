# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jerry/version'

Gem::Specification.new do |spec|
  spec.name          = 'jerry'
  spec.version       = Jerry::VERSION
  spec.authors       = ['Boris Bera']
  spec.email         = ['bboris@rsoft.ca']
  spec.summary       = %q{Jerry rigs your application together. It's an Inversion of Control container.}
  spec.description   = %q{Jerry is an Inversion of Control container. It allows you to decouple the code that bootstraps your application from the rest of your application}
  spec.homepage      = 'http://github.com/beraboris/jerry'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0.0'
  spec.add_development_dependency 'yard', '~> 0.8.7.4'
end
