module GamePlay
  class Bag
    private

    # Start the Pocket change animation
    # @param new_index [Integer] the new pocket index
    def animate_pocket_change(new_index)
      @bag_sprite.animate(new_index)
      @animation = proc do
        @bag_sprite.update
        next(@animation = nil) if @bag_sprite.done?
        next unless @bag_sprite.mid?
        # Set the new socket info on all UI
        change_pocket(new_index)
      end
    end

    # Start the move up/down animation
    # @param delta [Integer] number of time to move up/down
    def animate_list_index_change(delta)
      count = delta.abs
      max = delta.abs
      @animation = proc do
        @item_button_list.update
        # Wait until the list finished its animation
        next unless @item_button_list.done?
        next @animation = nil if count <= 0
        # Update the index
        @index += delta / max if max > 1
        # Set the list animation
        delta > 0 ? @item_button_list.move_up : @item_button_list.move_down
        # Update the scrollbar
        @scroll_bar.index = @index
        update_info
        # Update the animation counter
        count -= 1
      end
    end
  end
end
