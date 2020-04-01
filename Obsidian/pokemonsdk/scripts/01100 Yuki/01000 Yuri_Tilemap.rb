# Draw the Map on screen
# @author Nuri Yuri
class Tilemap
  # Bitmap used as a tileset
  # @return [Bitmap]
  attr_accessor :tileset
  # Array of Bitmap used as autotiles
  # @return [Array<Bitmap>]
  attr_accessor :autotiles
  # The tiles on the map
  # @return [Table]
  attr_accessor :map_data
  # The "z" attribute of each tiles in the tileset
  # @return [Table]
  attr_accessor :priorities
  # The offset x of the Tilemap
  # @return [Integer]
  attr_accessor :ox
  # The offset y of the Tilemap
  # @return [Integer]
  attr_accessor :oy
  # The viewport where the tilemap is shown
  # @return [Viewport]
  attr_reader :viewport
  # If the tilemap has been freed
  # @return [Boolean]
  attr_reader :disposed
  # Number of frame before each autotile change their animation frame
  Autotile_Frame_Count = PSDK_CONFIG.tilemap.autotile_idle_frame_count

  # The source rect (to draw autotiles)
  SRC = Rect.new(0, 0, 16, 16)
  # Number of tiles drawn on X axis
  NX = PSDK_CONFIG.tilemap.tilemap_size_x
  # Number of tiles drawn on Y axis
  NY = PSDK_CONFIG.tilemap.tilemap_size_y

  class << self
    # List of unparsed Autotile bitmap (to detect autotile change)
    attr_accessor :autotiles_copy
    @autotiles_copy = Array.new(7, -1)
  end

  # Create a new Tilemap object
  # @param viewport [Viewport] the viewport where the Tilemap is shown
  def initialize(viewport)
    @viewport = viewport
    @autotiles = Array.new(7, RPG::Cache.default_bitmap)
    @autotiles_counter = Array.new(8, 0)
    @autotiles_copy = Tilemap.autotiles_copy
    # @autotiles_bmp = @@autotile_bmp
    make_sprites(viewport)
    check_copy(@autotiles_copy)
    @last_ox = @last_oy = nil # Prevent from useless movement
    @disposed = false
    @map_linker = Yuki::MapLinker
  end

  # Force reset of the tilemap
  def reset
    @last_x = @last_y = @last_ox = @last_oy = nil
  end

  # Update the tilemap
  def update
    return if @disposed

    # ox / 32 = first visible tile (x), oy / 32 first visible tile (y)
    ox = (@ox.round >> 1 << 1)
    oy = (@oy.round >> 1 << 1)
    x = ox / 32 - 1
    y = oy / 32 - 1

    if @autotiles != @autotiles_copy # Draw all tiles if change detected in autotiles
      reload_autotiles
      draw_all(@last_x = x, @last_y = y, ox % 32, oy % 32)
    elsif (Graphics.frame_count % Autotile_Frame_Count) == 0 # If we need to update autotiles
      if x != @last_x || y != @last_y # If the map has moved from a tile, we need to draw everything
        update_autotile_counter(@autotiles_counter, @autotiles)
        draw_all(@last_x = x, @last_y = y, ox % 32, oy % 32)
      else
        draw_autotiles(@last_x = x, @last_y = y, ox % 32, oy % 32)
      end
    elsif ox != @last_ox || oy != @last_oy # If the map moved from few pixels
      if x != @last_x || y != @last_y # If the map has moved from a tile, we need to draw everything
        draw_all(@last_x = x, @last_y = y, ox % 32, oy % 32)
      else
        update_positions(@last_x = x, @last_y = y, ox % 32, oy % 32)
      end
    end
    @last_ox = ox
    @last_oy = oy
  end

  # Update the autotile counter
  # @param autotiles_counter [Array<Integer>] counter for each autotiles
  # @param autotiles_bmp [Array<Bitmap>] bitmap for each autotiles
  def update_autotile_counter(autotiles_counter, autotiles_bmp)
    1.upto(7) do |index|
      counter = autotiles_counter[index]
      counter += 32
      counter = 0 if autotiles_bmp[index - 1].height <= counter # if(autotiles_bmp[index * 48].height <= counter)
      autotiles_counter[index] = counter
    end
  end

  # Draw only autotiles
  # @param x [Integer] position x of the first tile shown
  # @param y [Integer] position y of the first tile shown
  # @param ox [Integer] ox of every tiles
  # @param oy [Integer] oy of every tiles
  def draw_autotiles(x, y, ox, oy)
    map_data = @map_data
    autotiles_counter = @autotiles_counter
    autotiles_bmp = @autotiles
    add_z = oy / 2
    maplinker = @map_linker
    update_autotile_counter(autotiles_counter, autotiles_bmp)
    @sprites.each_with_index do |sprite_table, pz|
      sprite_table.each_with_index do |sprite_col, px|
        sprite_col.each_with_index do |sprite, py|
          sprite.ox = ox
          sprite.oy = oy
          tile_id = map_data[cx = x + px, cy = y + py, pz]
          next unless tile_id

          sprite.src_rect.set((tile_id % 48) * 32, autotiles_counter[tile_id / 48], 32, 32) if tile_id.between?(1, 383)
          priority = maplinker.get_priority(cx, cy)[tile_id] # -- priorities[tile_id]
          next(sprite.z = 0) if !priority || priority == 0

          sprite.z = (py + priority) * 32 - add_z
        end
      end
    end
  end

  # Draw everything
  # @param x [Integer] position x of the first tile shown
  # @param y [Integer] position y of the first tile shown
  # @param ox [Integer] ox of every tiles
  # @param oy [Integer] oy of every tiles
  def draw_all(x, y, ox, oy)
    # -- priorities = @priorities
    map_data = @map_data
    autotiles_counter = @autotiles_counter
    autotiles_bmp = @autotiles # @autotiles_bmp
    # -- tileset1 = @tileset
    add_z = oy / 2
    maplinker = @map_linker
    @sprites.each_with_index do |sprite_table, pz|
      sprite_table.each_with_index do |sprite_col, px|
        sprite_col.each_with_index do |sprite, py|
          sprite.ox = ox
          sprite.oy = oy
          tile_id = map_data[cx = x + px, cy = y + py, pz]
          if !tile_id || tile_id == 0
            next(sprite.bitmap = nil)
          elsif tile_id < 384 # Autotile
            sprite.bitmap = autotiles_bmp[tile_id / 48 - 1]
            sprite.src_rect.set((tile_id % 48) * 32, autotiles_counter[tile_id / 48], 32, 32)
          else # Tile
            sprite.bitmap = maplinker.get_tileset(cx, cy) # -- tileset1
            tid = tile_id - 384
            tlsy = tid / 8 * 32
            max_size = sprite.bitmap.height
            sprite.src_rect.set((tid % 8 + tlsy / max_size * 8) * 32, tlsy % max_size, 32, 32)
          end

          priority = maplinker.get_priority(cx, cy)[tile_id] # -- priorities[tile_id]
          next(sprite.z = 0) if !priority || priority == 0

          sprite.z = (py + priority) * 32 - add_z
        end
      end
    end
  end

  # Only change the ox, oy and z position of each tiles
  # @param x [Integer] position x of the first tile shown
  # @param y [Integer] position y of the first tile shown
  # @param ox [Integer] ox of every tiles
  # @param oy [Integer] oy of every tiles
  def update_positions(x, y, ox, oy)
    # -- priorities = @priorities
    map_data = @map_data
    add_z = oy / 2
    maplinker = @map_linker
    @sprites.each_with_index do |sprite_table, pz|
      sprite_table.each_with_index do |sprite_col, px|
        sprite_col.each_with_index do |sprite, py|
          sprite.ox = ox
          sprite.oy = oy
          tile_id = map_data[cx = x + px, cy = y + py, pz]
          next if !tile_id || tile_id <= 0

          priority = maplinker.get_priority(cx, cy)[tile_id] # -- priorities[tile_id]
          next if !priority || priority == 0

          sprite.z = (py + priority) * 32 - add_z
        end
      end
    end
  end

  # Free the tilemap
  def dispose
    return if @disposed

    @sprites.each { |sprite_array| sprite_array.each { |sprite_col| sprite_col.each { |sprite| sprite.dispose } } }
    @disposed = true
  end
  # If the tilemap is disposed
  # @return [Boolean]
  alias disposed? disposed

  private

  # Generate the sprites of the tilemap with the right settings
  # @param viewport [Viewport] the viewport where tiles are shown
  # @param tile_size [Integer] the dimension of a tile
  # @param zoom [Numeric] the global zoom of a tile
  def make_sprites(viewport, tile_size = 32, zoom = 1)
    sprite = nil
    @sprites = Array.new(3) do
      Array.new(NX) do |x|
        Array.new(NY) do |y|
          sprite = Sprite.new(viewport)
          sprite.x = (x - 1) * tile_size
          sprite.y = (y - 1) * tile_size
          sprite.zoom_x = sprite.zoom_y = zoom
          next(sprite)
        end
      end
    end
  end

  # Reload the autotiles (internal)
  def reload_autotiles
    autotiles = @autotiles
    autotiles_copy = @autotiles_copy
    7.times do |j|
      if autotiles_copy[j] != autotiles[j]
        autotiles_copy[j] = autotiles[j]
        # load_autotile(j, (j + 1) * 48, autotiles)
      end
    end
  end

  # Check if the old autotile Array is not the same
  # @param copy [Array<Bitmap>]
  def check_copy(copy)
    if !copy || copy.any? { |element| element.is_a?(Bitmap) && element.disposed? }
      Tilemap.autotiles_copy = @autotiles_copy = Array.new(7, -1)
    end
  end
end
# PSDK Native resolution version the Tilemap
class Yuri_Tilemap < Tilemap
  # Generate the sprites of the tilemap with the right settings
  # @param viewport [Viewport] the viewport where tiles are shown
  def make_sprites(viewport)
    super(viewport, 16, 0.5)
  end
end
