guard 'rake', task: 'default' do
  watch 'Rakefile'
  watch '.rspec'
  watch '.reek'
  watch %r{^lib/}
  watch %r{^spec/}
end

guard 'rake', task: 'doc' do
  watch(/.+\.(md|markdown)/)
  watch %r{^lib/}
end
