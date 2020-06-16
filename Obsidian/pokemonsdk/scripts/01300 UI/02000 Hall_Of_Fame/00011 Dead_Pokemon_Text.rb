module UI
  module Hall_of_Fame
    # Class that define the Dead Pokemon text
    class Dead_Pokemon_Text < SpriteStack
      WHITE_COLOR = Color.new(255, 255, 255)
      # Initialize the SpriteStack
      # @param viewport [Viewport]
      # @param x [Integer]
      # @param y [Integer]
      def initialize(viewport, x, y)
        super(viewport, x, y)
        @box = add_sprite(0, 0, bmp_filename)
        @text = add_text(*text_coordinate, nil.to_s, 1)
        @text.fill_color = WHITE_COLOR
        @text.draw_shadow = false
      end

      # The base filename of the window
      # @return [String]
      def bmp_filename
        'hall_of_fame/text_window'
      end

      # The base coordinates of the text
      # @return [Array<Integer>] the coordinates
      def text_coordinate
        return 39, 5, 222, 16
      end

      # Change the text according to the data sent
      # @param pkm [PFM::Pokemon] the dead Pokemon we want the name of
      def text=(pkm)
        @text.text = ext_text(9004, 0) + ' ' + pkm.given_name
      end
    end
  end
end
