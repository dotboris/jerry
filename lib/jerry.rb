require 'jerry/version'
require 'jerry/config'

class Jerry
  class RigError < StandardError; end

  def initialize(*configs)
    @index = {}

    configs.each { |config| self << config }
  end

  def <<(config)
    components = config.components
    components.each { |component| @index[component] = config }
  end

  def rig(component)
    raise RigError, "could not find component #{component}" unless knows? component

    @index[component].public_send component
  end

  def knows?(component)
    @index.has_key? component
  end
end
