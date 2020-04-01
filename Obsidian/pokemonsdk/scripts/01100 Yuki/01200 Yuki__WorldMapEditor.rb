
module Yuki
  # Module that helps the user to edit his worldmap
  module WorldMapEditor
    module_function

    # Main function
    def main
      ($tester = Tester.allocate).data_load
      $pokemon_party = PFM::Pokemon_Party.new
      $pokemon_party.expand_global_var
      select_worldmap(0)
      select_zone(0)
      init
      show_help
      Graphics.transition
      until Input::Keyboard.press?(Input::Keyboard::Escape)
        Graphics.update
        update
      end
      @viewport.dispose
    end

    # Affiche l'aide
    def show_help
      cc 2
      puts 'list_zone : list all the zone'
      puts 'list_zone("name") : list the zone that match name'
      puts 'select_zone(id) : Select the zone id to place the with the mouse on the map'
      puts 'save : Save your modifications'
      puts 'clear_map : Clear the whole map'
      puts 'list_worldmap : list all the world maps'
      puts 'list_worldmap("name") : list the world maps that match name'
      puts 'select_worldmap(id) : select the world map to edit'
      puts "add_worldmap(\"image name\", text_id, [file_id]) : add the world map with the image filename without
        extension \n\tand the given name text id in file_id (by default ruby host)"
      puts 'delete_worldmap(id) : delete the worldmap and its data, be sure before use this'
      puts "set_worldmap_name(id, new_text_id, [new_file_id]) : change the name of the worldmap to the given text id and
        \n\tthe given file id (by default, file is ruby host)"
      puts 'set_worldmap_image(id, "new_image") : change the file displayed for the world map'
      cc 7
    end

    # Update the scene
    def update
      wm = GamePlay::WorldMap
      # > Position update
      update_origin(wm)
      return if (Mouse.x < 0) || (Mouse.y < 0)

      @last_x = @x
      @last_y = @y
      @x = (Mouse.x - wm::BitmapOffset) / wm::TileSize + @ox
      @y = (Mouse.y - wm::BitmapOffset) / wm::TileSize + @oy
      @map_sprite.set_origin(@ox * wm::TileSize, @oy * wm::TileSize)
      @cursor.set_position(
        (Mouse.x / wm::TileSize) * wm::TileSize,
        (Mouse.y / wm::TileSize) * wm::TileSize
      )
      update_infobox if (@last_x != @x) || (@last_y != @y)
      return if (@x < 0) || (@y < 0)

      update_zone if Mouse.press?(:left)
      remove_zone if Mouse.press?(:right)
    end

    # Update the current zone
    def update_zone
      GameData::WorldMap.get(@current_worldmap).data[@x, @y] = @current_zone
      update_infobox
    end

    # Clear the map
    def clear_map
      max_x = @map_sprite.width / GamePlay::WorldMap::TileSize
      max_y = @map_sprite.height / GamePlay::WorldMap::TileSize
      # $game_data_map = Array.new(max_x) { Array.new(max_y) }
      data = Table.new(max_x, max_y)
      0.upto(data.xsize - 1) do |x|
        0.upto(data.ysize - 1) do |y|
          data[x, y] = -1
        end
      end
      GameData::WorldMap.get(@current_worldmap).data = data
    end

    # Remove the zone
    def remove_zone
      GameData::WorldMap.get(@current_worldmap).data[@x, @y] = -1
      update_infobox
    end

    # Update the origin x/y
    # @param wm [Class] should contain TileSize and BitmapOffset constants
    def update_origin(worldmap)
      @ox += 1 if Input.repeat?(:right)
      max_ox = (@map_sprite.width - Graphics.width + worldmap::BitmapOffset) / worldmap::TileSize
      max_ox = 1 if max_ox <= 0
      @ox = max_ox - 1 if @ox >= max_ox
      @ox -= 1 if Input.repeat?(:left)
      @ox = 0 if @ox < 0
      @oy += 1 if Input.repeat?(:down)
      max_oy = (@map_sprite.height - Graphics.height + worldmap::BitmapOffset) / worldmap::TileSize
      max_oy = 1 if max_oy <= 0
      @oy = max_oy - 1 if @oy >= max_oy
      @oy -= 1 if Input.repeat?(:up)
      @oy = 0 if @oy < 0
    end

    # Save the world map
    def save
      # Gather zone worldmap
      GameData::WorldMap.all.each_with_index do |worldmap, id|
        # Set the correct id to the worldmap
        worldmap.id = id
        # Correct zones id
        0.upto(worldmap.data.xsize - 1) do |x|
          0.upto(worldmap.data.ysize - 1) do |y|
            worldmap.data[x, y] = -1 if worldmap.data[x, y] >= GameData::Zone.all.length
          end
        end
        # Set the zones
        worldmap.zone_list_from_data.each do |zone_id|
          GameData::Zone.get(zone_id).worldmap_id = id
        end
      end
      # Save the data
      save_data([$game_data_map, GameData::Zone.all], 'Data/PSDK/MapData.rxdata')
      save_data(GameData::WorldMap.all, 'Data/PSDK/WorldMaps.rxdata')
      $game_system.se_play($data_system.decision_se)
    end

    # List the zone
    def list_zone(name = '')
      name = name.downcase
      GameData::Zone.all.each_with_index do |zone, index|
        puts "#{index} : #{zone.map_name}" if zone && zone.map_name.downcase.include?(name)
      end
      show_help
    end

    # Select a zone
    def select_zone(id)
      @current_zone = id
      puts GameData::Zone.get(id).map_name
    end

    # Select a world map
    def select_worldmap(id)
      @current_worldmap = id
      worldmap = GameData::WorldMap.get(id)
      worldmap_filename = GameData::WorldMap.worldmap_image_filename(worldmap.image)
      if RPG::Cache.interface_exist?(worldmap_filename)
        bmp = RPG::Cache.interface(worldmap_filename)
        max_x = bmp.width / GamePlay::WorldMap::TileSize
        max_y = bmp.height / GamePlay::WorldMap::TileSize
        worldmap.image = worldmap.image if worldmap.data.xsize != max_x || worldmap.data.ysize != max_y
        @map_sprite&.bitmap = bmp

      end
      puts "World map #{worldmap.name} is now selected."
    end

    # Add a new world map and select it
    # @param image [String] the image of the map in graphics/interface folder
    # @param name_id [Integer] the text id in the file
    # @param file_id [String, Integer, nil] the file to pick the region name, by default the Ruby Host
    def add_worldmap(image, name_id, file_id = nil)
      GameData::WorldMap.all.push GameData::WorldMap.new(image, name_id, file_id)
      name = GameData::WorldMap.all.last.name
      puts "World map added : #{name.downcase}"
      select_worldmap(GameData::WorldMap.all.length - 1)
      clear_map
    end

    # Delete world map
    # @param id [Integer] the id of the map to delete
    def delete_worldmap(id)
      if GameData::WorldMap.all.length <= 1
        puts "You can't delete the last world map"
        return nil
      end
      puts "World map deleted : #{GameData::WorldMap.get(id)&.name}"
      GameData::WorldMap.all.delete_at(id)
      select_worldmap(0)
    end

    # Display all worldmaps
    # @param name [String, ''] the name to filter
    def list_worldmap(name = '')
      name = name.downcase
      GameData::WorldMap.all.each_with_index do |wm, index|
        puts "#{index} : #{wm.name}" if wm && wm.name.downcase.include?(name)
      end
      show_help
    end

    # Change the worldmap name to the given name text id in the given file id (by default in the ruby host)
    # @param id [Integer] the id of the world map to edit
    # @param name_id [Integer] the id of the text in the file
    # @param file_id [Integer, String, nil] the file id / name by default ruby host
    def set_worldmap_name(id, name_id, file_id = nil)
      old_name = GameData::WorldMap.get(id).name
      GameData::WorldMap.get(id).name_id = name_id
      GameData::WorldMap.get(id).name_file_id = file_id
      new_name = GameData::WorldMap.get(id).name
      puts "\"#{old_name}\" has been rename to \"#{new_name}\""
    end

    # Change the worldmap image to the given one
    # @param id [Integer] the id of the world map to edit
    # @param new_image [Integer] the new filename of the image
    def set_worldmap_image(id, new_image)
      worldmap_filename = GameData::WorldMap.worldmap_image_filename(new_image)
      if RPG::Cache.interface_exist?(worldmap_filename)
        GameData::WorldMap.get(id).image = new_image
        @map_sprite.set_bitmap(worldmap_filename, :interface) if @current_worldmap == id
        puts "#{GameData::WorldMap.get(id).name}'s' image updated to #{new_image}"
      else
        puts "#{worldmap_filename} doesn't exist!"
      end
    end

    # Init the editor
    def init
      wm = GamePlay::WorldMap
      @ox = @oy = 0 # Offset of the mapgrid
      @last_x = nil
      @last_y = nil
      @x = (Mouse.x - wm::BitmapOffset) / wm::TileSize - @ox
      @y = (Mouse.y - wm::BitmapOffset) / wm::TileSize - @oy
      init_sprites
      Object.define_method(:list_zone) { |name = ''| Yuki::WorldMapEditor.list_zone(name) }
      Object.define_method(:select_zone) { |id| Yuki::WorldMapEditor.select_zone(id) }
      Object.define_method(:save) { Yuki::WorldMapEditor.save }
      Object.define_method(:clear_map) { Yuki::WorldMapEditor.clear_map }
      Object.define_method(:select_worldmap) { |id| Yuki::WorldMapEditor.select_worldmap(id) }
      Object.define_method(:add_worldmap) { |name, image| Yuki::WorldMapEditor.add_worldmap(name, image) }
      Object.define_method(:delete_worldmap) { |id| Yuki::WorldMapEditor.delete_worldmap(id) }
      Object.define_method(:list_worldmap) { |name = ''| Yuki::WorldMapEditor.list_worldmap(name) }
      Object.define_method(:set_worldmap_image) { |id, value| Yuki::WorldMapEditor.set_worldmap_image(id, value) }
      Object.define_method(:set_worldmap_name) { |id, value| Yuki::WorldMapEditor.set_worldmap_name(id, value) }
      Object.define_method(:set_worldmap_back) { |id, value| Yuki::WorldMapEditor.set_worldmap_back(id, value) }
    end

    # Create the sprites
    def init_sprites
      @viewport = Viewport.create(0, 0, 640, 480, 2000)
      @map_sprite = Sprite.new(@viewport).set_bitmap(
        GameData::WorldMap.worldmap_image_filename(GameData::WorldMap.get(@current_worldmap).image),
        :interface
      )
      @cursor = Sprite.new(@viewport).set_bitmap('worldmap/' + 'cursor', :interface)
                      .set_rect_div(0, 0, 1, 2)
      @infobox = Text.new(0, @viewport,
                          @map_sprite.x + GamePlay::WorldMap::BitmapOffset,
                          @map_sprite.y + GamePlay::WorldMap::BitmapOffset - Text::Util::FOY,
                          @map_sprite.width - 2 * GamePlay::WorldMap::BitmapOffset, 16, nil.to_s)
    end

    # Update the infobox
    def update_infobox
      # zone = $env.get_zone(@x,@y)
      zone_id = GameData::WorldMap.get(@current_worldmap).data[@x, @y]
      zone = zone_id && (zone_id >= 0) ? GameData::Zone.get(zone_id) : nil
      if zone
        @infobox.visible = true
        if zone.warp_x && zone.warp_y
          color = 2
        else
          color = 0
        end
        @infobox.text = zone.map_name
        @infobox.load_color(color)
      else
        @infobox.visible = false
      end
    end
  end
end
