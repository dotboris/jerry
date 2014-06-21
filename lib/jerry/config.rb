require 'jerry/sugar'

class Jerry
  class Config
    def self.inherited(subclass)
      subclass.send :extend, Jerry::Sugar
    end

    def components
      self.class.components
    end

    protected

    def cache
      @cache ||= {}
    end
  end
end