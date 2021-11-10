module GamePlay
  class Summary
    # Update the input interactions
    def update_inputs
      return update_inputs_skill if @mode == :skill
      return update_inputs_view if @mode == :view
      @running = false if Input.trigger?(:B)
      return true
    end

    # Update the graphics
    def update_graphics
      @base_ui.update_background_animation
      @top.update_graphics
    end

    # Update the mouse
    # @param _moved [Boolean] if the mouse moved during the current frame
    def update_mouse(_moved)
      update_mouse_ctrl
      update_mouse_move_button
    end

    private

    # Update the inputs in skill mode
    def update_inputs_skill
      update_inputs_move_index
      if Input.trigger?(:A)
        $game_system.se_play($data_system.decision_se)
        update_inputs_skills_validation
      elsif Input.trigger?(:B)
        $game_system.se_play($data_system.cancel_se)
        @skill_selected = -1
        @running = false
      end
      return true
    end

    # Perform the validation of the update_inputs_skills
    def update_inputs_skills_validation
      return unless (skill = @pokemon.skills_set[@uis[2].index])

      if @extend_data
        if @extend_data.on_skill_choice(skill, self)
          @extend_data.on_skill_use(@pokemon, skill, self)
          @extend_data.bind(find_parent(Battle::Scene), @pokemon, skill)
          @running = false
        else # You cannot use that on this skill
          display_message(parse_text(22, 108))
        end
      else
        @skill_selected = @uis[2].index
        @running = false
      end
    end

    # Update the move index from inputs
    def update_inputs_move_index
      if Input.repeat?(:UP)
        @uis[2].index -= 2
      elsif Input.repeat?(:DOWN)
        @uis[2].index += 2
      elsif Input.repeat?(:LEFT)
        @uis[2].index -= 1
      elsif Input.repeat?(:RIGHT)
        @uis[2].index += 1
      end
    end

    # Update the inputs in view mode
    def update_inputs_view
      case @index
      when 0, 1
        update_inputs_basic
      when 2
        update_inputs_skill_ui
      end
      return true
    end

    # Update the basic inputs
    # @param allow_up_down [Boolean] if the player can press UP / DOWN in this method
    # @return [Boolean] if a key was pressed
    def update_inputs_basic(allow_up_down = true)
      # Make sure we don't allow to switch when there's not enough Pokemon in the party
      allow_up_down &&= @party.size > 1
      # Change the UI we show (If it's an egg it's forbidden)
      if !@pokemon.egg? && !@selecting_move && index_changed(:@index, :LEFT, :RIGHT, LAST_STATE)
        update_ui_visibility
        return true
      elsif allow_up_down && index_changed(:@party_index, :UP, :DOWN, @party.size - 1)
        update_switch_pokemon
        return true
      elsif Input.trigger?(:B)
        $game_system.se_play($data_system.cancel_se)
        @skill_selected = -1
        @running = false
      end
      return false
    end

    # When the player wants to see another Pokemon
    def update_switch_pokemon
      @pokemon = @party[@party_index]
      @index = 0 if @pokemon.egg?
      $game_system.se_play($data_system.decision_se)
      update_pokemon
    end

    # Update when we are in the move section
    def update_inputs_skill_ui
      return if update_inputs_basic(!@selecting_move)
      @running = true if @selecting_move && !@running
      update_inputs_move_index if @selecting_move
      if Input.trigger?(:A)
        $game_system.se_play($data_system.decision_se)
        update_input_a_skill_ui
        update_ctrl_state
      elsif Input.trigger?(:B)
        $game_system.se_play($data_system.cancel_se)
        @skill_selected = -1
        if @skill_index >= 0
          @uis[2].skills[@skill_index].moving = false
          @skill_index = -1
        else
          @running = false unless @selecting_move
          @selecting_move = false
        end
        update_ctrl_state
      end
    end

    # Perform the task to do when the player press A on the skill ui
    def update_input_a_skill_ui
      return @selecting_move = true unless @selecting_move
      if @skill_index < 0
        @skill_index = @uis[2].index
        @uis[2].skills[@skill_index].moving = true
      else
        @uis[2].skills[@skill_index].moving = false
        @pokemon.swap_skills_index(@uis[2].index, @skill_index)
        @uis[2].data = @pokemon
        @skill_index = -1
      end
    end
  end
end
