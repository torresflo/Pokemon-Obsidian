module UI
  module Bag
    # UI element showing the name of the Pocket in the bag
    class WinPocket < SpriteStack
      # Name of the background file
      BACKGROUND = 'bag/win_pocket'
      # Coordinate of the spritestack
      COORDINATES = 15, 4
      # Create a new WinPocket
      # @param viewport [Viewport]
      def initialize(viewport)
        super(viewport, *COORDINATES)
        init_sprite
      end

      # Set the text to show
      # @param text [String] the text to show
      def text=(text)
        @text.text = text
      end

      private

      def init_sprite
        create_background
        @text = create_text
      end

      # Create the background sprite
      def create_background
        add_background(BACKGROUND).set_z(1)
      end

      # Create the text
      # @return [Text]
      def create_text
        text = add_text(5, 6, 87, 13, nil.to_s, 1, color: 10)
        text.z = 2
        return text
      end
    end
  end
end
