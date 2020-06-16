module UI
  module Hall_of_Fame
    # Class that define the Pokemon Stars animation
    class Pokemon_Stars_Animation < SpriteStack
      X_ARRAY = [67, 16, 90, 40, 65, 30]
      Y_ARRAY = [20, 32, 90, 54, 48, 90]
      # Initialize the SpriteStack
      # @param viewport [Viewport]
      def initialize(viewport)
        super(viewport, *spritestack_coordinates)
        @stars = Array.new(6) { |i| add_sprite(X_ARRAY[i], Y_ARRAY[i], NO_INITIAL_IMAGE, type: Star_Animation) }
        @anim_counter = 0
      end

      # The SpriteStack initial coordinates
      # @return [Array<Integer>] the coordinates
      def spritestack_coordinates
        return 25, 125
      end

      # Update each star animation
      def update
        @stars.each_with_index do |star, index|
          star.update if @anim_counter > (index * 10)
        end
        @anim_counter += 1
      end

      # Reset the star animation to replay it when needed
      def reset
        return if @anim_counter == 0

        @anim_counter = 0
        @stars.each do |star| 
          #star.sx = 0
          star.finished = false
        end
      end
    end
  end
end
