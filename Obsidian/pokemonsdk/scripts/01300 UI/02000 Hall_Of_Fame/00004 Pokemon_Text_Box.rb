module UI
  module Hall_of_Fame
    # Class that define the Pokemon text box stack
    class Pokemon_Text_Box < SpriteStack
      WHITE_COLOR = Color.new(255, 255, 255)
      # Initialize the SpriteStack
      # @param viewport [Viewport]
      # @param pkm [PFM::Pokemon] the Pokemon's data
      def initialize(viewport, pkm)
        super(viewport, *spritesheet_coordinates)
        @box = add_sprite(0, 0, bmp_filename, 1, number_of_types, type: SpriteSheet)
        @box.mirror = true
        @box.sy = pkm.type1
        @name_text = add_text(*name_text_coordinates, pkm.given_name)
        @name_text.fill_color = WHITE_COLOR
        @name_text.draw_shadow = false
        @lvl_text = add_text(*lvl_text_coordinates, parse_text(27, 29) + " #{pkm.level}", 2)
        @lvl_text.fill_color = WHITE_COLOR
        @lvl_text.draw_shadow = false
      end

      # The base filename of the window
      # @return [String]
      def bmp_filename
        'hall_of_fame/type_window'
      end

      # The base coordinates of the name text
      # @return [Array<Integer>] the coordinates
      def name_text_coordinates
        return 8, 5, 98, 16
      end

      # The base coordinates of the level text
      # @return [Array<Integer>] the coordinates
      def lvl_text_coordinates
        return 121, 5, 35, 16
      end

      # Get the width of the box
      # @return [Integer] the width of the box sprite
      def width
        @box.width
      end

      # Check how many types the game has
      # @return [Integer] the number of types
      def number_of_types
        return GameData::Type.all.size
      end

      # The SpriteStack initial coordinates
      # @return [Array<Integer>] the coordinates
      def spritesheet_coordinates
        return 320, 200
      end
    end
  end
end
