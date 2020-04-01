module GamePlay
  # Class showing the basic World Map (TownMap) with navigation
  #
  # The world map is stored inside a 2D Array ($game_data_map) that holds each columns of the world map.
  # Each of these columns contain the ID of the zones at the y position of the cursor
  class WorldMap < BaseCleanUpdate
    # Base Z of the viewports
    # @return [Integer]
    ViewportsBaseZ = 51_000
    # Coord X of the map viewport
    # @return [Integer]
    VMapX = 48
    # Coord Y of the map viewport
    # @return [Integer]
    VMapY = 37
    # Width of the map viewport
    # @return [Integer]
    VMapWidth = 257
    # Height of the map viewport
    # @return [Integer]
    VMapHeight = 168
    # Coord X of the window tell the zone is unkonwn
    # @return [Integer]
    UnknownZoneX = 76
    # Coord Y of the window tell the zone is unkonwn
    # @return [Integer]
    UnknownZoneY = 77
    # Width of the window tell the zone is unkonwn
    # @return [Integer]
    UnknownZoneWidth = 200
    # Height of the window tell the zone is unkonwn
    # @return [Integer]
    UnknownZoneHeight = 30
    # Duration of the whole cursor animation
    # @return [Integer]
    CursorAnimationDuration = 60 # frames
    # Duration of the one case move
    # @return [Integer]
    CursorMoveDuration = 4
    # Offset of the World Map bitmap
    # @return [Integer]
    BitmapOffset = 0 # 8
    # Size of a tile in the WorldMap (Used outside of the script !)
    # @return [Integer]
    TileSize = 8
    # The height of the display zone on the map window
    # @return [Integer]
    UI_MAP_HEIGHT = 168
    # The width of the display zone on the map window
    # @return [Integer]
    UI_MAP_WIDTH = 256
    # Indicate if the zoom is usable in world map
    ZoomEnabled = true
    # Proc to define the zones color
    # @param counter [Integer] goes from 0 to 100 frame then goes back to 0
    PROC_ZONE_COLOR = proc do |counter|
      [1, 0, 0, (300 + counter).to_f / 500] # Red
    end
    # Proc to define the fly zones color
    # @param counter [Integer] goes from 0 to 100 frame then goes back to 0
    PROC_FLY_ZONE_COLOR = proc do |counter|
      [1, 0, 1, (300 + counter * 2).to_f / 600] # Purple
    end

    # Create a new World Map view
    # @param mode [Symbol] mode of the World Map (:view / :fly / :pokdex / :view_wall)
    # @param wm_id [Integer] the id of the world map to display
    # @param pokemon [PFM::Pokemon, Symbol] <default :map> the calling situation
    def initialize(mode = :view, wm_id = $env.get_worldmap, pokemon = nil)
      super(true)
      # Store parameters
      @mode = mode
      @worldmap_id = wm_id
      @pokemon = pokemon
      # Change external attributes
      $wild_battle.on_map_viewed if @mode == :view
      # Initialize attributes
      @map_display_ox = @map_display_oy = 0
      @map_display_ox_offset = @map_display_oy_offset = 0
      @worldmap_zoom = 1
      @cursor_animation_counter = 0
      @cursor_move_count = false
      @last_x = @last_y = @x = @y = 0
      @zoom = 1
      @zone_animation_backroll = false
      @zone_animation_counter = 0
    end

    # Update the inputs
    def update_inputs
      update_dir_input
      update_button_input
    end

    # Update the graphics
    def update_graphics
      # Update animations
      update_background_animation
      update_cursor_animation
      update_zones_animation
      # Update positions
      update_move
      update_display_position
    end

    def visible=(value)
      super
      @viewport_background.visible = value
      @viewport_map.visible = value
      @viewport_map_zones.visible = value
      @viewport_map_markers.visible = value
      @viewport_map_cursor.visible = value
      @viewport_ui.visible = value
    end

    def dispose
      super
      @__last_scene.sprite_set_visible = true if @__last_scene.class == ::Scene_Map
    end

    # Delete zones and markers sprite
    def dispose_zone_and_marker
      # Clear custom icons
      @marker_custom_icons.each(&:dispose)
      @marker_custom_icons.clear
      # Clear roaming pokemon
      @marker_roaming_pokemons.each(&:dispose)
      @marker_roaming_pokemons.clear
      # Clear the existing zones
      @marker_zones.each(&:dispose)
      @marker_zones.clear
      @zone_animation_counter = 0
      @zone_animation_backroll = false
    end

    # Create the viewports of the scene
    def create_viewport
      @viewport_background = Viewport.create(:main, ViewportsBaseZ)
      @viewport_map = Viewport.create(VMapX, VMapY, VMapWidth, VMapHeight, ViewportsBaseZ + 1000)
      @viewport_map_zones = Viewport.create(VMapX, VMapY, VMapWidth, VMapHeight, ViewportsBaseZ + 2000)
      @viewport_map_markers = Viewport.create(VMapX, VMapY, VMapWidth, VMapHeight, ViewportsBaseZ + 3000)
      @viewport_map_cursor = Viewport.create(VMapX, VMapY, VMapWidth, VMapHeight, ViewportsBaseZ + 4000)
      @viewport_ui = Viewport.create(:main, ViewportsBaseZ + 5000)
    end

    # Create all the graphics required by this Scene
    def create_graphics
      create_viewport
      create_background
      create_map
      create_cursor
      create_player_sprite
      create_markers
      create_frame
    end

    # Create the Worldmap background
    def create_background
      @bg_background = Sprite.new(@viewport_background).set_bitmap('worldmap/background_animated', :interface)
      @bg_frame = Sprite.new(@viewport_background).set_bitmap('worldmap/background_map', :interface)
    end

    # Create the map sprite
    def create_map
      @map_worldmap = Sprite.new(@viewport_map).set_bitmap(
        GameData::WorldMap.worldmap_image_filename(GameData::WorldMap.get(@worldmap_id).image),
        :interface
      )
    end

    # Create the cursor
    def create_cursor
      @cursor = Sprite.new(@viewport_map_cursor).set_bitmap('worldmap/cursor', :interface).set_rect_div(0, 0, 1, 2)
    end

    # Create the player marker
    def create_player_sprite
      @marker_player = Sprite::WithColor.new(@viewport_map_markers)
      player_icon = 'worldmap/player_icons/' \
                    "#{$game_player.charset_base}_#{$game_switches[Yuki::Sw::Gender] ? 'f' : 'm'}"
      player_icon = 'worldmap/player_icons/default' unless RPG::Cache.interface_exist?(player_icon)
      @marker_player.set_bitmap(player_icon, :interface)
      @marker_player.ox = @marker_player.src_rect.width / 2 - TileSize / 2
      @marker_player.oy = @marker_player.src_rect.height / 2 - TileSize / 2
    end

    # Create the markers (their holder)
    def create_markers
      @marker_zones = []
      @marker_zones_bitmap = RPG::Cache.interface('worldmap/zones')
      # Custom icons
      @marker_custom_icons = []
      # Roaming pokemon markers
      @marker_roaming_pokemons = []
    end

    # Create the frame
    def create_frame
      @ui_frame = Sprite.new(@viewport_ui).set_bitmap('worldmap/frame', :interface)
      @ui_infobox = UI::DexWinMap.new(@viewport_ui, @mode != :view_wall)
      @ui_infobox.data = @pokemon
      @ui_unknown_zone = UI::Window.new(@viewport_ui, UnknownZoneX, UnknownZoneY, UnknownZoneWidth, UnknownZoneHeight)
      @ui_unknown_zone.add_text(0, 0, 170, 13, ext_text(9000, 31), 1)
      @ui_unknown_zone.visible = false
      # Finish the display
      set_worldmap(@worldmap_id)
    end

    # Initialize the cursor and the player positions
    def init_cursor_and_player
      # Get the coords
      if @worldmap_id != $env.get_worldmap
        @x = @y = 0
        @marker_player.visible = false
      elsif (modified_coords = $env.modified_worldmap_position)
        @x = modified_coords[0]
        @y = modified_coords[1]
        @marker_player.visible = true
      else
        zone_id = $env.master_zone >= 0 ? $env.master_zone : $env.get_current_zone
        @x, @y = $env.get_zone_pos(zone_id)
        @x ||= 0
        @y ||= 0
        @marker_player.visible = true
      end
      # Set the coords
      @cursor.x = BitmapOffset + @map_worldmap.x + TileSize * @x
      @cursor.y = BitmapOffset + @map_worldmap.y + TileSize * @y
      @marker_player.x = @cursor.x
      @marker_player.y = @cursor.y
      # Update the display map
      update_display_origin
    end

    # Update the background sprite animation
    def update_background_animation
      @bg_background.set_origin((@bg_background.ox - 0.5) % 16, (@bg_background.oy - 0.5) % 16)
    end

    # Update the cursor sprite animation
    def update_cursor_animation
      @cursor_animation_counter += 1
      if @cursor_animation_counter == CursorAnimationDuration / 2
        @cursor.src_rect.y = @cursor.src_rect.height
      elsif @cursor_animation_counter == CursorAnimationDuration
        @cursor.src_rect.y = @cursor_animation_counter = 0
      end
    end

    # Update the animation of the zones
    def update_zones_animation
      return if @marker_zones.empty? # No zones, no animation

      # Backroll indicate if the color filter become more transparency ou less
      if @zone_animation_backroll
        @zone_animation_counter -= 1
        @zone_animation_backroll = @zone_animation_counter >= 0
      else
        @zone_animation_counter += 1
        @zone_animation_backroll = @zone_animation_counter >= 100
      end
      # Update the color filter considering the mode
      if @mode == :pokedex || @mode == :view
        color = PROC_ZONE_COLOR.call @zone_animation_counter
      elsif @mode == :fly
        color = PROC_FLY_ZONE_COLOR.call @zone_animation_counter
      else
        color = [0, 0, 0, 1] # No color (white)
      end
      # Update the color of each sprite
      @marker_zones.each { |zone| zone.set_color(color) }
    end

    # Get the direction 8 input and process it on the cursor
    def update_dir_input
      return if @cursor_move_count

      @last_x = @x
      @last_y = @y
      update_cursor_position_dir8
      if @last_x != @x || @last_y != @y
        @cursor_move_count = 0
        update_infobox
      end
    end

    # Update the buttons triggered
    def update_button_input
      # Quit map if B triggered
      return @running = false if Input.trigger?(:B)
      # Toggle zoom if allowed
      on_toggle_zoom if ZoomEnabled && Input.trigger?(:X)
      # No more input if wall view
      return if @mode == :view_wall
      # Load the next worldmap
      on_next_worldmap if Input.trigger?(:Y)
      return on_fly_attempt if @mode == :fly && Input.trigger?(:A)
    end

    # Update the cursor movement
    def update_move
      return unless @cursor_move_count

      # Update cursor position
      @cursor.x = BitmapOffset + @map_worldmap.x + TileSize * @last_x + (@x - @last_x) *
                  @cursor_move_count * TileSize / CursorMoveDuration
      @cursor.y = BitmapOffset + @map_worldmap.y + TileSize * @last_y + (@y - @last_y) *
                  @cursor_move_count * TileSize / CursorMoveDuration
      # Update display coords
      update_display_origin
      # Update counter
      @cursor_move_count += 1
      @cursor_move_count = false if @cursor_move_count > CursorMoveDuration
    end

    # Calculate the variables @map_display_ox and @map_display_oy
    def update_display_origin
      max_x = VMapWidth / TileSize * TileSize  - TileSize
      max_y = VMapHeight / TileSize * TileSize - TileSize
      if @cursor.x < @map_display_ox
        @map_display_ox = @cursor.x
      elsif @cursor.x - @map_display_ox >= max_x
        @map_display_ox = @cursor.x - max_x
      end
      if @cursor.y < @map_display_oy
        @map_display_oy = @cursor.y
      elsif @cursor.y - @map_display_oy >= max_y
        @map_display_oy = @cursor.y - max_y
      end
    end

    # Update the map position
    def update_display_position
      @viewport_map.ox = @viewport_map_cursor.ox = @viewport_map_zones.ox = @viewport_map_markers.ox = @map_display_ox + @map_display_ox_offset
      @viewport_map.oy = @viewport_map_cursor.oy = @viewport_map_zones.oy = @viewport_map_markers.oy = @map_display_oy + @map_display_oy_offset
    end

    # Update the cursor position using Input.dir8
    def update_cursor_position_dir8
      case (dir8 = Input.dir8)
      when 1, 4, 7
        @x -= 1
      when 3, 6, 9
        @x += 1
      end
      case dir8
      when 7, 8, 9
        @y -= 1
      when 1, 2, 3
        @y += 1
      end
      @y = 0 if @y < 0
      @x = 0 if @x < 0
      @y = @y_max - 1 if @y >= @y_max
      @x = @x_max - 1 if @x >= @x_max
    end

    # Method updating the infobox sprites
    def update_infobox
      zone = $env.get_zone(@x, @y, @worldmap_id)
      if zone
        @ui_infobox.set_location zone.map_name
      else
        @ui_infobox.set_location '...'
      end
    end

    # Change the zoom to 0.5 or 1
    def on_toggle_zoom
      # Set the zoom value
      @viewport_map.zoom = @viewport_map_cursor.zoom = @viewport_map_zones.zoom = 
        @viewport_map_markers.zoom = @zoom = (@zoom == 0.5 ? 1 : 0.5)
      # Correct map display
      @viewport_map.ox *= @zoom
      @viewport_map.oy *= @zoom
      @viewport_map_cursor.ox *= @zoom
      @viewport_map_cursor.oy *= @zoom
      @viewport_map_markers.ox *= @zoom
      @viewport_map_markers.oy *= @zoom
      @viewport_map_zones.ox *= @zoom
      @viewport_map_zones.oy *= @zoom
    end

    # We try to fly to the selected zone
    def on_fly_attempt
      zone = $env.get_zone(@x, @y, @worldmap_id)
      if zone&.warp_x && zone&.warp_y && $env.visited_zone?(zone)
        map_id = zone.map_id
        map_id = map_id.first unless map_id.is_a?(Numeric)
        $game_variables[::Yuki::Var::TMP1] = map_id
        $game_variables[::Yuki::Var::TMP2] = zone.warp_x
        $game_variables[::Yuki::Var::TMP3] = zone.warp_y
        $game_temp.common_event_id = 15
        return_to_scene(Scene_Map)
      end
    end

    # Load the next worldmap
    def on_next_worldmap
      old_worldmap_id = @worldmap_id
      @worldmap_id = (@worldmap_id + 1) % GameData::WorldMap.all.length
      @worldmap_id = (@worldmap_id + 1) % GameData::WorldMap.all.length until $env.visited_worldmap?(@worldmap_id)
      unless old_worldmap_id == @worldmap_id
        if @mode == :pokedex
          set_pokemon(@pokemon, @worldmap_id)
        else
          set_worldmap(@worldmap_id)
        end
      end
    end

    # Method retreiving the boundaries of the worldmap
    def set_bounds
      @x_max = (@map_worldmap.width - 2 * BitmapOffset) / TileSize
      @y_max = (@map_worldmap.height - 2 * BitmapOffset) / TileSize
    end

    # Change the display worldmap
    # @param id [Integer] the worldmap id to display
    def set_worldmap(id)
      # Update the worldmap
      @worldmap_id = id
      @map_worldmap.set_bitmap(
        GameData::WorldMap.worldmap_image_filename(GameData::WorldMap.get(@worldmap_id).image),
        :interface
      )
      recenter_map
      @ui_infobox.set_region GameData::WorldMap.get(@worldmap_id).name
      # Update player
      set_bounds
      init_cursor_and_player
      # Display available fly zones
      dispose_zone_and_marker
      display_fly_zones
      display_roaming_pokemons
      display_pokemon_zones
      display_custom_icons
      # Update location display
      update_infobox
    end

    # Reset the map display coords
    def recenter_map
      @map_display_ox = @map_display_oy = @map_display_oy_offset = @map_display_ox_offset = 0
      if (map_height = @map_worldmap.src_rect.height) < UI_MAP_HEIGHT
        @map_display_oy_offset = - (UI_MAP_HEIGHT - map_height) / 2
      end
      if (map_width = @map_worldmap.src_rect.width) < UI_MAP_WIDTH
        @map_display_ox_offset = - (UI_MAP_WIDTH - map_width) / 2
      end
    end

    # Set the pokemon to display
    # @param pkm [PFM::Pokemon] the pokemon object
    # @param forced_worldmap_id [Integer, nil] the worldmap to display, if nil, the best one will be picked
    def set_pokemon(pkm, forced_worldmap_id = nil)
      # Update the information
      @pokemon = pkm
      @ui_infobox.data = pkm
      return unless @mode == :pokedex && pkm

      # Update the worldmap display
      wm_id = forced_worldmap_id
      wm_id ||= $pokedex.best_worldmap_pokemon(pkm.id)
      set_worldmap(wm_id)
      # Display the unkown zone alert
      @ui_unknown_zone.visible = @marker_zones.empty?
    end

    # Display the customs icons
    def display_custom_icons
      return unless @mode == :view
      return unless (icons_data = $env.worldmap_custom_markers[@worldmap_id])

      icons_data.each do |icon|
        file = 'worldmap/icons/' + icon[0]
        next unless RPG::Cache.interface_exist?(file)

        # Initialize the sprite
        sprite = Sprite.new(@viewport_map_markers)
        sprite.set_bitmap(file, :interface)
        # Set the sprite
        process_icon_origin_mode(sprite, icon[3], icon[4])
        sx = BitmapOffset + @map_worldmap.x + TileSize * icon[1]
        sy = BitmapOffset + @map_worldmap.y + TileSize * icon[2]
        @marker_custom_icons.push sprite.set_position(sx, sy)
      end
    end

    # Define the sprite origin with the given parameters
    # @param sprite [Sprite] the sprite to modify
    # @param ox_mode [Symbol]
    # @param oy_mode [Symbol]
    def process_icon_origin_mode(sprite, ox_mode, oy_mode)
      case ox_mode
      when :center
        sprite.ox = sprite.src_rect.width / 2 - TileSize / 2
      when :left
        sprite.ox = 0
      when :right
        sprite.ox = sprite.src_rect.width - TileSize
      end
      case oy_mode
      when :center
        sprite.oy = sprite.src_rect.height / 2 - TileSize / 2
      when :down
        sprite.oy = sprite.src_rect.height - TileSize
      when :up
        sprite.oy = 0
      end
    end

    # Display the available fly zones
    def display_fly_zones
      return unless @mode == :fly

      # Initialize
      wm_data = GameData::WorldMap.get(@worldmap_id).data
      fly_zones = Table.new(wm_data.xsize, wm_data.ysize)
      # Test each world map case
      0.upto(wm_data.xsize - 1) do |x|
        0.upto(wm_data.ysize - 1) do |y|
          next if (zone_id = wm_data[x, y]) < 0 # No zone = no flight

          zone = GameData::Zone.get(zone_id)
          fly_zones[x, y] = 1 if zone.warp_x && zone.warp_y && $env.visited_zone?(zone)
        end
      end
      # Display each zone
      display_zones(fly_zones)
    end

    # Display the roaming pokemon zones and icons
    def display_roaming_pokemons
      return unless @mode == :view

      # Initialize
      wm_data = GameData::WorldMap.get(@worldmap_id).data
      pkm_zones = Table.new(wm_data.xsize, wm_data.ysize)
      pokemons = $wild_battle.roaming_pokemons
      coords_by_pkm = {}
      return if pokemons.empty?

      # Check each tile
      0.upto(wm_data.xsize - 1) do |x|
        0.upto(wm_data.ysize - 1) do |y|
          next if (zone_id = wm_data[x, y]) < 0 # No zone = no pokemon

          pokemons.each do |pokemon_info|
            next unless [GameData::Zone.get(zone_id).map_id].flatten.include? pokemon_info.map_id

            pkm_zones[x, y] = 1
            coords_by_pkm[pokemon_info] ||= []
            coords_by_pkm[pokemon_info].push [x, y]
          end
        end
      end
      # Display zones
      display_zones(pkm_zones)
      # Display pokemons
      # No more than one pokemon by case
      coords_by_pkm.keys.each do |infos|
        # Look for the image, next if no icon matching
        pkm_icon = 'worldmap/pokemons_icons/' + infos.pokemon.character_name
        next unless RPG::Cache.interface_exist?(pkm_icon)

        # Initialize the sprite
        sprite = Sprite.new(@viewport_map_markers)
        sprite.set_bitmap(pkm_icon, :interface)
        sprite.ox = sprite.src_rect.width / 2 - TileSize / 2
        sprite.oy = sprite.src_rect.height / 2 - TileSize / 2
        coords = coords_by_pkm[infos].sample
        # Set the sprite
        sx = BitmapOffset + @map_worldmap.x + TileSize * coords[0]
        sy = BitmapOffset + @map_worldmap.y + TileSize * coords[1]
        @marker_roaming_pokemons.push sprite.set_position(sx, sy)
      end
    end

    # Display the pokedex pokemon zones
    def display_pokemon_zones
      return unless @mode == :pokedex

      display_zones(search_pokemon_zone)
    end

    # Create the zones sprites
    # @param tab [Table] the table containing the data : 0=no zone, 1=zone
    def display_zones(tab)
      # Display each zone
      0.upto(tab.xsize - 1) do |x|
        0.upto(tab.ysize - 1) do |y|
          next if tab[x, y] == 0

          sx = BitmapOffset + @map_worldmap.x + TileSize * x
          sy = BitmapOffset + @map_worldmap.y + TileSize * y
          @marker_zones.push(s = Sprite::WithColor.new(@viewport_map_zones)
            .set_bitmap(@marker_zones_bitmap).set_position(sx, sy))
          set_zone_rect(tab, x, y, s)
        end
      end
    end

    # Change the zone appearence to match the neighbour
    # @param zones_tab [Table] the zones data
    # @param x [Integer] the x coord
    # @param y [Integer] the y coord
    # @param sprite [Sprite] the sprite to setup
    def set_zone_rect(zones_tab, x, y, sprite)
      code = 0
      [1, 2, 3, 4].each_with_index do |dir, index|
        nx = x + (dir == 2 ? -1 : dir == 3 ? 1 : 0)
        ny = y + (dir == 4 ? -1 : dir == 1 ? 1 : 0)
        tile = zones_tab[nx, ny]
        code |= ((tile || 0) << index)
      end
      case code # :down, :left, :right, :up
      when 0b0000 then sprite.set_rect_div(0, 0, 5, 5)
      # End
      when 0b1000 then sprite.set_rect_div(0, 3, 5, 5)
      when 0b0100 then sprite.set_rect_div(0, 4, 5, 5)
      when 0b0010 then sprite.set_rect_div(2, 4, 5, 5)
      when 0b0001 then sprite.set_rect_div(0, 1, 5, 5)
      # Line
      when 0b0110 then sprite.set_rect_div(1, 4, 5, 5)
      when 0b1001 then sprite.set_rect_div(0, 2, 5, 5)
      # Angles
      when 0b1100 then sprite.set_rect_div(1, 3, 5, 5)
      when 0b1010 then sprite.set_rect_div(2, 3, 5, 5)
      when 0b0101 then sprite.set_rect_div(1, 2, 5, 5)
      when 0b0011 then sprite.set_rect_div(2, 2, 5, 5)
      # Edges
      when 0b1110 then sprite.set_rect_div(2, 0, 5, 5)
      when 0b1101 then sprite.set_rect_div(1, 1, 5, 5)
      when 0b1011 then sprite.set_rect_div(2, 1, 5, 5)
      when 0b0111 then sprite.set_rect_div(1, 0, 5, 5)
      # Cross
      else sprite.set_rect_div(4, 0, 5, 5)
      end
    end

    # Search the pokemon encounter zone, return i
    # @return [Table] the table where the pokemon spawn
    def search_pokemon_zone
      # Initialize
      wm_data = GameData::WorldMap.get(@worldmap_id).data
      pkm_zones = Table.new(wm_data.xsize, wm_data.ysize)
      return pkm_zones unless @pokemon

      # Test each world map case
      0.upto(wm_data.xsize - 1) do |x|
        0.upto(wm_data.ysize - 1) do |y|
          next if (zone_id = wm_data[x, y]) < 0 # No zone = no pokemon

          # Check the roaming pokemon
          zone = GameData::Zone.get(zone_id)
          $wild_battle.roaming_pokemons.each do |infos|
            next unless [zone.map_id].flatten.include? infos.map_id
            next unless infos.pokemon.id == @pokemon.id

            pkm_zones[x, y] = 1
            infos.spotted = true
            break
          end
          next if pkm_zones[x, y] > 0

          # Check the group
          zone.groups.each do |group|
            group.each do |pkm|
              next unless pkm.is_a?(Hash) # No hash = not a pokemon
              next unless pkm[:id] == @pokemon.id # Not the pokemon we are looking for

              pkm_zones[x, y] = 1 # Set the zone ok
            end
          end
        end
      end
      # Return the table to display
      return pkm_zones
    end
  end
end
