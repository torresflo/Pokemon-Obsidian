module UI
  module Bag
    # Arrow telling which item is selected
    class Arrow < Sprite
      # Create a new arrow
      # @param viewport [Viewport]
      def initialize(viewport)
        super
        @counter = 0
        init_sprite
      end

      # Update the arrow animation
      def update
        if @counter == 30
          self.x -= 1
        elsif @counter == 60
          self.x += 1
          @counter = 0
        end
        @counter += 1
      end

      private

      # Initialize the sprite
      def init_sprite
        set_position(*coordinates)
        set_bitmap(image_name, :interface)
        self.z = 4
      end

      # Return the coordinate of the sprite
      # @return [Array<Integer>]
      def coordinates
        return 166, 72
      end

      # Return the name of the sprite
      # @return [String]
      def image_name
        'bag/arrow'
      end
    end
  end
end
