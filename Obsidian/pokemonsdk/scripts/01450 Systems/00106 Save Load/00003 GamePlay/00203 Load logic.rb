module GamePlay
  class Load
    # Create a new game and start it
    def create_new_game
      create_new_party
      PFM.game_state.expand_global_var
      PFM.game_state.load_parameters
      $trainer.redefine_var
      $scene = Scene_Map.new
      Yuki::TJN.force_update_tone
      @running = false
    end

    private

    # Load the current game
    def load_game
      @all_saves[@index].expand_global_var
      PFM.game_state.load_parameters
      $game_system.se_play($data_system.cursor_se)
      $game_map.setup($game_map.map_id)
      $game_player.moveto($game_player.x, $game_player.y) # center
      $game_party.refresh
      $game_system.bgm_play($game_system.playing_bgm)
      $game_system.bgs_play($game_system.playing_bgs)
      $game_map.update
      $game_temp.message_window_showing = false
      $trainer.load_time
      Pathfinding.load
      $trainer.redefine_var
      Yuki::FollowMe.set_battle_entry
      PFM.game_state.env.reset_zone
      $scene = Scene_Map.new
      Yuki::TJN.force_update_tone
      @running = false
    end

    # Creaye a new Pokemon Party object and ask the language if possible
    def create_new_party
      PFM.game_state = PFM::GameState.new(false, PSDK_CONFIG.default_language_code)
      PARGV.update_game_opts("--lang=#{PSDK_CONFIG.default_language_code}") if @all_saves.empty?
    end
  end
end
