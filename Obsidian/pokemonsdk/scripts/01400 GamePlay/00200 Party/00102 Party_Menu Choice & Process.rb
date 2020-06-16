module GamePlay
  class Party_Menu
    # List of all choice method to call according to the current mode
    CHOICE_METHODS = {
      menu: :show_menu_mode_choice,
      choice: :show_choice_mode_choice,
      battle: :show_battle_mode_choice,
      item: :show_item_mode_choice,
      hold: :show_hold_mode_choice,
      select: :show_select_mode_choice
    }
    # Show the proper choice
    def show_choice
      send(*(CHOICE_METHODS[@mode] || :show_map_mode_choice))
    end

    # Return the skill color
    # @return [Integer]
    def skill_color
      return 1
    end

    # Show the choice when party is in mode :menu
    def show_menu_mode_choice
      show_black_frame
      # @type [PFM::Pokemon]
      pokemon = @party[@index]
      choices = PFM::Choice_Helper.new(Yuki::ChoiceWindow::But, true, 999)
      unless pokemon.egg?
        pokemon.skills_set.each_with_index do |skill, i|
          if skill && (skill.map_use > 0 || PFM::SKILL_PROCESS[skill.db_symbol])
            choices.register_choice(skill.name, i, on_validate: method(:use_pokemon_skill), color: skill_color)
          end
        end
      end

      choices
        .register_choice(text_get(23, 4), on_validate: method(:launch_summary)) # Summary
        .register_choice(text_get(23, 8), on_validate: method(:action_move_current_pokemon), disable_detect: proc { @party.size <= 1 }) # Move
      unless pokemon.egg?
        if Yuki::FollowMe.in_lets_go_mode?
          if $storage.lets_go_follower == pokemon
            choices.register_choice(text_get(23, 165), on_validate: method(:deselect_follower)) # Unfollow
          else
            choices.register_choice(text_get(23, 164), on_validate: method(:select_follower)) # Follow
          end
        end
        choices
          .register_choice(text_get(23, 146), on_validate: method(:give_item)) # Give
          .register_choice(text_get(23, 147), on_validate: method(:take_item), disable_detect: method(:current_pokemon_has_no_item)) # Take
      end
      @base_ui.show_win_text(parse_text(23, 30, ::PFM::Text::PKNICK[0] => pokemon.given_name))
      x, y = get_choice_coordinates(choices)
      choice = choices.display_choice(@viewport, x, y, nil, choices, on_update: method(:update_menu_choice))
      @base_ui.hide_win_text if choice == 999
      hide_black_frame
    end

    # Update the scene during a choice
    # @param choices [PFM::Choice_Helper] choice interface to be able to cancel
    def update_menu_choice(choices)
      @choice_object = choices
      update_during_process
      update_mouse_ctrl
      @choice_object = nil
    end

    # Return the choice coordinates according to the current selected Pokemon
    # @param choices [PFM::Choice_Helper] choice interface to be able to cancel
    # @return [Array(Integer, Integer)]
    def get_choice_coordinates(choices)
      choice_height = 16
      height = choices.size * choice_height
      max_height = 217
      but_x = @team_buttons[@index].x + 53
      but_y = @team_buttons[@index].y + 32
      if but_y + height > max_height
        but_y -= (height - choice_height)
        but_y += choice_height while but_y < 0
      end
      return but_x, but_y
    end

    # Action of using a move of the current Pokemon
    # @param move_index [Integer] index of the move in the Pokemon moveset
    def use_pokemon_skill(move_index)
      # @type [PFM::Pokemon]
      pokemon = @party[@index]
      # @type [PFM::Skill]
      skill = pokemon.skills_set[move_index]
      if (@call_skill_process = PFM::SKILL_PROCESS[skill.db_symbol])
        if (type = @call_skill_process.call(pokemon, nil, true))
          if type == true
            @call_skill_process.call(pokemon, skill)
            @call_skill_process = nil
          elsif type == :choice
            @mode = :choice
            @return_data = @index
            @base_ui.show_win_text(text_get(23, 17))
            return
          elsif type == :block
            display_message(parse_text(22, 108))
            @base_ui.hide_win_text
            @call_skill_process = nil
            return
          end
        else
          @call_skill_process = [@call_skill_process, pokemon, skill]
        end
      else
        $game_temp.common_event_id = skill.map_use
      end
      @base_ui.hide_win_text
      @return_data = $game_variables[Yuki::Var::Party_Menu_Sel] = @index
      @running = false
    end

    # Action of launching the Pokemon Summary
    # @param mode [Symbol] mode used to launch the summary
    # @param extend_data [Hash, nil] the extended data used to launch the summary
    def launch_summary(mode = :view, extend_data = nil)
      @base_ui.hide_win_text
      call_scene(Summary, @party[@index], mode, @party, extend_data)
      Graphics.wait(4) { update_during_process }
    end

    # Action of deselecting the follower
    def deselect_follower
      $storage.lets_go_follower = nil
    end

    # Action of selecting the follower
    def select_follower
      $storage.lets_go_follower = @party[@index]
    end

    # Action of giving an item to the Pokemon
    # @param item2 [Integer] id of the item to give
    # @note if item2 is -1 it'll call the Bag interface to get the item
    def give_item(item2 = -1)
      # @type [PFM::Pokemon]
      pokemon = @party[@index]
      if item2 == -1
        @__result_process = proc { |scene| item2 = scene.return_data }
        call_scene(Bag, :hold)
        Graphics.wait(4) { update_during_process }
      end
      return @base_ui.hide_win_text if item2 == -1
      item1 = pokemon.item_holding
      give_item_message(item1, item2, pokemon)
      give_item_update_state(item1, item2, pokemon)
      @team_buttons[@index].refresh
      return @base_ui.hide_win_text unless pokemon.form_calibrate # Form adjustment
      @team_buttons[@index].refresh
      form_change_message(pokemon)
      @base_ui.hide_win_text
    end

    # Display the give item message
    # @param item1 [Integer] taken item
    # @param item2 [Integer] given item
    # @param pokemon [PFM::Pokemon] Pokemong getting the item
    def give_item_message(item1, item2, pokemon)
      if item1 != 0 && item1 != item2
        display_message(parse_text(22, 91, ::PFM::Text::ITEM2[0] => pokemon.item_name, ::PFM::Text::ITEM2[1] => ::GameData::Item[item2].name))
      elsif item1 != item2
        display_message(parse_text(22, 90, ::PFM::Text::ITEM2[0] => ::GameData::Item[item2].name))
      end
    end

    # Update the bag and pokemon state when giving an item
    # @param item1 [Integer] taken item
    # @param item2 [Integer] given item
    # @param pokemon [PFM::Pokemon] Pokemong getting the item
    def give_item_update_state(item1, item2, pokemon)
      pokemon.item_holding = item2
      $bag.remove_item(item2, 1)
      $bag.add_item(item1, 1) if item1 != 0
    end

    # Action of taking the item from the Pokemon
    def take_item
      @base_ui.hide_win_text
      # @type [PFM::Pokemon]
      pokemon = @party[@index]
      item = pokemon.item_holding
      $bag.add_item(item, 1)
      pokemon.item_holding = 0
      @team_buttons[@index].data = pokemon
      @team_buttons[@index].refresh
      display_message(parse_text(23, 78, ::PFM::Text::PKNICK[0] => pokemon.given_name, ::PFM::Text::ITEM2[1] => ::GameData::Item[item].name))
      return @base_ui.hide_win_text unless pokemon.form_calibrate # Form ajustment
      @team_buttons[@index].refresh
      form_change_message(pokemon)
      @base_ui.hide_win_text
    end

    # Form change message when item is taken or given
    # @note : Also update interface state
    # @param pokemon [PFM::Pokemon] Pokemon that change form
    def form_change_message(pokemon)
      pokemon.hp = ((pokemon.max_hp)*(pokemon.hp_rate)).round
      @team_buttons[@index].data = pokemon
      display_message(parse_text(22, 157, ::PFM::Text::PKNAME[0] => pokemon.given_name))
    end

    # Method telling if the Pokemon has no item or not
    # @return [Boolean]
    def current_pokemon_has_no_item
      @party[@index].item_holding <= 0
    end

    # Show the choice when the party is in mode :battle
    def show_battle_mode_choice
      show_black_frame
      # @type [PFM::Pokemon]
      pokemon = @party[@index]
      choices = PFM::Choice_Helper.new(Yuki::ChoiceWindow::But, true, 999)
      choices
        .register_choice(text_get(20, 25), on_validate: method(:on_send_pokemon)) # Send
        .register_choice(text_get(23, 4), on_validate: method(:launch_summary)) # Summary
      @base_ui.show_win_text(parse_text(23, 30, ::PFM::Text::PKNICK[0] => pokemon.given_name))
      x, y = get_choice_coordinates(choices)
      choices.display_choice(@viewport, x, y, nil, choices, on_update: method(:update_menu_choice))
      hide_black_frame
    end

    # When the player want to send a specific Pokemon to battle
    def on_send_pokemon
      # @type [PFM::Pokemon]
      pokemon = @party[@index]
      if pokemon.egg?
        display_message(parse_text(20, 34))
      elsif pokemon.dead?
        display_message(parse_text(20, 33, ::PFM::Text::PKNICK[1] => pokemon.given_name))
      elsif @index < $game_temp.vs_type
        display_message(parse_text(20, 32, ::PFM::Text::PKNICK[1] => pokemon.given_name))
      else
        @return_data = @index
        @running = false
      end
    end

    # Show the choice when the party is in mode :choice
    def show_choice_mode_choice
      show_black_frame
      # @type [PFM::Pokemon]
      pokemon = @party[@index]
      choices = PFM::Choice_Helper.new(Yuki::ChoiceWindow::But, true, 999)
      choices
        .register_choice(text_get(23, 209), on_validate: method(:on_skill_choice)) # Select
        .register_choice(text_get(23, 4), on_validate: method(:launch_summary)) # Summary
        .register_choice(text_get(23, 1), on_validate: @base_ui.method(:hide_win_text)) # Cancel
      @base_ui.show_win_text(parse_text(23, 30, ::PFM::Text::PKNICK[0] => pokemon.given_name))
      x, y = get_choice_coordinates(choices)
      choice = choices.display_choice(@viewport, x, y, nil, choices, on_update: method(:update_menu_choice))
      hide_black_frame
      @base_ui.show_win_text(text_get(23, 17)) if choice != 0
    end

    # Event that triggers when the player choose on which pokemon to apply the move
    def on_skill_choice
      # @type [PFM::Pokemon]
      pokemon = @party[@index]
      @call_skill_process.call(pokemon, nil)
      @call_skill_process = nil
      @mode = :menu
      @index = @return_data
      @return_data = -1
    end

    # Show the choice when the party is in mode :item
    def show_item_mode_choice
      show_black_frame
      # @type [PFM::Pokemon]
      pokemon = @party[@index]
      choices = PFM::Choice_Helper.new(Yuki::ChoiceWindow::But, true, 999)
      choices
        .register_choice(text_get(23, 209), on_validate: method(:on_item_use_choice)) # Select
        .register_choice(text_get(23, 4), on_validate: method(:launch_summary)) # Summary
        .register_choice(text_get(23, 1), on_validate: @base_ui.method(:hide_win_text)) # Cancel
      @base_ui.show_win_text(parse_text(23, 30, ::PFM::Text::PKNICK[0] => pokemon.given_name))
      x, y = get_choice_coordinates(choices)
      choice = choices.display_choice(@viewport, x, y, nil, choices, on_update: method(:update_menu_choice))
      hide_black_frame
      @base_ui.show_win_text(text_get(23, 24)) if choice != 0
    end

    # Event that triggers when the player choose on which pokemon to use the item
    def on_item_use_choice
      # @type [PFM::Pokemon]
      pokemon = @party[@index]
      if @extend_data[:on_pokemon_choice].call(pokemon)
        if @extend_data[:on_pokemon_use]
          @extend_data[:on_pokemon_use].call(pokemon)
          @return_data = @index
          @running = false
        elsif @extend_data[:open_skill]
          launch_summary(:skill, @extend_data)
          if @extend_data[:skill_selected]
            @return_data = @index
            @running = false
          end
        elsif @extend_data[:open_skill_learn]
          scene = Skill_Learn.new(pokemon, @extend_data[:open_skill_learn])
          scene.main
          @return_data = @index if scene.learnt
          @running = false
        elsif @extend_data[:action_to_push]
          @return_data = @index
          @running = false
        end
      else
        display_message(parse_text(22, 108))
      end
    end

    # Show the choice when the party is in mode :hold
    def show_hold_mode_choice
      show_black_frame
      # @type [PFM::Pokemon]
      pokemon = @party[@index]
      choices = PFM::Choice_Helper.new(Yuki::ChoiceWindow::But, true, 999)
      choices
        .register_choice(text_get(23, 146), on_validate: method(:on_item_give_choice)) # Select
        .register_choice(text_get(23, 4), on_validate: method(:launch_summary)) # Summary
        .register_choice(text_get(23, 1), on_validate: @base_ui.method(:hide_win_text)) # Cancel
      @base_ui.show_win_text(parse_text(23, 30, ::PFM::Text::PKNICK[0] => pokemon.given_name))
      x, y = get_choice_coordinates(choices)
      choice = choices.display_choice(@viewport, x, y, nil, choices, on_update: method(:update_menu_choice))
      hide_black_frame
      @base_ui.show_win_text(text_get(23, 23)) if choice != 0
    end

    # Event that triggers when the player choose on which pokemon to give the item
    def on_item_give_choice
      give_item(@extend_data)
      @running = false
    end

    # Show the choice when the party is in mode :select
    def show_select_mode_choice
      show_black_frame
      # @type [PFM::Pokemon]
      pokemon = @party[@index]
      extend_data = @extend_data
      choices = PFM::Choice_Helper.new(Yuki::ChoiceWindow::But, true, 999)
      if extend_data.is_a?(Array)
        if !@temp_team.include?(pokemon) && !extend_data.include?(pokemon.id)
          choices.register_choice(text_get(23, 140), on_validate: method(:on_select)) # Enter
        elsif @temp_team.include?(pokemon) && !extend_data.include?(pokemon.id)
          choices.register_choice(text_get(23, 141), on_validate: method(:on_select)) # Withdraw
        end
      elsif @temp_team.include?(pokemon)
        choices.register_choice(text_get(23, 141), on_validate: method(:on_select)) # Withdraw
      else
        choices.register_choice(text_get(23, 140), on_validate: method(:on_select)) # Enter
      end
      choices
        .register_choice(text_get(23, 4), on_validate: method(:launch_summary)) # Summary
        .register_choice(text_get(23, 1), on_validate: @base_ui.method(:hide_win_text)) # Cancel
      @base_ui.show_win_text(parse_text(23, 30, ::PFM::Text::PKNICK[0] => pokemon.given_name))
      x, y = get_choice_coordinates(choices)
      choice = choices.display_choice(@viewport, x, y, nil, choices, on_update: method(:update_menu_choice))
      hide_black_frame
      @base_ui.show_win_text(text_get(23, 110)) if choice != 0
    end

    # Event that triggers when a Pokemon is selected in :select mode
    def on_select
      pokemon = @party[@index]
      if !@temp_team.include?(pokemon) && enough_pokemon?(:button)
        @temp_team << pokemon
      elsif @temp_team.include?(pokemon)
        @temp_team[@temp_team.index(pokemon)] = nil
        @temp_team.compact!
      else
        return
      end
      @team_buttons[@index].data = pokemon
      @team_buttons[@index].refresh
      init_win_text
    end

    # Check if the temporary team contains the right number of Pokemon
    # @param caller [Symbol] used to determine the caller of the method
    # return Boolean 
    def enough_pokemon?(caller = :validate)
      return if check_select_mon_var == true
      if caller == :button
        if @temp_team.size + 1 > $game_variables[Yuki::Var::Max_Pokemon_Select]
          display_message(text_get(23, 115 + $game_variables[Yuki::Var::Max_Pokemon_Select]))
          return false
        else
          return true
        end
      elsif @temp_team.size < $game_variables[Yuki::Var::Max_Pokemon_Select]
        display_message(text_get(23, 109 + $game_variables[Yuki::Var::Max_Pokemon_Select]))
        return false
      else
        return true
      end
    end

    # Check if the $game_variables[6]'s value is between 1 and 6
    # If not, call action_B to exit to map
    # return Boolean
    def check_select_mon_var
      if $game_variables[6] > 6 || $game_variables[6] < 1
        display_message('Wrong number of Pokemon to select. Number must be between 1 and 6.')
        action_B
        true
      else
        false
      end
    end

    # Show the choice when the party is in mode :map
    def show_map_mode_choice
      show_black_frame
      # @type [PFM::Pokemon]
      pokemon = @party[@index]
      choices = PFM::Choice_Helper.new(Yuki::ChoiceWindow::But, true, 999)
      # Text missing for choosing a Mon
      choices
        .register_choice(text_get(23, 0), on_validate: method(:on_map_choice)) # Select
        .register_choice(text_get(23, 4), on_validate: method(:launch_summary)) # Summary
        .register_choice(text_get(23, 1), on_validate: @base_ui.method(:hide_win_text)) # Cancel
      @base_ui.show_win_text(parse_text(23, 30, ::PFM::Text::PKNICK[0] => pokemon.given_name))
      x, y = get_choice_coordinates(choices)
      choice = choices.display_choice(@viewport, x, y, nil, choices, on_update: method(:update_menu_choice))
      hide_black_frame
      @base_ui.show_win_text(text_get(23, 17)) if choice != 0
    end

    # Event that triggers when the player has choosen a Pokemon
    def on_map_choice
      @return_data = $game_variables[Yuki::Var::Party_Menu_Sel] = @index
      @running = false
    end

    # Process the switch between two pokemon
    def process_switch
      return $game_system.se_play($data_system.buzzer_se) if @move == @index
      tmp = @team_buttons[@move].data
      @team_buttons[@move].selected = false
      @party[@move] = @team_buttons[@move].data = @team_buttons[@index].data
      @party[@index] = @team_buttons[@index].data = tmp
      @move = -1
      @base_ui.hide_win_text
      @intern_mode = :normal
      $game_player.make_encounter_count
    end

    # Process the switch between the items of two pokemon
    def process_item_switch
      return $game_system.se_play($data_system.buzzer_se) if @move == @index
      tmp = @team_buttons[@move].data.item_holding
      # @type [PFM::Pokemon]
      pokemon = @team_buttons[@move].data
      pokemon.item_holding = @team_buttons[@index].data.item_holding
      if pokemon.form_calibrate # Form adjustment
        @team_buttons[@move].refresh
        display_message(parse_text(22, 157, ::PFM::Text::PKNAME[0] => pokemon.given_name))
      end
      @team_buttons[@move].refresh
      pokemon = @team_buttons[@index].data
      pokemon.item_holding = tmp
      if pokemon.form_calibrate # Form adjustment
        @team_buttons[@index].refresh
        display_message(parse_text(22, 157, ::PFM::Text::PKNAME[0] => pokemon.given_name))
      end
      @team_buttons[@index].refresh
      @team_buttons[@move].selected = false
      @move = -1
      @base_ui.hide_win_text
      hide_item_name
      @intern_mode = :normal
    end
  end
end
