class Game_Character
  # Update the Game_Character (manages movements and some animations)
  def update
    if jumping?
      update_jump
    elsif moving?
      update_move
    elsif @sliding
      update_sliding
    else
      update_stop
    end

    update_pattern

    return if @sliding
    return @wait_count -= 1 if @wait_count > 0 # or follower_sliding?
    return move_type_path if @path # Needs to have priority over move_type_custom
    return move_type_custom if @move_route_forcing
    return if @starting || lock?
    return unless @stop_count > @max_stop_count

    # Automatic movement
    case @move_type
    when 1
      move_type_random
    when 2
      move_type_toward_player
    when 3
      move_type_custom
    end
  end

  private

  # Update the pattern animation
  def update_pattern
    return if update_charset_animation
    return unless @anime_count > 18 - @move_speed * 2
    if (!@step_anime && @stop_count > 0) || @sliding
      @pattern = @original_pattern
      @pattern_state = false
    elsif @is_pokemon
      @pattern = (@pattern + 1) % 4
    else
      if @step_anime
        @pattern = (@pattern + 1) % 4
      else
        @pattern += (@pattern_state ? -1 : 1)
      end
      @pattern_state = true if @pattern == 3
      @pattern_state = false if @pattern <= 1
    end
    @anime_count = 0
  end

  # Update the pattern state
  def update_pattern_state
    @pattern_state = true if @pattern == 3
    @pattern_state = false if @pattern <= 1
  end

  # Update of the jump animation
  def update_jump
    @jump_count -= 1
    @real_x = ((@real_x * @jump_count + @x * 128) / (@jump_count + 1))
    @real_y = ((@real_y * @jump_count + @y * 128) / (@jump_count + 1))
    return if @jump_count > 0
    # Fix pattern and push dust particle
    @pattern = 0
    Scheduler::EventTasks.trigger(:end_jump, self)
  end

  # Update of the move animation
  def update_move
    was_moving = moving?
    update_real_position
    update_slope_offset_y
    # Update the anime_count for the pattern animation
    if @walk_anime
      @anime_count += 1.5
    elsif @step_anime
      @anime_count += 1
    end
    Scheduler::EventTasks.trigger(:end_step, self) if was_moving && !moving?
  end

  # Update the real_x/y positions
  def update_real_position
    distance = 2**move_speed
    @real_y = [@real_y + distance, @y * 128].min if @y * 128 > @real_y
    @real_x = [@real_x - distance, @x * 128].max if @x * 128 < @real_x
    @real_x = [@real_x + distance, @x * 128].min if @x * 128 > @real_x
    @real_y = [@real_y - distance, @y * 128].max if @y * 128 < @real_y
  end

  # Update the slope offset y if there is one
  def update_slope_offset_y
    @slope_offset_y = @slope_origin_x ? 32 * (@real_x - @slope_origin_x).abs / @slope_length : nil if @slope_origin_x
  end

  # Update no movement animation (triggers movement when staying on specific SystemTag)
  def update_stop
    if @step_anime
      @anime_count += 1
    elsif @pattern != @original_pattern
      @anime_count += 1.5
    end
    # unless false #@starting or lock? # Moving PNJ fix
    @stop_count += 1
    # end

    # Force the event to move down if it is on a tile that require the Mach Bike to go up
    move_down if system_tag == MachBike && !($game_switches[::Yuki::Sw::EV_Bicycle] && @lastdir4 == 8)
  end

  # SystemTags that forces the Game_Character to move
  RapidsTag = [RapidsL, RapidsU, RapidsD, RapidsR]
  # System tag that force the player to move regardless if the system tag in front
  ROCKET_TAGS = [RocketL, RocketU, RocketD, RocketR, RocketRL, RocketRU, RocketRD, RocketRR]
  # List of translations for system tag movement
  SLIDE_TAG_TO_MOVEMENT = {
    TIce => :move_forward, RapidsL => :move_left, RapidsR => :move_right, RapidsU => :move_up, RapidsD => :move_down,
    RocketL => :move_left, RocketU => :move_up, RocketD => :move_down, RocketR => :move_right,
    RocketRL => :move_left, RocketRU => :move_up, RocketRD => :move_down, RocketRR => :move_right,
    MachBike => :move_down
  }
  # System tags that rotate the player
  ROTATING_SLIDING_TAGS = [RocketRL, RocketRU, RocketRD, RocketRR]
  # Update when the Game_Character slides
  def update_sliding
    return stop_slide unless can_slide?

    sys_tag = system_tag
    unless moving?
      direction = @direction
      movement = SLIDE_TAG_TO_MOVEMENT[sys_tag] || (ROCKET_TAGS.include?(@sliding_parameter) && SLIDE_TAG_TO_MOVEMENT[@sliding_parameter])
      send(*movement) if movement
      if RapidsTag.include?(sys_tag) && $game_switches[::Yuki::Sw::EV_TurnRapids] || ROTATING_SLIDING_TAGS.include?(@sliding_parameter)
        @direction = direction
        turn_left_90
      end
    end

    update_move
  end

  # Function that completely sto
  def stop_slide
    @sliding = false
    Scheduler::EventTasks.trigger(:end_slide, self)
  end

  # Function that tells if the character can slide
  # @return [Boolean]
  def can_slide?
    ROCKET_TAGS.include?(@sliding_parameter) || SlideTags.include?(sys_tag = system_tag) || sys_tag == MachBike
  end

  # Random movement (when Event is on "Move random")
  def move_type_random
    # 乱数 0～5 で分岐
    case rand(6)
    when 0..3  # ランダム
      move_random
    when 4  # 一歩前進
      move_forward
    when 5  # 一時停止
      @stop_count = 0
    end
  end

  # Move toward player with some randomness
  def move_type_toward_player
    # プレイヤーの座標との差を求める
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    # 差の絶対値を求める
    abs_sx = sx > 0 ? sx : -sx
    abs_sy = sy > 0 ? sy : -sy
    # 縦横あわせて 20 タイル以上離れている場合
    if abs_sx + abs_sy >= 20
      # ランダム
      move_random
      return
    end
    # 乱数 0～5 で分岐
    case rand(6)
    when 0..3 # プレイヤーに近づく
      move_toward_player
    when 4  # ランダム
      move_random
    when 5  # 一歩前進
      move_forward
    end
  end

  # Move on a specified route
  def move_type_custom
    return unless movable?
    while @move_route_index < @move_route.list.size
      command = @move_route.list[@move_route_index]
      break if move_type_custon_exec_command(command)
    end
  end

  # Execute a move route command
  # @param command [RPG::MoveCommand]
  # @return [Boolean] if the loop calling the method should break
  def move_type_custon_exec_command(command)
    if command.code == 0
      move_type_custom_end
      return true
    end
    # Real movements (including moved check)
    if command.code <= 14
      move_type_custom_move(command)
      return true
    end
    # Wait command
    if command.code == 15
      @wait_count = command.parameters[0] * 2 - 1
      @move_route_index += 1
      return true
    end
    # Turn commands
    if command.code.between?(16, 26)
      move_type_custom_turn(command)
      return true
    end
    # Special commands
    @move_type_custom_special_result = false
    move_type_custom_special(command)
    return @move_type_custom_special_result
  end

  # When the command is 0 we reached the end and we loop back if the repeat mode is on
  def move_type_custom_end
    if @move_route&.repeat
      @move_route_index = 0
    else
      # Restore the original move route
      if @move_route_forcing # && !@move_route.repeat <= it's actually the case
        @move_route_forcing = false
        @move_route = @original_move_route
        @move_route_index = @original_move_route_index
        @original_move_route = nil
      end
      @stop_count = 0
    end
  end

  # When the command is a real move command
  # @param command [RPG::MoveCommand]
  def move_type_custom_move(command)
    case command.code
    when 1
      move_down
    when 2
      move_left
    when 3
      move_right
    when 4
      move_up
    when 5
      move_lower_left
    when 6
      move_lower_right
    when 7
      move_upper_left
    when 8
      move_upper_right
    when 9
      move_random
    when 10
      move_toward_player
    when 11
      move_away_from_player
    when 12
      move_forward
    when 13
      move_backward
    when 14
      jump(command.parameters[0], command.parameters[1])
    end
    move_type_custom_move_update_index
  end

  # Update the move_route_index if the character moved or can skip undoable route
  def move_type_custom_move_update_index
    return unless @move_route&.skippable || moving? || jumping?
    @move_route_index += 1
  end

  # When the move command is a turn command
  # @param command [RPG::MoveCommand]
  def move_type_custom_turn(command)
    case command.code
    when 16
      turn_down
    when 17
      turn_left
    when 18
      turn_right
    when 19
      turn_up
    when 20
      turn_right_90
    when 21
      turn_left_90
    when 22
      turn_180
    when 23
      turn_right_or_left_90
    when 24
      turn_random
    when 25
      turn_toward_player
    when 26
      turn_away_from_player
    end
    @move_route_index += 1
  end

  # When the move command is a special command
  # @param command [RPG::MoveCommand]
  def move_type_custom_special(command)
    case command.code
    when 27
      $game_switches[command.parameters[0]] = true
      $game_map.need_refresh = true
    when 28
      $game_switches[command.parameters[0]] = false
      $game_map.need_refresh = true
    when 29
      @move_speed = command.parameters[0]
    when 30
      self.move_frequency = command.parameters[0]
    when 31
      @walk_anime = true
    when 32
      @walk_anime = false
    when 33
      @step_anime = true
    when 34
      @step_anime = false
    when 35
      @direction_fix = true
    when 36
      @direction_fix = false
    when 37
      @through = true
    when 38
      @through = false
    when 39
      @always_on_top = true
    when 40
      @always_on_top = false
    when 41
      @tile_id = 0
      set_appearance(command.parameters[0], command.parameters[1])
      if @original_direction != command.parameters[2]
        @direction = command.parameters[2]
        @original_direction = @direction
        @prelock_direction = 0
      end
      if @original_pattern != command.parameters[3]
        @pattern = command.parameters[3]
        @original_pattern = @pattern
      end
    when 42
      @opacity = command.parameters[0]
    when 43
      @blend_type = command.parameters[0]
    when 44
      $game_system.se_play(command.parameters[0])
    when 45
      eval_script(command.parameters[0])
    end
    @move_route_index += 1
  end

  # Function that execute a script
  # @param script [String]
  def eval_script(script)
    last_eval = Yuki::EXC.get_eval_script
    script = script.force_encoding('UTF-8').gsub(/\n([(,])/, "\\1\n")
    Yuki::EXC.set_eval_script(script)
    eval(script)
  rescue StandardError => e
    Yuki::EXC.run(e)
  ensure
    Yuki::EXC.set_eval_script(last_eval)
  end

  public

  # Increase step prototype (sets @stop_count to 0)
  def increase_steps
    @stop_count = 0
  end

  def process_slope_y_modifier(y_modifier)
    @y += y_modifier
    @real_y = @y * 128
    update_slope_offset_y
  end
end
