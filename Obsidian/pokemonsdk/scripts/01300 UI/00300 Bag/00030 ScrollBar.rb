module UI
  module Bag
    class ScrollBar < SpriteStack
      # @return [Integer] current index of the scrollbar
      attr_reader :index
      # @return [Integer] number of possible indexes
      attr_reader :max_index
      # Number of pixel the scrollbar use to move the button
      HEIGHT = 160
      # Base Y for the scrollbar
      BASE_Y = 36
      # BASE X for the scrollbar
      BASE_X = 309
      # Background of the scrollbar
      BACKGROUND = 'bag/scroll'
      # Image of the button
      BUTTON = 'bag/button_scroll'
      # Create a new scrollbar
      # @param viewport [Viewport]
      def initialize(viewport)
        super(viewport, BASE_X, BASE_Y)
        @index = 0
        @max_index = 1
        init_sprite
      end

      # Set the current index of the scrollbar
      # @param value [Integer] the new index
      def index=(value)
        @index = value.clamp(0, @max_index)
        @button.y = BASE_Y + HEIGHT * @index / @max_index
      end

      # Set the number of possible index
      # @param value [Integer] the new max index
      def max_index=(value)
        @max_index = value <= 0 ? 1 : value
        self.index = 0
      end

      private

      def init_sprite
        create_background
        @button = create_button
      end

      # Create the background
      def create_background
        add_background(BACKGROUND).set_z(1)
      end

      # Create the button
      # @return [Sprite]
      def create_button
        add_sprite(-1, 0, BUTTON).set_z(2)
      end
    end
  end
end
