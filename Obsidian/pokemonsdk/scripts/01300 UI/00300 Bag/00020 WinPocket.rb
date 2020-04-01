module UI
  module Bag
    # UI element showing the name of the Pocket in the bag
    class WinPocket < SpriteStack
      # Create a new WinPocket
      # @param viewport [Viewport]
      def initialize(viewport)
        super(viewport, 15, 4)
        add_background('bag/win_pocket').set_z(1)
        @text = add_text(5, 6, 87, 13, nil.to_s, 1, color: 10)
        @text.z = 2
      end

      # Set the text to show
      # @param text [String] the text to show
      def text=(text)
        @text.text = text
      end
    end
  end
end
