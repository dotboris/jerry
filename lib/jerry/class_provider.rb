class Jerry
  # A provider that instanciates a given class by collecting constructor
  # arguments through a given jerry instance.
  class ClassProvider
    # @param klass [Class] class to be instanciated
    # @param args_spec [Array<Clsss, Symbol, Proc>] specification for the
    #   constructor arguments. Classes and Symbols are used to collect the
    #   arguments from the jerry instance. Procs are called to generate
    #   arguments.
    def initialize(klass, args_spec)
      @klass = klass
      @args_spec = args_spec
    end

    # @param jerry [Jerry] a jerry instance
    # @return An instance of the class given in the constructor
    def call(jerry)
      args = @args_spec.map do |spec|
        if spec.respond_to? :call
          spec.call
        else
          jerry[spec]
        end
      end

      @klass.new(*args)
    end
  end
end
