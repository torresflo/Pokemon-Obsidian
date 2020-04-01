class Tilemap
  # Class that draws the Map on screen. This class relies on SpriteMap to save an important amount of sprites.
  # To go even deeper in the sprite saving, priority layer that are higher than 1 can only show one tile instead of 3.
  # If you don't want that, you can change PRIORITY_LAYER_COUNT array.
  # @author Nuri Yuri
  class WithLessRubySprites < Tilemap
    # Array telling how much layer each priority layer can show
    PRIORITY_LAYER_COUNT = [3, 2, 2, 1, 1, 1]
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

      @sprites.each_with_index do |layer, pz|
        # Update the coordinates
        layer.each_with_index do |priority_layer, priority|
          next unless PRIORITY_LAYER_COUNT[priority] > pz

          priority_layer.each_with_index do |sprite, py|
            sprite.set_origin(ox, oy)
            sprite.z = (py + priority) * 32 - add_z if priority > 0
          end
        end
        NX.times do |px|
          NY.times do |py|
            tile_id = map_data[cx = x + px, cy = y + py, pz]
            next unless tile_id&.between?(1, 383)

            priority = maplinker.get_priority(cx, cy)[tile_id]
            layer.dig(priority, py).set_rect(px, (tile_id % 48) * 32, autotiles_counter[tile_id / 48], 32, 32)
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

      @all_sprites.each(&:reset)

      @sprites.each_with_index do |layer, pz|
        # Update the coordinates
        layer.each_with_index do |priority_layer, priority|
          next unless PRIORITY_LAYER_COUNT[priority] > pz

          priority_layer.each_with_index do |sprite, py|
            sprite.set_origin(ox, oy)
            sprite.z = (py + priority) * 32 - add_z if priority > 0
          end
        end
        rect = SRC
        NX.times do |px|
          NY.times do |py|
            tile_id = map_data[cx = x + px, cy = y + py, pz]
            next if !tile_id || tile_id == 0

            priority = maplinker.get_priority(cx, cy)[tile_id] || 0
            if tile_id < 384 # Autotile
              rect.set((tile_id % 48) * 32, autotiles_counter[tile_id / 48], 32, 32)
              layer.dig(priority, py).set(px, autotiles_bmp[tile_id / 48 - 1], rect)
            else
              tileset = maplinker.get_tileset(cx, cy)
              max_size = tileset.height
              tid = tile_id - 384
              tlsy = tid / 8 * 32
              rect.set((tid % 8 + tlsy / max_size * 8) * 32, tlsy % max_size, 32, 32)
              layer.dig(priority, py).set(px, tileset, rect)
            end
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
      add_z = oy / 2
      @sprites.each_with_index do |layer, pz|
        layer.each_with_index do |priority_layer, priority|
          next unless PRIORITY_LAYER_COUNT[priority] > pz

          priority_layer.each_with_index do |sprite, py|
            sprite.set_origin(ox, oy)
            sprite.z = (py + priority) * 32 - add_z if priority > 0
          end
        end
      end
    end

    # Free the tilemap
    def dispose
      return if @disposed

      @all_sprites.each(&:dispose)
      @all_sprites = nil
      @sprites = nil
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
      # Variable allowing to quicky update the sprites
      @all_sprites = []
      # Variable containing the sprite (in a way it's easier to access)
      @sprites = []
      3.times do |z|
        priority_array = Array.new(6) do |priority|
          # If we are allowed to draw more layer than the current layer we add a new priority layer
          if PRIORITY_LAYER_COUNT[priority] > z
            priority_layer = Array.new(NY) do |y|
              sprite = SpriteMap.new(viewport, tile_size, NX)
              sprite.set_position(-tile_size, (y - 1) * tile_size)
              sprite.tile_scale = zoom
              sprite.z = 0
              @all_sprites << sprite
              next(sprite)
            end
            next(priority_layer)
          else # Otherwise we take the last one
            next(adjust_sprite_layer(priority, PRIORITY_LAYER_COUNT[priority]))
          end
        end
        @sprites << priority_array
      end
    end
  end

  # Adjust the sprites variable when the priority allow only two sprites => c3 c2 c3
  # @param priority [Integer] the current priority
  # @param count [Integer] the number of layer allowed for the priority
  # @return [Sprite_Map]
  def adjust_sprite_layer(priority, count)
    return @sprites.last[priority] if count != 2

    sprite_to_return = @sprites.last[priority]
    @sprites.last[priority] = @sprites.first[priority]
    @sprites.first[priority] = sprite_to_return
    return sprite_to_return
  end

  # PSDK Native resolution version the Tilemap
  class WithLessRubySprites_16 < WithLessRubySprites
    # Generate the sprites of the tilemap with the right settings
    # @param viewport [Viewport] the viewport where tiles are shown
    def make_sprites(viewport)
      super(viewport, 16, 0.5)
    end
  end
end
