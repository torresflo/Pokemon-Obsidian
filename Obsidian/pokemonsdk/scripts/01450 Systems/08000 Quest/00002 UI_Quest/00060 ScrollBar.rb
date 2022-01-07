module UI
  module Quest
    class ScrollBar < SpriteStack
      # @return [Integer] current index of the scrollbar
      attr_reader :index
      # @return [Integer] number of possible indexes
      attr_reader :max_index

      # Number of pixel the scrollbar use to move the button
      HEIGHT = 153
      # Base Y for the scrollbar
      BASE_Y = 38
      # Create a new scrollbar
      # @param viewport [Viewport]
      def initialize(viewport)
        super(viewport, 310, BASE_Y)
        add_background('quest/scroll')
        @button = add_sprite(-1, 0, 'quest/button_scroll')
        @index = 0
        @max_index = 1
      end

      # Set the current index of the scrollbar
      # @param value [Integer] the new index
      def index=(value)
        @index = value.clamp(0, @max_index)
        @button.y = ((BASE_Y + 4) + HEIGHT * @index / @max_index)
      end

      # Set the number of possible index
      # @param value [Integer] the new max index
      def max_index=(value)
        @max_index = value <= 0 ? 1 : value
        self.index = 0
      end
    end
  end
end
