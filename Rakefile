require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'
require 'rubocop/rake_task'
require 'reek/rake/task'

task default: [:spec, :lint]

RSpec::Core::RakeTask.new :spec
YARD::Rake::YardocTask.new :doc

task lint: [:reek, :rubocop]

desc 'Run rubocop linter on lib/**/*.rb'
RuboCop::RakeTask.new :rubocop do |t|
  t.patterns = ['lib/**/*.rb']
  t.fail_on_error = false
end

desc 'Run reek linter on lib/**/*.rb'
Reek::Rake::Task.new :reek do |t|
  t.source_files = 'lib/**/*.rb'
  t.fail_on_error = false
end
