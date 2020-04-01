module PFM
  # Environment management (Weather, Zone, etc...)
  #
  # The global Environment object is stored in $env and $pokemon_party.env
  # @author Nuri Yuri
  class Environnement
    # Unkonw location text
    UNKNOWN_ZONE = 'Zone ???'
    include GameData::SystemTags
    # The master zone (zone that show the pannel like city, unlike house of city)
    # @note Master zone are used inside Pokemon data
    # @return [Integer]
    attr_reader :master_zone
    # Last visited map ID
    # @return [Integer]
    attr_reader :last_map_id
    # Custom markers on worldmap
    # @return [Array]
    attr_reader :worldmap_custom_markers
    # Return the modified worldmap position or nil
    # @return [Array, nil]
    attr_reader :modified_worldmap_position
    # Create a new Environnement object
    def initialize
      @weather = 0
      @battle_weather = 0
      @duration = Float::INFINITY
      # Zone where the player currently is
      @zone = 0
      # Zone where the current zone is a child of
      @master_zone = 0
      @warp_zone = 0
      @last_map_id = 0
      @visited_zone = []
      @visited_worldmap = []
      @deleted_events = {}
      # Worldmap where the player currently is
      @worldmap = 0
      @worldmap_custom_markers = []
    end

    # Apply a new weather to the current environment
    # @param id [Integer] ID of the weather : 0 = None, 1 = Rain, 2 = Sun/Zenith, 3 = Darud Sandstorm, 4 = Hail, 5 = Foggy
    # @param duration [Integer, nil] the total duration of the weather (battle), nil = never stops
    def apply_weather(id, duration = nil)
      @battle_weather = id
      @weather = id unless $game_temp.in_battle && !$game_switches[::Yuki::Sw::MixWeather]
      @duration = (duration || Float::INFINITY)
      ajust_weather_switches
    end

    # Ajust the weather switch to put the game in the correct state
    def ajust_weather_switches
      weather = current_weather
      $game_switches[::Yuki::Sw::WT_Rain] = (weather == 1)
      $game_switches[::Yuki::Sw::WT_Sunset] = (weather == 2)
      $game_switches[::Yuki::Sw::WT_Sandstorm] = (weather == 3)
      $game_switches[::Yuki::Sw::WT_Snow] = (weather == 4)
      $game_switches[::Yuki::Sw::WT_Fog] = (weather == 5)
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

    # Is it rainning?
    # @return [Boolean]
    def rain?
      return false if $game_temp.in_battle && ::BattleEngine.state[:air_lock]
      return current_weather == 1
    end

    # Is it sunny?
    # @return [Boolean]
    def sunny?
      return false if $game_temp.in_battle && ::BattleEngine.state[:air_lock]
      return current_weather == 2
    end

    # Duuuuuuuuuuuuuuuuuuuuuuun
    # Dun dun dun dun dun dun dun dun dun dun dun dundun dun dundundun dun dun dun dun dun dun dundun dundun
    # @return [Boolean]
    def sandstorm?
      return false if $game_temp.in_battle && ::BattleEngine.state[:air_lock]
      return current_weather == 3
    end

    # Does it hail ?
    # @return [Boolean]
    def hail?
      return false if $game_temp.in_battle && ::BattleEngine.state[:air_lock]
      return current_weather == 4
    end

    # Is it foggy ?
    # @return [Boolean]
    def fog?
      return false if $game_temp.in_battle && ::BattleEngine.state[:air_lock]
      return current_weather == 5
    end

    # Is the weather normal
    # @return [Boolean]
    def normal?
      return false if $game_temp.in_battle && ::BattleEngine.state[:air_lock]
      return current_weather == 0
    end

    # Is the player inside a building (and not on a systemtag)
    # @return [Boolean]
    def building?
      return (!$game_switches[Yuki::Sw::Env_CanFly] && $game_player.system_tag == 0)
    end

    # Update the zone informations, return the ID of the zone when the player enter in an other zone
    #
    # Add the zone to the visited zone Array if the zone has not been visited yet
    # @return [Integer, false] false = player was in the zone
    def update_zone
      return false if @last_map_id == $game_map.map_id
      @last_map_id = map_id = $game_map.map_id
      last_zone = @zone
      # Searching for the current zone
      GameData::Zone.all.each_with_index do |data, index|
        next unless data
        if data.map_included?(map_id)
          load_zone_information(data, index)
          break
        end
      end
      return false if last_zone == @zone
      return @zone
    end

    # Load the zone information
    # @param data [GameData::Map] the current zone data
    # @param index [Integer] the index of the zone in the stack
    def load_zone_information(data, index)
      @zone = index
      # We store this zone as the zone where to warp if it's possible
      @warp_zone = index if data.warp_x && data.warp_y
      # We store this zone as the master zone if there's a pannel
      @master_zone = index if data.panel_id&.>(0)
      # We memorize the fact we visited this zone
      @visited_zone << index unless @visited_zone.include?(index)
      # We memorize the fact we visited this worldmap
      @visited_worldmap << data.worldmap_id unless @visited_worldmap.include?(data.worldmap_id)
      # We store the zone worldmap
      @worldmap = data.worldmap_id
      # We store the new switch info
      $game_switches[Yuki::Sw::Env_CanFly] = (!data.warp_disallowed && data.fly_allowed)
      $game_switches[Yuki::Sw::Env_CanDig] = (!data.warp_disallowed && !data.fly_allowed)
      return unless data.forced_weather
      if data.forced_weather == 0
        $game_screen.weather(0, 0, $game_switches[Yuki::Sw::Env_CanFly] ? 40 : 0)
      else
        $game_screen.weather(0, 9, 40, psdk_weather: data.forced_weather)
      end
    end

    # Reset the zone informations to get the zone id with update_zone (Panel display)
    def reset_zone
      @last_map_id = -1
      @zone = -1
    end

    # Return the current zone in which the player is
    # @return [Integer] the zone ID in the database
    def current_zone
      return @zone
    end
    alias get_current_zone current_zone

    # Return the zone data in which the player is
    # @return [GameData::Zone]
    def current_zone_data
      GameData::Zone.get(@zone)
    end
    alias get_current_zone_data current_zone_data

    # Return the zone name in which the player is (master zone)
    # @return [String]
    def current_zone_name
      zone = @master_zone
      return GameData::Zone.get(zone).map_name if zone
      UNKNOWN_ZONE
    end

    # Return the warp zone ID (where the player will teleport with skills)
    # @return [Integer] the ID of the zone in the database
    def warp_zone
      return @warp_zone
    end
    alias get_warp_zone warp_zone

    # Get the zone data in the worldmap
    # @param x [Integer] the x position of the zone in the World Map
    # @param y [Integer] the y position of the zone in the World Map
    # @param worldmap_id [Integer] <default : @worldmap> the worldmap to refer at
    # @return [GameData::Map, nil] nil = no zone there
    def get_zone(x, y, worldmap_id = @worldmap)
      zone_id = GameData::WorldMap.get(worldmap_id).data[x, y]
      return zone_id && zone_id >= 0 ? GameData::Zone.get(zone_id) : nil
    end

    # Return the zone coordinate in the worldmap
    # @param zone_id [Integer] id of the zone in the database
    # @param worldmap_id [Integer] <default : @worldmap> the worldmap to refer at
    # @return [Array(Integer, Integer)] the x,y coordinates
    def get_zone_pos(zone_id, worldmap_id = @worldmap)
      return 0, 0 unless (zone = GameData::Zone.get(zone_id))
      return zone.pos_x, zone.pos_y if zone.pos_x && zone.pos_y
      # Trying to find the current zone
      w = GameData::WorldMap.get(worldmap_id).data.xsize
      h = GameData::WorldMap.get(worldmap_id).data.ysize
      0.upto(w - 1) do |x|
        0.upto(h - 1) do |y|
          return x, y if GameData::WorldMap.get(worldmap_id).data[x, y] == zone_id
        end
      end
      return 0, 0
    end

    # Check if a zone has been visited
    # @param zone [Integer, GameData::Map] the zone id in the database or the zone
    # @return [Boolean]
    def visited_zone?(zone)
      if zone.is_a?(GameData::Map)
        zone_index = GameData::Zone.all.index(zone)
        zone_index ||= GameData::Zone.all.find_index do |data|
          data.map_id == zone.map_id
        end
        zone = zone_index || -1
      end
      return @visited_zone.include?(zone)
    end

    # Get the worldmap from the zone
    # @param zone [Integer] <default : current zone>
    # @return [Integer]
    def get_worldmap(zone = @zone)
      if @modified_worldmap_position && @modified_worldmap_position[2]
        return @modified_worldmap_position[2]
      elsif zone.is_a?(GameData::Zone)
        return zone.worldmap_id
      else
        return GameData::Zone.get(zone).worldmap_id
      end
    end

    # Test if the given world map has been visited
    # @param worldmap [Integer, GameData::WorldMap]
    # @return [Boolean]
    def visited_worldmap?(worldmap)
      return @visited_worldmap.include?(GameData::WorldMap.all.index(worldmap)) if worldmap.is_a?(GameData::WorldMap)
      return @visited_worldmap.include? worldmap
    end

    # Is the player standing in grass ?
    # @return [Boolean]
    def grass?
      return ($game_switches[Yuki::Sw::Env_CanFly] && $game_player.system_tag == 0)
    end

    # Is the player standing in tall grass ?
    # @return [Boolean]
    def tall_grass?
      return $game_player.system_tag == TGrass
    end

    # Is the player standing in taller grass ?
    # @return [Boolean]
    def very_tall_grass?
      return $game_player.system_tag == TTallGrass
    end

    # Is the player in a cave ?
    # @return [Boolean]
    def cave?
      return $game_player.system_tag == TCave
    end

    # Is the player on a mount ?
    # @return [Boolean]
    def mount?
      return $game_player.system_tag == TMount
    end

    # Is the player on sand ?
    # @return [Boolean]
    def sand?
      tag = $game_player.system_tag
      return (tag == TSand || tag == TWetSand)
    end

    # Is the player on a pond/river ?
    # @return [Boolean]
    def pond? # Etang / Rivière etc...
      return $game_player.system_tag == TPond
    end

    # Is the player on a sea/ocean ?
    # @return [Boolean]
    def sea?
      return $game_player.system_tag == TSea
    end

    # Is the player underwater ?
    # @return [Boolean]
    def under_water?
      return $game_player.system_tag == TUnderWater
    end

    # Is the player on ice ?
    # @return [Boolean]
    def ice?
      return $game_player.system_tag == TIce
    end

    # Is the player on snow or ice ?
    # @return [Boolean]
    def snow?
      tag = $game_player.system_tag
      return (tag == TSnow || tag == TIce) # Ice will be the same as snow for skills
    end

    # Return the zone type
    # @param ice_prio [Boolean] when on snow for background, return ice ID if player is on ice
    # @return [Integer] 1 = tall grass, 2 = taller grass, 3 = cave, 4 = mount, 5 = sand, 6 = pond, 7 = sea, 8 = underwater, 9 = snow, 10 = ice, 0 = building
    def get_zone_type(ice_prio = false)
      if tall_grass?
        return 1
      elsif very_tall_grass?
        return 2
      elsif cave?
        return 3
      elsif mount?
        return 4
      elsif sand?
        return 5
      elsif pond?
        return 6
      elsif sea?
        return 7
      elsif under_water?
        return 8
      elsif snow?
        return ((ice_prio && ice?) ? 10 : 9)
      elsif ice?
        return 10
      else
        return 0
      end
    end

    # Convert a system_tag to a zone_type
    # @param system_tag [Integer] the system tag
    # @return [Integer] same as get_zone_type
    def convert_zone_type(system_tag)
      case system_tag
      when TGrass
        return 1
      when TTallGrass
        return 2
      when TCave
        return 3
      when TMount
        return 4
      when TSand
        return 5
      when TPond
        return 6
      when TSea
        return 7
      when TUnderWater
        return 8
      when TSnow
        return 9
      when TIce
        return 10
      else
        return 0
      end
    end

    # Is it night time ?
    # @return [Boolean]
    def night?
      return $game_switches[::Yuki::Sw::TJN_NightTime]
    end

    # Is it day time ?
    # @return [Boolean]
    def day?
      return $game_switches[::Yuki::Sw::TJN_DayTime]
    end

    # Is it morning time ?
    # @return [Boolean]
    def morning?
      return $game_switches[::Yuki::Sw::TJN_MorningTime]
    end

    # Is it sunset time ?
    # @return [Boolean]
    def sunset?
      return $game_switches[::Yuki::Sw::TJN_SunsetTime]
    end

    # Can the player fish ?
    # @return [Boolean]
    def can_fish?
      tag = $game_player.front_system_tag
      return (tag == TPond or tag == TSea)
    end

    # Set the delete state of an event
    # @param event_id [Integer] id of the event
    # @param map_id [Integer] id of the map where the event is
    # @param state [Boolean] new delete state of the event
    def set_event_delete_state(event_id, map_id = $game_map.map_id, state = true)
      deleted_events = @deleted_events = {} unless (deleted_events = @deleted_events)
      deleted_events[map_id] = {} unless deleted_events[map_id]
      deleted_events[map_id][event_id] = state
    end

    # Get the delete state of an event
    # @param event_id [Integer] id of the event
    # @param map_id [Integer] id of the map where the event is
    # @return [Boolean] if the event is deleted
    def get_event_delete_state(event_id, map_id = $game_map.map_id)
      return false unless (deleted_events = @deleted_events)
      return false unless deleted_events[map_id]
      return deleted_events[map_id][event_id]
    end

    # Add the custom marker to the worldmap
    # @param filename [String] the name of the icon in the interface/worldmap/icons directory
    # @param worldmap_id [Integer] the id of the worldmap
    # @param x [Integer] coord x on the worldmap
    # @param y [Integer] coord y on the wolrdmap
    # @param ox_mode [Symbol, :center] :center (the icon will be centered on the tile center), :base
    # @param oy_mode [Symbol, :center] :center (the icon will be centered on the tile center), :base
    def add_worldmap_custom_icon(filename, worldmap_id, x, y, ox_mode = :center, oy_mode = :center)
      @worldmap_custom_markers ||= []
      @worldmap_custom_markers[worldmap_id] ||= []
      @worldmap_custom_markers[worldmap_id].push [filename, x, y, ox_mode, oy_mode]
    end

    # Remove all custom worldmap icons on the coords
    # @param filename [String] the name of the icon in the interface/worldmap/icons directory
    # @param worldmap_id [Integer] the id of the worldmap
    # @param x [Integer] coord x on the worldmap
    # @param y [Integer] coord y on the wolrdmap
    def remove_worldmap_custom_icon(filename, worldmap_id, x, y)
      return unless @worldmap_custom_markers[worldmap_id]

      @worldmap_custom_markers[worldmap_id].delete_if { |i| i[0] == filename && i[1] == x && i[2] == y }
    end

    # Overwrite the zone worldmap position
    # @param new_x [Integer] the new x coords on the worldmap
    # @param new_y [Integer] the new y coords on the worldmap
    # @param new_worldmap_id [Integer, nil] the new worldmap id
    def set_worldmap_position(new_x, new_y, new_worldmap_id = nil)
      @modified_worldmap_position = [new_x, new_y, new_worldmap_id]
    end

    # Reset the modified worldmap position
    def reset_worldmap_position
      @modified_worldmap_position = nil
    end
  end

  class Pokemon_Party
    # The environment informations
    # @return [PFM::Environnement]
    attr_accessor :env
    on_player_initialize(:env) { @env = PFM::Environnement.new }
    on_expand_global_variables(:env) do
      # Variable containing all the environment related information (current zone, weather...)
      $env = @env
    end
  end
end
