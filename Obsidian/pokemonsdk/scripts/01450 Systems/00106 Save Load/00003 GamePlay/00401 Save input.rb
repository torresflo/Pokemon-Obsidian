module GamePlay
  class Save
    private

    def action_left
      return play_buzzer_se unless Configs.save_config.can_save_on_any_save

      super
    end

    def action_right
      return play_buzzer_se unless Configs.save_config.can_save_on_any_save

      super
    end

    def action_b
      play_decision_se
      @running = false
    end

    def action_a
      Save.save_index = Configs.save_config.single_save? ? 0 : @index + 1
      save_game
      @saved = true
      @running = false
      play_save_se
    end

    def play_save_se
      play_decision_se
    end
  end
end
