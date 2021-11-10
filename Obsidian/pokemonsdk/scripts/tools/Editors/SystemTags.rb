# All the PSDK editor as tool
module Editors
  # System Tag editor
  #
  # How to use
  # 1. Enter ScriptLoader.load_tool('Editors/SystemTags')
  # 2. Open the Editor this way: editor = Editors::SystemTags.new
  class SystemTags
    # Get the running state of the scene
    # @return [Boolean]
    attr_reader :running

    # Create a new Editor
    def initialize
      init_context
      create_window
      create_surfaces
      @running = true
      @mouse_x = 0
      @mouse_y = 0
    end

    # Execute the main loop of the editor
    def main
      Graphics.window.dispose if $scene == self
      load_tileset
      update while @running
      $scene = nil if $scene == self
    end

    def update
      @window.update
    end

    private

    def load_tileset
      @tileset_names.select_tileset(@tileset_index)
      @tileset.load_tileset(@data_tilesets[@tileset_index + 1])
      @tileset_tags.load_systemtags(@data_system_tags[@tileset_index + 1], 0)
      @autotiles.load_autotiles(@data_tilesets[@tileset_index + 1], @data_system_tags[@tileset_index + 1])
      @tileset_viewport.sort_z
    end

    def create_window
      @window = LiteRGSS::DisplayWindow.new('PSDK SystemTagEditor', 640, 480, 1, 32, 0, true, false, true)
      create_mouse_move_event
      create_scroll_event
      create_click_event
    end

    def create_mouse_move_event
      @window.on_mouse_moved = proc do |x, y|
        @mouse_x = x
        @mouse_y = y
        next unless @mouse_x.between?(0, 255)
        if Sf::Mouse.press?(Sf::Mouse::LEFT)
          next tileset_left_click
        elsif Sf::Mouse.press?(Sf::Mouse::RIGHT)
          next tileset_right_click
        end
      end
    end

    def create_click_event
      @window.on_mouse_button_released = proc do |button|
        if button == Sf::Mouse::LEFT
          next save if @save_button.simple_mouse_in?(@mouse_x, @mouse_y)
          next tileset_left_click if @mouse_x < 256
          next system_tag_left_click if @mouse_x.between?(268, 523)
          next tileset_name_click if @mouse_x.between?(536, 628)
        elsif button == Sf::Mouse::RIGHT
          next tileset_right_click if @mouse_x < 256
        end
      end
    end

    def save
      save_data(@data_system_tags, 'Data/PSDK/SystemTags.rxdata')
      Audio.se_play('audio/se/nintendo')
    end

    # @param tag_id [Integer] ID of the system tag
    def tileset_left_click(tag_id = @tag_id)
      return autotile_click(tag_id) if @mouse_y < 32

      my = @mouse_y - @tileset.y - 32
      @data_system_tags[@tileset_index + 1][384 + @mouse_x / 32 + my / 32 * 8] = tag_id
      @tileset_tags.load_systemtags(@data_system_tags[@tileset_index + 1], -@tileset.y / 32)
    end

    # @param tag_id [Integer] ID of the system tag
    def autotile_click(tag_id)
      return if @mouse_x < 32

      autotile_id = @mouse_x / 32 - 1
      @autotiles.update_tag(autotile_id, tag_id)
      system_tags = @data_system_tags[@tileset_index + 1]
      (48 + autotile_id * 48).upto(95 + autotile_id * 48) do |i|
        system_tags[i] = tag_id
      end
    end

    def tileset_right_click
      tileset_left_click(0)
    end

    def system_tag_left_click
      mx = @mouse_x - @system_tag_viewport.rect.x
      my = @mouse_y - @system_tag_viewport.rect.y
      return if my < 0

      my += @system_tag_viewport.oy
      @tag_id = mx / 32 + 384 + my / 32 * 8
      @selector_sprite.set_position(mx / 32 * 32, my / 32 * 32)
    end

    def tileset_name_click
      my = @mouse_y + @name_viewport.oy
      return if my / 16 >= @data_tilesets.size

      @tileset_index = my / 16
      load_tileset
    end

    def create_scroll_event
      @window.on_mouse_wheel_scrolled = proc do |wheel, delta|
        next if wheel != Sf::Mouse::VerticalWheel

        if @mouse_x < 256
          scroll_tileset(-delta)
        elsif @mouse_x.between?(268, 523)
          scroll_system_tags(-delta)
        elsif @mouse_x.between?(536, 628)
          scroll_text(-delta)
        end
      end
    end

    # @param delta [Numeric]
    def scroll_tileset(delta)
      delta_int = delta.to_i.clamp(-1, 1)
      delta.to_i.abs.times do
        break if delta_int < 0 && @tileset.y >= 0

        lower_limit = ((@data_system_tags[@tileset_index + 1].size - 384) / 8) - 14
        break if delta_int > 0 && (-@tileset.y / 32) >= lower_limit

        @tileset.move(0, -delta_int * 32)
        @tileset_tags.load_systemtags(@data_system_tags[@tileset_index + 1], -@tileset.y / 32)
      end
    end

    # @param delta [Numeric]
    def scroll_system_tags(delta)
      delta_int = delta.to_i.clamp(-1, 1)
      delta.to_i.abs.times do
        break if delta_int < 0 && @system_tag_viewport.oy <= 0

        lower_limit = (@system_tag_sprite.height / 32) - 14
        break if delta_int > 0 && (@system_tag_viewport.oy.abs / 32 >= lower_limit)

        @system_tag_viewport.oy += delta_int * 32
      end
    end

    # @param delta [Numeric]
    def scroll_text(delta)
      delta_int = delta.to_i.clamp(-1, 1)
      delta.to_i.abs.times do
        break if delta_int < 0 && @name_viewport.oy <= 0

        lower_limit = @tileset_names.size - 30
        break if delta_int > 0 && (@name_viewport.oy.abs / 16 >= lower_limit)

        @name_viewport.oy += delta_int * 16
      end
    end

    # Init the surface of all the thing to draw in the window
    def create_surfaces
      @tileset_viewport = LiteRGSS::Viewport.new(@window, 0, 32, 256, 448)
      @tileset = Tileset.new(@tileset_viewport)
      @tileset_tags = SystemTagGrid.new(@tileset_viewport)
      @system_tag_viewport = LiteRGSS::Viewport.new(@window, 268, 32, 256, 448)
      create_system_tag_sprites
      @name_viewport = LiteRGSS::Viewport.new(@window, 536, 0, 92, 480)
      @tileset_names = TilesetNames.new(@name_viewport, @data_tilesets)
      @main_viewport = LiteRGSS::Viewport.new(@window, 0, 0, 640, 480)
      create_main_sprites
      hook_main_vp_utility
    end

    def create_main_sprites
      @save_button = Sprite.new(@main_viewport)
      @save_button.load('save', :interface)
      @save_button.set_position(256, 0)
      @autotiles = Autotiles.new(@main_viewport)
    end

    def create_system_tag_sprites
      @system_tag_sprite = Sprite.new(@system_tag_viewport).load('prio_w', :tileset)
      @selector_sprite = Sprite.new(@system_tag_viewport)
      @selector_sprite.bitmap = Texture.new(32, 32)
      image = Image.new(32, 32)
      image.fill_rect(0, 0, 32, 32, Color.new(200, 255, 60, 200))
      image.fill_rect(4, 4, 24, 24, Color.new(80, 255, 60, 128))
      image.copy_to_bitmap(@selector_sprite.bitmap)
      image.dispose
    end

    def hook_main_vp_utility
      def @main_viewport.simple_mouse_in?(*)
        return true
      end
      def @main_viewport.translate_mouse_coords(mx, my)
        return mx, my
      end
    end

    # Init the editor context
    def init_context
      # @type [Array<RPG::Tileset>]
      @data_tilesets = _clean_name_utf8(load_data('Data/Tilesets.rxdata'))
      # @type [Array<Table>]
      @data_system_tags = load_data('Data/PSDK/SystemTags.rxdata')
      @running = true
      @tileset_index = 0
      @tag_id = 384
      normalize_data
    end

    # Normalize the SystemTag data (prevent missing SystemTags)
    def normalize_data
      tag_data = @data_system_tags
      tile_data = @data_tilesets
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

    class TilesetNames < UI::SpriteStack
      # Create a new TilesetNames element
      # @param viewport [Viewport]
      # @param tilesets [Array<RPG::Tileset>]
      def initialize(viewport, tilesets)
        super(viewport)
        tilesets.compact.each_with_index do |tileset, i|
          add_text(0, i * 16, 0, 16, tileset.name, color: 10)
        end
        @last_tileset = 0
      end

      # Select a tileset
      # @param i [Integer] index of the tileset in the list
      def select_tileset(i)
        @stack[@last_tileset].load_color(10)
        @stack[i].load_color(12)
        @last_tileset = i
      end
    end

    class SystemTagGrid < UI::SpriteStack
      # Create a new SystemTagGrid
      # @param viewport [Viewport]
      def initialize(viewport)
        super(viewport)
        14.times do |i|
          push_sprite(sprite = LiteRGSS::SpriteMap.new(viewport, 32, 8))
          sprite.set_position(0, i * 32)
          sprite.z = 1000
        end
        @texture = RPG::Cache.tileset('prio_w')
        @rect = Rect.new(0, 0, 32, 32)
      end

      # Load the system tags
      # @param system_tags [Array<Integer>]
      # @param offset_y [Integer] y offset in tiles
      def load_systemtags(system_tags, offset_y)
        14.times do |i|
          # @type [LiteRGSS::SpriteMap]
          sprite = @stack[i]
          sprite.reset
          8.times do |x|
            system_tag = system_tags[(i + offset_y) * 8 + x + 384]
            next if !system_tag || system_tag <= 0

            sprite.set(x, @texture, rect(system_tag))
          end
        end
      end

      # Get the rect based on the system_tag
      # @param system_tag [Integer]
      def rect(system_tag)
        @rect.set((system_tag - 384) % 8 * 32, (system_tag - 384) / 8 * 32)
        return @rect
      end
    end

    class Tileset < UI::SpriteStack
      # Load the tileset
      # @param tileset [RPG::Tileset]
      def load_tileset(tileset)
        each { |sp| sp.bitmap.dispose unless sp.bitmap.disposed? }
        dispose
        set_position(0, 0)
        return if !tileset.tileset_name || tileset.tileset_name.empty?

        mheight = LiteRGSS::DisplayWindow::MAX_TEXTURE_SIZE
        image = Image.new("graphics/tilesets/#{tileset.tileset_name}.png")
        (image.height.to_f / mheight).ceil.times do |i|
          sprite = add_sprite(0, i * mheight, NO_INITIAL_IMAGE)
          height = (image.height - i * mheight).clamp(1, mheight)
          image2 = Image.new(256, height)
          image2.blt(0, 0, image, Rect.new(0, sprite.y, 256, height))
          sprite.bitmap = Texture.new(256, height)
          image2.copy_to_bitmap(sprite.bitmap)
          image2.dispose
        end
        image.dispose
      rescue Exception
        log_error("Failed to load graphics/tilesets/#{tileset.tileset_name}")
      end
    end

    class Autotiles < UI::SpriteStack
      # Create a new Autotile handler
      # @param viewport [LiteRGSS::Viewport]
      def initialize(viewport)
        super(viewport)
        create_autotiles
        create_system_tags
      end

      # Load the autotiles
      # @param tileset [RPG::Tileset]
      # @param systemtags [Array] system tags for each autotiles
      def load_autotiles(tileset, systemtags)
        tileset.autotile_names.each_with_index do |name, i|
          @autotiles[i].visible = false
          update_tag(i, systemtags[i * 48 + 48])
          next if !name || name.empty?

          load_autotile(name, @autotiles[i])
        end
      end

      # Update a tag
      # @param i [Integer]
      # @param system_tag [Integer]
      def update_tag(i, system_tag)
        @tags[i].visible = system_tag != 0
        @tags[i].src_rect.set((system_tag - 384) % 8 * 32, (system_tag - 384) / 8 * 32)
      end

      private

      # @param name [String]
      # @param sprite [Sprite]
      def load_autotile(name, sprite)
        sprite.bitmap.dispose if sprite.bitmap && !sprite.bitmap.disposed?
        image = Image.new("graphics/autotiles/#{name}.png")
        image2 = Image.new(32, 32)
        image2.blt!(0, 0, image, Rect.new(0, 0, 32, 32))
        sprite.bitmap = Texture.new(32, 32)
        sprite.visible = true
        image2.copy_to_bitmap(sprite.bitmap)
        image.dispose
        image2.dispose
      rescue Exception
        log_error("Failed to load graphics/autotiles/#{name}")
      end

      def create_autotiles
        # @type [Array<Sprite>]
        @autotiles = 7.times.map do |i|
          add_sprite(32 + i * 32, 0, NO_INITIAL_IMAGE)
        end
      end

      def create_system_tags
        picture = RPG::Cache.tileset('prio_w')
        # @type [Array<Sprite>]
        @tags = 7.times.map do |i|
          add_sprite(32 + i * 32, 0, picture, rect: [0, 0, 32, 32])
        end
      end
    end
  end
end
