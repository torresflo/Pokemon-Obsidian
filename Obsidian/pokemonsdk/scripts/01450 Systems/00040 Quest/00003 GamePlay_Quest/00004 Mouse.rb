module GamePlay
  class QuestUI
    # List of action the mouse can perform with ctrl button
    ACTIONS = %i[action_a action_x action_y action_b]
    # Update the mouse interactions
    # @param moved [Boolean] if the mouse moved durring the frame
    # @return [Boolean] if the thing after can update
    def update_mouse(moved)
      unless deployed?
        return update_mouse_index if Mouse.wheel != 0
        return false if moved
      end
      return update_ctrl_button_mouse
    end

    private

    # Part where we update the mouse ctrl button
    def update_ctrl_button_mouse
      update_mouse_ctrl_buttons(@base_ui.ctrl, ACTIONS)
      return false
    end

    # Part where we try to update the list index if the mouse wheel change
    def update_mouse_index
      delta = -Mouse.wheel
      update_mouse_delta_index(delta)
      Mouse.wheel = 0
      return false
    end

    # Update the list index according to a delta with mouse interaction
    # @param delta [Integer] number of index we want to add / remove
    def update_mouse_delta_index(delta)
      new_index = (@composition.index + delta).clamp(0, @composition.scrollbar.max_index)
      delta = new_index - @composition.index
      return if delta == 0

      direction = delta < 0 ? :UP : :DOWN
      timing = delta.abs < 5 ? :medium : :fast
      action_scroll(direction, timing)
    end
  end
end
