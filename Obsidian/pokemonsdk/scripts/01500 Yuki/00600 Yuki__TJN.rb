module Yuki
  # PSDK DayNightSystem v2
  #
  # This script manage the day night tint & hour calculation
  #
  # It's inputs are :
  #   - $game_switches[Sw::TJN_NoTime] (8) : Telling not to update time
  #   - $game_switches[Sw::TJN_RealTime] (7) : Telling to use the real time (computer clock)
  #   - $game_variables[Var::TJN_Month] (15) : Month of the year (1~13 in virtual time)
  #   - $game_variables[Var::TJN_MDay] (16) : Day of the month (1~28 in virtual time)
  #   - $game_variables[Var::TJN_Week] (14) : Week since the begining (0~65535)
  #   - $game_variables[Var::TJN_WDay] (13) : Day of the week (1~7 in virtual time)
  #   - $game_variables[Var::TJN_Hour] (10) : Hour of the day (0~23)
  #   - $game_variables[Var::TJN_Min] (11) : Minute of the hour (0~59)
  #   - $game_switches[Sw::TJN_Enabled] (10) : If tone change is enabled
  #   - $game_switches[Sw::Env_CanFly] (20) : If the tone can be applied (player outside)
  #   - Yuki::TJN.force_update_tone : Calling this method will force the system to update the tint
  #   - PFM.game_state.tint_time_set : Name of the time set (symbol) to use in order to get the tone
  #
  # It's outputs are :
  #   - All the time variables (15, 16, 14, 13, 10, 11)
  #   - $game_variables[Var::TJN_Tone] : The current applied tone
  #       - 0 = Night
  #       - 1 = Sunset
  #       - 2 = Morning
  #       - 3 = Day time
  # @author Nuri Yuri
  module TJN
    # Neutral tone
    NEUTRAL_TONE = Tone.new(0, 0, 0, 0)
    # The different tones according to the time set
    TONE_SETS = {
      default: [
        Tone.new(-85, -85, -20, 0), # Night
        Tone.new(-17, -51, -34, 0), # Evening
        Tone.new(-75, -75, -10, 0), # Midnight
        NEUTRAL_TONE, # Day
        Tone.new(17, -17, -34, 0) # Dawn
      ],
      winter: [ # <= Those tones aren't correct, that's a test for the 24h tone
        Tone.new(-75, -75, -10, 0), # 0
        Tone.new(-80, -80, -10, 0), # 1
        Tone.new(-85, -85, -10, 0), # 2
        Tone.new(-80, -80, -12, 0), # 3
        Tone.new(-75, -75, -15, 0), # 4
        Tone.new(-65, -65, -18, 0), # 5
        Tone.new(-55, -55, -20, 0), # 6
        Tone.new(-25, -35, -22, 0), # 7
        Tone.new(-20, -25, -25, 0), # 8
        Tone.new(-15, -20, -30, 0), # 9
        Tone.new(-10, -17, -34, 0), # 10
        Tone.new(5, -8, -15, 0), # 11
        Tone.new(0, 0, -5, 0), # 12
        Tone.new(0, 0, 0, 0), # 13
        Tone.new(0, 0, 0, 0), # 14
        Tone.new(-10, -25, -10, 0), # 15
        Tone.new(-17, -51, -34, 0), # 16
        Tone.new(-20, -43, -30, 0), # 17
        Tone.new(-35, -35, -25, 0), # 18
        Tone.new(-45, -45, -20, 0), # 19
        Tone.new(-55, -55, -15, 0), # 20
        Tone.new(-60, -60, -14, 0), # 21
        Tone.new(-65, -65, -13, 0), # 22
        Tone.new(-70, -70, -10, 0) # 23
      ]
    }
    # The different tones
    TONE = TONE_SETS[:default]
    # The different time sets according to the time set
    TIME_SETS = {
      default: summer = [22, 19, 11, 7],
      summer: summer,
      winter: [17, 16, 12, 10],
      fall: fall = [19, 17, 11, 9],
      spring: fall
    }
    # The time when the tone changes
    TIME = TIME_SETS[:default]
    # The number of frame that makes 1 minute in Game time
    MIN_FRAMES = 600
    # Regular number of frame the tint change has to be performed
    REGULAR_TRANSITION_TIME = 20
    @timer = 0
    @forced = false
    @current_tone_value = Tone.new(0, 0, 0, 0)

    module_function

    # Function that init the TJN variables
    def init_variables
      # Fix the game variables
      unless $game_switches[Sw::TJN_RealTime]
        $game_variables[Var::TJN_WDay] = 1 if $game_variables[Var::TJN_WDay] <= 0
        $game_variables[Var::TJN_MDay] = 1 if $game_variables[Var::TJN_MDay] <= 0
        $game_variables[Var::TJN_Month] = 1 if $game_variables[Var::TJN_Month] <= 0
      end
      $user_data[:tjn_events] ||= {}
    end

    # Update the tone of the screen and the game time
    def update
      @timer < one_minute ? @timer += 1 : update_time
      if @forced
        update_real_time if $game_switches[Sw::TJN_RealTime] && @timer < one_minute
        update_tone
      end
    end

    # Force the next update to update the tone
    # @param value [Boolean] true to force the next update to update the tone
    def force_update_tone(value = true)
      @forced = value
    end

    # Return the current tone
    # @return [Tone]
    def current_tone
      $game_switches[Sw::TJN_Enabled] ? @current_tone_value : NEUTRAL_TONE
    end

    # Function that scan all the timed event for the current map in order to update them
    # @param map_id [Integer] ID of the map where to update the timed events
    def update_timed_events(map_id = $game_map.map_id)
      curr_time = $game_system.map_interpreter.current_time
      (map_data = $user_data.dig(:tjn_events, map_id))&.each do |event_id, data|
        if data.first <= curr_time
          $game_map.need_refresh = true
          $game_system.map_interpreter.set_self_switch(true, data.last, event_id, map_id)
          data.clear
        end
      end
      map_data&.delete_if { |_key, value| value.empty? }
    end

    class << self
      private

      # Return the number of frame between each virtual minutes
      # @return [Integer]
      def one_minute
        MIN_FRAMES
      end

      # Update the game time
      # @note If the game switch Yuki::Sw::TJN_NoTime is on, there's no time update.
      # @note If the game switch Yuki::Sw::TJN_RealTime is on, the time is the computer time
      def update_time
        @timer = 0
        return if $game_switches[Sw::TJN_NoTime]
        update_tone if $game_switches[Sw::TJN_RealTime] ? update_real_time : update_virtual_time
        # Trigger an on_update event for Yuki::TJN
        Scheduler.start(:on_update, self)
      end

      # Update the virtual time by adding 1 minute to the variable
      # @return [Boolean] if update_time should call update_tone
      def update_virtual_time
        update_timed_events
        return should_update_tone_each_minute unless ($game_variables[Var::TJN_Min] += 1) >= 60
        $game_variables[Var::TJN_Min] = 0
        return true unless ($game_variables[Var::TJN_Hour] += 1) >= 24
        $game_variables[Var::TJN_Hour] = 0
        if ($game_variables[Var::TJN_WDay] += 1) >= 8
          $game_variables[Var::TJN_WDay] = 1
          $game_variables[Var::TJN_Week] = 0 if ($game_variables[Var::TJN_Week] += 1) >= 0xFFFF
        end
        if ($game_variables[Var::TJN_MDay] += 1) >= 29
          $game_variables[Var::TJN_MDay] = 1
          $game_variables[Var::TJN_Month] = 1 if ($game_variables[Var::TJN_Month] += 1) >= 14
        end
        return true
      end

      # Update the real time values
      # @return [Boolean] if update_time should call update_tone
      def update_real_time
        last_hour = $game_variables[Var::TJN_Hour]
        last_min = $game_variables[Var::TJN_Min]
        @timer = MIN_FRAMES - 60 if MIN_FRAMES > 60
        time = Time.new
        $game_variables[Var::TJN_Min] = time.min
        $game_variables[Var::TJN_Hour] = time.hour
        $game_variables[Var::TJN_WDay] = time.wday
        $game_variables[Var::TJN_MDay] = time.day
        $game_variables[Var::TJN_Month] = time.month
        update_timed_events if last_min != time.min
        return should_update_tone_each_minute ? last_min != time.min : last_hour != time.hour
      end

      # Update the tone of the screen
      # @note if the game switch Yuki::Sw::TJN_Enabled is off, the tone is not updated
      def update_tone
        return unless $game_switches[Sw::TJN_Enabled]
        change_tone_to_neutral unless (day_tone = $game_switches[Sw::Env_CanFly])
        day_tone = false if $env.sunny? # Zenith adds an other tone so we don't change
        update_tone_internal(day_tone)
        $game_map.need_refresh = true
        ::Scheduler.start(:on_hour_update, $scene.class)
      ensure
        @forced = false
      end

      # Internal part of the update tone where flags are set & tone is processed
      # @param day_tone [Boolean] if we can process a tone (not inside / locked by something else)
      def update_tone_internal(day_tone)
        v = $game_variables[Var::TJN_Hour]
        timeset = current_time_set
        if v >= timeset[0] # Night (before midnight)
          change_tone(0) if day_tone
          update_switches_and_variables(Sw::TJN_NightTime, 0)
        elsif v >= timeset[1] # Sunset
          change_tone(1) if day_tone
          $game_screen.start_tone_change(TONE[@current_tone = 1], tone_change_time) if day_tone
          update_switches_and_variables(Sw::TJN_SunsetTime, 1)
        elsif v >= timeset[2] # Day
          change_tone(3) if day_tone
          update_switches_and_variables(Sw::TJN_DayTime, 3)
        elsif v >= timeset[3] # Morning
          change_tone(4) if day_tone
          update_switches_and_variables(Sw::TJN_MorningTime, 2)
        else # Night (after midnight)
          change_tone(2) if day_tone
          update_switches_and_variables(Sw::TJN_NightTime, 0)
        end
      end

      # Change the game tone to the neutral one
      def change_tone_to_neutral
        @current_tone_value.set(NEUTRAL_TONE.red, NEUTRAL_TONE.green, NEUTRAL_TONE.blue, NEUTRAL_TONE.gray)
        $game_screen.start_tone_change(NEUTRAL_TONE, tone_change_time)
      end

      # Change tone of the map
      # @param tone_index [Integer] index of the tone if there's no 24 tones inside the tone array
      def change_tone(tone_index)
        tones = current_tone_set
        if tones.size == 24
          delta_minutes = 60
          current_minute = $game_variables[Var::TJN_Min]
          one_minus_alpha = delta_minutes - current_minute
          current_tone = tones[$game_variables[Var::TJN_Hour]]
          next_tone = tones[($game_variables[Var::TJN_Hour] + 1) % 24]
          @current_tone_value.set(
            (current_tone.red * one_minus_alpha + next_tone.red * current_minute) / delta_minutes,
            (current_tone.green * one_minus_alpha + next_tone.green * current_minute) / delta_minutes,
            (current_tone.blue * one_minus_alpha + next_tone.blue * current_minute) / delta_minutes,
            (current_tone.gray * one_minus_alpha + next_tone.gray * current_minute) / delta_minutes
          )
        else
          current_tone = tones[tone_index]
          @current_tone_value.set(current_tone.red, current_tone.green, current_tone.blue, current_tone.gray)
        end
        $game_screen.start_tone_change(@current_tone_value, tone_change_time)
      end

      # Time to change tone
      # @return [Integer]
      def tone_change_time
        @forced == true ? 0 : REGULAR_TRANSITION_TIME
      end

      # Get the time set
      # @return [Array<Integer>] 4 values : [night_start, evening_start, day_start, morning_start]
      def current_time_set
        TIME_SETS[PFM.game_state.tint_time_set] || TIME
      end

      # Get the tone set
      # @return [Array<Tone>] 5 values : night, evening, morning / night, day, dawn
      def current_tone_set
        TONE_SETS[PFM.game_state.tint_time_set] || TONE
      end

      # List of the switch name used by the TJN system (it's not defined here so we use another access)
      TJN_SWITCH_LIST = %i[TJN_NightTime TJN_DayTime TJN_MorningTime TJN_SunsetTime]

      # Update the state of the switches and the tone variable
      # @param switch_id [Integer] ID of the switch that should be true (all the other will be false)
      # @param variable_value [Integer] new value of $game_variables[Var::TJN_Tone]
      def update_switches_and_variables(switch_id, variable_value)
        $game_variables[Var::TJN_Tone] = variable_value
        TJN_SWITCH_LIST.each do |switch_name|
          switch_index = Sw.const_get(switch_name)
          $game_switches[switch_index] = switch_index == switch_id
        end
      end

      # If the tone should update each minute
      def should_update_tone_each_minute
        return current_tone_set.size == 24
      end
    end
  end
end

Hooks.register(Spriteset_Map, :finish_init, 'Yuki::TJN') do
  Yuki::TJN.force_update_tone
  Yuki::TJN.update
end
Hooks.register(Spriteset_Map, :update_fps_balanced, 'Yuki::TJN') { Yuki::TJN.update }
