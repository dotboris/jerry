require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'
require 'rubocop/rake_task'

task default: %i[spec lint]

RSpec::Core::RakeTask.new :spec
YARD::Rake::YardocTask.new :doc

desc 'Run code style checks'
task lint: %i[rubocop]

desc 'Run rubocop linter on lib/**/*.rb and spec/**/*.rb'
RuboCop::RakeTask.new :rubocop
