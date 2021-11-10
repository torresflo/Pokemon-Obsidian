class Game_Character
  # Remove the memorized moves of the follower
  # @author Nuri Yuri
  def reset_follower_move
    @memorized_move_arg = @memorized_move = nil if @memorized_move
    @follower&.reset_follower_move
  end

  # Move a follower
  # @author Nuri Yuri
  def follower_move
    return unless @follower
    return if @sliding && @follower.sliding && ROCKET_TAGS.include?(@sliding_parameter)
    return if $game_variables[Yuki::Var::FM_Sel_Foll] > 0 && @follower.class == Game_Character

    @follower.move_speed = @move_speed
    if @memorized_move
      @memorized_move_arg ? @follower.send(@memorized_move, *@memorized_move_arg) : @follower.send(@memorized_move)
      @memorized_move_arg = nil
      @memorized_move = nil
      return
    end
    x = @x - @follower.x
    y = @y - @follower.y
    d = @direction
    case d
    when 2
      if x < 0
        @follower.move_left
      elsif x > 0
        @follower.move_right
      elsif y > 1
        @follower.move_down
      elsif y == 0
        @follower.move_up
      end
    when 4
      if y < 0
        @follower.move_up
      elsif y > 0
        @follower.move_down
      elsif x < -1
        @follower.move_left
      elsif x == 0
        @follower.move_right
      end
    when 6
      if y < 0
        @follower.move_up
      elsif y > 0
        @follower.move_down
      elsif x > 1
        @follower.move_right
      elsif x == 0
        @follower.move_left
      end
    when 8
      if x < 0
        @follower.move_left
      elsif x > 0
        @follower.move_right
      elsif y < -1
        @follower.move_up
      elsif y == 0
        @follower.move_down
      end
    end
  end

  # Warp the follower to the event it follows
  # @author Nuri Yuri
  def move_follower_to_character
    return unless @follower
    return if $game_variables[Yuki::Var::FM_Sel_Foll] > 0
    @follower.move_follower_to_character # Fix left<->right stair issue but there's still a graphic glitch ^^'
    @follower.x = @x
    @follower.y = @y
    @follower.increase_steps
    @follower.update
  end

  # Check if the follower slides
  # @return [Boolean]
  # @author Nuri Yuri
  def follower_sliding?
    if @follower
      return @follower.follower_sliding? unless @follower.sliding?
      return true
    end
    return false
  end

  # Define the follower of the event
  # @param follower [Game_Character, Game_Event] the follower
  # @author Nuri Yuri
  def set_follower(follower)
    @follower = follower
  end

  # Return the tail of the following queue
  # @return [Game_Character, self]
  def follower_tail
    return self unless (current_follower = @follower)
    while (next_follower = current_follower.follower)
      current_follower = next_follower
    end
    return current_follower
  end

  # Rerturn the first follower that is a Game_Event in the queue
  # @return [Game_Event, nil]
  def next_event_follower
    f = @follower
    f = f.follower while !f.nil? && !f.is_a?(Game_Event)
    return f.is_a?(Game_Event) ? f : nil
  end

  def reset_follower
    return unless (current_follower = @follower)

    while (next_follower = current_follower.follower)
      current_follower.set_follower(nil)
      current_follower = next_follower
      break unless next_follower.is_a?(Game_Event)
    end
    # @follower = nil
    set_follower(nil)
  end
end
