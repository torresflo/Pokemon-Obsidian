module PFM
  class Environnement
    # Apply a new weather to the current environment
    # @param id [Integer, Symbol] ID of the weather : 0 = None, 1 = Rain, 2 = Sun/Zenith, 3 = Darud Sandstorm, 4 = Hail, 5 = Foggy
    # @param duration [Integer, nil] the total duration of the weather (battle), nil = never stops
    def apply_weather(id, duration = nil)
      id = GameData::Weather::NAMES.index(id) || 0 if id.is_a?(Symbol)
      @battle_weather = id
      @weather = id unless $game_temp.in_battle && !$game_switches[::Yuki::Sw::MixWeather]
      @duration = (duration || Float::INFINITY)
      ajust_weather_switches
    end

    # Return the current weather duration
    # @return [Numeric] can be Float::INFINITY
    def weather_duration
      return @duration
    end
    alias get_weather_duration weather_duration

    # Decrease the weather duration, set it to normal (none = 0) if the duration is less than 0
    # @return [Boolean] true = the weather stopped
    def decrease_weather_duration
      @duration -= 1 if @duration > 0
      if @duration <= 0 && @battle_weather != 0
        apply_weather(0, 0)
        return true
      end
      return false
    end

    # Return the current weather id according to the game state (in battle or not)
    # @return [Integer]
    def current_weather
      return $game_temp.in_battle ? @battle_weather : @weather
    end

    # Return the db_symbol of the current weather
    # @return [Symbol]
    def current_weather_db_symbol
      GameData::Weather::NAMES[current_weather] || :__undef__
    end

    # Is it rainning?
    # @return [Boolean]
    def rain?
      return current_weather_db_symbol == :rain
    end

    # Is it sunny?
    # @return [Boolean]
    def sunny?
      return current_weather_db_symbol == :sunny
    end

    # Duuuuuuuuuuuuuuuuuuuuuuun
    # Dun dun dun dun dun dun dun dun dun dun dun dundun dun dundundun dun dun dun dun dun dun dundun dundun
    # @return [Boolean]
    def sandstorm?
      return current_weather_db_symbol == :sandstorm
    end

    # Does it hail ?
    # @return [Boolean]
    def hail?
      return current_weather_db_symbol == :hail
    end

    # Is it foggy ?
    # @return [Boolean]
    def fog?
      return current_weather_db_symbol == :fog
    end

    # Is the weather normal
    # @return [Boolean]
    def normal?
      return current_weather_db_symbol == :none
    end

    private

    # Update the state of each switches so the system knows what happens
    def ajust_weather_switches
      weather = current_weather
      weather_switches.each_with_index do |switch_id, i|
        next if switch_id < 1

        $game_switches[switch_id] = weather == i
      end
      $game_map.need_refresh = true
    end

    # Get the list of switch related to weather
    # @return [Array<Integer>]
    def weather_switches
      sw = Yuki::Sw
      return [-1, sw::WT_Rain, sw::WT_Sunset, sw::WT_Sandstorm, sw::WT_Snow, sw::WT_Fog]
    end
  end
end
