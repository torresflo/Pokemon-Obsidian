module GamePlay
  class Party_Menu
    # Array of actions to do according to the pressed button
    Actions = %i[action_A action_X action_Y action_B]

    # Action triggered when A is pressed
    def action_A
      case @mode
      when :menu
        action_A_menu
      else
        $game_system.se_play($data_system.decision_se)
        show_choice
      end
    end

    # Action when A is pressed and the mode is menu
    def action_A_menu
      case @intern_mode
      when :choose_move_pokemon
        action_move_current_pokemon
      when :choose_move_item
        return $game_system.se_play($data_system.buzzer_se) if @team_buttons[@index].data.item_holding == 0
        @team_buttons[@move = @index].selected = true
        @intern_mode = :move_item
        @base_ui.show_win_text(text_get(23, 22))
      when :move_pokemon
        process_switch
      when :move_item
        process_item_switch
      else
        $game_system.se_play($data_system.decision_se)
        return show_choice
      end
      $game_system.se_play($data_system.decision_se)
    end

    # Action triggered when B is pressed
    def action_B
      return if no_leave_B
      # Ensure we don't leave with a call_skill_process
      @call_skill_process = nil
      $game_system.se_play($data_system.cancel_se)
      # Cancel choice attempt
      return @choice_object.cancel if @choice_object
      # Returning to normal mode
      if @intern_mode != :normal
        @base_ui.hide_win_text
        hide_item_name
        @team_buttons[@move].selected = false if @move != -1
        @move = -1
        return @intern_mode = :normal
      end
      # Emptying $game_temp.temp_team if in select mode
      if @mode == :select
        $game_temp.temp_team = []
      end
      @running = false
    end

    # Function that detect no_leave and forbit the B action to process
    # @return [Boolean] true = no leave, false = process normally
    def no_leave_B
      if @no_leave
        return false if @choice_object
        return false if @intern_mode != :normal
        $game_system.se_play($data_system.buzzer_se)
        return true
      end
      return false
    end

    # Action triggered when X is pressed
    def action_X
      $game_temp.temp_team = @temp_team if @mode == :select
      # Check if the number of selected Pokemon is equal to the required number
      @running = false if @mode == :select && enough_pokemon? == true
      return if @mode != :menu 
      return $game_system.se_play($data_system.buzzer_se) if @intern_mode != :normal or @party.size <= 1
      @base_ui.show_win_text(text_get(23, 19))
      @intern_mode = :choose_move_pokemon
    end

    # Action triggered when Y is pressed
    def action_Y
      return if @mode != :menu
      return $game_system.se_play($data_system.buzzer_se) if @intern_mode != :normal or @party.size <= 1
      @base_ui.show_win_text(text_get(23, 20))
      @intern_mode = :choose_move_item
      show_item_name
    end

    # Update the mouse interaction with the ctrl buttons
    def update_mouse_ctrl
      if @mode != :select
        update_mouse_ctrl_buttons(@base_ui.ctrl, Actions, @base_ui.win_text_visible?)
      else
        update_mouse_ctrl_buttons(@base_ui.ctrl, [nil, nil, nil, :action_X], false)
      end
    end

    # Update the movement of the Cursor
    def update_selector_move
      party_size = @team_buttons.size
      index2 = @index % 2
      if Input.trigger?(:DOWN)
        next_index = @index + 2
        next_index = index2 if next_index >= party_size
        update_selector_coordinates(@index = next_index)
      elsif Input.trigger?(:UP)
        next_index = @index - 2
        if next_index < 0
          next_index += 6
          next_index -= 2 while next_index >= party_size
        end
        update_selector_coordinates(@index = next_index)
      elsif index_changed(:@index, :LEFT, :RIGHT, party_size - 1)
        update_selector_coordinates
      else
        update_mouse_selector_move
      end
    end

    # Update the movement of the selector with the mouse
    def update_mouse_selector_move
      return unless Mouse.moved || Mouse.trigger?(:left) # Safety preventing index conflict
      @team_buttons.each_with_index do |btn, i|
        next unless btn.simple_mouse_in?
        update_selector_coordinates(@index = i) if @index != i
        action_A if Mouse.trigger?(:left)
        return true
      end
    end

    # Update the selector coordinates
    def update_selector_coordinates(*)
      btn = @team_buttons[@index]
      @selector.set_position(btn.x + 3, btn.y + 3)
    end

    # Select the current pokemon to move with an other pokemon
    def action_move_current_pokemon
      return if @party.size <= 1
      @team_buttons[@move = @index].selected = true
      @intern_mode = :move_pokemon
      @base_ui.show_win_text(text_get(23, 21))
    end
  end
end
