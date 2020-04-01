#encoding: utf-8

module Yuki
  # MapLinker, script that emulate the links between maps. This script also display events.
  # @author Nuri Yuri
  module MapLinker
    # The offset in X until we see black borders
    OffsetX = PSDK_CONFIG.tilemap.maplinker_offset_x
    # The offset in Y until we seen black borders
    OffsetY = PSDK_CONFIG.tilemap.maplinker_offset_y
    # The number of tiles the Maker has to let in common between each maps
    DeltaMaker = 3
    # The default Map (black borders)
    DefaultMap = RPG::Map.new(20, 15)
    # The map filename format
    Map_Format = 'Data/Map%03d.rxdata'

    module_function

    # Get the OffsetX
    # @return [Integer]
    def get_OffsetX
      return $game_switches[Sw::MapLinkerDisabled] ? 0 : OffsetX
    end

    # Get the OffsetY
    # @return [Integer]
    def get_OffsetY
      return $game_switches[Sw::MapLinkerDisabled] ? 0 : OffsetY
    end

    # Get the OffsetX for the current map
    # @return [Integer]
    def current_OffsetX
      return @current_disabled_state ? 0 : OffsetX
    end

    # Get the OffsetY for the current map
    # @return [Integer]
    def current_OffsetY
      return @current_disabled_state ? 0 : OffsetY
    end

    # Get the added events
    # @return [Hash<Integer => Array<RPG::Event>>] Integer is map_id
    def get_added_events
      return @added_events
    end

    # Test if the given event is from the center map or not
    # @param event [Game_Event] the event to test
    # @return [Boolean, nil]
    def from_center_map?(event)
      return !@added_events.key?(event.original_map)
      # return !(@added_events[event.original_map].select { |e| e.id == event.original_id }).empty?
    end

    # Reset the module when the RGSS resets itself
    def reset
      # [n_id, n_addx, e_id, e_addy, s_id, s_addx, o_id, o_addy]
      @link_data = nil
      # Data of the linked maps
      @north_data = nil
      @east_data = nil
      @sud_data = nil
      @west_data = nil
      # Last map information
      @last_map = nil
      @last_map_id = nil
      @last_map_data = nil
      @last_events = nil
      @last_event_id = 0
      # Warp informations
      @warp = [OffsetY, 0, 0, OffsetX]
      # Event added in the map to ensure proper link
      @added_events = {}
      # Table containing the tilesets for each tile
      @tileset_table = []
      # Table containing the priorities for each tile
      @priority_table = []
    end

    # Load a map and its linked map
    # @param map_id [Integer] the map ID
    # @return [RPG::Map] the map adjusted
    def load_map(map_id)
      Yuki::ElapsedTime.start(:maplinker)
      if (@current_disabled_state = $game_switches[Sw::MapLinkerDisabled])
        @link_data = nil
        @last_map = current_map_data = load_map_data(map_id)
        @last_map_id = map_id
        @last_map_data = nil
        load_tileset_and_priority
        return current_map_data
      end
      # Reset the last map data to its original state
      if @last_map && @last_map_data
        @last_map.data = @last_map_data
        @last_map.events = @last_events
        @last_map.width = @last_map_data.xsize
        @last_map.height = @last_map_data.ysize
      end
      # Load the new map
      current_map_data = load_map_data(map_id).clone
      Yuki::ElapsedTime.show(:maplinker, 'Loading the map data took')
      # Generate the new grid / shift events / Manage systemTags
      generate_map_grid(current_map_data, map_id)
      Yuki::ElapsedTime.show(:maplinker, 'Generating the grid took')
      # Load link data
      link_data = $game_data_maplinks[map_id]
      if link_data
        north_data = load_map_data(link_data[0])
        est_data = load_map_data(link_data[2])
        sud_data = load_map_data(link_data[4])
        west_data = load_map_data(link_data[6])
        Yuki::ElapsedTime.show(:maplinker, 'Loading the map links took')
      else
        north_data = est_data = sud_data = west_data = load_map_data(0)
      end
      @link_data = link_data
      # Generate the grid and try to load the events
      if link_data
        @added_events.clear
        generate_map_data_link(current_map_data, north_data, est_data, sud_data, west_data)
        Yuki::ElapsedTime.show(:maplinker, 'Loading the linked events took')
      end
      # Save the data
      @north_data = north_data
      @east_data = est_data
      @sud_data = sud_data
      @west_data = west_data
      @last_map = current_map_data
      @last_map_id = map_id
      @warp[1] = current_map_data.data.xsize - OffsetX - DeltaMaker + 1
      @warp[2] = current_map_data.data.ysize - OffsetY - DeltaMaker + 1
      # Generate the tileset/priority informations
      load_tileset_and_priority
      Yuki::ElapsedTime.show(:maplinker, 'Loading the tileset & priority took')
      # Preload the music of the other map
      # autoload_sounds(map_id)
      # Return the expected data
      return current_map_data
    end

    # Load the data of a map (with some optimizations)
    # @param map_id [Integer] the id of the Map
    # @return [RPG::Map]
    def load_map_data(map_id)
      return DefaultMap if map_id == 0
      return @last_map if map_id == @last_map_id
      if (link_data = @link_data) # Une des map linké
        return @north_data if map_id == link_data[0]
        return @east_data if map_id == link_data[2]
        return @sud_data if map_id == link_data[4]
        return @west_data if map_id == link_data[6]
      end
      return load_data(format(Map_Format, map_id))
    rescue StandardError
      return RPG::Map.new(20, 15)
    end

    # Shift the map of OffsetX, OffsetY on a larger map grid
    def generate_map_grid(data, _map_id)
      last_map_data = data.data
      tbl = Table.new(last_map_data.xsize + OffsetX * 2, last_map_data.ysize + OffsetY * 2, 3)
      tbl.fill(0)
      last_event_id = 0
      ox = OffsetX
      oy = OffsetY
      tbl.copy(last_map_data, ox, oy) # Around 130 & 250µs => 10x faster
      # Adjust the event position
      events = data.events
      nevent = {}
      tmpevt = nil
      events.each do |id, event|
        nevent[id] = tmpevt = event.clone
        tmpevt.x += ox
        tmpevt.y += oy
        last_event_id = id if id > last_event_id
      end
      # Save the old data and set the new data
      @last_map_data = last_map_data
      @last_events = events
      @last_event_id = last_event_id
      data.events = nevent
      data.data = tbl
      data.width += ox * 2
      data.height += oy * 2
    end

    # Generate the link (tile copy / event copy)
    # @param data [RPG::Map] the current map
    # @param north_data [RPG::Map] the north map
    # @param est_data [RPG::Map] the east map
    # @param west_data [RPG::Map] the west map
    def generate_map_data_link(data, north_data, est_data, sud_data, west_data)
      tbl = data.data
      last_event_id = @last_event_id
      events = data.events
      link_data = @link_data
      # Clone north tiles
      ox = link_data[1] + OffsetX
      oy = north_data.height - OffsetY - DeltaMaker
      tbl.copy_modulo(north_data.data, (-ox) % north_data.width, oy, 0, 0, tbl.xsize, OffsetY)
      # Clone south tiles
      ox = link_data[5] + OffsetX
      tbl.copy_modulo(sud_data.data, (-ox) % sud_data.width, DeltaMaker, 0, tbl.ysize - OffsetY, tbl.xsize, OffsetY)
      # Clone the west tiles
      ox = west_data.width - OffsetX - DeltaMaker
      oy = link_data[7]
      tbl.copy_modulo(west_data.data, ox, (-oy) % west_data.height, 0, OffsetY, OffsetX, tbl.ysize - 2 * OffsetY)
      # Clone the east tiles
      oy = link_data[3]
      tbl.copy_modulo(est_data.data, DeltaMaker, (-oy) % est_data.height, tbl.xsize - OffsetX, OffsetY, OffsetX, tbl.ysize - 2 * OffsetY)
      # Copy the north events
      oy = north_data.height - OffsetY - DeltaMaker
      last_event_id = ajust_events(north_data, oy, north_data.height - DeltaMaker - 1,
                                   link_data[1] + OffsetX, -oy, last_event_id,
                                   events, link_data[0], :y)
      # Copy the south events
      last_event_id = ajust_events(sud_data, DeltaMaker, OffsetY + DeltaMaker - 1,
                                   link_data[5] + OffsetX, tbl.ysize - OffsetY - DeltaMaker,
                                   last_event_id, events, link_data[4], :y)
      # Copy the west events
      ox = west_data.width - OffsetX - DeltaMaker
      last_event_id = ajust_events(west_data, ox, west_data.width - DeltaMaker - 1, -ox,
                                   link_data[7] + OffsetY, last_event_id, events, link_data[6])
      # Copy the east event
      ajust_events(est_data, DeltaMaker, OffsetX + DeltaMaker - 1,
                   tbl.xsize - OffsetX - DeltaMaker, link_data[3] + OffsetY,
                   last_event_id, events, link_data[2])
    end

    # Adjust the event position and id. Move them on the current map
    # @param data [RPG::Map] the map where the event normally are
    # @param min [Integer] the min position where the event can be to be cloned
    # @param max [Integer] the max position where the event can be to be cloned
    # @param ox [Integer] the offset x of the event
    # @param oy [Integer] the offset y of the event
    # @param last_event_id [Integer] the last event id
    # @param events [Hash] the event hash of the current map
    # @param map_id [Integer] the map id of the event
    # @param type [Symbol] the property checked on the event to check if they're cloned or not
    # @return [Integer] the new last_event_id
    def ajust_events(data, min, max, ox, oy, last_event_id, events, map_id, type = :x)
      added_events = @added_events[map_id] = []
      nevent = nil
      env = $env
      data.events.each do |id, event|
        next unless event.send(type).between?(min, max)
        next if env.get_event_delete_state(id, map_id)
        events[last_event_id += 1] = nevent = event.clone
        nevent.x += ox
        nevent.y += oy
        nevent.id = last_event_id
        nevent.original_id = id
        nevent.original_map = map_id
        nevent.offset_x = ox
        nevent.offset_y = oy
        added_events << nevent
      end
      return last_event_id
    end

    # Autoload the sounds of the other maps
    # @param map_id [Integer] id of the map the player warped
    def autoload_sounds(map_id)
      log_info 'MapLinker autoload sounds...' unless PSDK_CONFIG.release?
      args = []
      [@north_data, @east_data, @sud_data, @west_data].each do |data|
        next unless data
        args << "audio/bgm/#{data.bgm.name.downcase}" if data.autoplay_bgm
        args << "audio/bgm/#{data.bgs.name.downcase}" if data.autoplay_bgs
      end
      Audio::Cache.autoload_sounds(map_id, *args)
    end

    # Test if the player can warp between maps and warp him
    def test_warp
      return unless @link_data
      x = $game_player.x
      y = $game_player.y
      # Nord
      if y <= @warp[0]
        warp(@link_data[0], x - @link_data[1] - OffsetX, @north_data.height - DeltaMaker)
      # Est
      elsif x >= @warp[1]
        warp(@link_data[2], DeltaMaker - 2, y - @link_data[3] - OffsetY)
      # Sud
      elsif y >= @warp[2]
        warp(@link_data[4], x - @link_data[5] - OffsetX, DeltaMaker - 2)
      # Ouest
      elsif x <= @warp[3]
        warp(@link_data[6], @west_data.width - DeltaMaker, y - @link_data[7] - OffsetY)
      end
    end

    # Warp a player to a new map and a new location
    # @param map_id [Integer] the ID of the new map
    # @param x [Integer] the new x position of the player
    # @param y [Integer] the new y position of the player
    def warp(map_id, x, y)
      return if map_id == 0
      $game_temp.player_transferring = true
      $game_temp.player_new_map_id = map_id
      $game_temp.player_new_x = x + OffsetX
      $game_temp.player_new_y = y + OffsetY
      $game_temp.player_new_direction = $game_player.direction
    end

    # Load the buildings of the map (Building System)
    def load_buildings
      load_building(@last_map_id, 0, 0)
      return unless (link_data = @link_data)
      load_building(link_data[0], DeltaMaker, -@north_data.height + DeltaMaker, :nord)
      load_building(link_data[2], @last_map.width - OffsetX * 2 - DeltaMaker, -DeltaMaker, :est)
      load_building(link_data[4], -DeltaMaker, @last_map.height - OffsetY * 2 - DeltaMaker, :sud)
      load_building(link_data[6], -@west_data.width + DeltaMaker, DeltaMaker, :ouest)
    end

    # Path of the building data
    BPath = 'Data/Buildings/%03d.rxdata'
    # Load the bulding of a map
    # @param map_id [Integer] the id of the map
    # @param ox [Integer] the offset x of the map
    # @param oy [Integer] the offset y of the map
    # @param check [Symbol, false] the criteria to check to show a building
    def load_building(map_id, ox, oy, check = false)
      if File.exist?(filename = format(BPath, map_id))
        arr = load_data(filename)
        arr.each do |args|
          if check
            next if !args[4] or !args[4].include?(check)
            args[1] += ox
            args[2] += oy
          end
          Particles.add_building(*args)
        end
        unless check
          parallaxe = arr.instance_variable_get(:@parallaxe)
          if parallaxe
            parallaxe.each do |args|
              Particles.add_parallax(*args)
            end
          end
        end
      end
    end

    # Load the tilesets and the priority tables
    def load_tileset_and_priority
      current_tileset, current_priority = get_map_tileset_name(@last_map_id, @last_map)
      @tileset_table.clear
      @priority_table.clear
      @current_tileset_name = current_tileset
      if @link_data
        construct_tandp_tables(current_tileset, current_priority)
      else
        col_arr = Array.new(@last_map.height, RPG::Cache.tileset(current_tileset))
        @last_map.width.times { @tileset_table << col_arr }
        col_arr = Array.new(@last_map.height, current_priority)
        @last_map.width.times { @priority_table << col_arr }
      end
    end

    # Return the current tileset name
    def tileset_name
      @current_tileset_name
    end

    # Construct the 3 tables used to make the tileset & priority table
    # @param current_tileset [String] filename of the current tileset
    # @param current_priority [Table] priority table of the current map
    def construct_tandp_tables(current_tileset, current_priority)
      north_tileset, north_priority = get_map_tileset_name(@link_data[0], @north_data)
      south_tileset, south_priority = get_map_tileset_name(@link_data[4], @sud_data)
      west_tileset, west_priority = get_map_tileset_name(@link_data[6], @west_data)
      east_tileset, east_priority = get_map_tileset_name(@link_data[2], @east_data)
      north_part = Array.new(OffsetY, RPG::Cache.tileset(north_tileset))
      south_part = Array.new(OffsetY, RPG::Cache.tileset(south_tileset))
      west_part = north_part + Array.new(ysize = @last_map_data.ysize, RPG::Cache.tileset(west_tileset)).concat(south_part)
      east_part = north_part + Array.new(ysize, RPG::Cache.tileset(east_tileset)).concat(south_part)
      middle_part = north_part + Array.new(ysize, RPG::Cache.tileset(current_tileset)).concat(south_part)
      # Priority
      north_part = Array.new(OffsetY, north_priority)
      south_part = Array.new(OffsetY, south_priority)
      west_p_part = north_part + Array.new(ysize, west_priority).concat(south_part)
      east_p_part = north_part + Array.new(ysize, east_priority).concat(south_part)
      middle_p_part = north_part + Array.new(ysize, current_priority).concat(south_part)
      OffsetX.times do
        @tileset_table << west_part
        @priority_table << west_p_part
      end
      @last_map_data.xsize.times do
        @tileset_table << middle_part
        @priority_table << middle_p_part
      end
      OffsetX.times do
        @tileset_table << east_part
        @priority_table << east_p_part
      end
    end

    # Get the tileset name and the priority of a map
    # @param map_id [Integer]
    # @param data [RPG::Map] data of the map
    def get_map_tileset_name(map_id, data)
      tileset = $data_tilesets[data.tileset_id]
      $game_temp.maplinker_map_id = map_id
      $game_temp.tileset_temp = tileset.tileset_name
      Scheduler.start(:on_getting_tileset_name)
      name = get_tileset_name($game_temp.tileset_name || tileset.tileset_name)
      $game_temp.tileset_name = nil
      return name, tileset.priorities
    end

    # Get the tileset for a tile
    # @param x_pos [Integer]
    # @param y_pos [Integer]
    # @return [Bitmap, nil]
    def get_tileset(x_pos, y_pos)
      return @tileset_table[x_pos][y_pos]
    end

    # Get the priority for a tile
    # @param x_pos [Integer]
    # @param y_pos [Integer]
    # @return [Table]
    def get_priority(x_pos, y_pos)
      return (@priority_table[x_pos][y_pos] || @priority_table[0][0])
    end

    # Get the tileset_name PSDK should use
    # @param tilesetname [String] filename of the tileset
    # @return [String] filename of the tileset
    def get_tileset_name(tilesetname)
      filename = tilesetname.downcase + '_._ingame'
      if should_tileset_be_converted?(filename, tilesetname)
        Converter.convert_tileset("graphics/tilesets/#{tilesetname}.png")
        filename = tilesetname unless RPG::Cache.tileset_exist?(filename)
      end
      return filename
    end

    # Tell if the tileset has to be reconverted
    # @param filename [String] result of the conversion
    # @param tilesetname [String] tileset to convert
    # @return [Boolean]
    def should_tileset_be_converted?(filename, tilesetname)
      return true unless RPG::Cache.tileset_exist?(filename)
      return false if PSDK_CONFIG.release?
      return true unless File.exist?(filename = "graphics/tilesets/#{filename}.png")
      return File.mtime("graphics/tilesets/#{tilesetname}.png".downcase) >
             File.mtime(filename)
    end
  end
end
