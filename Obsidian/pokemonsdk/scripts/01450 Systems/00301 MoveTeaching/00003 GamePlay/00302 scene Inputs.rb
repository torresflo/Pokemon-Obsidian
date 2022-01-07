module GamePlay
  class MoveTeaching
    # List of methds associated to the inputs
    AIU_KEY2METHOD = {
      UP: :action_up, DOWN: :action_down, LEFT: :action_left, RIGHT: :action_right,
      A: :action_a, B: :action_b
    }

    # Update inputs every frame
    def update_inputs
      return message_start if @state == :start
      return false unless @state == :move_choice

      return update_buttons_inputs
    end

    private

    # Update buttons inputs
    def update_buttons_inputs
      old_index = @index
      unless automatic_input_update(AIU_KEY2METHOD)
        swap_buttons(old_index)
        return false
      end

      return true
    end

    # Swap the button selection state
    # @param old_index [Integer] previous index to make that button "not selected"
    def swap_buttons(old_index)
      @skill_set[old_index].selected = false
      @skill_set[@index].selected = true
      @skill_description.data = @index < 4 ? @pokemon.skills_set[@index] : @skill_learn
    end

    # Action when the up button is pressed
    def action_up
      return if @index == 4

      play_cursor_se
      if @index.between?(2, 3)
        @index -= 2
      elsif @index < 2
        @index = 4
      end
    end

    # Action when the down button is pressed
    def action_down
      return if @index.between?(2, 3)

      play_cursor_se
      @index == 4 ? @index = 0 : @index += 2
    end

    # Action when the left button is pressed
    def action_left
      return if @index == 0 || @index == 4

      play_cursor_se
      @index -= 1
    end

    # Action when the right button is pressed
    def action_right
      return if @index == 3 || @index == 4

      play_cursor_se
      @index += 1
    end

    # Action when the A button is pressed
    def action_a
      if @index < 4
        play_decision_se
        @skill_set[@index].forget = true
        forget
      else
        message_end
      end
    end

    # Action when the B button is pressed
    def action_b
      play_cancel_se
      message_end
    end
  end
end
