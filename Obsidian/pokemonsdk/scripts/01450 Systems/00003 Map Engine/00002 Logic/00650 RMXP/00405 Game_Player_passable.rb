class Game_Player
  # is the tile in front of the player passable ? / Plays a BUMP SE in some conditions
  # @param x [Integer] x position on the Map
  # @param y [Integer] y position on the Map
  # @param d [Integer] direction : 2, 4, 6, 8, 0. 0 = current position
  # @return [Boolean] if the front/current tile is passable
  def passable?(x, y, d)
    return true if debug? && Input::Keyboard.press?(Input::Keyboard::LControl) # or Yuki::SystemTag.running?

    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    return maplinker_passable?(new_x, new_y) unless $game_map.valid?(new_x, new_y)

    result = super
    #> Check passable avec acro bike
    result = acro_passable_check(d, result)
=begin
    #Lignes pour faire le bump à la Pokémon, faut les conserver !!!
    if(!result and @bump_count < 1 and $game_temp.common_event_id == 0) # 
      #Audio.se_play(BUMP_FILE)
      puts "bmp"
      @bump_count = 30
      @step_anime = true if @lastdir4 != 0 and !@surfing and !@sliding
    end
=end
    return result
  end

  # Tags that are Bike bridge (jumpable on Acro Bike)
  AccroTag = [AcroBikeRL, AcroBikeUD]
  # Tags where the Bike cannot pass
  NO_BIKE_TILE = [SwampBorder, DeepSwamp, TTallGrass]
  # Test if the player can pass Bike bridge
  # @author Nuri Yuri
  def acro_passable_check(d, result)
    on_bike = (@on_acro_bike or $game_switches[::Yuki::Sw::EV_Bicycle])
    if @z > 1 and on_bike
      sys_tag = front_system_tag
      case d
      when 4, 6
        return true if sys_tag == AcroBikeRL
      when 8, 2
        return true if sys_tag == AcroBikeUD
      else
        return true if AccroTag.include?(sys_tag)
      end
      return false if @__bridge and AccroTag.include?(@__bridge.first) and !ZTag.include?(sys_tag)
      @__bridge = nil if result and ZTag.include?(sys_tag)
    elsif on_bike
      return false if NO_BIKE_TILE.include?(front_system_tag)
    end
    return result
  end

  # Check the surf related passabilities
  # @param sys_tag [Integer] current system_tag
  # @return [Boolean] if the tile is passable according to the surf rules
  def passage_surf_check?(sys_tag)
    if !@surfing && SurfTag.include?(sys_tag)
      if $game_switches[Yuki::Sw::NoSurfContact]
        event = front_tile_event
        return false unless event&.through || event&.character_name&.empty?
        $game_temp.common_event_id = Game_CommonEvent::SURF_ENTER
      end
      return false
    elsif @surfing
      unless SurfLTag.include?(sys_tag)
        # unless $game_switches[Yuki::Sw::NoSurfContact]
        event = front_tile_event
        return false if event && !event.through && !event.character_name.empty?
        change_shadow_disabled_state(false)
        @surfing = false
        $game_temp.common_event_id = Game_CommonEvent::SURF_LEAVE
        # end
        return false
      end
      if sys_tag == WaterFall
        $game_temp.common_event_id = Game_CommonEvent::WATERFALL
        return false
      end
    end
    return true
  end

  # Check the passage related to events
  # @param new_x [Integer] new x position
  # @param new_y [Integer] new y position
  # @param z [Integer] current z position
  # @param game_map [Game_Map] map object
  # @return [Boolean] if the tile has no event that block the way
  def event_passable_check?(new_x, new_y, z, game_map)
    game_map.events.each_value do |event|
      next unless event.contact?(new_x, new_y, z)
      next if event.through
      return false unless event.character_name.empty?
    end
    return true
  end

  private

  # is the tile in front of the player passable for maplinker uses
  # @param new_x [Integer] new x position on the Map
  # @param new_y [Integer] new y position on the Map
  # @return [Boolean] if the front/current tile is passable
  def maplinker_passable?(new_x, new_y)
    return false unless Yuki::MapLinker.passable?(new_x, new_y, @direction)

    return event_passable_check?(new_x, new_y, z, $game_map)
  end
end
