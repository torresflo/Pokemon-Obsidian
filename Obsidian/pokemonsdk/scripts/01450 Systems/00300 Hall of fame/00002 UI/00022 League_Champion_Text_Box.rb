module UI
  module Hall_of_Fame
    # Class that define the League Champion text box stack
    class League_Champion_Text_Box < SpriteStack
      attr_accessor :text
      Y_FINAL = 10
      WHITE_COLOR = Color.new(255, 255, 255, 255)
      # Initialize the SpriteStack
      # @param viewport [Viewport]
      def initialize(viewport)
        super(viewport, *initial_coordinates)
        @box = add_sprite(0, 0, box_filename)
        @text = add_text(*text_coordinates, parse_text(32, 111), 1)
        @text.fill_color = WHITE_COLOR
        @text.draw_shadow = false
        @text.opacity = 0
      end

      # The SpriteStack initial coordinates
      # @return [Array<Integer>] the coordinates
      def initial_coordinates
        return 10, -28
      end

      # The base filename of the window
      # @return [String]
      def box_filename
        'hall_of_fame/text_window_congrats'
      end

      # Get the constant's value
      # @return [Integer]
      def y_final
        Y_FINAL
      end

      # The base coordinates of the text
      # @return [Array<Integer>] the coordinates
      def text_coordinates
        return 40, 5, 220, 16
      end
    end
  end
end
