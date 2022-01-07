module GamePlay
  class Shop
    # Update the inputs every frame
    def update_inputs
      unless @force_close
        return false if @animation

        return update_ctrl_button &&
               update_list_input
      end
    end

    private

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
        update_item_desc
        @scroll_bar.index = @index
      end
      return false
    end

    # Update CTRL button (A/B)
    def update_ctrl_button
      if Input.trigger?(:B) # Quit
        action_b
      elsif Input.trigger?(:A) # Action
        action_a
      else 
        return true
      end
      return false
    end

    # Action related to B button
    def action_b
      play_cancel_se
      $game_variables[::Yuki::Var::TMP1] = how_do_the_player_leave
      @running = false
    end

    # Action related to A button
    def action_a
      if PFM.game_state.money >= @list_price[@index]
        launch_buy_sequence
      else
        display_message(parse_text(11, 24))
      end
    end
  end
end
