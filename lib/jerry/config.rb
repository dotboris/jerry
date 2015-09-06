require 'jerry/class_provider'
require 'jerry/errors'

class Jerry
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
      # @param ctor_args [Array<Class, Symbol, Proc>] specifies the arguments to
      #   be given to the constructor
      def bind(klass, ctor_args = [])
        named_bind klass, klass, ctor_args
      end

      # Specify how to wire the dependencies of a given class giving it a name
      #
      # @param name [Symbol] The name used to identify this way of building the
      #   given class
      # @param klass [Class] The class to wire the dependencies for
      # @param ctor_args [Array<Class, Symbol, Proc>] specifies the arguments to
      #   be given to the constructor
      def named_bind(name, klass, ctor_args = [])
        providers[name] = ClassProvider.new klass, ctor_args
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
        provider.call @jerry, self
      else
        fail InstantiationError,
             "Failed to instanciate #{key}. Can't find provider for it"
      end
    rescue RuntimeError
      raise InstantiationError, "Provider for #{key} raised an error"
    end

    # @return true if this config can provide the given key, false otherwise
    def knows?(key)
      self.class.providers.key? key
    end
  end
end
