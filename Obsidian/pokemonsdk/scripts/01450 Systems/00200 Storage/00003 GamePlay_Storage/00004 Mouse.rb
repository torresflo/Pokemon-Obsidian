module GamePlay
  class PokemonStorage
    # Update the mouse action
    def update_mouse(moved)
      if Mouse.wheel != 0
        mouse_wheel_action
      elsif Mouse.trigger?(:LEFT)
        mouse_left_action
      elsif Mouse.trigger?(:RIGHT)
        mouse_right_action
      elsif moved
        mouse_moved_action
      else
        update_mouse_ctrl_buttons(@base_ui.ctrl, @mouse_actions[@base_ui.mode])
      end
      return false
    end

    private

    # Action when clicking left
    def mouse_left_action
      if @composition.hovering_left_arrow? || @composition.hovering_right_arrow?
        change_box(@composition.hovering_right_arrow?)
      elsif @composition.hovering_box_option?
        action_a
      elsif @mode_handler.mode == :battle && @composition.hovering_party_left_arrow?
        action_l
      elsif @mode_handler.mode == :battle && @composition.hovering_party_right_arrow?
        action_r
      elsif @composition.hovering_pokemon_sprite?
        action_a
      elsif @composition.hovering_mode_indicator?
        action_r2
      elsif @composition.hovering_selection_mode_indicator?
        action_l2
      else
        update_mouse_ctrl_buttons(@base_ui.ctrl, @mouse_actions[@base_ui.mode])
      end
    end

    # Action when clicking right
    def mouse_right_action
      action_x
    end

    # Action when the mouse moved
    def mouse_moved_action
      last_index = @cursor.index
      @composition.hovering_pokemon_sprite?
      update_summary if last_index != @cursor.index
    end

    # Action when a Mouse.wheel event appear
    def mouse_wheel_action
      @storage.current_box = (@storage.current_box + (Mouse.wheel > 0 ? -1 : 1)) % @storage.max_box
      refresh
      Mouse.wheel = 0
    end
  end
end
