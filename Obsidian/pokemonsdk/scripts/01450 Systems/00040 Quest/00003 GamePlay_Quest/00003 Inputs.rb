module GamePlay
  class QuestUI
    # List of method called by automatic_input_update when pressing on a key
    AIU_KEY2METHOD = {
      A: :action_a, X: :action_x, Y: :action_y, B: :action_b,
      LEFT: :action_left, RIGHT: :action_right
    }

    # Update the input of the scene
    def update_inputs
      return false unless @composition.done?
      return false unless automatic_input_update(AIU_KEY2METHOD)
      return false unless check_up_down_keys
    end

    private

    # Return the keys used to scroll
    # @return [Array<Symbol>]
    SCROLL_KEYS = %i[UP DOWN]

    # Check if the scroll keys are triggered or pressed depending on the context3
    # @return [Boolean] if update_inputs should continue
    def check_up_down_keys
      direction = timing = nil
      SCROLL_KEYS.each do |key|
        bool = deployed? ? Input.trigger?(key) : Input.press?(key)
        next unless bool

        direction = key
        @key_counter = @last_key == key ? @key_counter + 1 : 0
        @last_key = key
        if @key_counter >= 5
          timing = :fast
        elsif @key_counter >= 2
          timing = :medium
        else
          timing = :slow
        end
        action_scroll(direction, timing)
        return false
      end
      @last_key = nil

      return true
    end

    # Action related to A button
    def action_a
      return if deployed?

      switch_quest_mode
    end

    # Action related to B button
    def action_b
      return switch_quest_mode if deployed?

      play_cancel_se
      @running = false
    end

    # Action related to X button
    def action_x
      return unless deployed?

      case @deployed_mode
      when :descr
        @deployed_mode = :rewards
      when :rewards
        @deployed_mode = :objectives
      when :objectives
        @deployed_mode = :descr
      end
      update_x_button_text
      @composition.change_deployed_mode(@deployed_mode)
    end

    # Action related to Y button
    def action_y
      # TODO: Add the quest following feature later
    end

    # When the player press LEFT
    def action_left
      return @composition.swap_rewards(:left) if deployed? && @deployed_mode == :rewards
      return if deployed?

      change_category(:left)
    end

    # When the player press RIGHT
    def action_right
      return @composition.swap_rewards(:right) if deployed? && @deployed_mode == :rewards
      return if deployed?

      change_category(:right)
    end

    # Return the right scroll action depending on the context
    # @param direction [Symbol]
    # @param timing [Symbol]
    def action_scroll(direction, timing = :slow)
      return unless @composition.current_list
      return @composition.scroll_objective_list(direction) if deployed? && @deployed_mode == :objectives
      return if deployed?

      @composition.input_direction(direction, timing)
    end
  end
end
