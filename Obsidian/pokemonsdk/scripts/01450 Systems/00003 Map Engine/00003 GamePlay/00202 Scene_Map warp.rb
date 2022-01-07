class Scene_Map
  private

  # Execute the begin calculation of the transfer_player processing
  def transfer_player_begin
    Scheduler.start(:on_warp_start)
    if $game_map.map_id != $game_temp.player_new_map_id
      # Setting player coords to prevent glitch with events that triggers on player position
      $game_player.x = $game_temp.player_new_x
      $game_player.y = $game_temp.player_new_y
      # Load new map
      $game_map.setup($game_temp.player_new_map_id)
    end
    $game_temp.player_transferring = false # Moved here to prevent some event starting during warp process
    $game_player.moveto($game_temp.player_new_x, $game_temp.player_new_y)
    $game_player.direction = $game_temp.player_new_direction if $game_temp.player_new_direction != 0 && !$game_player.direction_fix
    $game_player.straighten
    $game_map.update
  end

  # Teleport the play between map or inside the map
  def transfer_player
    Yuki::ElapsedTime.start(:transfer_player)
    Pathfinding.clear
    transfer_player_begin
    # Adjustment of the Spriteset Data
    zone = $env.update_zone
    Scheduler.start(:on_warp_process)
    # Special transition
    wrp_anime = $game_switches[Yuki::Sw::WRP_Transition]
    $game_switches[Yuki::Sw::WRP_Transition] = false if !$env.get_current_zone_data.warp_disallowed || $game_temp.transition_processing
    transition_sprite = @spriteset.dispose(true)
    Graphics.sort_z
    # We restore the flag of the special transition
    $game_switches[Yuki::Sw::WRP_Transition] = wrp_anime
    # We play the specific transition if there's no transition sprite (fade out)
    transfer_player_specific_transition unless transition_sprite
    @spriteset.reload(zone)
    Scheduler.start(:on_warp_end)
    Yuki::ElapsedTime.show(:transfer_player, 'Transfering player took')
    # We reset the frame information so Graphics doesn't try to compensate lag from loading map data
    Graphics.frame_reset
    # We process the end of the transition (fade in)
    transfer_player_end(transition_sprite)
  end

  # End of the transfer player processing (transitions)
  def transfer_player_end(transition_sprite)
    if transition_sprite # We play BW transition if there's a sprite
      Yuki::Transitions.bw_zoom(transition_sprite)
      $game_map.autoplay
    elsif (transition_id = $game_variables[::Yuki::Var::MapTransitionID]) > 0
      $game_variables[::Yuki::Var::MapTransitionID] = 0
      Graphics.brightness = 255
      $game_map.autoplay
      case transition_id
      when 1 # Circular transition
        ::Yuki::Transitions.circular(1)
      when 2 # Directed transition
        ::Yuki::Transitions.directed(1)
      end
      $game_temp.transition_processing = false
    elsif $game_temp.transition_processing
      $game_map.autoplay
      $game_temp.transition_processing = false
      Graphics.transition(20)
    else
      $game_map.autoplay
    end
  end

  # Start a specific transition
  def transfer_player_specific_transition
    if (transition_id = $game_variables[::Yuki::Var::MapTransitionID]) > 0
      Graphics.transition(1) if $game_temp.transition_processing
      case transition_id
      when 1 # Circular transition
        ::Yuki::Transitions.circular
      when 2 # Directed transition
        ::Yuki::Transitions.directed
      end
      Graphics.brightness = 0
      Graphics.wait(15)
    end
  end
end
