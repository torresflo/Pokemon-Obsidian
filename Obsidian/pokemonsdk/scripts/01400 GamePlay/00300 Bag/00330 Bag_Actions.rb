module GamePlay
  class Bag
    include Util::Item

    private

    # When player wants to use the item
    def use_item
      item_id = @item_list[index = @index]
      return play_buzzer_se unless $bag.contain_item?(item_id)

      util_item_useitem(item_id) do
        @base_ui.hide_win_text
        hide_shadow_frame
        update_bag_ui_after_action(index)
      end
    end

    # When player wants to use the item
    def use_item_in_battle
      item_id = @item_list[index = @index]
      return action_b if item_id == nil
      return play_buzzer_se unless GameData::Item[item_id].battle_usable

      play_decision_se
      util_item_useitem(item_id)
      update_bag_ui_after_action(index)
    end

    # Make sure the bag UI gets update after an action
    # @param index [Integer] previous index value
    def update_bag_ui_after_action(index)
      # Adjust the bag info
      load_item_list
      @index = index.clamp(0, @last_index)
      # Reload the graphics
      update_item_button_list
      update_info
    end

    # When the player wants to give an item
    def give_item
      item_id = @item_list[index = @index]
      return play_buzzer_se unless $bag.contain_item?(item_id)

      call_scene(Party_Menu, $actors, :hold, item_id) do
        @base_ui.hide_win_text
        hide_shadow_frame
        update_bag_ui_after_action(index)
      end
    end

    # When the player wants to register an item
    def register_item
      item_id = @item_list[@index]
      validate_meth = method(:set_shortcut)
      last_proc = proc do
        if (index = $bag.shortcuts.index(item_id)) && index < 4
          $bag.shortcuts[index] = 0
        end
        $bag.shortcuts << item_id
      end
      choices = PFM::Choice_Helper.new(Yuki::ChoiceWindow::But, true, 999)
      choices.register_choice('↑', item_id, 0, on_validate: validate_meth)
             .register_choice('←', item_id, 1, on_validate: validate_meth)
             .register_choice('↓', item_id, 2, on_validate: validate_meth)
             .register_choice('→', item_id, 3, on_validate: validate_meth)
             .register_choice(ext_text(9000, 151), on_validate: last_proc)
      y = 200 - 16 * choices.size
      choices.display_choice(@viewport, 306, y, nil, on_update: method(:update_graphics), align_right: true)
      update_bag_ui_after_action(@index)
    end

    # Process method that set the new shortcut
    # @param item_id [Integer] ID of the item to register
    # @param index [Integer] index of the shortcut to change
    def set_shortcut(item_id, index)
      if (sh_index = $bag.shortcuts.index(item_id)) && sh_index > 3
        $bag.shortcuts[sh_index] = nil
      end
      $bag.shortcuts[index] = item_id
      $bag.shortcuts.compact!
    end

    # When the player wants to unregister an item
    def unregister_item
      item_id = @item_list[@index]
      sh_index = $bag.shortcuts.index(item_id)
      if sh_index > 3
        $bag.shortcuts[sh_index] = nil
      else
        $bag.shortcuts[sh_index] = 0
      end
      $bag.shortcuts.compact!
      update_bag_ui_after_action(@index)
    end

    # When the player wants to throw an item
    def throw_item
      item_id = @item_list[index = @index]
      return play_buzzer_se unless $bag.contain_item?(item_id)

      $game_temp.num_input_variable_id = Yuki::Var::EnteredNumber
      $game_temp.num_input_digits_max = $bag.item_quantity(item_id).to_s.size
      $game_temp.num_input_start = $bag.item_quantity(item_id)
      PFM::Text.set_item_name(GameData::Item[item_id].exact_name)
      display_message(parse_text(22, 38))
      value = $game_variables[Yuki::Var::EnteredNumber]
      if value > 0
        display_message(parse_text(22, 39, PFM::Text::NUM3[1] => value.to_s))
        $bag.remove_item(item_id, value)
        update_bag_ui_after_action(index)
      end
      PFM::Text.reset_variables
    end

    # When the player wants to sort the item by name
    def sort_name
      if pocket_id == FAVORITE_POCKET_ID
        shortcuts = $bag.shortcuts[0, 4]
        $bag.shortcuts.shift(4)
        $bag.sort_alpha(:favorites)
        $bag.shortcuts.unshift(*shortcuts)
      else
        $bag.sort_alpha(pocket_id)
      end
      update_bag_ui_after_action(@index)
      display_message(text_get(22, 69))
    end

    # When the player wants to sort the item by number
    def sort_number
      if pocket_id == FAVORITE_POCKET_ID
        shortcuts = $bag.shortcuts[0, 4]
        $bag.shortcuts.shift(4)
        $bag.reset_order(:favorites)
        $bag.shortcuts.unshift(*shortcuts)
      else
        $bag.reset_order(pocket_id)
      end
      update_bag_ui_after_action(@index)
      display_message(text_get(22, 86))
    end

    # When the player wants to sort by favorites
    def sort_favorites
      return if pocket_id == FAVORITE_POCKET_ID
      fav = $bag.get_order(:favorites)
      ori_list = @item_list.clone
      @item_list.sort! do |item_id_a, item_id_b|
        (fav.index(item_id_a) || (ori_list.index(item_id_a) + fav.size)) <=>
          (fav.index(item_id_b) || (ori_list.index(item_id_b) + fav.size))
      end
      update_bag_ui_after_action(@index)
    end

    # When the player wants to search an item
    def search_item
      @base_ui.show_win_text('')
      @base_ui.ctrl.last.visible = false
      @search_bar.visible = true
      sort_sprites
      @searching = ''
      @item_ids ||= 1..GameData::Item::LAST_ID
      @saved_keys = Input::Keys[:A].clone
      Input::Keys[:A].clear << Input::Keyboard::Enter
      @pocket_name.text = ext_text(9000, 160)
      @item_list = []
      @last_index = 0
      update_search_info
    end

    # When the search gets a new character
    # @param _full_text [String] current text in search
    # @param char [String] added char
    def search_add(_full_text, char)
      # First attempt
      gdi = GameData::Item
      searching = Regexp.new(@searching + char, true)
      results = @item_ids.select { |id| gdi[id].exact_name =~ searching && $bag.contain_item?(id) }
      if results.empty?
        # Try with other . instead
        char = '.'
        searching = Regexp.new(@searching + char, true)
        results = @item_ids.select { |id| gdi[id].exact_name =~ searching && $bag.contain_item?(id) }
      end
      @item_list = results
      @last_index = results.size
      update_search_info
      @searching << char
    rescue RegexpError
      @searching << char
    end

    # When the search removes a character
    # @param _full_text [String] current text in search
    # @param _char [String] removed char
    def search_rem(_full_text, _char)
      @searching.chop!
      gdi = GameData::Item
      searching = Regexp.new(@searching, true)
      results = @item_ids.select { |id| gdi[id].exact_name =~ searching && $bag.contain_item?(id) }
      @item_list = results
      @last_index = results.size
      update_search_info
    rescue RegexpError
      0
    end

    # Update the search info
    def update_search_info
      update_item_button_list
      update_info
      update_scroll_bar
    end

    # When the player wants to sell an item
    def sell_item
      play_decision_se
      item_id = @item_list[@index]
      return action_b if item_id == nil
      price = GameData::Item[item_id].price / 2
      PFM::Text.set_item_name(GameData::Item[item_id].exact_name)
      if price > 0
        $game_temp.num_input_variable_id = ::Yuki::Var::EnteredNumber
        $game_temp.num_input_digits_max = $bag.item_quantity(item_id).to_s.size
        $game_temp.num_input_start = $bag.item_quantity(item_id)
        $game_temp.shop_calling = price
        display_message(parse_text(22, 170))
        $game_temp.shop_calling = false
        value = $game_variables[::Yuki::Var::EnteredNumber]
        return unless value > 0
        c = display_message(parse_text(22, 171, NUM7R => (value * price).to_s), 1, text_get(11, 27), text_get(11, 28))
        return if c != 0
        $bag.remove_item(item_id, value)
        $pokemon_party.add_money(value * price)
        update_bag_ui_after_action(@index)
        display_message(parse_text(22, 172, NUM7R => (value * price).to_s))
      else
        ::PFM::Text.set_plural(false)
        display_message(parse_text(22, 174)) # You can't sell this item
      end
    ensure
      PFM::Text.reset_variables
    end
  end
end
