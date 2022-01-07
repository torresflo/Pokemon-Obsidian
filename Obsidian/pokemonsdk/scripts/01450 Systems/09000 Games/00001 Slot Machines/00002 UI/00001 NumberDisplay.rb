module UI
  # Module containing all the Casino related UI elements
  module Casino
    # Object showing images of credit / payout element in casino UI
    class NumberDisplay < SpriteStack
      # List of files that shows the number
      FILES = %w[casino/n0 casino/n1 casino/n2 casino/n3 casino/n4
                 casino/n5 casino/n6 casino/n7 casino/n8 casino/n9]
      # Delta of number between each frame
      DELTA = 3
      # Number that is currently displayed
      # @return [Integer]
      attr_reader :number
      # Target that the UI element should animatedly aim
      # @return [Integer]
      attr_accessor :target

      # Create a new NumberDipslay
      # @param viewport [Viewport]
      # @param x [Integer]
      # @param y [Integer]
      # @param max_numbers [Integer] maximum number of numbers to display
      def initialize(viewport, x, y, max_numbers)
        super(viewport, x, y)
        width = number_width
        max_numbers.times do |i|
          add_sprite((max_numbers - i - 1) * width, 0, NO_INITIAL_IMAGE)
        end
        @number = 0
        @target = 0
      end

      # Sets the number to display
      # @param number [Integer] number to display
      def number=(number)
        @number = number
        @target = number
        update_numbers
      end

      # Update the animation
      def update
        return if done?
        if @target > @number
          @number = (@number + DELTA).clamp(@number, @target)
        else
          @number = (@number - DELTA).clamp(@target, @number)
        end
        update_numbers
      end

      # Tell if the animation is done
      # @return [Boolean]
      def done?
        @number == @target
      end

      private

      def update_numbers
        current_number = @number
        @stack.each do |sprite|
          sprite.bitmap = RPG::Cache.interface(FILES[current_number % 10])
          current_number /= 10
        end
      end

      def number_width
        RPG::Cache.interface(FILES.first).width
      end
    end
  end
end
