class Game_Character
  # Turn down unless direction fix
  def turn_down
    unless @direction_fix
      @direction = 2
      @stop_count = 0
    end
  end

  # Turn left unless direction fix
  def turn_left
    unless @direction_fix
      @direction = 4
      @stop_count = 0
    end
  end

  # Turn right unless direction fix
  def turn_right
    unless @direction_fix
      @direction = 6
      @stop_count = 0
    end
  end

  # Turn up unless direction fix
  def turn_up
    unless @direction_fix
      @direction = 8
      @stop_count = 0
    end
  end

  # Turn 90° to the right of the Game_Character
  def turn_right_90
    case @direction
    when 2
      turn_left
    when 4
      turn_up
    when 6
      turn_down
    when 8
      turn_right
    end
  end

  # Turn 90° to the left of the Game_Character
  def turn_left_90
    case @direction
    when 2
      turn_right
    when 4
      turn_down
    when 6
      turn_up
    when 8
      turn_left
    end
  end

  # Turn 180°
  def turn_180
    case @direction
    when 2
      turn_up
    when 4
      turn_right
    when 6
      turn_left
    when 8
      turn_down
    end
  end

  # Turn random right or left 90°
  def turn_right_or_left_90
    if rand(2) == 0
      turn_right_90
    else
      turn_left_90
    end
  end

  # Turn in a random direction
  def turn_random
    case rand(4)
    when 0
      turn_up
    when 1
      turn_right
    when 2
      turn_left
    when 3
      turn_down
    end
  end

  # Turn toward the player
  def turn_toward_player
    turn_toward_character($game_player)
  end

  # Turn toward another character
  # @param character [Game_Character]
  def turn_toward_character(character)
    sx = @x - character.x
    sy = @y - character.y
    return if sx == 0 && sy == 0
    if sx.abs > sy.abs
      sx > 0 ? turn_left : turn_right
    else
      sy > 0 ? turn_up : turn_down
    end
  end

  # Turn away from the player
  def turn_away_from_player
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    return if sx == 0 && sy == 0
    if sx.abs > sy.abs
      sx > 0 ? turn_right : turn_left
    else
      sy > 0 ? turn_down : turn_up
    end
  end
end