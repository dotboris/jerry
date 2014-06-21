class Jerry
  class ComponentError < StandardError; end

  module Sugar
    def components
      @components ||= []
    end

    def component(name, options={}, &block)
      raise Jerry::ComponentError, "could not define component #{name}, block is missing" if block.nil?

      scope = options[:scope] || :single
      unless [:single, :instance].include? scope
        raise Jerry::ComponentError, "could not define component #{name}, scope #{scope} is unknown"
      end

      define_method name do
        case scope
          when :single
            cache[name] ||= block.call
          when :instance
            block.call
        end
      end

      components << name
    end
  end
end