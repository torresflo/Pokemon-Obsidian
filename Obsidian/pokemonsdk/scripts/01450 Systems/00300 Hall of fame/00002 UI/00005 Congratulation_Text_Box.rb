module UI
  module Hall_of_Fame
    # Class that define the Congratulation text box stack
    class Congratulation_Text_Box < SpriteStack
      WHITE_COLOR = Color.new(255, 255, 255)
      # Initialize the SpriteStack
      # @param viewport [Viewport]
      # @param pkm [PFM::Pokemon] the Pokemon's data
      def initialize(viewport, pkm)
        super(viewport, *spritesheet_coordinates)
        @box = add_sprite(0, 0, bmp_filename, 1, number_of_types, type: SpriteSheet)
        @box.sy = pkm.type1
        @text = add_text(*text_coordinates, parse_text(32, 109))
        @text.fill_color = WHITE_COLOR
        @text.draw_shadow = false
      end

      # The base filename of the window
      # @return [String]
      def bmp_filename
        'hall_of_fame/type_window'
      end

      # The base coordinates of the text
      # @return [Array<Integer>] the coordinates
      def text_coordinates
        return 28, 5, 152, 16
      end

      # Check how many types the game has
      # @return [Integer] the number of types
      def number_of_types
        return GameData::Type.all.size
      end

      # Get the width of the box
      # @return [Integer] the width of the box sprite
      def width
        @box.width
      end

      # The SpriteStack initial coordinates
      # @return [Array<Integer>] the coordinates
      def spritesheet_coordinates
        return -184, 20
      end
    end
  end
end
