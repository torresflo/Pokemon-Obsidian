module UI
  module Quest
    class ObjectiveList < SpriteStack
      # Initialize the ObjectiveList component
      # @param viewport [Viewport]
      def initialize(viewport)
        super(viewport, *coordinates)
        @max_index = 0
        @index_text = 0
        create_text
        create_arrows
      end

      # Update the text depending on the forwarded data
      # @param data [Array<Array<String, Boolean>>]
      def update_text(data)
        @text.y = y
        @index_text = 0
        text = ''
        # Reducing by 4 to get an index and to account for the first 4 items
        # Useful to make sure the player can't scroll until he sees only one objective
        @max_index = data.size - 4
        @max_index = 0 if @max_index < 0
        data.each_with_index do |arr, i|
          color = arr[1] ? "\c[13]" : "\c[12]"
          text += arr[0]
          text += "\n" if i < data.size - 1
        end
        @text.multiline_text = text
        update_arrows
      end

      # Scroll the text in the right direction if there's more than 4 objectives
      # @param direction [Symbol] :UP or :DOWN
      def scroll_text(direction)
        return if @max_index <= 4
        return if @index_text == 0 && direction == :UP
        return if @index_text == @max_index && direction == :DOWN

        coord = direction == :UP ? 16 : -16
        @index_text += direction == :UP ? -1 : 1
        @text.y = @text.y + coord
        update_arrows
      end

      private

      def create_text
        @text = add_text(0, 0, 272, 16, '')
      end

      def create_arrows
        @arrow_up = push_sprite(Sprite.new(viewport))
        @arrow_up.set_bitmap('quest/arrow_choice', :interface)
        @arrow_up.angle = 90
        @arrow_up.set_origin(@arrow_up.width, 0)
        @arrow_up.set_position(257, 3)
        @arrow_up.visible = false
        @arrow_down = push_sprite(Sprite.new(viewport))
        @arrow_down.set_bitmap('quest/arrow_choice', :interface)
        @arrow_down.angle = -90
        @arrow_down.set_origin(0, @arrow_down.height)
        @arrow_down.set_position(257, 59)
        @arrow_down.visible = false
      end

      # Update the text arrows depending on the current position of the text
      def update_arrows
        return @arrow_up.opacity = @arrow_down.opacity = 0 if @max_index <= 3

        @arrow_up.opacity = @index_text == 0 ? 0 : 255
        @arrow_down.opacity = @index_text == @max_index ? 0 : 255
      end

      def coordinates
        return 0, 0
      end
    end
  end
end
