module UI
  module Quest
    class CategoryDisplay < SpriteStack
      TEXT_CATEGORY = {
        primary: [:ext_text, 9006, 5],
        secondary: [:ext_text, 9006, 6],
        finished: [:ext_text, 9006, 7]
      }
      # Initialize the QuestButton component
      # @param viewport [Viewport]
      # @param category [Symbol] the initial category the player spawns in (here for future compability)
      def initialize(viewport, category)
        super(viewport, *coordinates)
        @viewport = viewport
        @category = category
        create_frame
        create_category_text
        create_arrow_frames
      end

      # Update the category text depending on the new category
      # @param category [Symbol]
      def update_category_text(category)
        @category = category
        @text.text = send(*TEXT_CATEGORY[@category])
        update_arrows
      end

      private

      def create_frame
        @frame = add_sprite(0, 0, "quest/win_cat")
      end

      def create_category_text
        @text = add_text(*text_coordinates, 88, 0, send(*TEXT_CATEGORY[@category]), 1, color: 10)
      end

      def create_arrow_frames
        @left_arrow = add_sprite(-10, 6, "quest/arrow_frame_l")
        @right_arrow = add_sprite(@frame.width + 2, 6, "quest/arrow_frame_r")
        update_arrows
      end

      def coordinates
        return 28, 4
      end

      def text_coordinates
        return 5, 13
      end

      # Update the states of the arrows according to current category
      def update_arrows
        case @category
        when :primary
          @left_arrow.visible = false
        when :secondary
          @left_arrow.visible = true
          @right_arrow.visible = true
        when :finished
          @right_arrow.visible = false
        end
      end
    end
  end
end
