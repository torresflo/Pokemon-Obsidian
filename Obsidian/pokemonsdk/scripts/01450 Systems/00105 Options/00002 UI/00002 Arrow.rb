module UI
  module Options
    # Arrow telling which option is selected
    class Arrow < Sprite
      # Create a new arrow
      # @param viewport [Viewport]
      def initialize(viewport)
        super
        set_bitmap('options/arrow', :interface)
        set_origin(0, height / 2)
        @counter = 0
      end

      # Update the arrow animation
      def update
        if @counter == 30
          self.x += 1
        elsif @counter == 60
          self.x -= 1
          @counter = 0
        end
        @counter += 1
      end
    end
  end
end
