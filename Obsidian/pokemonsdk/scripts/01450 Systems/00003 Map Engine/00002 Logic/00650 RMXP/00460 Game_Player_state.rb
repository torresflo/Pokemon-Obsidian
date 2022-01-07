class Game_Player
  # @return [Hash] List of appearence suffix according to the state
  STATE_APPEARANCE_SUFFIX = {
    cycling: '_cycle_roll',
    cycle_stop: '_cycle_stop',
    roll_to_wheel: '_cycle_roll_to_wheel',
    wheeling: '_cycle_wheel',
    fishing: '_fish',
    surf_fishing: '_surf_fish',
    saving: '_pokecenter',
    using_skill: '_pokecenter',
    giving_pokemon: '_pokecenter',
    taking_pokemon: '_pokecenter',
    running: '_run',
    walking: '_walk',
    surfing: '_surf',
    swamp: '_swamp',
    swamp_running: '_swamp_run',
    sinking: '_deep_swamp_sinking'
  }
  # @return [Hash] List of movement speed, movement frequency according to the state
  STATE_MOVEMENT_INFO = {
    walking: [3, 4],
    running: [4, 4],
    wheeling: [4, 4],
    cycling: [5, 4],
    surfing: [4, 4]
  }
  # @return [Symbol, nil] the update_callback
  attr_reader :update_callback

  # Update the move_speed & move_frequency parameters
  # @param state [Symbol] the name of the state to fetch the move parameter
  def update_move_parameter(state)
    @move_speed, @move_frequency = STATE_MOVEMENT_INFO[state]
    # Make sure event gets the same speed as the player even if there is pokemons between them
    next_event_follower&.move_speed = @move_speed
  end

  # Enter in walking state (supports the swamp state)
  # @return [:walking] (It's used inside set_appearance_set when no state is defined)
  def enter_in_walking_state
    $game_switches[Yuki::Sw::EV_Run] = false if $game_switches
    @state = @in_swamp ? :swamp : :walking
    update_move_parameter(:walking)
    update_appearance(@pattern)
    return @state
  end

  # Enter in running state (supports the swamp state)
  def enter_in_running_state
    $game_switches[::Yuki::Sw::EV_Run] = true
    @state = @in_swamp ? :swamp_running : :running
    update_move_parameter(:running)
    update_appearance(@pattern)
  end

  # Enter in surfing state
  def enter_in_surfing_state
    @state = :surfing
    update_move_parameter(:surfing)
    update_appearance(@pattern)
  end

  # Leave the surfing state
  def leave_surfing_state
    change_shadow_disabled_state(false)
    @surfing = false
    return_to_previous_state
  end

  # Enter in the wheel state
  def enter_in_wheel_state
    @update_callback = :update_enter_wheel_state
    @update_callback_count = 0
    @state = :roll_to_wheel
    update_appearance(0)
  end

  # Callback called when we are entering in wheel state
  def update_enter_wheel_state
    @update_callback_count += 1
    return unless (@update_callback_count % 6) == 0
    @pattern += 1
    return unless @pattern > 3
    @state = :wheeling
    @update_callback = nil
    update_appearance(0)
  end

  # Leave the wheel state
  def leave_wheel_state
    @update_callback = :update_leave_wheel_state
    @update_callback_count = 0
    @state = :roll_to_wheel
    update_appearance(3)
  end

  # Callback called when we are leaving in wheel state
  def update_leave_wheel_state
    @update_callback_count += 1
    return unless (@update_callback_count % 6) == 0
    @pattern -= 1
    return unless @pattern < 0
    @state = :cycling
    @update_callback = nil
    update_appearance(0)
  end

  # Jump on the mach bike
  def enter_in_cycling_state
    $game_switches[::Yuki::Sw::EV_Bicycle] = true
    $game_switches[::Yuki::Sw::EV_AccroBike] = false
    self.on_acro_bike = false
    $game_map.need_refresh = true
    @state = moving? ? :cycling : :cycle_stop
    update_move_parameter(:cycling)
    update_appearance(@pattern)
  end

  # Jump on the acro bike
  def enter_in_acro_bike_state
    $game_switches[::Yuki::Sw::EV_Bicycle] = false
    $game_switches[::Yuki::Sw::EV_AccroBike] = true
    self.on_acro_bike = true
    $game_map.need_refresh = true
    @state = moving? ? :cycling : :cycle_stop
    update_move_parameter(:wheeling)
    update_appearance(@pattern)
  end

  # Leave the cycling state
  def leave_cycling_state
    $game_switches[::Yuki::Sw::EV_Bicycle] = false
    $game_switches[::Yuki::Sw::EV_AccroBike] = false
    self.on_acro_bike = false
    $game_map.need_refresh = true
    enter_in_walking_state
  end
  alias leave_acro_bike_state leave_cycling_state

  # Update the cycling state
  def update_cycling_state
    @state = moving? ? :cycling : :cycle_stop
    update_appearance(@pattern)
  end

  # Test if the player is cycling
  # @return [Boolean]
  def cycling?
    @state == :cycling || @state == :cycle_stop || @state == :wheeling
  end

  # Enter in fishing state
  def enter_in_fishing_state
    @offset_screen_y = 8 unless @surfing
    leave_cycling_state if cycling?
    @state = @surfing ? :surf_fishing : :fishing
    @update_callback = :update_enter_fishing_state
    @update_callback_count = 0
    update_appearance(0)
  end

  # Callback called when we are entering in wheel state
  def update_enter_fishing_state
    @update_callback_count += 1
    return unless (@update_callback_count % 6) == 0
    @pattern += 1
    return unless @pattern > 2
    @update_callback = :update_locked_state
  end

  # Leave fishing state
  def leave_fishing_state
    @state = @surfing ? :surf_fishing : :fishing
    @update_callback = :update_leave_fishing_state
    @update_callback_count = 0
    update_appearance(3)
  end

  # Callback called when we are leaving in wheel state
  def update_leave_fishing_state
    @update_callback_count += 1
    return unless (@update_callback_count % 6) == 0
    @pattern -= 1
    return unless @pattern < 0
    @state = @surfing ? :surfing : :walking
    @update_callback = nil
    @offset_screen_y = nil
    update_appearance(0)
  end

  # Enter in sinking state
  def enter_in_sinking_state
    @update_callback = :update_enter_sinking_state
    @update_callback_count = 0
  end

  # Callback called when we are entering in wheel state
  def update_enter_sinking_state
    if moving?
      last_real_x = @real_x
      last_real_y = @real_y
      update_move
      update_scroll_map(last_real_x, last_real_y)
      return update_pattern
    end
    unless @state == :sinking
      @state = :sinking
      update_appearance(3)
    end
    @update_callback_count += 1
    return unless (@update_callback_count % 6) == 0
    @pattern -= 1
    return unless @pattern < 0
    @update_callback = nil
    update_appearance(0)
  end

  # Leave sinking state
  def leave_sinking_state
    @state = :sinking
    @update_callback = :update_leave_sinking_state
    @update_callback_count = 0
    update_appearance(0)
  end

  # Callback called when we are leaving in wheel state
  def update_leave_sinking_state
    @update_callback_count += 1
    return unless (@update_callback_count % 6) == 0
    @pattern += 1
    return unless @pattern > 3
    @update_callback = nil
    @pattern = 3
    enter_in_walking_state
  end

  # Enter in saving state
  def enter_in_saving_state
    @state = :saving
    @update_callback = :update_4_step_animation
    @update_callback_count = 0
    @prelock_direction = @direction
    @direction = 8
    update_appearance(0)
  end

  # Enter in using_skill state
  def enter_in_using_skill_state
    @state = :using_skill
    @update_callback = :update_4_step_animation
    @update_callback_count = 0
    @prelock_direction = @direction
    @direction = 6
    update_appearance(0)
  end

  # Enter in giving_pokemon state
  def enter_in_giving_pokemon_state
    @state = :giving_pokemon
    @update_callback = :update_giving_pokemon_state
    @update_callback_count = 0
    @prelock_direction = @direction
    @direction = 2
    update_appearance(0)
  end

  # Update the Pokemon giving animation
  def update_giving_pokemon_state
    if @direction == 2
      update_4_step_animation
      if @update_callback == :update_locked_state
        @direction = 4
        @update_callback = :update_giving_pokemon_state
      end
      return
    end
    update_4_step_animation_to_previous
  end

  # Enter in taking_pokemon state
  def enter_in_taking_pokemon_state
    @state = :taking_pokemon
    @update_callback = :update_taking_pokemon_state
    @update_callback_count = 0
    @prelock_direction = @direction
    @direction = 4
    update_appearance(3)
  end

  # Update the Pokemon taking animation
  def update_taking_pokemon_state
    if @direction == 4
      update_4_step_animation(-1)
      if @update_callback == :update_locked_state
        @direction = 2
        @update_callback = :update_taking_pokemon_state
      end
      return
    end
    update_4_step_animation_to_previous(-1)
  end

  # Callback called when we only want the character to show it's 4 pattern (it'll lock the player, use return_to_previous_state to unlock)
  # @param factor [Integer] the number added to pattern
  def update_4_step_animation(factor = 1)
    @update_callback_count += 1
    return unless (@update_callback_count % 12) == 0
    @pattern += factor
    return unless @pattern > 3 || @pattern < 0
    @update_callback = :update_locked_state
    @pattern = @pattern > 3 ? 3 : 0
  end

  # Callback called when we only want the character to show it's 4 pattern and return to previous state
  # @param factor [Integer] the number added to pattern
  def update_4_step_animation_to_previous(factor = 1)
    @update_callback_count += 1
    return unless (@update_callback_count % 12) == 0
    @pattern += factor
    return unless @pattern > 3 || @pattern < 0
    return_to_previous_state
  end

  # Return to the correct state
  def return_to_previous_state
    @update_callback = nil
    @direction = @prelock_direction if @prelock_direction > 0
    @prelock_direction = 0
    @pattern = 0
    if @surfing
      enter_in_surfing_state
    elsif $game_switches[::Yuki::Sw::EV_Bicycle]
      enter_in_cycling_state
    elsif $game_switches[::Yuki::Sw::EV_AccroBike]
      enter_in_acro_bike_state
    else
      enter_in_walking_state
    end
  end

  # Update the locked state
  def update_locked_state() end
end
