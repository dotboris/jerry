require 'jerry/version'
require 'jerry/config'

# Inversion of Control container.
#
# This class is in charge of bootstrapping your application. This is done by defining {Jerry::Config configs}.
#
# @example
#   class MyConfig < Jerry::Config
#     component(:app) { MyApp.new }
#   end
#   jerry = Jerry.new MyConfig.new
#   jerry.rig :app #=> #<MyApp:...>
class Jerry
  class RigError < StandardError; end

  # @param [Jerry::Config] configs Configs used to rig components. Multiple config can be given. If two configs
  #   define the same component, the later one will have priority.
  def initialize(*configs)
    @index = {}

    configs.each { |config| self << config }
  end

  # Load a config
  #
  # @param [Jerry::Config] config Config to be loaded. If the loaded config defines a component already defined
  #   by another config, the component from the new config will take priority.
  def <<(config)
    components = config.components
    components.each { |component| @index[component] = config }
    config.jerry = self
  end

  # Rigs a component
  #
  # @param [Symbol] component Component to rig.
  # @return The component requested
  # @raise [Jerry::RigError] when the requested component does not exist
  def rig(component)
    raise RigError, "could not find component #{component}" unless knows? component

    @index[component].public_send component
  end

  # Checks if a component exists
  #
  # @param [Symbol] component component to check
  def knows?(component)
    @index.has_key? component
  end
end
