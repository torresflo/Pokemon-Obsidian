require 'nuri_game/tsx_reader'

class TMXConverter
  # Function that build all the tilesets
  def build_tilesets
    tilesets = load_tilesets_rxdata
    @systemtags = load_systemtags
    @png_images = {}
    @tsx_readers = {}
    counter = 1
    @rect = Rect.new(0, 0, 32, 32)
    @rect2 = Rect.new(0, 0, 32, 32)
    @project_tilesets.each do |name, tileset|
      update_tileset(tilesets, tileset, counter, name)
      counter += 1
    end
    @png_images.each { |*, image| image.dispose }
    save_tilesets_rxdata(tilesets)
    save_systemtags_rxdata(@systemtags)
  end

  # Function that updates a single tileset
  # @param tilesets [Array<RPG::Tileset>] RMXP tilesets
  # @param tileset [TMX_Tileset]
  # @param counter [Integer] index of the tileset in the RMXP tilesets
  # @param name [String] name of the tileset in the project
  def update_tileset(tilesets, tileset, counter, name)
    puts "Updating #{name}"
    rmxp_tileset = (tilesets[counter] ||= RPG::Tileset.new)
    adjust_rmxp_tileset(rmxp_tileset, tileset)
    (@systemtags[counter] = Table.new(rmxp_tileset.passages.xsize)).fill(0)
    # puts 'Table filled with 0'
    rmxp_tileset.tileset_name = @project_data[:tilesets][name].gsub('.png', '')
    create_tileset_data(rmxp_tileset, tileset, counter)
  end

  # Function that create the tileset data and its image
  # @param rmxp_tileset [RPG::Tileset]
  # @param tileset [TMX_Tileset]
  # @param counter [Integer]
  def create_tileset_data(rmxp_tileset, tileset, counter)
    # puts 'Creating image'
    image = Image.new(256, ((rmxp_tileset.passages.xsize - 384) / 8 + 1) * 32)
    puts 'Drawing tiles'
    tile_id = 384
    x = 0
    y = 0
    priorities = rmxp_tileset.priorities
    passages = rmxp_tileset.passages
    terrain_tags = rmxp_tileset.terrain_tags
    systemtags = @systemtags[counter]

    tileset.z_layers.each_with_index do |layer, z|
      layer.each do |tile|
        priorities[tile_id] = z
        passages[tile_id] = tile[-3].clamp(0, 0x1FFF)
        systemtags[tile_id] = tile[-2].clamp(0, 0x1FFF)
        terrain_tags[tile_id] = tile[-1].clamp(0, 0x1FFF)
        draw_tile(x, y, tile, tileset, image)
        if (x += 32) >= 256
          x = 0
          y += 32
        end
        tile_id += 1
      end
    end

    puts 'Saving image'
    save_image('graphics/tilesets/' + rmxp_tileset.tileset_name + '.png', image)
    # puts 'Freeing memory'
    image.dispose
  end

  # Function that save the tileset image
  # @param tileset_name [String] the tileset filename
  # @param image [LiteRGSS::Image] the image
  def save_image(tileset_name, image)
    Dir.chdir(@output_dir) do
      Dir.mkdir('graphics') unless Dir.exist?('graphics')
      Dir.mkdir('graphics/tilesets') unless Dir.exist?('graphics/tilesets')
      image.to_png_file(tileset_name)
    end
  end

  # Function that draw a tile to the image
  # @param x [Integer] x position of the tile
  # @param y [Integer] y position of the tile
  # @param tile [Array] tiles to draw
  # @param tileset [TMX_Tileset]
  # @param image [LiteRGSS::Image] image
  def draw_tile(x, y, tile, tileset, image)
    (tile.size - 3).times do |i|
      tid = tile[i]
      source, rect = get_tile_image(tid, tileset)
      next unless source
      if rect.width != 32
        @rect2.set(x, y)
        image.stretch_blt(@rect2, source, rect)
      else
        image.blt(x, y, source, rect)
      end
    end
  end

  # Function that return the correct image with the correct rect according to the tile id
  # @param tid [Integer] tile id
  # @param tileset [TMX_Tileset]
  def get_tile_image(tid, tileset)
    source = nil
    firstgid = 0
    tileset.tiled_db.each do |tiled_tileset|
      if tid >= tiled_tileset.firstgid
        source = tiled_tileset.source
        firstgid = tiled_tileset.firstgid
      end
    end
    return (@png_images[nil] ||= Image.new(32,32)), @rect if !source or source.empty?
    tid -= firstgid
    tsx = (@tsx_readers[source] ||= NuriGame::TsxReader.new(source))
    image = (@png_images[tsx.image.source] ||= get_image(tsx))
    tx = tid % tsx.columns
    ty = tid / tsx.columns
    @rect.set(tx * (tsx.tilewidth + tsx.spacing) + tsx.margin, ty * (tsx.tileheight + tsx.spacing) + tsx.margin, tsx.tilewidth, tsx.tileheight)
    width = @rect.x + @rect.width
    height = @rect.y + @rect.height
    if image.width < width || image.height < height || image.width <= @rect.x || image.height <= @rect.y
      puts "Error #{tid} of #{tileset.name} out of image boundaries !"
      return nil, nil
    end
    return image, @rect
  end

  # Function that return an image according to the tsx
  # @param tsx [NuriGame::TsxReader]
  def get_image(tsx)
    if tsx.image.source
      image = Image.new(tsx.image.source)
    else
      image = Image.new(tsx.image.data)
    end
    if tsx.image.trans
      col_comp = tsx.image.trans.sub('#', '').split(/([0-9a-f]{2})/i).reject(&:empty?).collect { |i| i.to_i(16) }
      image.create_mask(Color.new(*col_comp), 0)
    end
    if tsx.columns == 0
      tsx.instance_variable_set(:@columns, image.width / tsx.tilewidth)
    end
    return image
  end

  # Function that adjust the RMXP tileset data
  # @param rmxp_tileset [RPG::Tileset]
  # @param tileset [TMX_Tileset]
  def adjust_rmxp_tileset(rmxp_tileset, tileset)
    rmxp_tileset.name = tileset.name
    tile_count = 0
    tileset.z_layers.each { |layer| tile_count += layer.size }
    rmxp_tileset.passages = Table.new(384 + tile_count).fill(0)
    rmxp_tileset.priorities = Table.new(384 + tile_count).fill(0)
    rmxp_tileset.priorities[0] = 5
    rmxp_tileset.terrain_tags = Table.new(384 + tile_count).fill(0)
  end

  # Function that load Data/Tilesets.rxdata
  # @return [Array<RPG::Tileset>]
  def load_tilesets_rxdata
    Dir.mkdir(@output_dir) unless Dir.exist?(@output_dir)
    Dir.chdir(@output_dir) do
      Dir.mkdir('Data') unless Dir.exist?('Data')
      if File.exist?('Data/Tilesets.rxdata')
        return load_data('Data/Tilesets.rxdata')
      else
        return []
      end
    end
  end

  # Function that load Data/PSDK/SystemTags.rxdata
  # @return [Array<Table>]
  def load_systemtags
    Dir.mkdir(@output_dir) unless Dir.exist?(@output_dir)
    Dir.chdir(@output_dir) do
      Dir.mkdir('Data') unless Dir.exist?('Data')
      Dir.mkdir('Data/PSDK') unless Dir.exist?('Data/PSDK')
      if File.exist?('Data/PSDK/SystemTags.rxdata')
        return load_data('Data/PSDK/SystemTags.rxdata')
      else
        return []
      end
    end
  end

  # Function that save tilesets into Data/Tilesets.rxdata
  # @param tilesets [Array<RPG::Tileset>]
  def save_tilesets_rxdata(tilesets)
    Dir.chdir(@output_dir) do
      save_data(tilesets, 'Data/Tilesets.rxdata')
    end
  end

  # Function that save systemtags into Data/PSDK/SystemTags.rxdata
  # @param systemtags [Array<Table>]
  def save_systemtags_rxdata(systemtags)
    Dir.chdir(@output_dir) do
      save_data(systemtags, 'Data/PSDK/SystemTags.rxdata')
    end
  end
end
