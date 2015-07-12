require 'jerry/version'
require 'jerry/errors'
require 'jerry/config'

# Inversion of Control container.
#
# This class is in charge of bootstrapping your application. This is done by
# defining {Jerry::Config configs}.
#
# @example Basic usage
#   class FooConfig < Jerry::Config
#     # ...
#   end
#
#   class BarConfig < Jerry::Config
#     # ...
#   end
#
#   jerry = Jerry.new FooConfig.new, BarConfig.new
#   jerry[SomeClass] #=> #<Someclass:...>
class Jerry
  # @param configs [Array<Jerry::Config>] configurations describing how to wire
  #   your application
  def initialize(*configs)
    configs.each { |conf| conf.jerry = self }

    @configs = configs
  end

  # @param key what to provide
  # @return an insance of the sepcified key provided by one of the configs
  # @raise [Jerry::InstantiationError] if can't instanciate key
  def [](key)
    config = @configs.find { |conf| conf.knows? key }
    if config
      config[key]
    else
      fail Jerry::InstantiationError, "Can't find #{key} in any config"
    end
  end
end
