module GamePlay
  class Summary
    # Actions to do on the button according to the actual ID state of the buttons
    ACTIONS = [
      %i[mouse_next mouse_left mouse_right mouse_quit],
      %i[mouse_next mouse_left mouse_right mouse_quit],
      %i[mouse_a mouse_left mouse_right mouse_quit],
      %i[mouse_a object_id object_id mouse_cancel],
      %i[mouse_a object_id object_id mouse_cancel],
      %i[object_id object_id object_id mouse_quit]
    ]
    # List of the translated coordinates that gives a new move index
    TRANSLATED_MOUSE_COORD_DETECTION = [
      [x02 = 8..21, y01 = 18..23],
      [x13 = 24..37, y01],
      [x02, y23 = 25..30],
      [x13, y23]
    ]

    private

    # Update the mouse action inside the moves buttons
    def update_mouse_move_button
      return if @index != 2
      @uis[2].skills.each_with_index do |skill, index|
        update_mouse_in_skill_button(skill, index)
      end
    end

    # Update the mouse action inside a move button
    # @param skill [UI::Summary_Skill] skill button
    # @param index [Integer] index of the button in the stack
    def update_mouse_in_skill_button(skill, index)
      return unless skill.visible && skill.simple_mouse_in?
      @uis[2].index = index if (@selecting_move || @mode == :skill) && Mouse.moved
      if Mouse.trigger?(:LEFT)
        if @selecting_move || @mode == :skill
          mouse_a
        elsif @mode != :skill
          update_mouse_switch_skill(skill, index)
        end
      end
    end

    # Try to quick switch moves using the tiny buttons
    # @param skill [UI::Summary_Skill] skill button
    # @param index [Integer] index of the button in the stack
    def update_mouse_switch_skill(skill, index)
      x, y = skill.stack[0].translate_mouse_coords
      TRANSLATED_MOUSE_COORD_DETECTION.each_with_index do |coords, index2|
        next unless coords.first.include?(x) && coords.last.include?(y)
        $game_system.se_play($data_system.decision_se)
        @pokemon.swap_skills_index(index, index2)
        @uis[2].data = @pokemon
      end
    end

    # Update the mouse interaction with the ctrl buttons
    def update_mouse_ctrl
      update_mouse_ctrl_buttons(@base_ui.ctrl, ACTIONS[ctrl_id_state], @mode == :skill)
    end

    # Action performed when the player press on the [A] button with the mouse
    def mouse_a
      $game_system.se_play($data_system.decision_se)
      return update_inputs_skills_validation if @mode == :skill
      update_input_a_skill_ui
      update_ctrl_state
    end

    # Action performed when the player press on the [<] button with the mouse
    def mouse_left
      return if @mode == :skill || @pokemon.egg?
      $game_system.se_play($data_system.decision_se)
      @index -= 1
      @index = LAST_STATE if @index < 0
      update_ui_visibility
    end

    # Action performed when the player press on the [>] button with the mouse
    def mouse_right
      return if @mode == :skill || @pokemon.egg?
      $game_system.se_play($data_system.decision_se)
      @index += 1
      @index = 0 if @index > LAST_STATE
      update_ui_visibility
    end

    # Action performed when the player press on the [v] button with the mouse
    def mouse_next
      $game_system.se_play($data_system.decision_se)
      @party_index += 1
      @party_index = 0 if @party_index >= @party.size
      update_switch_pokemon
    end

    # Action performed when the player press on the [B] quit button with the mouse
    def mouse_quit
      $game_system.se_play($data_system.cancel_se)
      @skill_selected = -1
      @running = false
    end

    # Action performed when the player press on the [B] cancel button with the mouse
    def mouse_cancel
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
end
