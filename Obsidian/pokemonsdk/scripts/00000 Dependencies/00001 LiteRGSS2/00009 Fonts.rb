raise 'You did not loaded LiteRGSS2' unless defined?(LiteRGSS::DisplayWindow)

module LiteRGSS
  module Fonts
    # Tell if the game supports specific pokemon glyph
    NO_POKEMON_FONT = !PSDK_CONFIG.layout.general.supports_pokemon_number
    @line_heights = []
    class << self
      # Load a line height for a specific font
      # @param font_id [Integer] ID of the font
      # @param line_height [Integer] new line height for the font
      def load_line_height(font_id, line_height)
        @line_heights[font_id] = line_height
      end

      # Get the line height for a specific font
      # @param font_id [Integer] ID of the font
      # @return [Integer]
      def line_height(font_id)
        @line_heights[font_id] || 16
      end
    end
  end
end
# Alias access to the Fonts module
Fonts = LiteRGSS::Fonts

Graphics.on_start do
  PSDK_CONFIG.layout.general.ttf_files.each do |ttf_file|
    id = ttf_file[:id]
    LiteRGSS::Fonts.load_font(id, "Fonts/#{ttf_file[:name]}.ttf")
    LiteRGSS::Fonts.set_default_size(id, ttf_file[:size])
    LiteRGSS::Fonts.load_line_height(id, ttf_file[:line_height])
  end
  PSDK_CONFIG.layout.general.alt_sizes.each do |size|
    id = size[:id]
    LiteRGSS::Fonts.set_default_size(id, size[:size])
    LiteRGSS::Fonts.load_line_height(id, size[:line_height])
  end
end
