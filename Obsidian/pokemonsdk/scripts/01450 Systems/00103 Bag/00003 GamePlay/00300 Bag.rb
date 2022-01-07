module GamePlay
  # Scene responsive of displaying the bag
  #
  # The bag has various modes :
  #   - :menu : when opened from the menu
  #   - :battle : when opened from the battle
  #   - :berry : when opened to plant berry
  #   - :hold : when opened to give an item to a Pokemon
  #   - :shop : when opened to sell item
  #   - :map : when an event request an item
  class Bag < BaseCleanUpdate::FrameBalanced
    include BagMixin
    # List of pocket name
    POCKET_NAMES = [
      nil.to_s,
      [:text_get, 15, 4], # Items
      [:text_get, 15, 1], # Pokeball
      [:text_get, 15, 5], # CT / CS
      [:text_get, 15, 3], # Berries
      [:text_get, 15, 8], # Key Items
      [:text_get, 15, 0], # Medicine
      [:ext_text, 9000, 150], # Letters
      [:ext_text, 9000, 151] # Favorites
    ]
    # List of pocket index the player can see according to the modes
    POCKETS_PER_MODE = {
      menu: [1, 2, 6, 3, 5, 4, 8],
      battle: [2, 6, 4],
      berry: [4],
      hold: [1, 2, 6, 4],
      shop: [1, 2, 6, 3, 4]
    }
    POCKETS_PER_MODE.default = POCKETS_PER_MODE[:menu]
    # ID of the favorite pocket (shortcut)
    FAVORITE_POCKET_ID = 8
    # Create a new Bag Scene
    # @param mode [Symbol] mode of the bag scene allowing to choose the pocket to show
    def initialize(mode = :menu)
      super()
      @return_data = -1
      @mode = mode
      load_pockets
      @socket_index = $user_data.dig(:psdk_bag, :socket_index, mode) || $bag.last_socket || 0
      @socket_index = @socket_index.clamp(0, @last_socket_index = @pocket_indexes.size - 1)
      load_item_list
      @index = $user_data.dig(:psdk_bag, :index, mode) || $bag.last_index || 0
      @index = @index.clamp(0, @last_index)
      @compact_mode = $user_data.dig(:psdk_bag, :compact_mode) || :enabled
      @searching = false
      Mouse.wheel = 0
    end

    private

    # Ensure we store all the information for the next time we open the bag
    def main_end
      super
      $bag.last_socket =
        (($user_data[:psdk_bag] ||= {})[:socket_index] ||= {})[@mode] = @socket_index
      $bag.last_index =
        ($user_data[:psdk_bag][:index] ||= {})[@mode] = @index
      $user_data[:psdk_bag][:compact_mode] = @compact_mode
    end

    # Load the list of item (ids) for the current pocket
    def load_item_list
      if pocket_id == FAVORITE_POCKET_ID
        @item_list = $bag.get_order(:favorites)
      else
        @item_list = $bag.get_order(pocket_id)
      end
      @index = 0
      @last_index = @item_list.size
    end
    alias reload_item_list load_item_list

    # Load the pockets index & names
    def load_pockets
      @pocket_indexes = POCKETS_PER_MODE[@mode]
      @pocket_names = @pocket_indexes.collect { |id| get_text(POCKET_NAMES[id]) }
    end

    # Get the actual pocket ID
    def pocket_id
      @pocket_indexes[@socket_index]
    end

    # Change the pocket
    # @param new_index [Integer] new pocket index
    def change_pocket(new_index)
      @socket_index = new_index
      @pocket_ui.index = new_index
      update_pocket_name
      reload_item_list
      update_scroll_bar
      update_item_button_list
      update_info
    end
  end
end

GamePlay.bag_class = GamePlay::Bag
