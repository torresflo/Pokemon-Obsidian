module Battle
  class Scene
    private

    # Method that add the actions of the player, sort them and let the main phase process
    def start_battle_phase
      log_info('Starting battle phase')
      # Add player actions
      @logic.add_actions(@player_actions)
      @player_actions.clear
      @logic.sort_actions
      @message_window.width = @visual.viewport.rect.width
      @message_window.wait_input = true
      # Tell to call udpdate_battle_phase on the next frame
      @next_update = :udpdate_battle_phase
    end

    # Method that makes the battle logic perform an action
    # @note Should call the after_action_dialog event
    def udpdate_battle_phase
      return if @logic.perform_next_action
      # If the battle logic couldn't perform the next action (ie there's nothing to do)
      # We call the after_action_dialog event, check if the battle can continue and choose the right thing to do
      call_event(:after_action_dialog)
      if @logic.can_battle_continue?
        @next_update = :player_action_choice
      else
        @next_update = :battle_end
        @battle_result = @logic.battle_result
      end
    end

    # Method that perform everything that needs to be performed at battle end (phrases etc...) and gives back the master to Scene_Map
    def battle_end
      log_info('Exiting battle')
      # TODO : battle_end procedure
      $game_temp.in_battle = false
      return_to_last_scene
    end

    # Method that tells to return to the last scene (Scene_Map)
    def return_to_last_scene
      $scene = Scene_Map.new
      @running = false
    end
  end
end
