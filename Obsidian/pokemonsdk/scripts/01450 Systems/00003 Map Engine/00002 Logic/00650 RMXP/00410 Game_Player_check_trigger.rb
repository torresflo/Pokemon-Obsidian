class Game_Player
  # Check if there's an event trigger on the tile where the player stands
  # @param triggers [Array<Integer>] the list of triggers to check
  # @return [Boolean]
  def check_event_trigger_here(triggers)
    return false if $game_system.map_interpreter.running?
    result = false
    z = @z
    $game_map.events.each_value do |event|
      y_modifier = (@direction == 4 ? slope_check_left(false) : @direction == 6 ? slope_check_right(false) : 0)
      next unless event.contact?(@x, @y + y_modifier, z) && triggers.include?(event.trigger)
      next unless !event.jumping? && event.over_trigger?
      event.start
      result = true
    end
    return result
  end

  # Check if there's an event trigger in front of the player (when he presses A)
  # @param triggers [Array<Integer>] the list of triggers to check
  # @return [Boolean]
  def check_event_trigger_there(triggers)
    return false if $game_system.map_interpreter.running?
    result = false
    d = @direction
    new_x = @x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = @y + (d == 2 ? 1 : d == 8 ? -1 : 0) + (@direction == 4 ? slope_check_left(false) : @direction == 6 ? slope_check_right(false) : 0)
    z = @z

    $game_map.events.each_value do |event|
      next unless event.contact?(new_x, new_y, z) && triggers.include?(event.trigger)
      next if event.jumping? || event.over_trigger?
      event.start
      result = true
    end
    z = @z
    return true if result

    # Try the event one tile after the front tile if it's a counter tile
    if $game_map.counter?(new_x, new_y)
      new_x2 = new_x + (d == 6 ? 1 : d == 4 ? -1 : 0)
      new_y2 = new_y + (d == 2 ? 1 : d == 8 ? -1 : 0)
      $game_map.events.each_value do |event|
        next unless event.contact?(new_x2, new_y2, z) && triggers.include?(event.trigger)
        next if event.jumping? || event.over_trigger?
        event.start
        result = true
      end
    end
    return true if result

    check_common_event_trigger_there(new_x, new_y, z, d)
    result ||= check_follower_trigger_there(new_x, new_y) if @follower
    return result
  end

  # Tile tha allow to use DIVE
  DIVE_TILE = [TSea, TUnderWater]
  # Check the common event call
  # @param new_x [Integer] the x position to check
  # @param new_y [Integer] the y position to check
  # @param z [Integer] the z of the event
  # @param d [Integer] the direction where to check
  def check_common_event_trigger_there(new_x, new_y, z, d)
    sys_tag = system_tag
    front_sys_tag = $game_map.system_tag(new_x, new_y)
    # Dive
    if terrain_tag == 6 && DIVE_TILE.include?(sys_tag)
      $game_temp.common_event_id = Game_CommonEvent::DIVE
    # Headbutt
    elsif front_sys_tag == HeadButt
      $game_temp.common_event_id = Game_CommonEvent::HEADBUTT
    # Surf
    elsif !@surfing && SurfTag.include?(front_sys_tag) && z <= 1 && $game_map.passable?(x, y, d, nil)
      if $game_map.passable?(new_x, new_y, 10 - d, self) || Yuki::MapLinker.passable?(new_x, new_y, 10 - d, nil)
        $game_temp.common_event_id = Game_CommonEvent::SURF_ENTER
      end
    end
  end

  # Check the follower common event call
  # @param new_x [Integer] the x position to check
  # @param new_y [Integer] the y position to check
  # @return [Boolean] if the trigger happened
  def check_follower_trigger_there(new_x, new_y)
    if @follower.x == new_x && @follower.y == new_y
      if @follower.is_a?(Game_Event)
        @follower.start
      else
        @follower.turn_toward_player
        $game_temp.common_event_id = Game_CommonEvent::FOLLOWER_SPEECH
      end
      return true
    end
    return false
  end

  # Check if the player touch an event and start it if so
  # @param x [Integer] the x position to check
  # @param y [Integer] the y position to check
  def check_event_trigger_touch(x, y)
    return false if $game_system.map_interpreter.running?
    result = false
    z = @z

    $game_map.events.each_value do |event|
      next unless event.contact?(x, y, z) && [1, 2].include?(event.trigger)
      next if event.jumping? || event.over_trigger?
      event.start
      result = true
    end
    return result
  end
end
