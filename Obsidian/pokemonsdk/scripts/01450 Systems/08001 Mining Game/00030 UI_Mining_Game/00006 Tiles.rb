module UI
  module MiningGame
    # Class that describes the Tiles sprite
    class Tiles < SpriteSheet
      # @return [Integer] state of the tile
      attr_accessor :state

      # Create the Tiles
      # @param viewport [Viewport]
      # @param state [Integer] the state the image is initialized on (between 0 and 6)
      def initialize(viewport, state)
        super(viewport, possible_state_number, number_of_y_images)
        @state = state
        update_sx
      end

      # Update the state of the sheet
      def update_sx
        self.sx = @state
      end

      # Lower the state and update the image in consequence
      # @param reason [Symbol] the reason of lowering
      def lower_state(reason)
        if %i[pickaxe mace].include? reason
          @state -= 2
        elsif reason == :side_pickaxe
          @state -= 1
        elsif reason == :side_dynamite
          @state -= 4
        elsif reason == :dynamite
          @state -= 6
        end
        @state = 0 if @state < 0
        update_sx
      end

      private

      # The number of column of the sheet
      # @return [Integer]
      def number_of_y_images
        return 1
      end

      # The number of possible state of a tile
      # @return [Integer]
      def possible_state_number
        return 7
      end
    end
  end
end
