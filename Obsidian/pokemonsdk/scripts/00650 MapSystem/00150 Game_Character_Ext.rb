class Game_Character
  # Return tile position in front of the player
  # @return [Array(Integer, Integer)] the position x and y
  def front_tile
    xf = @x + (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
    yf = @y + (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
    return [xf, yf]
  end

  # Return the event that stand in the front of the Player
  # @return [Game_Event, nil]
  def front_tile_event
    xf = @x + (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
    yf = @y + (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
    $game_map.events.each_value do |event|
      return event if event.x == xf and event.y == yf
    end
    return nil
  end

  # Check a the #front_event has a specific name
  # @return [Boolean]
  # @author Nuri Yuri
  def front_name_check(name)
    return true if front_tile_event&.event&.name == name
    return false
  end
  alias front_name_detect front_name_check

  # Return the id of the #front_tile_event
  # @return [Integer, 0] 0 if no front_tile_event
  # @author Nuri Yuri
  def front_tile_id
    return front_tile_event&.event&.id.to_i
  end

  # Return the SystemTag in the front of the Game_Character
  # @return [Integer] ID of the SystemTag
  # @author Nuri Yuri
  def front_system_tag
    xf = @x + (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
    yf = @y + (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
    return $game_map.system_tag(xf,yf)
  end

  # Look directly to a specific event
  # @param event_id [Integer] id of the event on the Map
  # @author Nuri Yuri
  def look_to(event_id)
    return unless (event = $game_map.events[event_id])
    delta_x = event.x - @x
    delta_y = event.y - @y
    if delta_x.abs <= delta_y.abs
      if delta_y < 0
        turn_up
      else
        turn_down
      end
    else
      if delta_x < 0
        turn_left
      else
        turn_right
      end
    end
  end

  # Array of SystemTag that define stairs
  StairsTag = [StairsL, StairsD, StairsU, StairsR]

  # Dynamic move_speed value of the Game_Character, return a different value than @move_speed
  # @return [Integer] the dynamic move_speed
  # @author Nuri Yuri
  def move_speed
    return (@in_swamp == 1 ? 2 : 1) if @in_swamp
    move_speed = @move_speed
    if move_speed > 1
      direction = @direction
      sys_tag = system_tag
      if (direction == 6 && (sys_tag == StairsR || $game_map.system_tag(@x - 1, @y) == StairsL)) ||
         (direction == 4 && (sys_tag == StairsL || $game_map.system_tag(@x + 1, @y) == StairsR))
        move_speed -= 1
      elsif (direction == 2 || direction == 8) and (sys_tag == StairsU || sys_tag == StairsD)
        move_speed -= 1
      end
    end
    return move_speed
  end

  # Check if it's possible to have contact interaction with this Game_Character at certain coordinates
  # @param x [Integer] x position
  # @param y [Integer] y position
  # @param z [Integer] z position
  # @return [Boolean]
  # @author Nuri Yuri
  def contact?(x, y, z)
    return (@x == x and y == @y and (@z - z).abs <= 1)
  end

  # Detect if the event walks in a swamp or a deep swamp and change the Game_Character states.
  # @author Nuri Yuri
  def detect_swamp
    sys_tag = system_tag
    if sys_tag == SwampBorder
      change_shadow_disabled_state(true)
      @in_swamp = 1
    elsif sys_tag == DeepSwamp
      change_shadow_disabled_state(true)
      @in_swamp = 4 + (rand(2) == 0 ? 4 + rand(4) : 0)
    else
      change_shadow_disabled_state(false)
      @in_swamp = false
    end
  end
end
