module Battle
  class Scene
    private

    # Method that trigger all the AI
    # @note It should first trigger the trainer_dialog event and for each AI trigger the AI_force_action event
    def trigger_all_AI
      call_event(:trainer_dialog)
      @AIs.each_with_index do |ai, index|
        log_debug("Triggering AI##{index}...")
        actions = call_event(:AI_force_action, ai, index)
        if actions
          @logic.add_actions(actions)
        else
          @logic.add_actions(ai.trigger)
        end
      end
      @next_update = :start_battle_phase
    end
  end
end
