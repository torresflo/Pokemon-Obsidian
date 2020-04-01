module Util
  class Animation
    # Animation that moves a sprite to a specified location in a certain amount of time
    #
    # Example :
    #   # Move the sprite to 50, 50 in 0.5 second
    #   Util::Animation::MoveTo.new(sprite, 50, 50, 0.5)
    class MoveTo < Animation
      # Create a new MoveTo animation
      # @param x [Integer, nil] X coordinate where the sprite should go
      # @param y [Integer, nil] Y coordinate where the sprite should go
      # @param duration [Numeric] amount of time to perform the movement
      def initialize(sprite, x, y, duration)
        super(sprite, duration)
        @target_x = x
        @target_y = y
        create_movement
        reset
      end

      # Reset the movement
      # @return [self]
      def reset
        super
        @origin_x = @object.x
        @origin_y = @object.y
        return self
      end

      private

      def tick(delta)
        @elapsed_time += delta
        return @movement.call(delta)
      end

      def create_movement
        @movement = proc do |delta|
          elapsed = elapsed_time

          new_x = @origin_x
          new_x += (@target_x - @origin_x) * elapsed / @duration if @target_x
          new_y = @origin_y
          new_y += (@target_y - @origin_y) * elapsed / @duration if @target_y

          @object.set_position(new_x, new_y)

          next termination_test(delta)
        end
      end
    end
  end
end
