module GamePlay
  class Pokemon_Shop < Shop
    # Tell if the mouse over is enabled
    MOUSE_OVER_ENABLED = false

    private

    # Part where we try to update the list index if the mouse wheel change
    def update_mouse_index
      delta = -Mouse.wheel
      update_mouse_delta_index(delta) unless @list_item.size == 1
      Mouse.wheel = 0
      return false
    end
  end
end
