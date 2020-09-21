require 'pp'

class TMXConverter
  # Show help to user
  def show_help
    puts 'Help'.center(80, '=')
    puts '> add tileset name png_filename : Add a new tileset with the specified name'
    puts '> add map tmx_filename tileset_name rmxp_map_id : Add a new map'
    puts '> reset tileset name : Reset the tileset (its tile may change position if reprocessed)'
    puts '> del tileset name : Delete tileset from project'
    puts '> del map tmx_filename : Delete the map (won\'t delete file)'
    puts '> convert tmx_filename : Trigger the map conversion'
    puts '> convert * : Trigger the map conversion of all maps in the project'
    puts '> build tileset : Trigger the tileset creation (png + rxdata)'
    puts '> list map : Show the list of map in the project'
    puts '> list tileset : Show the list of tilesets in the project'
    puts '> exit : Exit the converter'
    puts '> save : Save the data'
    puts '> run : Build all tilesets, convert all maps and exit'
    puts '> debug : Call the debug method (progammer only)'
  end

  # Show help to user
  def debug_converter
    puts "Loading tilesets"
    tilesets = load_tilesets_rxdata

    puts "--------------- Tileset ---------------"
    tilesets.each_with_index do |tileset, index|
      rmxp_tileset = (tilesets[index] ||= RPG::Tileset.new)

      pp rmxp_tileset

      passages = rmxp_tileset.passages
      priorities = rmxp_tileset.priorities
      terrain_tags = rmxp_tileset.terrain_tags

      puts "----- Passages -----"
      pp passages
      
      passages_xsize = passages.xsize
      $i = 0

      while $i < passages_xsize  do
        puts passages[$i]
        $i +=1
      end

      puts "----- Priorities -----"
      pp priorities

      puts "----- Terrain Tags -----"
      pp terrain_tags

    end
  end

end

=begin
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
=end