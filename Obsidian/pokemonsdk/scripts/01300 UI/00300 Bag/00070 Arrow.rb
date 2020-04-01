module UI
  module Bag
    # Arrow telling which item is selected
    class Arrow < Sprite
      # Create a new arrow
      # @param viewport [Viewport]
      def initialize(viewport)
        super
        set_position(166, 72)
        set_bitmap('bag/arrow', :interface)
        self.z = 4
        @counter = 0
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
    end
  end
end
