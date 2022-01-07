module GamePlay
  class Pokemon_Shop < Shop

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

    # Action related to A button
    def action_a
      if PFM.game_state.money >= @list_item[@index][:price]
        buy_pokemon
      else
        display_message(parse_text(11, 24))
      end
    end
  end
end
