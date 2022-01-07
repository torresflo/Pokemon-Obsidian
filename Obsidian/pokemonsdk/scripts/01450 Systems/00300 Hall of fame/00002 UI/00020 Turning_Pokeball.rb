module UI
  module Hall_of_Fame
    # Class that define the turning Pokeball
    class Turning_Pokeball < Sprite
      # Initialize the Sprite
      # @param viewport [Viewport]
      def initialize(viewport)
        super(viewport)
        set_bitmap(bitmap_filename, :interface)
        set_origin(*new_origin)
        self.opacity = 0
      end

      # The base filename of the image
      # @return [String]
      def bitmap_filename
        return 'hall_of_fame/ball'
      end

      # The new origin of the Sprite
      # @return [Array<Integer>]
      def new_origin
        return 228, 228
      end

      # Update the angle of the ball
      def update_anim
        self.angle += 1
        self.angle = 0 if angle == 360
      end
    end
  end
end
