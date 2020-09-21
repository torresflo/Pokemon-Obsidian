class TMXConverter
  # Function that convert a map
  # @param map_name [String] name of the map in the project
  def convert_map(map_name)
    puts format('Starting to convert %<name>s', name: map_name)
    tmx_data = NuriGame::TmxReader.new(map_name)
    puts 'Map loaded'
    layers = convert_map_layer(tmx_data)
    tileset = @project_tilesets[@project_data[:maps][map_name][:tileset]]
    tileset.update_tiled_db(tmx_data.tilesets)
    tileset_id = get_tileset_id(map_name)
    save_map(@project_data[:maps][map_name][:id], convert_to_rmxp_layer(layers, tmx_data, tileset), tileset_id)
  end

  # Function that calculate the tileset id of a specific map
  # @param map_name [String] name of the map
  # @return [Integer]
  def get_tileset_id(map_name)
    tileset_name = @project_data[:maps][map_name][:tileset]
    return @project_tilesets.keys.index(tileset_name).to_i + 1
  end

  # Function that save the map data
  # @param map_id [Integer]
  # @param table [Table]
  # @param tileset_id [Integer] id of the tileset in the new database
  def save_map(map_id, table, tileset_id)
    Dir.mkdir(@output_dir) unless Dir.exist?(@output_dir)
    Dir.chdir(@output_dir) do
      Dir.mkdir('Data') unless Dir.exist?('Data')
      map_name = format('Data/Map%03d.rxdata', map_id)
      if File.exist?(map_name)
        map = load_data(map_name)
      else
        map = RPG::Map.new(table.xsize, table.ysize)
      end
      map.data = table
      map.width = table.xsize
      map.height = table.ysize
      map.tileset_id = tileset_id
      save_data(map, map_name)
    end
  end

  # Function that converts the tmx layer into map layers (not RMXP but tileset z layer)
  # @param tmx_data [NuriGame::TmxReader]
  # @return [Array]
  def convert_map_layer(tmx_data)
    puts 'Converting layers to priority layers'
    xp_layers = Array.new(6) { Array.new(tmx_data.width * tmx_data.height) { [] } }
    sp_layers = Array.new(5) { Array.new(tmx_data.width * tmx_data.height, 0) }
    tmx_data.layers.each do |layer_name, layer|
      print '.'
      if layer_name.include?('passages')
        next convert_passages(sp_layers.first, layer, tmx_data)
      elsif layer_name.include?('interactions')
        next convert_interactions(sp_layers.first, layer)
      elsif layer_name.include?('collisions')
        convert_collisions(sp_layers.first, layer)
      elsif layer_name.include?('systemtags')
        next convert_systemtags(layer_name, sp_layers, layer, tmx_data)
      elsif layer_name.include?('terraintags')
        next convert_terrains(sp_layers.last, layer, tmx_data)
      end
      z = layer_name[-1].to_i - 1
      z = 0 if z < 0
      z = 5 if z > 5
      convert_layer(xp_layers[z], layer)
    end
    puts ' '
    flatten_layers(xp_layers)
    merge_special_layers(sp_layers, xp_layers)
    return xp_layers
  end

  # Function that convert the tile of the collision layer to blockable tiles
  def convert_collisions(passages, tmx_layer)
    tmx_layer.each_with_index do |tile_id, index|
      passages[index] = 15 if tile_id > 0
    end
  end

  # Function that merge the tiles of the tmx layer into the xp tile layer
  # @param xp_layer [Array] RMXP tile layer
  # @param tmx_layer [Array] tiled layer
  def convert_layer(xp_layer, tmx_layer)
    tmx_layer.each_with_index { |tile_id, index| xp_layer[index] << tile_id if tile_id > 0 }
  end

  # Function that convert the passage layer (adjust tile_id)
  # @note : The passages can be detected only if a passages.tsx tileset exist
  # @param layer [Array] passage layer for the tile conversion
  # @param tmx_layer [Array] tiled layer
  # @param tmx_data [NuriGame::TmxReader] the tmx data
  def convert_passages(layer, tmx_layer, tmx_data)
    gid = 0
    tmx_data.tilesets.each { |tileset| gid = tileset.firstgid if tileset.source.casecmp?('passages.tsx') }
    puts 'passages.tsx has not been found in the map' if gid.zero?
    tmx_layer.each_with_index do |tile_id, index|
      layer[index] = layer[index] + tile_id - gid if tile_id >= gid
    end
  end

  # Function that convert the interaction layer (adjust tile_id)
  # @param layer [Array] passage layer for the tile conversion
  # @param tmx_layer [Array] tiled layer
  def convert_interactions(passages, tmx_layer)
    tmx_layer.each_with_index do |tile_id, index| 
      passages[index] = passages[index] + 128 if tile_id > 0
    end
  end

  # Function that convert the passage layer (adjust tile_id)
  # @note : The passages can be detected only if a passages.tsx tileset exist
  # @param layer [Array] passage layer for the tile conversion
  # @param tmx_layer [Array] tiled layer
  # @param tmx_data [NuriGame::TmxReader] the tmx data
  def convert_terrains(layer, tmx_layer, tmx_data)
    gid = 0
    tmx_data.tilesets.each { |tileset| gid = tileset.firstgid if tileset.source.casecmp?('terraintags.tsx') }
    puts 'terraintags.tsx has not been found in the map' if gid.zero?
    tmx_layer.each_with_index do |tile_id, index|
      layer[index] = tile_id - gid if tile_id >= gid
    end
  end

  # Function that convert the system tag passage to the right system_tag layer
  # @param layer_name [String] name of the layer (to detect the right sp_layer to choose)
  # @param sp_layers [Array] special layers
  # @param tmx_layer [Array] the tiled layer
  # @param tmx_data [NuriGame::TmxReader] the tmx data
  def convert_systemtags(layer_name, sp_layers, tmx_layer, tmx_data)
    gid = 0
    tmx_data.tilesets.each { |tileset| gid = tileset.firstgid if tileset.source.casecmp?('systemtags.tsx') }
    puts 'systemtags.tsx has not been found in the map' if gid.zero?
    gid -= 384 # RMXP effect
    case layer_name.downcase
    when 'systemtags'
      layer = sp_layers[1]
    when 'systemtags_bridge1'
      layer = sp_layers[2]
    when 'systemtags_bridge2'
      layer = sp_layers[3]
    end
    tmx_layer.each_with_index do |tile_id, index|
      layer[index] = tile_id - gid if tile_id > 0
    end
  end

  # Function that merge the sp layers into the xp layers
  # @param sp_layers [Array]
  # @param xp_layers [Array]
  def merge_special_layers(sp_layers, xp_layers)
    passages = sp_layers.first
    xp_layers.each_with_index do |layer, z|
      sp_layer = sp_layers[z.zero? ? 1 : (z > 3 ? 3 : 2)]
      terrain_tag = z.zero? ? sp_layers.last : Hash.new(0)
      layer.each_with_index do |tile, index|
        next if tile.empty?
        tile << passages[index]
        tile << sp_layer[index]
        tile << terrain_tag[index]
      end
    end
  end

  # Function that flatten the XP layer to get 3 layers
  # @param xp_layers [Array]
  def flatten_layers(xp_layers)
    size = xp_layers.first.size
    mod = size / 60
    mod = 1 if mod.zero?
    empty_tile = []
    count = 0
    size.times do |i|
      print("\r#{('=' * (i / mod)).ljust(60, '_')}") if (i % mod).zero?
      count = 0
      1.upto(5) do |z|
        count += 1 unless xp_layers[z][i].empty?
      end
      merge_tiles_to_highest_layer(xp_layers, i, empty_tile) if count > 2
    end
    puts ' '
  end

  # Function that merge the tiles to the highest layer
  # @param xp_layers [Array]
  # @param index [Integer] tiled index in the tables
  # @param empty_tile [Array] an empty tile
  def merge_tiles_to_highest_layer(xp_layers, index, empty_tile)
    last_merged_z = 2
    3.upto(5) do |z|
      next if xp_layers[z][index].empty?
      xp_layers[z][index] = xp_layers[last_merged_z][index].concat(xp_layers[z][index])
      xp_layers[last_merged_z][index] = empty_tile
      last_merged_z = z
    end
  end

  # Function that converts the actual layers to RMXP layers
  # @param layers [Array]
  # @param tmx_data [NuriGame::TmxReader]
  # @param tileset [TMX_Tileset]
  # @return [Table]
  def convert_to_rmxp_layer(layers, tmx_data, tileset)
    puts 'Converting to RMXP layers'
    table = Table.new(w = tmx_data.width, tmx_data.height, 3)
    table.fill(0)
    size = layers.first.size
    mod = size / 60
    mod = 1 if mod.zero?
    c = 0
    2.times do # Done twice to get the correct tile id since its dynamic
      size.times do |i|
        print("\r#{('=' * (i / mod)).ljust(60, '_')}") if (i % mod).zero?
        x = i % w
        y = i / w
        c = -1
        layers.each_with_index do |layer, z|
          table[x, y, c += 1] = tileset.add_tile(z, layer[i]) unless layer[i].empty?
        end
      end
    end
    puts ' '
    return table
  end
end
