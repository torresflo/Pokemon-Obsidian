# Class that describe and manipulate a Character (Player/Events)
class Game_Character
  include GameData::SystemTags
  # Id of the event in the map
  # @return [Integer]
  attr_reader :id
  # @return [Integer] X position of the event in the current map
  attr_accessor :x
  # @return [Integer] Y position of the event in the current map
  attr_accessor :y
  # @return [Integer] Z priority of the event
  attr_accessor :z
  # @return [Integer] "real" X position of the event, usually x * 128
  attr_reader :real_x
  # @return [Integer] "real" Y position of the event, usually y * 128
  attr_reader :real_y
  # @return [Integer] direction where the event is looking (2 = down, 6 = right, 4 = left, 8 = up)
  attr_accessor :direction
  # @return [Boolean] if the character is forced to move using a specific route
  attr_reader :move_route_forcing
  # @return [Boolean] if the character is traversable and it can walk through any tiles
  attr_accessor :through
  # @return [Integer] ID of the animation to play on the character
  attr_accessor :animation_id
  # @return [Integer] exponant of two added to the real_x/y when the event is moving
  attr_accessor :move_speed
  # @return [Game_Character, nil] the follower
  attr_reader :follower
  # @return [Boolean] if the character is sliding
  attr_reader :sliding
  # If the direction is fixed
  # @return [Boolean]
  attr_reader :direction_fix
  # If the character has reflection
  # @return [Boolean]
  attr_reader :reflection_enabled

  # Default initializer
  def initialize
    @id = 0
    @x = 0
    @y = 0
    @z = 1
    @real_x = 0
    @real_y = 0
    @tile_id = 0
    set_appearance(nil.to_s, 0)
    @opacity = 255
    @blend_type = 0
    @direction = 2
    @pattern = 0
    @move_route_forcing = false
    @through = false
    @animation_id = 0
    @transparent = false
    @original_direction = 2
    @original_pattern = 0
    @move_type = 0
    @move_speed = 4
    self.move_frequency = 6
    @move_route = nil
    @move_route_index = 0
    @original_move_route = nil
    @original_move_route_index = 0
    @walk_anime = true
    @step_anime = false
    @direction_fix = false
    @always_on_top = false
    @anime_count = 0
    @stop_count = 0
    @jump_count = 0
    @jump_peak = 0
    @wait_count = 0
    @slope_offset_y = 0
    @slope_y_modifier = 0
    @locked = false
    @prelock_direction = 0
    @surfing = false # Variable indiquant si le chara est sur l'eau
    @sliding = false # Variable indiquant si le chara slide
    @sliding_parameter = nil # Variable giving extra information for sliding
    @pattern_state = false # Indicateur de la direction du pattern
    @can_make_footprint = true
    @reflection_enabled = $game_player&.reflection_enabled 
  end

  # Set the move_frequency (and define the max_stop_count value)
  # @param value [Numeric]
  def move_frequency=(value)
    @move_frequency = value
    @max_stop_count = (40 - value * 2) * (6 - value)
  end

  # Adjust the character position
  def straighten
    if @walk_anime or @step_anime
      @pattern = 0
      @pattern_state = false
    end
    @anime_count = 0
    @prelock_direction = 0
  end

  # Force the character to adopt a move route and save the original one
  # @param move_route [RPG::MoveRoute]
  def force_move_route(move_route)
    if @original_move_route.nil?
      @original_move_route = @move_route
      @original_move_route_index = @move_route_index
    end
    @move_route = move_route
    @move_route_index = 0
    @move_route_forcing = true
    @prelock_direction = 0
    @wait_count = 0
    move_type_custom
  end

  # Warps the character on the Map to specific coordinates.
  # Adjust the z position of the character.
  # @param x [Integer] new x position of the character
  # @param y [Integer] new y position of the character
  def moveto(x, y)
    @x = x # % $game_map.width # Removed because of new tilemap
    @y = y # % $game_map.height
    @real_x = @x * 128
    @real_y = @y * 128
    @prelock_direction = 0
    # Warp the follower
    if @follower
      @follower.moveto(x, y)
      @follower.direction = @direction
    end
    # Update the stop count
    self.move_frequency = @move_frequency
    moveto_system_tag_manage
  end

  # Change the reflection of a Game_Character
  def reflection_enabled=(bool)
    @reflection_enabled = bool
  end

  private

  # Array used to detect if a character is on a bridge tile
  BRIDGE_TILES = [BridgeRL, BridgeUD]
  SLOPES_TILES = [SlopesL, SlopesR]
  # Manage the system_tag part of the moveto method
  def moveto_system_tag_manage(skip_bridges = false)
    # return @z = 1 if !@z && self == $game_player && $scene.class != Scene_Map
    sys_tag = system_tag
    unless skip_bridges
      if BRIDGE_TILES.include?(sys_tag)
        @z = $game_map.priorities[$game_map.get_tile(@x, @y)].to_i + 1
      elsif ZTag.include?(sys_tag)
        @z = ZTag.index(sys_tag)
      else
        @z = 1
      end
    end
    # Handle slope moveto
    if SLOPES_TILES.include?(sys_tag)
      @slope_length = -1 # the center tile is counter twice
      furthest_x = [@x, @x]
      [0, 2].each do |step_x| #-1 / +1
        nx = @x
        ny = @y
        while $game_map.system_tag(nx, ny) == sys_tag
          furthest_x[step_x / 2] = nx
          nx += (step_x - 1) # -1 / +1
          @slope_length += 1
        end
      end
      # Prepare the data
      if sys_tag == SlopesR
        @slope_origin_x = furthest_x[0] * 128
      else
        @slope_origin_x = furthest_x[1] * 128
      end
      @slope_length *= -128
      update_slope_offset_y
    end
    particle_push
  end

  public

  # Return the x position of the sprite on the screen
  # @return [Integer]
  def screen_x
    return (@real_x - $game_map.display_x + 3) / 4 + 16
  end

  # Return the y position of the sprite on the screen
  # @return [Integer]
  def screen_y
    y = (@real_y - $game_map.display_y + 3) / 4 + 32
    y += @offset_screen_y if @offset_screen_y
    y += @slope_offset_y if @slope_offset_y
    if @jump_count >= @jump_peak
      n = @jump_count - @jump_peak
    else
      n = @jump_peak - @jump_count
    end
    return y - (@jump_peak * @jump_peak - n * n) / 2
  end

  # Return the x position of the shadow of the character on the screen
  # @return [Integer]
  def shadow_screen_x
    return (@real_x - $game_map.display_x + 3) / 4 + 16
  end

  # Return the y position of the shadow of the character on the screen
  # @return [Integer]
  def shadow_screen_y
    return (@real_y - $game_map.display_y + 3) / 4 + 34 + (@offset_shadow_screen_y || 0) + (@slope_offset_y || 0) # +3 => +5
  end

  # Return the z superiority of the sprite of the character
  # @param _height [Integer] height of a frame of the character (ignored)
  # @return [Integer]
  def screen_z(_height = 0)
    return 999 if @always_on_top
    z = (@real_y - $game_map.display_y + 3) / 4 + 32 * @z
    return z + $game_map.priorities[@tile_id].to_i * 32 if @tile_id > 0
    return z + 31
    # return z + ((height > 64) ? 31 : 0)
  end

  # Define the function check_event_trigger_touch to prevent bugs
  def check_event_trigger_touch(*args); end

  # Check if the character is activate. Useful to make difference between event without active page and others.
  # @return [Boolean]
  def activated?
    true
  end
end
