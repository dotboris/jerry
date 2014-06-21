require 'jerry/sugar'

class Jerry
  class Config
    def self.inherited(subclass)
      subclass.send :extend, Jerry::Sugar
    end

    def components
      self.class.components
    end

    attr_writer :jerry

    protected

    def rig(component)
      @jerry.rig component
    end

    def knows?(component)
      @jerry.knows? component
    end

    def cache
      @cache ||= {}
    end
  end
end