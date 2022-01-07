class Game_Character
  # @return [Integer, false] if the character is in swamp tile and the power of the swamp tile
  attr_accessor :in_swamp
  # @return [Boolean] if the character is a Pokemon (affect the step anime)
  attr_accessor :is_pokemon
  # @return [Boolean] tell if the character can make footprint on the ground or not
  attr_accessor :can_make_footprint
  
  # is the character moving ?
  # @return [Boolean]
  def moving?
    return (@real_x != @x * 128 || @real_y != @y * 128)
  end

  # is the character jumping ?
  # @return [Boolean]
  def jumping?
    return @jump_count > 0
  end

  # Is the character able to execute a move action
  def movable?
    !(moving? || jumping?)
  end

  # Set the Game_Character in the "surfing" mode (not able to walk on ground but able to walk on water)
  # @author Nuri Yuri
  def set_surfing
    change_shadow_disabled_state(true)
    @surfing = true
  end

  # Check if the Game_Character is in the "surfing" mode
  # @return [Boolean]
  # @author Nuri Yuri
  def surfing?
    return @surfing
  end

  # Check if the Game_Character slides
  # @return [Boolean]
  # @author Nuri Yuri
  def sliding?
    return @sliding
  end

  # Make the character look the player during a dialog
  def lock
    return if @locked
    # Store the old direction
    @prelock_direction = @direction
    # Make it look to the player
    turn_toward_player
    # Store the state
    @locked = true
  end

  # Is the character locked ? (looking to the player when it's activated)
  # @note in this state, the character is not able to perform automatic moveroute (rmxp conf)
  # @return [Boolean]
  def lock?
    return @locked
  end

  # Release the character, can perform its natural movements
  def unlock
    return unless @locked
    # Store the state
    @locked = false
    # We don't change the direction if it's a fix direction
    return if @direction_fix
    # We change the direction if the prelock direction is not zero
    @direction = @prelock_direction unless @prelock_direction == 0
  end

  # current terrain tag on which the character steps
  # @return [Integer, nil]
  def terrain_tag
    return $game_map.terrain_tag(@x, @y)
  end

  # Return the SystemTag where the Game_Character stands
  # @return [Integer] ID of the SystemTag
  # @author Nuri Yuri
  def system_tag
    return $game_map.system_tag(@x,@y)
  end
end