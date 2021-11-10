return unless PSDK_CONFIG.debug?

module InspectElements
  class TextRaw < LiteRGSS::Text
  end
  module DisplayDataElement
    attr_reader :_display_data
  end

  LiteRGSS::Viewport.class_eval { include InspectElements::DisplayDataElement }
  Hooks.register(LiteRGSS::Viewport, :initialize, 'Inspect Elements Viewport initialize') { @_display_data = InspectElements::DisplayDataNode.new(nil, self, Color.new(180, 80, 80)) }
  Hooks.register(LiteRGSS::Viewport, :dispose, 'Inspect Elements Viewport dispose') { @_display_data.on_dispose unless @_display_data.nil?; @_display_data = nil}
  LiteRGSS::Window.class_eval { include InspectElements::DisplayDataElement }
  Hooks.register(LiteRGSS::Window, :initialize, 'Inspect Elements Window initialize') { @_display_data = InspectElements::DisplayDataNode.new(self.viewport.is_a?(LiteRGSS::DisplayWindow) ? nil : self.viewport._display_data, self, Color.new(80, 80, 180)) }
  Hooks.register(LiteRGSS::Window, :dispose, 'Inspect Elements Window dispose') { @_display_data.on_dispose unless @_display_data.nil?; @_display_data = nil}
  LiteRGSS::Sprite.class_eval { include InspectElements::DisplayDataElement }
  Hooks.register(LiteRGSS::Sprite, :initialize, 'Inspect Elements Sprite initialize') { @_display_data = InspectElements::DisplayDataNode.new(self.viewport.is_a?(LiteRGSS::DisplayWindow) ? nil : self.viewport._display_data, self, Color.new(224, 63, 216)) }
  Hooks.register(LiteRGSS::Sprite, :dispose, 'Inspect Elements Sprite dispose') { @_display_data.on_dispose unless @_display_data.nil?; @_display_data = nil}
  LiteRGSS::Text.class_eval { include InspectElements::DisplayDataElement }
  Hooks.register(LiteRGSS::Text, :initialize, 'Inspect Elements Text initialize') { @_display_data = nil; @_display_data = InspectElements::DisplayDataNode.new(self.viewport.is_a?(LiteRGSS::DisplayWindow) ? nil : self.viewport._display_data, self, Color.new(224, 63, 216)) unless self.is_a?(InspectElements::TextRaw) }
  Hooks.register(LiteRGSS::Text, :dispose, 'Inspect Elements Text dispose') { @_display_data.on_dispose unless @_display_data.nil?; @_display_data = nil}
end