module UI
  module Bag
    # Class that shows a search bar
    class SearchBar < SpriteStack
      # @return [UI::UserInput] the search input object
      attr_reader :search_input
      # Create a new SearchBar
      # @param viewport [Viewport]
      def initialize(viewport)
        super(viewport, 3, 220)
        add_background('bag/search_bar')
        @search_input = add_text(29, 1, 0, 13, nil.to_s, type: UserInput)
        add_sprite(216, 1, NO_INITIAL_IMAGE, Input::Keyboard::Enter, type: KeyShortcut)
        self.z = 506 # 500 + 6 since ctrl button has more priority
      end

      # Update the search bar
      def update
        @search_input.update
      end
    end
  end
end
