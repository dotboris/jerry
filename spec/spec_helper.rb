Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

silence_warnings do
  require 'coveralls'
  Coveralls.wear!
end

RSpec.configure do |config|
  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = true
  end
end
