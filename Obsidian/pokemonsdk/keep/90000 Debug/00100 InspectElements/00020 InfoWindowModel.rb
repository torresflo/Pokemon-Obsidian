return unless PSDK_CONFIG.debug?

module InspectElements
  class InfoWindowModel
    attr_accessor :text_entered

    def initialize
      @text_entered = ''
      @display_datas = []
    end

    def data=(display_datas)
      @display_datas = display_datas
    end

    def data
      return @display_datas
    end
  end
end
