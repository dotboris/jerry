guard 'rake', task: 'default' do
  watch 'Rakefile'
  watch 'Gemfile'
  watch 'Guardfile'
  watch '.rspec'
  watch '.rubocop.yml'
  watch %r{^lib/}
  watch %r{^spec/}
end

guard 'rake', task: 'doc' do
  watch '.yardopts'
  watch 'LICENSE.txt'
  watch(/.+\.(md|markdown)/)
  watch %r{^lib/}
  watch %r{^doc/}
end
