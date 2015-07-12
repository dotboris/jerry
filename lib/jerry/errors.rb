require 'English'

class Jerry
  # Base error class for Jerry that allows recording causing exceptions
  class Error < RuntimeError
    attr_reader :cause

    def initialize(message = nil)
      super
      @cause = $ERROR_INFO
    end
  end

  # Failed to instanciate a class
  class InstanciationError < RuntimeError; end
end
