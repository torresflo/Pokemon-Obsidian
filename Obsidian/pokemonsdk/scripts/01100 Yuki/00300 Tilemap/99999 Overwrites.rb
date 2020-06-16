# This script is used to overwrite some RMXP / PSDK script to use the new Tilemap system
# To get the new_tilemap working, add new_tilemap to game.exe launch parameters
if ARGV.include?('new_tilemap')
  class Spriteset_Map
    def tilemap_class
      return Yuki::Tilemap16px if PSDK_CONFIG.tilemap.tilemap_class.match?(/16|Yuri_Tilemap/)

      return Yuki::Tilemap
    end

    def init_tilemap
      tilemap_class = self.tilemap_class
      if @tilemap.class != tilemap_class
        @tilemap&.dispose
        # @type [Yuki::Tilemap]
        @tilemap = tilemap_class.new(@viewport1)
      end
      Yuki::ElapsedTime.show(:spriteset_map, 'Creating tilemap object took')
      map_datas = Yuki::MapLinker.map_datas
      map_datas.each(&:load_tileset)
      Yuki::ElapsedTime.show(:spriteset_map, 'Loading tilesets took')
      @tilemap.map_datas = map_datas
      @tilemap.reset
      Yuki::ElapsedTime.show(:spriteset_map, 'Resetting the tilemap took')
    end
  end

  class Game_Player
    # Adjust the map display according to the given position
    # @param x [Integer] the x position on the MAP
    # @param y [Integer] the y position on the MAP
    def center(x, y)
      if $game_switches[Yuki::Sw::MapLinkerDisabled]
        max_x = ($game_map.width - 20) * 128
        max_y = ($game_map.height - 15) * 128
        $game_map.display_x = (x * 128 - CENTER_X).clamp(0, max_x) # [0, [x * 128 - CENTER_X, max_x].min].max
        $game_map.display_y = (y * 128 - CENTER_Y).clamp(0, max_y) # [0, [y * 128 - CENTER_Y, max_y].min].max
      else
        $game_map.display_x = x * 128 - CENTER_X
        $game_map.display_y = y * 128 - CENTER_Y
      end
    end
  end

  class Game_Map
    # Scrolls the map down
    # @param distance [Integer] distance in y to scroll
    # @param is_priority [Boolean] used if there is a prioratary scroll running
    def scroll_down(distance, is_priority = false)
      return if @scroll_y_priority && !is_priority

      if $game_switches[Yuki::Sw::MapLinkerDisabled]
        @display_y = (@display_y + distance).clamp(0, (height - NUM_TILE_VIEW_Y) * 128)
      else
        @display_y += distance
      end
    end

    # Scrolls the map left
    # @param distance [Integer] distance in -x to scroll
    # @param is_priority [Boolean] used if there is a prioratary scroll running
    def scroll_left(distance, is_priority = false)
      return if @scroll_x_priority && !is_priority

      if $game_switches[Yuki::Sw::MapLinkerDisabled]
        @display_x = (@display_x - distance).clamp(0, @display_x)
      else
        @display_x -= distance
      end
    end

    # Scrolls the map right
    # @param distance [Integer] distance in x to scroll
    # @param is_priority [Boolean] used if there is a prioratary scroll running
    def scroll_right(distance, is_priority = false)
      return if @scroll_x_priority && !is_priority

      if $game_switches[Yuki::Sw::MapLinkerDisabled]
        @display_x = (@display_x + distance).clamp(0, (width - NUM_TILE_VIEW_X) * 128)
      else
        @display_x += distance
      end
    end

    # Scrolls the map up
    # @param distance [Integer] distance in -y to scroll
    # @param is_priority [Boolean] used if there is a prioratary scroll running
    def scroll_up(distance, is_priority = false)
      return if @scroll_y_priority && !is_priority

      if $game_switches[Yuki::Sw::MapLinkerDisabled]
        @display_y = (@display_y - distance).clamp(0, @display_y)
      else
        @display_y -= distance
      end
    end
  end

  module Yuki
    # MapLinker, script that emulate the links between maps. This script also display events.
    # @author Nuri Yuri
    module MapLinker
      # List of link types for the link loading
      LINK_TYPES = %i[north east south west]

      module_function

      # Get the OffsetX
      # @return [Integer]
      def get_OffsetX
        0
      end

      # Get the OffsetY
      # @return [Integer]
      def get_OffsetY
        0
      end

      # Get the OffsetX for the current map
      # @return [Integer]
      def current_OffsetX
        return 0
      end

      # Get the OffsetY for the current map
      # @return [Integer]
      def current_OffsetY
        return 0
      end

      # Return the map datas
      # @return [Array<Yuki::Tilemap::MapData>]
      def map_datas
        @map_datas
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
        load_building(@map_datas[0].map_id, 0, 0)
        return # unless (link_data = @link_data)
        load_building(link_data[0], DeltaMaker, -@north_data.height + DeltaMaker, :nord)
        load_building(link_data[2], @last_map.width - OffsetX * 2 - DeltaMaker, -DeltaMaker, :est)
        load_building(link_data[4], -DeltaMaker, @last_map.height - OffsetY * 2 - DeltaMaker, :sud)
        load_building(link_data[6], -@west_data.width + DeltaMaker, DeltaMaker, :ouest)
      end
    end
  end
end
