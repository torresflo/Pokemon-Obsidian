module Yuki
  # The SystemTag editor of PSDK
  # @author Nuri Yuri
  module SystemTagEditor
    @running = false
    # Background Color
    BackColor = Color.new(255, 255, 255)
    # Color used to generate the selector
    SelectColor = Color.new(160, 170, 200)
    # Name of the tileset that contains SystemTag images
    TilesetName = 'prio_w'
    # Rect used to perform copy
    AutotileRect = Rect.new(0, 0, 32, 32)
    # File where SystemTags are stored
    DataFile = 'Data/PSDK/SystemTags.rxdata'
    # Input.get_text when pressing CTRL+V
    # @note : Got using ```Thread.new do while true;p Input.get_text if Input.get_text;sleep(0.015) end end```
    CTRL_V = "\u0016"

    module_function

    # Fake the main function of a scene
    def main
      start
      $scene = nil
    end

    # Fork the process to run smoothly the SystemTagEditor
    def fork
      th = Thread.new do
        system('Game.exe --tags') if system('ruby Game.rb --tags').nil?
        Thread.kill(Thread.current)
      end
      txt = Text.new(0, nil, 0, -4, Graphics.width, Graphics.height, 'Waiting for you to edit system tags...', 1, 1)
      txt.load_color(9)
      Graphics.update while th.status
      txt.dispose
    end

    # Start the SystemTag edition
    def start
      return if @running
      return fork unless PARGV[:tags]

      init_context
      init_surfaces
      until Input::Keyboard.press?(Input::Keyboard::Escape)
        Graphics.update
        update_click unless update_scroll_bar
        update_control
      end
      restore_context
    rescue Exception
      @running = false
      raise
    end

    # Initialize the SystemTag Editor context (resolution)
    def init_context
      # @GraphicsInfo = Graphics.width, Graphics.height
      # Graphics.resize_screen(640, 480)

      $data_tilesets = _clean_name_utf8(load_data('Data/Tilesets.rxdata'))
      $data_system_tags = load_data('Data/PSDK/SystemTags.rxdata')
      $game_map ||= Game_Map.new
      @running = true
      @tileset_id = 0
      @tag_id = 384
      normalize_data
    end

    # Restore the old context
    def restore_context
      clear_all
      # Graphics.resize_screen(*@GraphicsInfo)
      @running = false
    end

    # Update the controls (Save)
    def update_control
      click_save = (Mouse.trigger?(:left) && @save_button.simple_mouse_in?)
      if Input.get_text == CTRL_V || click_save # VK_CONTROL
        save_data($data_system_tags, DataFile)
        Audio.se_play('audio/se/select.wav')
      end
      update_extended_tileset
    end

    # Update the extended tileset interaction
    def update_extended_tileset
      if @tileset_sprite.bitmap.width > 256
        max = @tileset_sprite.bitmap.width / 256
        if Input.trigger?(:left)
          @tileset_offset -= 1
          @tileset_offset = max - 1 if @tileset_offset < 0
        elsif Input.trigger?(:right)
          @tileset_offset += 1
          @tileset_offset = 0 if @tileset_offset >= max
        else
          return
        end
        @tileset_sprite.src_rect.x = @tileset_offset * 256
        @tileset_tag.src_rect.x = @tileset_offset * 256
      end
    end

    # Update the mouse click interactions
    def update_click
      if Mouse.press?(:left)
        if @tileset_name_sprite.simple_mouse_in?
          update_tileset_name
        elsif @tileset_sprite.simple_mouse_in?
          update_tileset_tag
        elsif @autotile_tag.simple_mouse_in?
          update_autotile_tag
        elsif @tag_sprite.simple_mouse_in?
          update_tag
        end
      elsif Mouse.press?(:right)
        if @tileset_sprite.simple_mouse_in?
          update_tileset_tag(0)
        elsif @autotile_tag.simple_mouse_in?
          update_autotile_tag(0)
        end
      end
    end

    # Update an autotile SystemTag
    # @param tag_id [Integer] the new SystemTag
    def update_autotile_tag(tag_id = @tag_id)
      mx, my = @autotile_tag.translate_mouse_coords
      bitmap = @autotile_tag.bitmap
      return if mx < 32 || my < 0 || mx >= bitmap.width || my >= bitmap.height

      mx /= 32
      data = @data_systemtags
      (48 * mx).upto(48 * mx + 47) do |tile_id|
        data[tile_id] = tag_id
      end
      draw_tag(@autotile_tag.bitmap, mx * 32, 0, tag_id == 0)
    end

    # Update a tile SystemTag
    # @param tag_id [Integer] the new SystemTag
    def update_tileset_tag(tag_id = @tag_id)
      mx, my = @tileset_sprite.translate_mouse_coords
      bitmap = @tileset_sprite.bitmap
      return if mx < 0 || my < 0 || mx >= bitmap.width || my >= bitmap.height

      mx /= 32
      my /= 32
      draw_tag(@tileset_tag.bitmap, mx * 32, my * 32, tag_id == 0)
      offset_y = 0
      max_tiles = @tileset_tag.bitmap.height / 32 * 8
      while mx >= 8
        offset_y += max_tiles
        mx -= 8
      end
      tile_id = 384 + mx + my * 8 + offset_y
      @data_systemtags[tile_id] = tag_id
    end

    # Draw the current SystemTag
    # @param bitmap [Bitmap] the bitmap where the SystemTag is drawn
    # @param x [Integer] the x position where the SystemTag is drawn
    # @param y [Integer] the y position where the SystemTag is drawn
    # @param no_draw [Boolean] if the function only clears the surface where the SystemTag should be drawn
    def draw_tag(bitmap, x, y, no_draw)
      return if @draw_tag_x == x && @draw_tag_y == y && @draw_tag_id == (no_draw ? 0 : @tag_id)

      AutotileRect.x = (@tag_id % 8) * 32
      AutotileRect.y = (@tag_id - 384) / 8 * 32
      bitmap.clear_rect(x, y, 32, 32) # bitmap.fill_rect(x, y, 32, 32, GameData::Colors::Transparent)
      bitmap.blt(x, y, @tag_sprite.bitmap, AutotileRect) unless no_draw
      bitmap.update
      AutotileRect.x = AutotileRect.y = 0
      @draw_tag_x = x
      @draw_tag_y = y
      @draw_tag_id = no_draw ? 0 : @tag_id
    end

    # Update the SystemTag selection
    def update_tag
      mx, my = @tag_sprite.translate_mouse_coords
      bitmap = @tag_sprite.bitmap
      return if mx < 0 || my < 0 || mx >= bitmap.width || my >= bitmap.height

      mx /= 32
      my /= 32
      @tag_id = 384 + mx + my * 8
      update_tag_selector
    end

    # Update the tileset selection
    def update_tileset_name
      mx, my = @tileset_name_sprite.translate_mouse_coords
      return if my < 0

      my /= 16
      # Changement de tileset
      if my != @tileset_id
        return if my >= $data_tilesets.size

        $data_system_tags[@tileset_id + 1] = @data_systemtags
        @tileset_id = my
        load_tileset
        update_tileset_name_surface
      end
    end

    # Update each scroll bar
    def update_scroll_bar
      return true if @tileset_scroll_bar.update
      return true if @tileset_name_scroll_bar.update
      return true if @tag_scroll_bar.update

      return false
    end

    # Free every resources created there
    def clear_all
      @tileset_name_sprite.bitmap.dispose
      @tileset_name_sprite.dispose
      @tileset_name_scroll_bar.dispose
      @tileset_sprite.dispose
      @tileset_scroll_bar.dispose
      @background.dispose
      @tag_sprite.dispose
      @tag_selector.bitmap.dispose
      @tag_selector.dispose
      @autotile_tag.bitmap.dispose
      @autotile_tag.dispose
      @tileset_tag.bitmap.dispose
      @tileset_tag.dispose
      @tag_scroll_bar.dispose
      @autotile_sprite.dispose
      @save_button.dispose
      @tileset_name_viewport.dispose
      @info_text.dispose
      @save_button = nil
      @autotile_sprite = nil
      @tag_scroll_bar = nil
      @tag_selector = nil
      @tag_sprite = nil
      @background = nil
      @tileset_scroll_bar = nil
      @tileset_sprite = nil
      @tileset_name_sprite = nil
      @tileset_name_helper = nil
      @tileset_name_lines = nil
      @tileset_name_scroll_bar = nil
    end

    # Create every surfaces the editor needs
    def init_surfaces
      @background = Viewport.new(0, 0, 640, 480)
      @background.z = 19_999
      @background.color = BackColor
      @save_button = Utils.create_sprite(nil, 'save', 256, 0, 20_002, sprite_class: ::Sprite)
      txt = "Appuyez droite ou gauche pour\nafficher l'extension du tileset."
      @info_text = Text.new(0, nil, 288, -Text::Util::FOY, 224, 16, txt, 0, 1).load_color(6)
      @info_text.z = 20_002
      init_tileset_name_surface
      init_editable_surface
      init_tag_surface
      init_tileset_surface
      update_tileset_name_surface
      update_tag_selector
      Graphics.transition
    end

    # Create the edit surfaces
    def init_editable_surface
      @autotile_tag = ::Sprite.new
      @autotile_tag.z = 20_001
      @autotile_tag.bitmap = Bitmap.new(256, 32)
      @tileset_tag = ::Sprite.new
      @tileset_tag.z = 20_001
      @tileset_tag.y = 32
    end

    # Create the tileset view surfaces
    def init_tileset_surface
      @tileset_sprite = ::Sprite.new
      @tileset_sprite.z = 20_000
      @tileset_sprite.y = 32
      @tileset_sprite.bitmap = RPG::Cache.tileset(TilesetName)
      @autotile_sprite = ::Sprite.new
      @autotile_sprite.z = 20_000
      @autotile_sprite.bitmap = Bitmap.new(256, 32)
      load_tileset
      @tileset_scroll_bar = Yuki::ScrollBar.new(
        @tileset_sprite,
        sprite_class: ::Sprite, scroll_unit: 32,
        callback: method(:update_tileset_tag_position)
      )
    end

    # Create the SystemTag selection & selector surface
    def init_tag_surface
      @tag_sprite = ::Sprite.new
      @tag_sprite.x = 256 + 12
      @tag_sprite.y = 32
      @tag_sprite.z = 20_000
      @tag_sprite.bitmap = RPG::Cache.tileset(TilesetName)
      @tag_sprite.src_rect.set(0, 0, 256, 448)
      @tag_selector = ::Sprite.new
      @tag_selector.bitmap = Bitmap.new(32, 32)
      @tag_selector.bitmap.fill_rect(0, 0, 32, 32, Color.new(200, 255, 60, 200))
      @tag_selector.bitmap.fill_rect(4, 4, 24, 24, Color.new(80, 255, 60, 128))
      @tag_selector.bitmap.update
      @tag_selector.z = @tag_sprite.z + 1
      @tag_scroll_bar = Yuki::ScrollBar.new(
        @tag_sprite,
        sprite_class: ::Sprite, scroll_unit: 32
      )
    end

    # Load a tileset
    def load_tileset
      @tileset_offset = 0
      @tileset_sprite.bitmap = RPG::Cache.tileset(
        MapLinker.get_tileset_name($data_tilesets[@tileset_id + 1].tileset_name))
      @info_text.visible = @tileset_sprite.bitmap.width > 256
      @tileset_sprite.src_rect.set(0, 0, 256, 448)
      @tileset_tag.bitmap&.dispose
      @tileset_tag.bitmap = Bitmap.new(@tileset_sprite.bitmap.width, @tileset_sprite.bitmap.height)
      @tileset_tag.src_rect.set(0, 0, 256, 448)
      @tileset_scroll_bar&.load_parameters
      bmp = @autotile_sprite.bitmap
      bmp.clear
      $data_tilesets[@tileset_id + 1].autotile_names.each_with_index do |name, i|
        next if !name || name.empty?

        atile = RPG::Cache.autotile(name)
        bmp.blt((i + 1) * 32, 0, atile, AutotileRect)
      end
      bmp.update
      load_systemtags
    end

    # Load the tileset's SystemTags
    def load_systemtags
      data = @data_systemtags = $data_system_tags[@tileset_id + 1]
      bmpdst = @autotile_tag.bitmap
      bmpdst.clear
      bmpsrc = @tag_sprite.bitmap
      rect = Rect.new(0, 0, 32, 32)
      # Chargement des tags des autotiles
      idtag = 0
      1.upto(7) do |i|
        idtag = data.fetch(i * 48, 0)
        next if idtag == 0

        rect.x = (idtag % 8) * 32
        rect.y = ((idtag - 384) / 8) * 32
        bmpdst.blt(i * 32, 0, bmpsrc, rect)
      end
      bmpdst.update
      # Chargement des tags des tiles
      bmpdst = @tileset_tag.bitmap
      384.upto($data_tilesets[@tileset_id + 1].terrain_tags.xsize - 1) do |i|
        idtag = data.fetch(i, 0)
        next if idtag == 0

        i -= 384
        rect.x = (idtag % 8) * 32
        rect.y = ((idtag - 384) / 8) * 32
        offset_x = 0
        max_tiles = bmpdst.height / 32 * 8
        while i >= max_tiles
          i -= max_tiles
          offset_x += 256
        end
        bmpdst.blt(i % 8 * 32 + offset_x, i / 8 * 32, bmpsrc, rect)
      end
      bmpdst.update
    end

    # Create the tileset name surface
    def init_tileset_name_surface
      num_tileset = $data_tilesets.size - 1
      data_tilesets = $data_tilesets
      @tileset_name_sprite = ::Sprite.new
      height = num_tileset * 16
      height = 480 if height < 480
      @tileset_name_sprite.bitmap = Bitmap.new(92, height)
      @tileset_name_sprite.src_rect.set(0, 0, 92, 480)
      x = @tileset_name_sprite.x = Graphics.width - 92 - 12
      @tileset_name_sprite.z = 20_000
      @tileset_name_viewport = Viewport.new(x, 0, 92, 480)
      @tileset_name_viewport.z = 20_001
      @tileset_name_stack = Array.new(num_tileset) do |i|
        Text.new(0, @tileset_name_viewport, 0, i * 16 - 4, 92, 16, data_tilesets[i+1].name)
      end
      @last_text = @tileset_name_stack.first
      @tileset_name_scroll_bar = Yuki::ScrollBar.new(
        @tileset_name_sprite,
        sprite_class: ::Sprite,
        callback: proc { |position| @tileset_name_viewport.oy = position }
      )
    end

    # Update the tileset name surface
    def update_tileset_name_surface
      text = @tileset_name_stack[@tileset_id].load_color(2)
      if @last_text != text
        @last_text.load_color(0)
        @last_text = text
      end
    end

    # Update the SystemTag selector position and state
    def update_tag_selector
      @tag_selector.x = (@tag_id % 8) * 32 + @tag_sprite.x
      @tag_selector.y = ((@tag_id - 384) / 8) * 32 - @tag_sprite.src_rect.y + @tag_sprite.y
      @tag_selector.visible = @tag_selector.y.between?(32, 480)
    end

    # Update the SystemTag selection view position
    # @param position [Integer] the new position of the view
    def update_tileset_tag_position(position)
      @tileset_tag.src_rect.y = position
    end

    # Normalize the SystemTag data (prevent missing SystemTags)
    def normalize_data
      tag_data = $data_system_tags
      tile_data = $data_tilesets
      tile_data.each_with_index do |tileset, i|
        next unless tileset.is_a?(RPG::Tileset)

        tags = tag_data[i]
        tags ||= []
        tags = fix_tags_to_array(tags) if tags.is_a?(Table)
        tags[tileset.terrain_tags.xsize - 1] = 0 if tags.size < tileset.terrain_tags.xsize
        tags.each_with_index do |value, index|
          tags[index] = 0 unless value
        end
        tag_data[i] = tags
      end
    end

    # Fix the tags format
    # @param tags [Table] the tags in the wrong format
    # @return [Array]
    def fix_tags_to_array(tags)
      Array.new(tags.xsize) { |i| tags[i].to_i }
    end
  end
end
