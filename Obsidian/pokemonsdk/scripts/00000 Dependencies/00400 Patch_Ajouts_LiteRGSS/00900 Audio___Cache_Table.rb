#encoding: utf-8

module Audio
  module Cache
    # Table that define what music Audio Cache should load when the player enters a map
    # @return [Hash<id_map => Array<String>]
    Table = {
      1 => ["audio/bgm/43 camphrier town", "audio/bgm/rosa_wild_battle"], # PSDK Forest
      5 => ["audio/bgm/43 camphrier town"], # Pokemon Center
      9 => ["audio/bgm/24 pokemon center", "audio/bgm/01 glittering cave"], # PSDK Town
      2 => ["audio/bgm/13 cave of origin", "audio/bgm/43 camphrier town"], # Cave
      6 => ["audio/bgm/01 glittering cave"], # Ice cave
    }
    module_function
    # Function that autoloads the files
    # @param map_id [Integer] ID of the map where the player warped
    # @param args [Array<String>] complementary file to load (Yuki::MapLinker)
    def autoload_sounds(map_id, *args)
      table = Table[map_id]
      table&.each { |filename| preload_sound(filename) }
      args.each { |filename| preload_sound(filename) }
      flush_sound
      load
    end
  end
end
