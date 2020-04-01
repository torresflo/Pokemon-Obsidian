class Game_Character
  # Move Game_Character down
  # @param turn_enabled [Boolean] if the Game_Character turns when impossible move
  def move_down(turn_enabled = true)
    turn_down if turn_enabled
    if passable?(@x, @y, 2)
      if $game_map.system_tag(@x, @y + 1) == JumpD
        jump(0, 2, false)
        return follower_move
      end
      turn_down
      bridge_down_check(@z)
      @y += 1
      movement_process_end
      increase_steps
    else
      @sliding = false
      check_event_trigger_touch(@x, @y + 1)
    end
  end

  # Move Game_Character left
  # @param turn_enabled [Boolean] if the Game_Character turns when impossible move
  def move_left(turn_enabled = true)
    turn_left if turn_enabled
    return if stair_move_left
    y_modifier = slope_check_left
    if passable?(@x, @y + y_modifier, 4)
      if $game_map.system_tag(@x - 1, @y + y_modifier) == JumpL
        jump(-2, 0, false)
        return follower_move
      end
      turn_left
      bridge_left_check(@z)
      @x -= 1
      movement_process_end
      if y_modifier != 0
        @memorized_move = :move_toward
        @memorized_move_arg = [@x, @y]
        process_slope_y_modifier(y_modifier)
      end
      increase_steps
    else
      @sliding = false
      check_event_trigger_touch(@x - 1, @y + y_modifier)
    end
  end

  # Try to move the Game_Character on a stair to the left
  # @return [Boolean] if the player cannot perform a regular movement (success or blocked)
  def stair_move_left
    # unless @through
    if front_system_tag == StairsL
      return true unless $game_map.system_tag(@x - 1, @y - 1) == StairsL
      move_upper_left
      return true
    elsif system_tag == StairsR
      move_lower_left
      return true
    end
    # end
    return false
  end

  # Update the slope values when moving to left
  def slope_check_left(write = true)
    # No slope move check if no slope involved
    front_sys_tag = front_system_tag
    return 0 unless (sys_tag = system_tag) == SlopesL || sys_tag == SlopesR ||
                  front_sys_tag == SlopesL || front_sys_tag == SlopesR

    # Begining of Left up slope
    if sys_tag != SlopesL && front_sys_tag == SlopesL
      if write
        @slope_length = 0
        nx = @x - 1
        ny = @y
        while $game_map.system_tag(nx, ny) == SlopesL
          nx -= 1
          @slope_length += 1
        end
        # Prepare the data
        @slope_origin_x = @real_x
        @slope_length *= -128 # display_length conversion
      end
    
    # End of the left up slope
    elsif sys_tag == SlopesL && front_sys_tag != SlopesL
      @slope_offset_y = @slope_origin_x = @slope_length = nil if passable?(@x, @y - 1, 4) && write
      return -1

    # Start to go down the right slope
    elsif sys_tag != SlopesR && front_sys_tag == SlopesR
      return 1 unless passable?(@x, @y + 1, 4)

      if write
        @slope_length = 0
        nx = @x - 1
        ny = @y + 1
        while $game_map.system_tag(nx, ny) == SlopesR
          nx -= 1
          @slope_length += 1
        end
        # Prepare data
        @slope_origin_x = (nx + 1) * 128 # Begin at next tile
        @slope_length *= -128
      end
      return 1

    # End of the slope left down
    elsif sys_tag == SlopesR && front_sys_tag != SlopesR
      @slope_offset_y = @slope_origin_x = @slope_length = nil if write
    end
    return 0
  end

  # Move Game_Character right
  # @param turn_enabled [Boolean] if the Game_Character turns when impossible move
  def move_right(turn_enabled = true)
    turn_right if turn_enabled
    return if stair_move_right
    y_modifier = slope_check_right
    if passable?(@x, @y + y_modifier, 6)
      if $game_map.system_tag(@x + 1, @y) == JumpR
        return (jump(2, 0, false) ? follower_move : nil)
      end
      turn_right
      bridge_right_check(@z)
      @x += 1
      movement_process_end
      if y_modifier != 0
        @memorized_move = :move_toward
        @memorized_move_arg = [@x, @y]
        process_slope_y_modifier(y_modifier)
      end
      increase_steps
    else
      @sliding = false
      check_event_trigger_touch(@x + 1, @y + y_modifier)
    end
  end

  # Try to move the Game_Character on a stair to the right
  # @return [Boolean] if the player cannot perform a regular movement (success or blocked)
  def stair_move_right
    # unless @through
    if system_tag == StairsL
      move_lower_right
      return true
    elsif front_system_tag == StairsR
      return true unless $game_map.system_tag(@x + 1, @y - 1) == StairsR
      move_upper_right
      return true
    end
    # end
    return false
  end

  # Update the slope values when moving to right, and return y slope modifier
  # @return [Integer]
  def slope_check_right(write = true)
    # No slope move check if no slope involved
    front_sys_tag = front_system_tag
    return 0 unless (sys_tag = system_tag) == SlopesL || sys_tag == SlopesR ||
                  front_sys_tag == SlopesL || front_sys_tag == SlopesR

    # Begining of Right up slope
    if sys_tag != SlopesR && front_sys_tag == SlopesR
      if write
        @slope_length = 0
        nx = @x + 1
        ny = @y
        while $game_map.system_tag(nx, ny) == SlopesR
          nx += 1
          @slope_length += 1
        end
        # Prepare the data
        @slope_origin_x = @real_x
        @slope_length *= -128 # display_length conversion
      end
    
    # End of the right up slope
    elsif sys_tag == SlopesR && front_sys_tag != SlopesR
      @slope_offset_y = @slope_origin_x = @slope_length = nil if passable?(@x, @y - 1, 6) && write
      return -1

    # Start to go down the left slope
    elsif sys_tag != SlopesL && front_sys_tag == SlopesL
      return 1 unless passable?(@x, @y + 1, 6)

      if write
        @slope_length = 0
        nx = @x + 1
        ny = @y + 1
        while $game_map.system_tag(nx, ny) == SlopesL
          nx += 1
          @slope_length += 1
        end
        # Prepare data
        @slope_origin_x = (nx - 1) * 128 # Begin at next tile
        @slope_length *= -128
      end
      return 1

    # End of the slope left down
    elsif sys_tag == SlopesL && front_sys_tag != SlopesL
      @slope_offset_y = @slope_origin_x = @slope_length = nil if write
    end
    return 0
  end

  # Move Game_Character up
  # @param turn_enabled [Boolean] if the Game_Character turns when impossible move
  def move_up(turn_enabled = true)
    turn_up if turn_enabled
    if passable?(@x, @y, 8)
      if $game_map.system_tag(@x, @y - 1) == JumpU
        return (jump(0, -2, false) ? follower_move : nil)
      end
      turn_up
      bridge_up_check(@z)
      @y -= 1
      movement_process_end
      increase_steps
    else
      @sliding = false
      check_event_trigger_touch(@x, @y-1)
    end
  end

  # Move the Game_Character lower left
  def move_lower_left
    unless @direction_fix
      @direction = (@direction == 6 ? 4 : @direction == 8 ? 2 : @direction)
    end
    if (passable?(@x, @y, 2) && passable?(@x, @y + 1, 4)) ||
       (passable?(@x, @y, 4) && passable?(@x - 1, @y, 2)) # 8 a la place de 2 sur les deux lignes
      move_follower_to_character
      @x -= 1
      @y += 1
      if @follower && $game_variables[Yuki::Var::FM_Sel_Foll] == 0
        @memorized_move = :move_lower_left
        @follower.direction = @direction
      end
      movement_process_end(true)
      increase_steps
    end
  end

  # Move the Game_Character lower right
  def move_lower_right
    unless @direction_fix
      @direction = (@direction == 4 ? 6 : @direction == 8 ? 2 : @direction)
    end
    if (passable?(@x, @y, 2) && passable?(@x, @y + 1, 6)) ||
       (passable?(@x, @y, 6) && passable?(@x + 1, @y, 2))
      move_follower_to_character
      @x += 1
      @y += 1
      if @follower && $game_variables[Yuki::Var::FM_Sel_Foll] == 0
        @memorized_move = :move_lower_right
        @follower.direction = @direction
      end
      movement_process_end(true)
      increase_steps
    end
  end

  # Move the Game_Character upper left
  def move_upper_left
    unless @direction_fix
      @direction = (@direction == 6 ? 4 : @direction == 2 ? 8 : @direction)
    end
    if (passable?(@x, @y, 8) && passable?(@x, @y - 1, 4)) ||
       (passable?(@x, @y, 4) && passable?(@x - 1, @y, 8))
      move_follower_to_character
      @x -= 1
      @y -= 1
      if @follower && $game_variables[Yuki::Var::FM_Sel_Foll] == 0
        @memorized_move = :move_upper_left
        @follower.direction = @direction
      end
      movement_process_end(true)
      increase_steps
    end
  end

  # Move the Game_Character upper right
  def move_upper_right
    unless @direction_fix
      @direction = (@direction == 4 ? 6 : @direction == 2 ? 8 : @direction)
    end
    if (passable?(@x, @y, 8) && passable?(@x, @y - 1, 6)) ||
       (passable?(@x, @y, 6) && passable?(@x + 1, @y, 8))
      move_follower_to_character
      @x += 1
      @y -= 1
      if @follower && $game_variables[Yuki::Var::FM_Sel_Foll] == 0
        @memorized_move = :move_upper_right
        @follower.direction = @direction
      end
      movement_process_end(true)
      increase_steps
    end
  end

  # Move the Game_Character to a random direction
  def move_random
    case rand(4)
    when 0
      move_down(false)
    when 1
      move_left(false)
    when 2
      move_right(false)
    when 3
      move_up(false)
    end
  end

  # Move the Game_Character toward the player
  def move_toward_player
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    return if sx == 0 && sy == 0

    abs_sx = sx.abs
    abs_sy = sy.abs
    if abs_sx == abs_sy
      rand(2) == 0 ? abs_sx += 1 : abs_sy += 1
    end

    if abs_sx > abs_sy
      sx > 0 ? move_left : move_right
      unless moving? || sy == 0
        sy > 0 ? move_up : move_down
      end
    else
      sy > 0 ? move_up : move_down
      unless moving? || sx == 0
        sx > 0 ? move_left : move_right
      end
    end
  end

  # Move the Game_Character away from the player
  def move_away_from_player
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    return if sx == 0 && sy == 0

    abs_sx = sx.abs
    abs_sy = sy.abs
    if abs_sx == abs_sy
      rand(2) == 0 ? abs_sx += 1 : abs_sy += 1
    end

    if abs_sx > abs_sy
      sx > 0 ? move_right : move_left
      unless moving? || sy == 0
        sy > 0 ? move_down : move_up
      end
    else
      sy > 0 ? move_down : move_up
      unless moving? || sx == 0
        sx > 0 ? move_right : move_left
      end
    end
  end

  def move_toward(tx, ty)
    sx = @x - tx
    sy = @y - ty
    return if sx == 0 && sy == 0

    abs_sx = sx.abs
    abs_sy = sy.abs
    if abs_sx == abs_sy
      rand(2) == 0 ? abs_sx += 1 : abs_sy += 1
    end

    if abs_sx > abs_sy
      sx > 0 ? move_left : move_right
      unless moving? || sy == 0
        sy > 0 ? move_up : move_down
      end
    else
      sy > 0 ? move_up : move_down
      unless moving? || sx == 0
        sx > 0 ? move_left : move_right
      end
    end
  end

  # Move the Game_Character forward
  def move_forward
    case @direction
    when 2
      move_down(false)
    when 4
      move_left(false)
    when 6
      move_right(false)
    when 8
      move_up(false)
    end
  end

  # Move the Game_Character backward
  def move_backward
    last_direction_fix = @direction_fix
    @direction_fix = true
    case @direction
    when 2  # 下
      move_up(false)
    when 4  # 左
      move_right(false)
    when 6  # 右
      move_left(false)
    when 8  # 上
      move_down(false)
    end
    @direction_fix = last_direction_fix
  end

  # Make the Game_Character jump
  # @param x_plus [Integer] the number of tile the Game_Character will jump on x
  # @param y_plus [Integer] the number of tile the Game_Character will jump on y
  # @param follow_move [Boolean] if the follower moves when the Game_Character starts jumping
  # @return [Boolean] if the character is jumping
  def jump(x_plus, y_plus, follow_move = true)
    jump_bridge_check(x_plus, y_plus)
    new_x = @x + x_plus
    new_y = @y + y_plus

    if (x_plus == 0 && y_plus == 0) || passable?(new_x, new_y, 0) ||
       ($game_switches[::Yuki::Sw::EV_AccroBike] && front_system_tag == AcroBike)
      straighten
      @x = new_x
      @y = new_y
      distance = Math.sqrt(x_plus * x_plus + y_plus * y_plus).round
      @jump_peak = 10 + distance - @move_speed
      @jump_count = @jump_peak * 2
      @stop_count = 0
      @pattern = (rand(2) == 0 ? 1 : 3) unless follow_move
      movement_process_end(true)
      if follow_move && @follower && $game_variables[Yuki::Var::FM_Sel_Foll] == 0 && (x_plus != 0 || y_plus != 0)
        follower_move
        @memorized_move = :jump
        @memorized_move_arg = [x_plus, y_plus]
      end
    end
    particle_push
    return @jump_count > 0
  end

  # Perform the bridge check for the jump operation
  # @param x_plus [Integer] the number of tile the Game_Character will jump on x
  # @param y_plus [Integer] the number of tile the Game_Character will jump on y
  def jump_bridge_check(x_plus, y_plus)
    return if x_plus == 0 && y_plus == 0
    if x_plus.abs > y_plus.abs
      x_plus < 0 ? turn_left : turn_right
      bridge_left_check(@z)
    else
      y_plus < 0 ? turn_up : turn_down
      bridge_down_check(@z)
    end
  end

  # SystemTags that triggers "sliding" state
  SlideTags = [TIce, RapidsL, RapidsR, RapidsU, RapidsD]

  # End of the movement process
  # @param no_follower_move [Boolean] if the follower should not move
  # @author Nuri Yuri
  def movement_process_end(no_follower_move = false)
    follower_move unless no_follower_move
    particle_push
    if SlideTags.include?(sys_tag = system_tag) ||
       (sys_tag == MachBike && !($game_switches[::Yuki::Sw::EV_Bicycle] && @lastdir4 == 8))
      @sliding = true
      Scheduler::EventTasks.trigger(:begin_slide, self)
    end
    z_bridge_check(sys_tag)
    detect_swamp
    if jumping?
      Scheduler::EventTasks.trigger(:begin_jump, self)
    elsif moving?
      Scheduler::EventTasks.trigger(:begin_step, self)
    end
  end
end
