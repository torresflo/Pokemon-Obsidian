# Interpreter of the event script commands
class Interpreter < Interpreter_RMXP
  # Detect if the event can spot the player and move to the player
  # @param nb_pas [Integer] number of step the event should do to spot the player
  # @return [Boolean] if the event spot the player or not
  # @example To detect the player 7 tiles in front of the event, put in a condition :
  #   player_spotted?(7)
  # @author Nuri Yuri
  def player_spotted?(nb_pas)
    return false if $game_switches[Yuki::Sw::Env_Detection]
    c = $game_map.events[@event_id]
    # Detect if the player is too far away from the event
    return false if (c.x - $game_player.x).abs > nb_pas || (c.y - $game_player.y).abs > nb_pas
    return false if c.z != $game_player.z # Prevent detection when event & player arent both on a bridge
    x = c.x
    y = c.y
    d = c.direction
    new_x = (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = (d == 2 ? 1 : d == 8 ? -1 : 0)
    result = false
    # Detect if the player is right in front of the event
    result = true if $game_player.x == (x + new_x) && $game_player.y == (y + new_y)
    # Detect the player by simulating walking
    unless result
      0.upto(nb_pas) do
        if c.passable?(x, y, d, true)
          break(result = true) if $game_player.x == x && $game_player.y == y
        else
          result = true if $game_player.x == x && $game_player.y == y
          break
        end
        x += new_x
        y += new_y
      end
    end
    # Detect if the player triggered the event from Action key
    result ||= (Input.trigger?(:A) && $game_player.front_tile_event == c)
    # Stop the player from Running
    if result
      $game_switches[::Yuki::Sw::EV_Run] = false
      $game_temp.common_event_id = Game_CommonEvent::APPEARANCE
    end
    return result
  end
  alias trainer_spotted player_spotted?

  # Detect if the event can spot the player and move to the player with direction relative detection
  # @param up [Integer] number of step to the up direction
  # @param down [Integer] number of step to the down direction
  # @param left [Integer] number of step to the left direction
  # @param right [Integer] number of step to the right direction
  # @example The event turn left and bottom but does not have the same vision when turned bottom
  #   player_spotted_directional?(left: 7, bottom: 3)
  # @return [Boolean] if the event spotted the player
  def player_spotted_directional?(up: nil, down: nil, left: nil, right: nil)
    case $game_map.events[@event_id].direction
    when 2
      return player_spotted?(down || up || left || right || 1)
    when 8
      return player_spotted?(up || down || left || right || 1)
    when 4
      return player_spotted?(left || right || up || down || 1)
    when 6
      return player_spotted?(right || left || up || down || 1)
    end
    return false
  end

  # Detect the player in a specific direction
  # @param nb_pas [Integer] the number of step between the event and the player
  # @param direction [Symbol, Integer] the direction : :right, 6, :down, 2, :left, 4, :up or 8
  # @return [Boolean]
  # @author Nuri Yuri
  def detect_player(nb_pas, direction)
    return false if $game_switches[Yuki::Sw::Env_Detection]
    c = $game_map.events[@event_id]
    dx = $game_player.x - c.x
    dy = $game_player.y - c.y
    case direction
    when :right, 6
      return (dy == 0 && dx >= 0 && dx <= nb_pas)
    when :down, 2
      return (dx == 0 && dy >= 0 && dy <= nb_pas)
    when :left, 4
      return (dy == 0 && dx <= 0 && dx >= -nb_pas)
    else
      return (dx == 0 && dy <= 0 && dy >= -nb_pas)
    end
  end

  # Detect the player in a rectangle around the event
  # @param nx [Integer] the x distance of detection between the event and the player
  # @param ny [Integer] the y distance of detection between the event and the player
  # @return [Boolean]
  # @author Nuri Yuri
  def detect_player_rect(nx, ny)
    return false if $game_switches[Yuki::Sw::Env_Detection]
    c = $game_map.events[@event_id]
    dx = ($game_player.x - c.x).abs
    dy = ($game_player.y - c.y).abs
    return (dx <= nx && dy <= ny)
  end

  # Detect the player in a circle around the event
  # @param r [Numeric] the square radius (r = R²) of the circle around the event
  # @return [Boolean]
  # @author Nuri Yuri
  def detect_player_circle(r)
    return false if $game_switches[Yuki::Sw::Env_Detection]
    c = $game_map.events[@event_id]
    dx = $game_player.x - c.x
    dy = $game_player.y - c.y
    return ((dx * dx) + (dy * dy)) <= r
  end

  # Delete the current event forever
  def delete_this_event_forever
    $env.set_event_delete_state(@event_id)
    $game_map.events[@event_id]&.erase
  end

  # Wait for the end of the movement of this particular character
  # @param event_id [Integer] <default : calling event's> the id of the event to watch
  def wait_character_move_completion(event_id = @event_id)
    @move_route_waiting = true
    @move_route_waiting_id = event_id
  end
  alias attendre_fin_deplacement_cet_event wait_character_move_completion
  alias wait_event wait_character_move_completion
  alias attendre_event wait_character_move_completion
  
  # Detect if a specified tile (in layer 3) is in the specified zone
  # @param x [Integer] the coordinate x of the zone
  # @param y [Integer] the coordinate y of the zone
  # @param width [Integer] the width of the zone
  # @param height [Integer] the height of the zone
  # @param tile_id [Integer] the tile's id in the tileset
  # @return [Boolean] "true" if the tile is detected in the zone, else "false"
  # @example To detect if there is non-cracked ice floor tile in a zone going from
  #      X = 15 (included) to 24 and Y = 10 (included) to 15, you have to write : 
  #      detect_invalid_tile(15, 10, 10, 6, 394)
  #      To calculate tile_id the formula is this one : 384 + tileset_x + tileset_y * 8
  #      For example : the tile is the third of the second line we then have tileset_x = 2, tileset_y = 1 which gives 394.
  def detect_invalid_tile(x, y, width, height, tile_id)
    ox = Yuki::MapLinker.get_OffsetX
    oy = Yuki::MapLinker.get_OffsetY
    rangex = (x + ox)...(x + ox + width)
    rangey = (y + oy)...(y + oy + height)
    gm = $game_map
    return rangex.any? { |tx| rangey.any? { |ty| gm.get_tile(tx, ty) == tile_id } }
  end

end
