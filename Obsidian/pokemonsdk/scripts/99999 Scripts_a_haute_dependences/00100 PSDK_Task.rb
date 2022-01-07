module Scheduler
  add_proc(:on_warp_start, ::Scene_Map, 'Enregistrement positions', 1000) do
    @storage[:was_outside] = $game_switches[Yuki::Sw::Env_CanFly]
    @storage[:old_player_x] = $game_player.x - Yuki::MapLinker.current_OffsetX
    @storage[:old_player_y] = $game_player.y - Yuki::MapLinker.current_OffsetY
    @storage[:old_player_id] = $game_map.map_id
    $env.reset_worldmap_position # Reset the arbitrary worldmap position
    $game_player.reset_follower
  end

  add_proc(:on_warp_start, ::Scene_Map, 'Calcul des positions des followers', 999) do
    @storage[:follower_arr] = arr = []
    add_x = $game_temp.player_new_x - $game_player.x
    add_y = $game_temp.player_new_y - $game_player.y
    Yuki::FollowMe.each_follower do |i|
      arr << (i.x + add_x)
      arr << (i.y + add_y)
      arr << i.direction
    end
  end

  add_proc(:on_warp_process, ::Scene_Map, 'Descendre du vélo s\'il faut & reset force', 100) do
    if $env.get_current_zone_data.warp_disallowed
      if $game_switches[::Yuki::Sw::EV_Bicycle]
        $game_system.map_interpreter.launch_common_event(11)
        $game_system.map_interpreter.update
      elsif $game_switches[::Yuki::Sw::EV_AccroBike]
        $game_system.map_interpreter.launch_common_event(33)
        $game_system.map_interpreter.update
      end
    end
    $game_switches[::Yuki::Sw::EV_Strength] = false
  end

  add_proc(:on_warp_end, ::Scene_Map, 'Reposition followers + update système', 1000) do
    unless Game_Character::SurfTag.include? $game_player.system_tag
      $game_player.leave_surfing_state
    end
    if (@storage[:was_outside] && $game_switches[Yuki::Sw::Env_CanFly]) || $game_switches[Yuki::Sw::Env_FM_REP]
      $game_switches[Yuki::Sw::Env_FM_REP] = false
      Yuki::FollowMe.set_positions(*@storage[:follower_arr])
    else
      Yuki::FollowMe.reset_position unless $game_switches[Yuki::Sw::FM_NoReset]
      $game_switches[Yuki::Sw::FM_NoReset] = false
    end
    Yuki::FollowMe.update
    Yuki::Particles.update
    PFM::Wild_RoamingInfo.unlock
    $wild_battle.reset
    $wild_battle.load_groups
  end

  add_proc(:on_warp_end, ::Scene_Map, 'Tunnel', 999) do
    if @storage[:was_outside] && $game_switches[Yuki::Sw::Env_CanDig]
      $game_variables[Yuki::Var::E_Dig_ID] = @storage[:old_player_id]
      $game_variables[Yuki::Var::E_Dig_X] = @storage[:old_player_x]
      $game_variables[Yuki::Var::E_Dig_Y] = @storage[:old_player_y]
    end
  end

  add_proc(:on_scene_switch, ::Scene_Title, 'Correction du TJN', 1000) do
    next unless $scene.is_a?(Scene_Map)

    Yuki::TJN.init_variables
  end

  add_proc(:on_warp_start, ::Scene_Map, 'Trigger timed events', 1000) do
    Yuki::TJN.update_timed_events($game_temp.player_new_map_id)
  end

=begin
  add_proc(:on_update, ::Scene_Map, 'Ajout Visual Debug', 1100) do
    if false#Input.trigger?(Input::F9) #£VisualDebug
      unless Yuki::VisualDebug.enabled? #£VisualDebug
        Yuki::VisualDebug.enable #£VisualDebug
      else #£VisualDebug
        Yuki::VisualDebug.disable #£VisualDebug
      end #£VisualDebug
    end #£VisualDebug
    Yuki::VisualDebug.update if Yuki::VisualDebug.enabled? #£VisualDebug
  end
=end

  add_proc(:on_hour_update, ::Scene_Map, 'Actualisation des groupes', 1000) do
    $wild_battle.reset
    $wild_battle.load_groups
  end

  add_proc(:on_hour_update, ::Scene_Map, 'Actualisation de la forme de Shaymin', 1000) do
    selected = $actors.select { |pkmn| pkmn.db_symbol == :shaymin }
    selected.each { |pkmn| pkmn.form_calibrate(:none) if $env.sunset? || $env.night? }
  end

  add_proc(:on_scene_switch, GamePlay::Load, 'Correction des formes', 1000) do
    next unless $scene.is_a?(Scene_Map)

    log_info('Correction des formes des Pokémon')
    block = proc { |pokemon| pokemon&.form_calibrate(:load) }
    $actors.each(&block)
    $storage.each_pokemon(&block)
    $wild_battle.each_roaming_pokemon(&block)
  end

  add_proc(:on_update, :any, 'KeyBinding addition', 0) do
    if $scene.class != GamePlay::KeyBinding
      if Input::Keyboard.press?(Input::Keyboard::F1) && !$game_temp&.message_window_showing
        GameData::Text.load unless $options
        GamePlay::KeyBinding.new.main
        Graphics.transition
      end
    end
  end

  add_proc(:on_scene_switch, GamePlay::Load, 'Fix quests', 1000) do
    next unless $scene.is_a?(Scene_Map)
    next if PFM.game_state.trainer.current_version > 6407

    log_info('Fixing quest data')
    PFM.game_state.quests.import_from_dot24
  end

=begin
  # Exemple de chargement de tileset automatique
  add_proc(:on_getting_tileset_name, :any, 'Changement de tileset map 9', 1000,
    proc {
      if $game_temp.maplinker_map_id == 9
        $game_temp.tileset_name = '4G tileset_glace'
      end
    }
  )
=end

  add_message(:on_dispose, Scene_Map, 'Dispose the particles', 1000, Yuki::Particles, :dispose)
  add_message(:on_dispose, Scene_Map, 'Dispose the FollowMe', 1000, Yuki::FollowMe, :dispose)
end
