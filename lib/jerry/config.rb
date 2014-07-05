class Jerry
  # Indicated that an error occurred when defining a component
  class ComponentError < StandardError; end

  # Base class for all jerry configs.
  #
  # A config is a class that tells jerry about a set of available
  # components and how those should be created
  #
  # @abstract Subclass to define a config
  # @example
  #   class MyConfig < Jerry::Config
  #     component(:service) { MyService.new }
  #     component(:app) { MyApp.new rig(:service) }
  #   end
  class Config
    class << self
      # @return [Array<Symbol>] list of the components defined by the config
      def components
        @components ||= []
      end

      # Defines a component
      #
      # @param [Symbol] name name of the component
      # @param [Hash] options options hash see supported options
      # @option options [Symbol] (:single) The scope of the component. Can be either :single or :instance.
      #   When the scope is :single, only one instance of the component will be created and every call
      #   to Jerry#rig will return the same instance. When the scope is :instance, every call to Jerry#rig
      #   will return a new instance.
      # @yield Block used to instantiate the component. This block in only called when Jerry#rig is called.
      # @raise [Jerry::ComponentError] when the block is missing or the scope is invalid
      def component(name, options={}, &block)
        raise Jerry::ComponentError, "could not define component #{name}, block is missing" if block.nil?

        scope = options[:scope] || :single
        unless [:single, :instance].include? scope
          raise Jerry::ComponentError, "could not define component #{name}, scope #{scope} is unknown"
        end

        define_method name do
          case scope
            when :single
              cache[name] ||= instance_eval(&block)
            when :instance
              instance_eval(&block)
          end
        end

        components << name
      end
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
    #
    # This should be used inside the block passed to Config::component
    def rig(component)
      @jerry.rig component
    end

    # Check if given component exists
    #
    # This should be used inside the block passed to Config::component
    def knows?(component)
      @jerry.knows? component
    end

    # Used internally to cache single instance components
    def cache
      @cache ||= {}
    end
  end
end