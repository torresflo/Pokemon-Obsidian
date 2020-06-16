module GamePlay
  class Shop
    private

    # Start the move up/down animation
    # @param delta [Integer] number of time to move up/down
    def animate_list_index_change(delta)
      count = delta.abs
      max = delta.abs
      @animation = proc do
        @item_list.update
        # Wait until the list finished its animation
        next unless @item_list.done?
        next @animation = nil if count <= 0
        # Update the index
        @index += delta / max if max > 1
        # Set the list animation
        delta > 0 ? @item_list.move_up : @item_list.move_down
        # Update the scrollbar
        @scroll_bar.index = @index
        update_item_desc
        # Update the animation counter
        count -= 1
      end
    end
  end
end
