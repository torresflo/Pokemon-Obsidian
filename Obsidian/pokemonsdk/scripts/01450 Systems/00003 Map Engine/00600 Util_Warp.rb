module Util
  # Module that hold a warping function
  # @author Nuri Yuri
  module Warp
    module_function

    # Warp to an event of another map (below by default)
    # @param map_id [Integer] ID of the map where to warp
    # @param name_or_id [Integer, String] name or ID of the event that will be found
    # @param transition_type [Integer] 0 = no transition, 1 = circular transition, 2 = directed transition, -1 = bw transition
    # @param offset_x [Integer] offset x to add to the warp x coordinate
    # @param offset_y [Integer] offset y to add to the warp y coordinate
    # @param direction [Integer] new direction of the player
    def to(map_id, name_or_id, transition_type = 0, offset_x: 0, offset_y: 1, direction: 0)
      x, y = find_event_from(map_id, name_or_id)
      setup_transition(transition_type) unless transition_type == 0
      warp(map_id, x + offset_x, y + offset_y, direction)
    end

    # Define the transition for the warping process
    # @param type [Integer] type of transition
    def setup_transition(type)
      if type < 0
        $game_switches[::Yuki::Sw::WRP_Transition] = true
      else
        $game_variables[::Yuki::Var::MapTransitionID] = type
      end
    end

    # Warp to the specified coordinate
    # @param map_id [Integer] ID of the map where to warp
    # @param x_pos [Integer] x coordinate where to warp
    # @param y_pos [Integer] y coordinate where to warp
    # @param direction [Integer] new direction of the player
    def warp(map_id, x_pos, y_pos, direction)
      $game_temp.player_new_x = x_pos
      $game_temp.player_new_y = y_pos
      $game_temp.player_new_direction = direction
      $game_temp.player_new_map_id = map_id
      $game_temp.player_transferring = true
    end

    # Find the event coordinate in another map
    # @param map_id [Integer] ID of the map where to warp
    # @param name_or_id [Integer, String] name or ID of the event that will be found
    # @return [Array<Integer>] x & y coordinate of the event in the other map
    def find_event_from(map_id, name_or_id)
      $game_map.setup(map_id) if $game_map.map_id != map_id
      if name_or_id.is_a?(Integer)
        event = $game_map.events[name_or_id]
      else
        event = $game_map.events_list.find { |event| event.event.name == name_or_id }
      end
      return 0, 0 unless event
      return event.x, event.y
    end
  end
end
