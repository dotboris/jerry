require 'jerry/version'
require 'jerry/errors'
require 'jerry/config'

# Inversion of Control container.
#
# This class is in charge of bootstrapping your application. This is done by
# defining {Jerry::Config configs}.
#
# @example
#   class MyConfig < Jerry::Config
#     component(:app) { MyApp.new }
#   end
#
#   jerry = Jerry.new MyConfig.new
#   jerry.rig :app #=> #<MyApp:...>
class Jerry
  def initialize(*configs)
    configs.each { |conf| conf.jerry = self }

    @configs = configs
  end

  # @param key what to provide
  # @return an insance of the sepcified key provided by one of the configs
  # @raise [Jerry::InstanciationError] if can't instanciate key
  def [](key)
    config = @configs.find { |conf| conf.knows? key }
    if config
      config[key]
    else
      fail Jerry::InstanciationError, "Can't find #{key} in any config"
    end
  end
end
