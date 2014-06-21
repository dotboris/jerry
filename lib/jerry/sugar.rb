class Jerry
  class ComponentError < StandardError; end

  # Contains all the class helper methods that are injected when you inherit from Jerry::Config
  module Sugar
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
end