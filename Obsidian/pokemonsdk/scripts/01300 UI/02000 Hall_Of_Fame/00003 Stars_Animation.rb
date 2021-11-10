module UI
  module Hall_of_Fame
    # Class that define the Star Animation
    class Star_Animation < SpriteSheet
      # The counter for the animation
      # @return [Integer]
      attr_accessor :counter
      # Tell if the animation is finished or not
      # @return [Boolean]
      attr_accessor :finished
      # Initialize the SpriteSheet
      # @param viewport [Viewport]
      # @param frame_count [Integer] how many frames between each anim update
      # @param repeat [Boolean] if the animation has to repeat itself
      def initialize(viewport, frame_count = 2, repeat: false)
        super(viewport, 6, 1)
        set_bitmap('hall_of_fame/stars', :interface)
        set_position(x, y)
        self.opacity = 0
        @frame_count = frame_count
        @repeat = repeat
        @finished = false
        @counter = 0
        @reversing = false
      end

      # Update the animation depending on the @frame_count
      def update
        return if @finished

        if @counter == @frame_count
          @counter = 0
          if @reversing == true
            self.sx -= 1
            if self.sx == 0
              self.opacity = 0
              @reversing = false
              @finished = true if !@repeat
            end
          elsif @reversing == false
            self.opacity = 255 if self.sx == 0
            self.sx += 1
            @reversing = true if self.sx == 5
          end
        end
        @counter += 1
      end
    end
  end
end
