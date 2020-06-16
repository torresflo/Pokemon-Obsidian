module UI
  module Bag
    # Class that shows a search bar
    class SearchBar < SpriteStack
      # Coordinate of the search bar
      COORDINATES = 3, 220
      # @return [UI::UserInput] the search input object
      attr_reader :search_input
      # Create a new SearchBar
      # @param viewport [Viewport]
      def initialize(viewport)
        super(viewport, *COORDINATES)
        init_sprite
        self.z = 506 # 500 + 6 since ctrl button has more priority
      end

      # Update the search bar
      def update
        @search_input.update
      end

      private

      def init_sprite
        create_background
        @search_input = create_user_input
        create_shortcut_image
      end

      def create_background
        add_background('bag/search_bar')
      end

      # @return [UserInput]
      def create_user_input
        add_text(29, 1, 0, 13, nil.to_s, type: UserInput)
      end

      # @return [KeyShortcut]
      def create_shortcut_image
        add_sprite(216, 1, NO_INITIAL_IMAGE, Input::Keyboard::Enter, type: KeyShortcut)
      end
    end
  end
end
