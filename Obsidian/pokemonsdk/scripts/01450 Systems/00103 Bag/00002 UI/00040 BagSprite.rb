module UI
  module Bag
    # Class that show the bag sprite in the Bag UI
    class BagSprite < SpriteSheet
      # @return [Integer] the current socket index
      attr_reader :index
      # Array translating real pocket id to sprite piece
      POCKET_TRANSLATION = [0, 0, 1, 3, 5, 4, 2, 6, 7]
      # Coordinates of the bag
      COORDINATES = [71, 103]
      # Create a new Bah Sprite
      # @param viewport [Viewport]
      # @param pocket_indexes [Array<Integer>] each shown pocket by the UI
      def initialize(viewport, pocket_indexes)
        super(viewport, 1, 8)
        @index = 0
        @pocket_indexes = pocket_indexes
        init_sprite
      end

      # Set the current socket index
      def index=(value)
        @index = value.clamp(0, 7)
        self.sy = POCKET_TRANSLATION[@pocket_indexes[@index]]
      end

      # Start the animation between socket
      def animate(target_index)
        @target_index = target_index.clamp(0, 7)
        @counter = 0
      end

      # Update the animation
      def update
        return if done?
        if @counter < 2
          self.x = COORDINATES.first - @counter
        elsif @counter < 4
          self.x = COORDINATES.first - 4 + @counter
        elsif @counter == 4
          self.index = @target_index
        elsif @counter < 6
          self.x = COORDINATES.first + @counter - 4
        else
          self.x = COORDINATES.first + 8 - @counter
        end
        @counter += 1
      end

      # Test if the animation is done
      # @return [Boolean]
      def done?
        @counter >= 8
      end

      # Test if the animation is at the middle of its progression
      # @return [Boolean]
      def mid?
        @counter == 4
      end

      private

      def init_sprite
        set_bitmap(bag_filename, :interface)
        set_position(*COORDINATES)
        set_origin(width / 2, height / 2)
        self.z = 1
      end

      # Return the bag filename
      # @return [String]
      def bag_filename
        $trainer.playing_girl ? 'bag/bag_girl' : 'bag/bag'
      end
    end
  end
end
