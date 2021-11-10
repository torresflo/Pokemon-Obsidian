class Game_Character
  # SystemTags that trigger Surfing
  SurfTag = [TPond, TSea]
  # SystemTags that does not trigger leaving water
  SurfLTag = SurfTag + [BridgeUD, BridgeRL, RapidsL, RapidsR, RapidsU, RapidsD, AcroBikeRL, AcroBikeUD, WaterFall,
                        JumpD, JumpL, JumpR, JumpU]
  # Is the tile in front of the character passable ?
  # @param x [Integer] x position on the Map
  # @param y [Integer] y position on the Map
  # @param d [Integer] direction : 2, 4, 6, 8, 0. 0 = current position
  # @param skip_event [Boolean] if the function does not check events
  # @return [Boolean] if the front/current tile is passable
  def passable?(x, y, d, skip_event = false)
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    z = @z
    game_map = $game_map
    return false unless game_map.valid?(new_x, new_y) || instance_of?(Game_Character)

    # Case where the event can pass through anything
    if @through
      return true unless @sliding
      return true if $game_switches[::Yuki::Sw::ThroughEvent] # Event is sliding here
    end
    sys_tag = game_map.system_tag(new_x, new_y)
    return false unless passable_bridge_check?(x, y, d, new_x, new_y, z, game_map, sys_tag) &&
                        passage_surf_check?(sys_tag)

    return true if skip_event
    return false unless event_passable_check?(new_x, new_y, z, game_map)

    # Game Player check
    if $game_player.contact?(new_x, new_y, z)
      return false unless $game_player.through || @character_name.empty?
    end

    return false unless follower_check?(new_x, new_y, z)

    return true
  end

  # Check the bridge related passabilities
  # @param x [Integer] current x position
  # @param y [Integer] current y position
  # @param d [Integer] current direction
  # @param new_x [Integer] new x position
  # @param new_y [Integer] new y position
  # @param z [Integer] current z position
  # @param game_map [Game_Map] map object
  # @param sys_tag [Integer] current system_tag
  # @return [Boolean] if the tile is passable according to the bridge rules
  def passable_bridge_check?(x, y, d, new_x, new_y, z, game_map, sys_tag)
    bridge = @__bridge
    no_game_map = false
    if z > 1
      if bridge
        return false unless game_map.system_tag_here?(new_x, new_y, bridge[0]) ||
                            game_map.system_tag_here?(new_x, new_y, bridge[1]) ||
                            game_map.system_tag_here?(x, y, bridge[1])
      end
      case d
      when 2, 8
        no_game_map = true if sys_tag == BridgeUD
      when 4, 6
        no_game_map = true if sys_tag == BridgeRL
      end
    end
    return true if bridge || no_game_map
    return false unless game_map.passable?(x, y, d, self)
    return false unless game_map.passable?(new_x, new_y, 10 - d)
    return true
  end

  # Check the surf related passabilities
  # @param sys_tag [Integer] current system_tag
  # @return [Boolean] if the tile is passable according to the surf rules
  def passage_surf_check?(sys_tag)
    return false if !@surfing && SurfTag.include?(sys_tag)
    if @surfing
      return false unless SurfLTag.include?(sys_tag)
      return false if sys_tag == WaterFall
    end
    return true
  end

  # Check the passage related to events
  # @param new_x [Integer] new x position
  # @param new_y [Integer] new y position
  # @param z [Integer] current z position
  # @param game_map [Game_Map] map object
  # @return [Boolean] if the tile has no event that block the way
  def event_passable_check?(new_x, new_y, z, game_map)
    game_map.events.each_value do |event|
      next unless event.contact?(new_x, new_y, z)
      return false unless event.through
    end
    return true
  end

  # Check the passage related to events
  # @param new_x [Integer] new x position
  # @param new_y [Integer] new y position
  # @param z [Integer] current z position
  # @return [Boolean] if the tile has no event that block the way
  def follower_check?(new_x, new_y, z)
    unless Yuki::FollowMe.is_player_follower?(self) || self == $game_player
      Yuki::FollowMe.each_follower do |event|
        return false if event.contact?(new_x, new_y, z)
      end
    end
    return true
  end
end
