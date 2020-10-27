module GamePlay
  class PokemonStorage
    # List of Action depending on the selection mode
    SELECTION_MODE_ACTIONS = {
      detailed: :action_a_detailed,
      fast: :action_a_fast,
      grouped: :action_a_grouped
    }
    # List of method called by automatic_input_update when pressing on a key
    AIU_KEY2METHOD = {
      A: :action_a, B: :action_b, X: :action_x, Y: :action_y,
      L: :action_l, R: :action_r, L2: :action_l2, R2: :action_r2,
      LEFT: :action_left, RIGHT: :action_right, UP: :action_up, DOWN: :action_down
    }

    # Update the input of the scene
    def update_inputs
      return false unless @composition.done?

      return automatic_input_update(AIU_KEY2METHOD)
    end

    private

    # When the player press B we quit the computer
    def action_b
      if @moving_pokemon
        play_decision_se
        @selection.clear
        @base_ui.hide_win_text
        refresh
        @moving_pokemon = false
      elsif @mode_handler.selection_mode != :detailed
        if @selection.empty?
          play_buzzer_se
        else
          play_decision_se
          @selection.clear
          refresh
        end
      elsif can_leave_storage?
        Audio.se_play('audio/se/computerclose')
        @running = false
      else
        display_message_and_wait(text_get(33, 88), 1)
      end
    end

    # When the player press A we act depending on the state
    def action_a
      if @moving_pokemon
        action_a_fast_swap
        if @selection.all_selected_pokemon.empty?
          @moving_pokemon = false
          @base_ui.hide_win_text
        end
      elsif @cursor.mode == :box_choice
        play_decision_se
        choice_box_option
      else
        send(SELECTION_MODE_ACTIONS[@mode_handler.selection_mode])
      end
    end

    # When the player press X
    def action_x
      return play_buzzer_se if @moving_pokemon

      if @mode_handler.selection_mode == :detailed
        play_buzzer_se
      else
        @selection.empty? ? play_buzzer_se : action_a_fast_swap
      end
    end

    # When the player press A in detailed selection
    def action_a_detailed
      if @selection.empty?
        choice_single_pokemon
      else
        choice_selected_pokemon
      end
    end

    # When the player press A in fast mode, we select and then swap
    def action_a_fast
      if @selection.empty?
        @selection.select
        refresh
      elsif @cursor.mode != :box_choice
        action_a_fast_swap
      else
        play_buzzer_se
      end
    end

    # Action when the player need to swap pokemon (in fast mode)
    def action_a_fast_swap
      if @mode_handler.mode == :item
        result = @selection.move_items_to_cursor
      else
        result = @selection.move_pokemon_to_cursor
      end
      result ? play_decision_se : play_buzzer_se
      refresh
    end

    # Action when the player press A in grouped mode
    def action_a_grouped
      @selection.select
      play_decision_se
      refresh
    end

    # When the player press RIGHT
    def action_right
      return change_box(true) if @cursor.mode == :box_choice

      @cursor.move_right ? play_cursor_se : play_buzzer_se
      update_summary
      update_mode
    end

    # When the player press LEFT
    def action_left
      return change_box(false) if @cursor.mode == :box_choice

      @cursor.move_left ? play_cursor_se : play_buzzer_se
      update_summary
      update_mode
    end

    # When the player press UP
    def action_up
      @cursor.move_up ? play_cursor_se : play_buzzer_se
      update_summary
      update_mode
    end

    # When the player press DOWN
    def action_down
      @cursor.move_down ? play_cursor_se : play_buzzer_se
      update_summary
      update_mode
    end

    # When player press L we update the battle_box index
    def action_l
      return play_buzzer_se if @mode_handler.mode != :battle

      play_cursor_se
      @storage.current_battle_box = (@storage.current_battle_box - 1) % @storage.battle_boxes.size
      refresh
    end

    # When player press R we update the battle_box index
    def action_r
      return play_buzzer_se if @mode_handler.mode != :battle

      play_cursor_se
      @storage.current_battle_box = (@storage.current_battle_box + 1) % @storage.battle_boxes.size
      refresh
    end

    # When player press R2, the mode changes
    def action_r2
      play_cursor_se
      @mode_handler.swap_mode
      refresh
    end

    # When player press L2, the selection mode changes
    def action_l2
      return play_buzzer_se if @moving_pokemon

      play_cursor_se
      @mode_handler.swap_selection_mode
      refresh
    end

    # When the player press Y, the summary is shown
    def action_y
      return play_buzzer_se if @cursor.mode != :box

      play_cursor_se
      @summary.reduced ? @summary.show : @summary.reduce
    end
  end
end
