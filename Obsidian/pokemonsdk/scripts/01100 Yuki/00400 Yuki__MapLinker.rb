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
    # List of link types for the link loading
    LINK_TYPES = %i[north east south west]

    # Get the OffsetX
    # @return [Integer]
    alias get_OffsetX void0
    # Get the OffsetY
    # @return [Integer]
    alias get_OffsetY void0
    # Get the OffsetX for the current map
    # @return [Integer]
    alias current_OffsetX void0
    # Get the OffsetY for the current map
    # @return [Integer]
    alias current_OffsetY void0
    module_function :get_OffsetX, :get_OffsetY, :current_OffsetX, :current_OffsetY

    class << self
      # Return the map datas
      # @return [Array<Yuki::Tilemap::MapData>]
      attr_reader :map_datas
      # Return the SpritesetMap object used to load the map
      # @return [Spriteset_Map]
      attr_accessor :spriteset
    end

    module_function

    # Get the added events
    # @return [Hash<Integer => Array<RPG::Event>>] Integer is map_id
    def added_events
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
      # [n_id, n_addx, e_id, e_addy, s_id, s_addx, o_id, o_addy, ...repeating]
      @link_data = nil
      # All the map_data_shown
      # @type [Array<Yuki::Tilemap::MapData>]
      @map_datas = []
      @last_events = nil
      @last_event_id = 0
      # Event added in the map to ensure proper link
      @added_events = {}
    end

    # Load a map and its linked map
    # @param map_id [Integer] the map ID
    # @return [RPG::Map] the map adjusted
    def load_map(map_id)
      Yuki::ElapsedTime.start(:maplinker)
      map_datas.first&.map&.events = @last_events if @last_events
      # @type [Array<Yuki::Tilemap::MapData>]
      map_datas = [@map_datas.find { |map| map.map_id == map_id } || Tilemap::MapData.new(load_map_data(map_id), map_id)]
      current_map = map_datas.first.map
      map_datas.first.load_position(current_map, :self, 0)

      if $game_switches[Sw::MapLinkerDisabled]
        reset
      elsif (link_data = $game_data_maplinks[map_id])
        (link_data.size / 2).times do |i|
          sub_map_id = link_data[i * 2]
          next if sub_map_id == 0

          map_data = @map_datas.find { |map| map.map_id == sub_map_id } || Tilemap::MapData.new(load_map_data(sub_map_id), sub_map_id)
          map_data.load_position(current_map, LINK_TYPES[i % 4], link_data[i * 2 + 1])
          map_datas << map_data
        end
      end

      @map_datas = map_datas
      load_events

      Yuki::ElapsedTime.show(:maplinker, 'Loading the tileset & priority took')
      return current_map
    end

    # Load the data of a map (with some optimizations)
    # @param map_id [Integer] the id of the Map
    # @return [RPG::Map]
    def load_map_data(map_id)
      return DefaultMap if map_id == 0

      return load_data(format(Map_Format, map_id))
    rescue StandardError
      return RPG::Map.new(20, 15)
    end

    # Load the visible events for all maps
    def load_events
      @last_events = @map_datas.first.map.events.clone
      @last_event_id = 1000 + @last_events.size

      @map_datas.each do |map|
        next if map.side == :self

        load_events_loop(map)
      end
    end

    # Load the visible event of a map
    # @param map [Yuki::Tilemap::MapData]
    def load_events_loop(map)
      map_id = map.map_id
      events = @map_datas.first.map.events
      ox = -map.offset_x
      oy = -map.offset_y
      if map.side == :north
        min = map.map.height - OffsetY - 2
        max = map.map.height - DeltaMaker - 1
        @last_event_id = ajust_events(map.map, min, max, ox, oy, @last_event_id, events, map_id, :y)
      elsif map.side == :south
        @last_event_id = ajust_events(map.map, DeltaMaker, OffsetY + 1, ox, oy, @last_event_id, events, map_id, :y)
      elsif map.side == :east
        @last_event_id = ajust_events(map.map, DeltaMaker, OffsetX + 1, ox, oy, @last_event_id, events, map_id, :x)
      else
        min = map.map.width - OffsetX - 2
        max = map.map.width - DeltaMaker - 1
        @last_event_id = ajust_events(map.map, min, max, ox, oy, @last_event_id, events, map_id, :x)
      end
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

    # Test if the player can warp between maps and warp him
    def test_warp
      x = $game_player.x
      y = $game_player.y
      # North
      if y <= 1
        y -= DeltaMaker
        return unless (target_map = @map_datas.find { |map| map.x_range.include?(x) && map.y_range.include?(y) })

        warp(target_map.map_id, x + target_map.offset_x, target_map.map.height - $game_player.y - 1)
      # East
      elsif x >= (@map_datas.first.map.width - 1)
        x += DeltaMaker
        return unless (target_map = @map_datas.find { |map| map.x_range.include?(x) && map.y_range.include?(y) })

        warp(target_map.map_id, 2, y + target_map.offset_y)
      # South
      elsif y >= (@map_datas.first.map.height - 1)
        y += DeltaMaker
        return unless (target_map = @map_datas.find { |map| map.x_range.include?(x) && map.y_range.include?(y) })

        warp(target_map.map_id, x + target_map.offset_x, 2)
      # West
      elsif x <= 1
        x -= DeltaMaker
        return unless (target_map = @map_datas.find { |map| map.x_range.include?(x) && map.y_range.include?(y) })

        warp(target_map.map_id, target_map.map.width - $game_player.x - 1, y + target_map.offset_y)
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
      $game_temp.player_new_x = x
      $game_temp.player_new_y = y
      $game_temp.player_new_direction = $game_player.direction
    end

    # Load the buildings of the map (Building System)
    def load_buildings
      @map_datas.each do |map|
        load_building(map.map_id, map.offset_x, map.offset_y, map.side == :self ? false : map.side)
      end
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
          next if check && (!args[4] || !args[4].include?(check))

          args[1] += ox
          args[2] += oy
          Particles.add_building(*args)
        end
        parallaxe = arr.instance_variable_get(:@parallaxe)
        parallaxe&.each do |args|
          args[1] += ox
          args[2] += oy
          Particles.add_parallax(*args)
        end
      end
    end
    Hooks.register(Spriteset_Map, :finish_init) { Yuki::MapLinker.load_buildings }

    # Return the current tileset name
    def tileset_name
      @map_datas.first.tileset_name
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
