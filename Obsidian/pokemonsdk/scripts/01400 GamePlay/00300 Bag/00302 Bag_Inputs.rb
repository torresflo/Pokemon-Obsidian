module GamePlay
  class Bag
    def update_inputs
      return false if @animation
      return update_search &&
             update_ctrl_button &&
             update_socket_input &&
             update_list_input
    end

    private

    # Input update related to the socket index
    # @return [Boolean] if other update can be done
    def update_socket_input
      return true unless index_changed(:@socket_index, :LEFT, :RIGHT, @last_socket_index)
      play_cursor_se
      @bag_sprite.visible ? animate_pocket_change(@socket_index) : change_pocket(@socket_index)
      return false
    end

    # Input update related to the item list
    # @return [Boolean] if another update can be done
    def update_list_input
      index = @index
      return true unless index_changed(:@index, :UP, :DOWN, @last_index)
      play_cursor_se
      delta = @index - index
      if delta.abs == 1
        animate_list_index_change(delta)
      else
        update_item_button_list
        update_info
        @scroll_bar.index = @index
      end
      return false
    end

    # Update the search input
    # @return [Boolean] if the other action can be performed
    def update_search
      return true unless @searching
      if Input.trigger?(:A)
        @searching = false
        @search_bar.visible = false
        @base_ui.hide_win_text
        @base_ui.ctrl.last.visible = true
        Input::Keys[:A].clear.concat(@saved_keys)
      else
        @search_bar.update
        update_list_input
      end
      return false
    end

    # Update CTRL button (A/B/X/Y)
    def update_ctrl_button
      if Input.trigger?(:B) # Quit
        action_b
      elsif Input.trigger?(:A) # Action
        action_a
      elsif Input.trigger?(:X) # Info
        action_x
      elsif Input.trigger?(:Y) # Sort
        action_y
      else
        return true
      end
      return false
    end

    # Action related to B button
    def action_b
      play_cancel_se
      @running = false
    end

    # Action related to A button
    def action_a
      send(CHOICE_MODE_A[@mode])
    end

    # Action related to X button
    def action_x
      play_decision_se
      @compact_mode = (@compact_mode == :enabled ? :disabled : :enabled)
      update_info_visibility
      update_info
    end

    # Action related to Y button
    def action_y
      send(CHOICE_MODE_Y[@mode])
    end
  end
end
