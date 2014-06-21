require 'jerry/sugar'

class Jerry
  # Base class for all jerry configs.
  #
  # It defines all of the instance methods for a config
  #
  # @abstract Subclass to define a config
  # @example
  #   class MyConfig < Jerry::Config
  #     component(:service) { MyService.new }
  #     component(:app) { MyApp.new rig(:service) }
  #   end
  # @see Jerry::Sugar injected class methods
  class Config
    # Injects Jerry::Sugar into inherited classes
    def self.inherited(subclass)
      subclass.send :extend, Jerry::Sugar
    end

    # @return [Array<Symbol>] list of components defined by the config
    def components
      self.class.components
    end

    # Jerry instance the config is part of
    #
    # This gets set by Jerry when it loads a config
    attr_writer :jerry

    protected

    # Creates a component
    def rig(component)
      @jerry.rig component
    end

    # Check if given component exists
    def knows?(component)
      @jerry.knows? component
    end

    def cache
      @cache ||= {}
    end
  end
end