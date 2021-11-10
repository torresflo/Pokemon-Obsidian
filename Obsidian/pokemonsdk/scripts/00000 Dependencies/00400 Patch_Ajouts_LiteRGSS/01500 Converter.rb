# Module that helps to convert stuff
module Converter
  module_function

  # Convert a tileset to a PSDK readable PSDK tileset (if required)
  # @param filename [String]
  # @param max_size [Integer] Maximum Size of the texture in the Graphic Card
  # @param min_size [Integer] Minimum Size of the texture for weak Graphic Card
  # @example Converter.convert_tileset("Graphics/tilesets/tileset.png")
  def convert_tileset(filename, max_size = 4096, min_size = 1024)
    return unless File.exist?(filename.downcase)

    img = Image.new(filename.downcase)
    new_filename = filename.downcase.gsub('.png', '_._ingame.png')

    if img.height > (min_size / 256 * min_size)
      log_error("#{filename} is too big for weak Graphic Card !")
      min_size = max_size
    end

    if img.height > (max_size / 256 * max_size)
      log_error("#{filename} is too big for most Graphic Card !")
      return
    end
    nb_col = (img.height / min_size.to_f).ceil
    # return img.dispose if nb_col == 1 # Removed to get better loading.
    if nb_col > 32
      log_error("#{filename} cannot be converted to #{new_filename}, there's too much tiles.")
      return
    end
    new_image = Image.new(256 * nb_col, min_size)
    nb_col.times do |i|
      height = min_size
      height = img.height - (i * min_size) if (i * min_size + height) > img.height
      new_image.blt(256 * i, 0, img, Rect.new(0, i * min_size, 256, height))
    end
    new_image.to_png_file(new_filename)
    log_info("#{filename} converted to #{new_filename}!")
    img.dispose
    new_image.dispose
  end

  # Convert an autotile file to a specific autotile file
  # @param filename [String]
  # @example Converter.convert_autotile("Graphics/autotiles/eauca.png")
  def convert_autotile(filename)
    autotiles = [Image.new(filename)]
    bmp_arr = Array.new(48) { |i| generate_autotile_bmp(i + 48, autotiles) }
    bmp = Image.new(48 * 32, bmp_arr.first.height)
    bmp_arr.each_with_index do |sub_bmp, i|
      bmp.blt(32 * i, 0, sub_bmp, sub_bmp.rect)
    end
    bmp.to_png_file(new_filename = filename.gsub('.png', '_._tiled.png'))
    bmp.dispose
    bmp_arr.each(&:dispose)
    autotiles.first.dispose
    log_info("#{filename} converted to #{new_filename}!")
  end

  # The autotile builder data
  Autotiles = [
    [ [27, 28, 33, 34], [ 5, 28, 33, 34], [27,  6, 33, 34], [ 5,  6, 33, 34],
      [27, 28, 33, 12], [ 5, 28, 33, 12], [27,  6, 33, 12], [ 5,  6, 33, 12] ],
    [ [27, 28, 11, 34], [ 5, 28, 11, 34], [27,  6, 11, 34], [ 5,  6, 11, 34],
      [27, 28, 11, 12], [ 5, 28, 11, 12], [27,  6, 11, 12], [ 5,  6, 11, 12] ],
    [ [25, 26, 31, 32], [25,  6, 31, 32], [25, 26, 31, 12], [25,  6, 31, 12],
      [15, 16, 21, 22], [15, 16, 21, 12], [15, 16, 11, 22], [15, 16, 11, 12] ],
    [ [29, 30, 35, 36], [29, 30, 11, 36], [ 5, 30, 35, 36], [ 5, 30, 11, 36],
      [39, 40, 45, 46], [ 5, 40, 45, 46], [39,  6, 45, 46], [ 5,  6, 45, 46] ],
    [ [25, 30, 31, 36], [15, 16, 45, 46], [13, 14, 19, 20], [13, 14, 19, 12],
      [17, 18, 23, 24], [17, 18, 11, 24], [41, 42, 47, 48], [ 5, 42, 47, 48] ],
    [ [37, 38, 43, 44], [37,  6, 43, 44], [13, 18, 19, 24], [13, 14, 43, 44],
      [37, 42, 43, 48], [17, 18, 47, 48], [13, 18, 43, 48], [ 1,  2,  7,  8] ]
  ]
  # The source rect (to draw autotiles)
  SRC = Rect.new(0, 0, 16, 16)
  # Generate one tile of an autotile
  # @param id [Integer] id of the tile
  # @param autotiles [Array<Texture>] autotiles bitmaps
  # @return [Texture] the calculated bitmap
  def generate_autotile_bmp(id, autotiles)
    autotile = autotiles[id / 48 - 1]
    return Image.new(32, 32) if !autotile or autotile.width < 96

    src = SRC
    id %= 48
    tiles = Autotiles[id >> 3][id & 7]
    frames = autotile.width / 96
    bmp = Image.new(32, frames * 32)
    frames.times do |x|
      anim = x * 96
      4.times do |i|
        tile_position = tiles[i] - 1
        src.set(tile_position % 6 * 16 + anim, tile_position / 6 * 16, 16, 16)
        bmp.blt(i % 2 * 16, i / 2 * 16 + x * 32, autotile, src)
      end
    end
    return bmp
  end
end
