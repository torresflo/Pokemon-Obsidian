module UI
  module Shop
    class Arrow < UI::Bag::Arrow
      # Initialize the arrow Sprite for the UI
      # @param viewport [Viewport] the viewport in which the Sprite will be displayed
      def initialize(viewport)
        super
        set_position(*arrow_pos)
        set_bitmap(arrow_filename, :interface)
        self.z = 4
        @counter = 0
      end

      def arrow_pos
        return 105, 79
      end

      def arrow_filename
        'shop/arrow'
      end
    end
  end
end
