module GamePlay
  class Bag
    # Constant that list all the choice method called when the player press A
    # depending on the bag mode
    CHOICE_MODE_A = {
      menu: :choice_a_menu,
      berry: :choice_a_berry,
      hold: :choice_a_hold,
      shop: :choice_a_shop,
      map: :choice_a_map,
      battle: :choice_a_battle
    }
    CHOICE_MODE_A.default = CHOICE_MODE_A[:menu]
    # Constant that list all the choice called when the player press Y
    # depending on the bag mode
    CHOICE_MODE_Y = {
      menu: :choice_y_menu
    }
    CHOICE_MODE_Y.default = CHOICE_MODE_Y[:menu]
    # Index of the search choice when pressing Y
    SEARCH_CHOICE_INDEX = 3

    private

    # Choice shown when you press A on menu mode
    def choice_a_menu
      item_id = @item_list[@index]
      return action_b if item_id.nil?
      return play_buzzer_se if item_id == 0
      play_decision_se
      show_shadow_frame
      # Prepare the choice info
      # Use option
      map_usable = proc { !GameData::Item[item_id].map_usable }
      # Give option
      giv_check = proc { $pokemon_party.pokemon_alive <= 0 || !GameData::Item[item_id].holdable }
      # Unregister / register
      if $bag.shortcuts.include?(item_id)
        reg_id = 14
        reg_meth = method(:unregister_item)
      else
        reg_id = 2
        reg_meth = method(:register_item)
        reg_check = map_usable
      end
      # Throw option
      thr_check = proc { !GameData::Item[item_id].limited }
      # Create the choice
      choices = PFM::Choice_Helper.new(Yuki::ChoiceWindow::But, true, 999)
      choices.register_choice(text_get(22, 0), on_validate: method(:use_item), disable_detect: map_usable)
             .register_choice(text_get(22, 3), on_validate: method(:give_item), disable_detect: giv_check)
             .register_choice(text_get(22, reg_id), on_validate: reg_meth, disable_detect: reg_check)
             .register_choice(text_get(22, 1), on_validate: method(:throw_item), disable_detect: thr_check)
             .register_choice(text_get(22, 7))
      # Show selection : item_name
      @base_ui.show_win_text(parse_text(22, 35, PFM::Text::ITEM2[0] => GameData::Item[item_id].exact_name))
      # Process the actual choice
      y = 200 - 16 * choices.size
      choices.display_choice(@viewport, 306, y, nil, on_update: method(:update_graphics), align_right: true)
      @base_ui.hide_win_text
      hide_shadow_frame
    end

    # Choice shown when you press Y on menu mode
    def choice_y_menu
      play_decision_se
      show_shadow_frame
      @base_ui.show_win_text(text_get(22, 79))
      choices = PFM::Choice_Helper.new(Yuki::ChoiceWindow::But, true, 999)
      choices.register_choice(text_get(22, 81), on_validate: method(:sort_name))
             .register_choice(text_get(22, 84), on_validate: method(:sort_number))
             .register_choice(ext_text(9000, 151), on_validate: method(:sort_favorites))
             .register_choice(text_get(33, 130), on_validate: method(:search_item))
             .register_choice(text_get(22, 7))
      # Process the actual choice
      y = 200 - 16 * choices.size
      choice = choices.display_choice(@viewport, 306, y, nil, on_update: method(:update_graphics), align_right: true)
      @base_ui.hide_win_text if choice != SEARCH_CHOICE_INDEX
      hide_shadow_frame
    end

    # Choice when the player press A in berry/map mode
    def choice_a_berry
      play_decision_se
      @running = false
      @return_data = @item_list[@index] || -1
    end
    alias choice_a_map choice_a_berry

    # Choice when the player press A in Hold mode
    def choice_a_hold
      item_id = @item_list[@index]
      return action_b if item_id.nil?
      return play_buzzer_se if item_id == 0 || !GameData::Item[item_id].holdable

      play_decision_se
      @running = false
      @return_data = @item_list[@index]
    end

    # Choice when the player press A in shop mode
    def choice_a_shop
      sell_item
    end

    # Choice when the player press A in battle
    def choice_a_battle
      use_item_in_battle
    end
  end
end
