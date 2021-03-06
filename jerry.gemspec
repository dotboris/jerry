
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jerry/version'

Gem::Specification.new do |spec|
  spec.name          = 'jerry'
  spec.version       = Jerry::VERSION
  spec.authors       = ['Boris Bera']
  spec.email         = ['bboris@rsoft.ca']
  spec.summary       = "Jerry rigs your application together. It's an " \
                       'Inversion of Control container.'
  spec.description   = 'Jerry is an Inversion of Control container. ' \
                       'It allows you to decouple the code that bootstraps ' \
                       'your application from the rest of your application'
  spec.homepage      = 'http://github.com/beraboris/jerry'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'coveralls', '~> 0.8'
  spec.add_development_dependency 'guard', '<= 2.13'
  spec.add_development_dependency 'guard-rake', '~> 1.0'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'rake', '~> 10.4'
  spec.add_development_dependency 'rspec', '~> 3.3'
  spec.add_development_dependency 'rubocop', '~> 0.49'
  spec.add_development_dependency 'yard', '~> 0.9.11'
end
