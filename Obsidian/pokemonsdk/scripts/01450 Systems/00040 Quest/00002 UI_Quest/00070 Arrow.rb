module UI
  module Quest
    # Arrow telling which item is selected
    class Arrow < Sprite
      # Create a new arrow
      # @param viewport [Viewport]
      def initialize(viewport)
        super
        @animation = nil
        init_sprite
      end

      # Update the arrow animation
      def update
        @animation.update
      end

      private

      # Initialize the sprite
      def init_sprite
        set_position(*coordinates)
        set_bitmap(image_name, :interface)
        self.z = 4
        set_animation
      end

      # Return the coordinate of the sprite
      # @return [Array<Integer>]
      def coordinates
        return 3, 46
      end

      # Return the name of the sprite
      # @return [String]
      def image_name
        'quest/arrow'
      end

      # Set the looped animation of the arrow
      def set_animation
        anim = Yuki::Animation
        @animation = anim.timed_loop_animation(0.5)
        wait = anim.wait(0.5)
        movement = anim.move(0.25, self, x, y, x - 2, y)
        movement.play_before(anim.move(0.25, self, x - 2, y, x, y))
        wait.parallel_add(movement)
        @animation.play_before(wait)
        @animation.start
      end
    end
  end
end
