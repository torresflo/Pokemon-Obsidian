module GamePlay
  class Shop
    # Tell if the mouse over is enabled
    MOUSE_OVER_ENABLED = false
    # Update the mouse interactions
    # @param moved [Boolean] if the mouse moved durring the frame
    # @return [Boolean] if the thing after can update
    def update_mouse(moved)
      unless @force_close
        return update_mouse_index if Mouse.wheel != 0
        return false if moved && update_mouse_list
      else 
        @running = false
      end
    end

    private

    # Part where we try to update the list index
    def update_mouse_list
      return false unless MOUSE_OVER_ENABLED # Currently not practical at all so disabled
      delta = @item_list.mouse_delta_index
      return true if delta == 0 || @last_mouse_delta == delta
      update_mouse_delta_index(delta)
      return false
    ensure
      @last_mouse_delta = delta
    end

    # Part where we try to update the list index if the mouse wheel change
    def update_mouse_index
      delta = -Mouse.wheel
      update_mouse_delta_index(delta) unless @list_item.size == 1
      Mouse.wheel = 0
      return false
    end

    # Update the list index according to a delta with mouse interaction
    # @param delta [Integer] number of index we want to add / remove
    def update_mouse_delta_index(delta)
      new_index = (@index + delta).clamp(0, @scroll_bar.max_index)
      delta = new_index - @index
      return if delta == 0
      if delta.abs < 5
        @index = new_index if delta.abs == 1
        animate_list_index_change(delta)
      else
        @index = new_index
        update_item_button_list
        @scroll_bar.index = @index
      end
    end
  end
end
