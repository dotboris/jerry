require 'jerry/class_provider'

class Jerry
  class InstanciationError < RuntimeError; end
  # A configuration specifies how to wire parts of an application
  #
  # @abstract Subclass this class in order to create a configuration
  # @example Basic usage
  #   class Door; end
  #   class Window; end
  #
  #   class House
  #     def initialize(door, window)
  #       # ...
  #     end
  #   end
  #
  #   class MyConfig < Jerry::Config
  #     bind House, [Door, Window]
  #     bind Door
  #     bind Window
  #   end
  class Config
    class << self
      # Specify how to wire the dependencies of a given class
      #
      # @param klass [Class] The class to wire the dependencies for
      # @param ctor_args [Array<Class, Symbol, Proc>] specifies the arguments to be
      #   given to the constructor
      def bind(klass, ctor_args = [])
        provider = ClassProvider.new klass, ctor_args
        providers[klass] = provider
      end

      def providers
        @providers ||= {}
      end
    end

    # The jerry instance this config is part of
    attr_writer :jerry

    # @return an instance of an object wired by the config
    def [](key)
      provider = self.class.providers[key]

      if provider
        provider.call @jerry
      else
        fail InstanciationError,
             "Failed to instanciate #{key}. Can't find provider for it"
      end
    end
  end
end
