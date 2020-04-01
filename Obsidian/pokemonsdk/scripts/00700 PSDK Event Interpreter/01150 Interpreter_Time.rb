class Interpreter
  # Return the current time in minute
  # @return [Integer]
  def current_time
    return ((time = Time.new).to_i / 60 + time.gmtoff / 60) if $game_switches[Yuki::Sw::TJN_RealTime]
    $game_variables[Yuki::Var::TJN_Min] +
      $game_variables[Yuki::Var::TJN_Hour] * 60 +
      (($game_variables[Yuki::Var::TJN_MDay] - 1) % 7) * 1440 +
      ($game_variables[Yuki::Var::TJN_Week]) * 10_080
  end

  # Store a timed event (will enable the desired local switch when the timer reached the amount of minutes)
  # @param amount_of_minutes [Integer] number of minute from now to enable the switch
  # @param local_switch_letter [String] letter of the local switch to enable in order to trigger the event
  # @param event_id [Integer] event id that should be activated
  # @param map_id [Integer] map where the event should be located
  # @example Setting an event in 24h for the current event (local switch D)
  #   trigger_event_in(24 * 60, 'D')
  def trigger_event_in(amount_of_minutes, local_switch_letter, event_id = @event_id, map_id = @map_id)
    next_time = current_time + amount_of_minutes
    # Store the event to trigger
    (($user_data[:tjn_events] ||= {})[map_id] ||= {})[event_id] = [next_time, local_switch_letter]
    # Set its local switch to false
    set_self_switch(false, local_switch_letter, event_id, map_id)
    $game_map.need_refresh = true
  end

  # Get the remaining time until the trigger (in minutes)
  # @param event_id [Integer] event id that should be activated
  # @param map_id [Integer] map where the event should be located
  # @return [Integer]
  def timed_event_remaining_time(event_id = @event_id, map_id = @map_id)
    return ($user_data.dig(:tjn_events, map_id, event_id)&.first || current_time) - current_time
  end
end
