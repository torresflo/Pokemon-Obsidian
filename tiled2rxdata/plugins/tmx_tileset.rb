# Class describing a tileset for the conversion
class TMX_Tileset
  # @return [String] name of the tileset
  attr_accessor :name
  # @return [Array] z_layers of the tileset (containing tile arrays)
  attr_reader :z_layers
  # @return [Array] animated z_layers of the tileset (containing tile arrays)
  attr_reader :z_anim_layers
  # @return [Integer] number of tiles
  attr_reader :tile_count
  # @return [Array] tiled Tileset db
  attr_reader :tiled_db
  # Maximum number of tiles we can put in a 4096x4096 texture (the smallest encountered)
  MAX_TILE_COUNT = 16_384

  # Create a new tileset
  def initialize(name = '')
    # Z Layer for each animated tiles
    @z_anim_layers = Array.new(6) { [] }
    # Each group of tile will be stored in a z_layer (to allow creation of the same tile with different z property)
    @z_layers = Array.new(6) { [] }
    # We'll count tiles in order to prevent texture overflow (GPU friendly)
    @tile_count = 0
    # Tiled db
    @tiled_db = []
    @name = name
  end

  # Add a tile to a layer
  # @param z_coord [Integer] id of the z layer
  # @param tile [Array<Integer>] list of tiles to build the tile (the two last value are passage and system tag)
  # @return [Integer] tile id (in RMXP tileset)
  def add_tile(z_coord, tile)
    return 0 unless z_coord.between?(0, 5)
    add_tile_to_layer(tile, @z_layers[z_coord]) + 384
  end

  # Add an animated tile to a layer
  # @param z_coord [Integer] id of the z layer
  # @param tile [Array<Integer>] list of tiles to build the tile (the two last value are passage and system tag)
  # @return [Integer] tile id (in RMXP tileset)
  def add_animated_tile(z_coord, tile)
    return 0 unless z_coord.between?(0, 5)
    add_tile_to_layer(tile, @z_anim_layers[z_coord]) + 48
  end

  # Add a tile to a given layer
  def add_tile_to_layer(tile, layer)
    index = layer.index(tile)
    return get_tile_id(layer, index) if index
    index = layer.size
    layer << tile
    @tile_count += 1
    return get_tile_id(layer, index) unless @tile_count >= MAX_TILE_COUNT
    raise "Too much tiles on '#{@name}', create a new tileset for your maps to limit the number of tiles"
  end

  # Return the real tile id of a tile
  # @param layer [Array] the layer where the tile was pushed
  # @param index [Integer] the index of the tile in this layer
  def get_tile_id(layer, index)
    layers = @z_layers.include?(layer) ? @z_layers : @z_anim_layers
    count = 0
    layers.each do |sub_layer|
      return count + index if sub_layer == layer
      count += sub_layer.size
    end
    return count
  end

  # Update the tiled db (to allow tileset conversion)
  # @param tilesets [Array<NuriGame::TmxReader::Tileset>] tilesets
  def update_tiled_db(tilesets)
    tilesets.each_with_index do |tileset, index|
      db_tileset = @tiled_db[index]
      next @tiled_db << tileset unless db_tileset
      if db_tileset.firstgid != tileset.firstgid
        raise format('The tileset %<name>s is outdated, please reset it and redo the conversion', name: @name)
      end
    end
  end
end
