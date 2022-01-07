# Module that holds every UI object
module UI
  # Class that helps to define a single object constitued of various sprites.
  # With this class you can move the sprites as a single sprite, change the data that generate the sprites and some other cool stuff
  class SpriteStack
    # Constant specifiying the sprite will have no image during initialization
    NO_INITIAL_IMAGE = nil
    # X coordinate of the sprite stack
    # @return [Numeric]
    attr_reader :x
    # Y coordinate of the sprite stack
    # @return [Numeric]
    attr_reader :y
    # Data used by the sprites of the sprite stack to generate themself
    attr_reader :data
    # Get the stack
    attr_reader :stack
    # Get the viewport
    # @return [Viewport]
    attr_reader :viewport

    # Create a new Sprite stack
    # @param viewport [Viewport] the viewport where the sprites will be shown
    # @param x [Numeric] the x position of the sprite stack
    # @param y [Numeric] the y position of the sprite stack
    # @param default_cache [Symbol] the RPG::Cache function to call when setting the bitmap
    def initialize(viewport, x = 0, y = 0, default_cache: :interface)
      @viewport = viewport
      @stack = []
      @x = x
      @y = y
      @default_cache = default_cache
    end

    # Push a sprite to the stack
    # @param x [Numeric] the relative x position of the sprite in the stack (sprite.x = stack.x + x)
    # @param y [Numeric] the relative y position of the sprite in the stack (sprite.y = stack.y + y)
    # @param args [Array] the arguments after the viewport argument of the sprite to create the sprite
    # @param rect [Array, nil] the src_rect.set arguments if required
    # @param type [Class] the class to use to generate the sprite
    # @param ox [Numeric] the ox of the sprite
    # @param oy [Numeric] the oy of the sprite
    # @return [Sprite] the pushed sprite
    def push(x, y, bmp, *args, rect: nil, type: Sprite, ox: 0, oy: 0)
      sprite = type.new(@viewport, *args)
      sprite.set_position(@x + x, @y + y).set_origin(ox, oy)
      sprite.set_bitmap(bmp, @default_cache) if bmp
      sprite.src_rect.set(*rect) if rect.is_a?(Array)
      sprite.src_rect = rect if rect.is_a?(Rect)
      return push_sprite(sprite)
    end
    alias add_sprite push

    # Add a text inside the stack, the offset x/y will be adjusted
    # @param x [Integer] the x coordinate of the text surface
    # @param y [Integer] the y coordinate of the text surface
    # @param width [Integer] the width of the text surface
    # @param height [Integer, nil] the height of the text surface (if nil, uses the line_height from sizeid)
    # @param str [String] the text shown by this object
    # @param align [0, 1, 2] the align of the text in its surface (best effort => no resize), 0 = left, 1 = center, 2 = right
    # @param outlinesize [Integer, nil] the size of the text outline
    # @param type [Class] the type of text
    # @param color [Integer] the id of the color
    # @return [Text] the text object
    def add_text(x, y, width, height, str, align = 0, outlinesize = Text::Util::DEFAULT_OUTLINE_SIZE, type: Text, color: nil, sizeid: nil)
      height ||= Fonts.line_height(sizeid || @font_id.to_i)
      text = type.new(@font_id.to_i, @viewport, x + @x, y - Text::Util::FOY + @y, width, height, str, align, outlinesize, color, sizeid)
      text.draw_shadow = outlinesize.nil?
      @stack << text
      return text
    end

    # Push a background image
    # @param filename [String] name of the image in the cache
    # @param rect [Array, nil] the src_rect.set arguments if required
    # @param type [Class] the class to use to generate the sprite
    # @return [Sprite]
    def add_background(filename, type: Sprite, rect: nil)
      sprite = type.new(@viewport)
      sprite.set_position(@x, @y)
      sprite.set_bitmap(filename, @default_cache)
      sprite.src_rect.set(*rect) if rect.is_a?(Array)
      sprite.src_rect = rect if rect.is_a?(Rect)
      return push_sprite(sprite)
    end
    alias add_foreground add_background

    # Push a sprite object to the stack
    # @param sprite [Sprite, Text]
    # @return [sprite]
    def push_sprite(sprite)
      @stack << sprite
      return sprite
    end
    alias add_custom_sprite push_sprite

    # Execute push operations with an alternative cache
    #
    # @example
    #   with_cache(:pokedex) { add_background('win_sprite') }
    # @param cache [Symbol] function of RPG::Cache used to load images
    def with_cache(cache)
      last_cache = @default_cache
      @default_cache = cache
      yield
    ensure
      @default_cache = last_cache
    end

    # Execute add_text operation with an alternative font
    #
    # @example
    #   with_font(2) { add_text(0, 0, 320, 32, 'Big Text', 1) }
    # @param font_id [Integer] id of the font
    def with_font(font_id)
      last_font = @font_id
      @font_id = font_id
      yield
    ensure
      @font_id = last_font
    end

    # Execute add_line with specific metrics info
    # @example
    #   with_surface(x, y, unit_width, size_id) do
    #     add_line(0, "Centered", 1)
    #     add_line(1, "Left Red", color: 2)
    #     add_line(2, "Right Blue", 2, color: 1)
    #     add_line(0, "Centered on next surface", 1, dx: 1)
    #   end
    # @param x [Integer] X position of the surface
    # @param y [Integer] Y position of the surface
    # @param unit_width [Integer] Width of the line (for alignment and offset x)
    # @param size_id [Integer] Size to use to get the right metrics
    # @param offset_width [Integer] offset between each columns when dx: is used
    def with_surface(x, y, unit_width, size_id = 0, offset_width = 2)
      last_surface_x = @surface_x
      last_surface_y = @surface_y
      last_unit_width = @surface_width
      last_size_id = @surface_size_id
      last_offset_width = @surface_offset_width
      @surface_x = x
      @surface_y = y
      @surface_width = unit_width
      @surface_size_id = size_id
      @surface_offset_width = offset_width
      yield
    ensure
      @surface_x = last_surface_x
      @surface_y = last_surface_y
      @surface_width = last_unit_width
      @surface_size_id = last_size_id
      @surface_offset_width = last_offset_width
    end

    # Add a text inside the stack using metrics given by with_surface
    # @param line_index [Integer] index of the line in the surface
    # @param str [String] the text shown by this object
    # @param align [0, 1, 2] the align of the text in its surface (best effort => no resize), 0 = left, 1 = center, 2 = right
    # @param outlinesize [Integer, nil] the size of the text outline
    # @param type [Class] the type of text
    # @param color [Integer] the id of the color
    # @param dx [Integer] offset x to use "table like" display (this value is multiplied by width)
    # @return [Text] the text object
    def add_line(line_index, str, align = 0, outlinesize = Text::Util::DEFAULT_OUTLINE_SIZE, type: Text, color: nil, dx: 0)
      x = @surface_x + dx * (@surface_width + @surface_offset_width)
      y = @surface_y + line_index * (height = Fonts.line_height(@surface_size_id || @font_id.to_i))
      text = type.new(@font_id.to_i, @viewport, x + @x, y - Text::Util::FOY + @y, @surface_width, height, str, align, outlinesize, color, @surface_size_id)
      text.draw_shadow = outlinesize.nil?
      @stack << text
      return text
    end

    # Return an element of the stack
    # @param index [Integer] index of the element in the stack
    # @return [Sprite, Text]
    def [](index)
      @stack[index]
    end

    # Return the size of the stack
    # @return [Integer]
    def size
      @stack.size
    end
    alias length size

    # Change the x coordinate of the sprite stack
    # @param value [Numeric] the new value
    def x=(value)
      delta = value - @x
      @x = value
      @stack.each { |sprite| sprite.x += delta }
    end

    # Change the y coordinate of the sprite stack
    # @param value [Numeric] the new value
    def y=(value)
      delta = value - @y
      @y = value
      @stack.each { |sprite| sprite.y += delta }
    end

    # Change the x and y coordinate of the sprite stack
    # @param x [Numeric] the new x value
    # @param y [Numeric] the new y value
    # @return [self]
    def set_position(x, y)
      delta_x = x - @x
      delta_y = y - @y
      return move(delta_x, delta_y)
    end

    # Move the sprite stack
    # @param delta_x [Numeric] number of pixel the sprite stack should be moved in x
    # @param delta_y [Numeric] number of pixel the sprite stack should be moved in y
    # @return [self]
    def move(delta_x, delta_y)
      @x += delta_x
      @y += delta_y
      @stack.each { |sprite| sprite.set_position(sprite.x + delta_x, sprite.y + delta_y) }
      return self
    end

    # Set the origin (does nothing)
    # @param _ox [Integer] new origin x
    # @param _oy [Integer] new origin y
    # @note this function is only for compatibility, it does nothing
    def set_origin(_ox, _oy)
      # Does nothing
    end

    # If the sprite stack is visible
    # @note Return the visible property of the first sprite
    # @return [Boolean]
    def visible
      return false if @stack.empty?
      return @stack.first.visible
    end

    # Change the visible property of each sprites
    # @param value [Boolean]
    def visible=(value)
      @stack.each { |sprite| sprite.visible = value }
    end

    # Detect if the mouse is in the first sprite of the stack
    # @param mx [Numeric] mouse x coordinate
    # @param my [Numeric] mouse y coordinate
    # @return [Boolean]
    def simple_mouse_in?(mx = Mouse.x, my = Mouse.y)
      return false if @stack.empty?
      return @stack.first.simple_mouse_in?(mx, my)
    end

    # Translate the mouse coordinate to mouse position inside the first sprite of the stack
    # @param mx [Numeric] mouse x coordinate
    # @param my [Numeric] mouse y coordinate
    # @return [Array(Numeric, Numeric)]
    def translate_mouse_coords(mx = Mouse.x, my = Mouse.y)
      return 0,0 if @stack.empty?
      return @stack.first.translate_mouse_coords(mx, my)
    end

    # Set the data source of the sprites
    # @param v [Object]
    def data=(v)
      @data = v
      @stack.each do |sprite|
        sprite.data = v if sprite.respond_to?(:data=)
      end
    end

    # yield a block on each sprite
    # @param block [Proc]
    def each(&block)
      return @stack.each unless block
      @stack.each(&block)
    end

    # Dispose each sprite of the sprite stack and clear the stack
    def dispose
      @stack.each(&:dispose)
      @stack.clear
    end

    # >>> Section from Yuki::Sprite <<<
    # If the sprite has a self animation
    # @return [Boolean]
    attr_accessor :animated
    # If the sprite is moving
    # @return [Boolean]
    attr_accessor :moving
    # Update sprite (+move & animation)
    def update
      update_animation(false) if @animated
      update_position if @moving
      @stack.each { |sprite| sprite.update if sprite.respond_to?(:update) }
    end

    # Move the sprite to a specific coordinate in a certain amount of frame
    # @param x [Integer] new x Coordinate
    # @param y [Integer] new y Coordinate
    # @param nb_frame [Integer] number of frame to go to the new coordinate
    def move_to(x, y, nb_frame)
      @moving = true
      @move_frame = nb_frame
      @move_total = nb_frame
      @new_x = x
      @new_y = y
      @del_x = self.x - x
      @del_y = self.y - y
    end

    # Update the movement
    def update_position
      @move_frame -= 1
      @moving = false if @move_frame == 0
      set_position(
        @new_x + (@del_x * @move_frame) / @move_total,
        @new_y + (@del_y * @move_frame) / @move_total
      )
    end

    # Start an animation
    # @param arr [Array<Array(Symbol, *args)>] Array of message
    # @param delta [Integer] Number of frame to wait between each animation message
    def anime(arr, delta = 1)
      @animated = true
      @animation = arr
      @anime_pos = 0
      @anime_delta = delta
      @anime_count = 0
    end

    # Update the animation
    # @param no_delta [Boolean] if the number of frame to wait between each animation message is skiped
    def update_animation(no_delta)
      unless no_delta
        @anime_count += 1
        return if @anime_delta > @anime_count
        @anime_count = 0
      end
      anim = @animation[@anime_pos]
      send(*anim) if anim[0] != :send && anim[0].class == Symbol
      @anime_pos += 1
      @anime_pos = 0 if @anime_pos >= @animation.size
    end

    # Force the execution of the n next animation message
    # @note this method is used in animation message Array
    # @param n [Integer] Number of animation message to execute
    def execute_anime(n)
      @anime_pos += 1
      @anime_pos = 0 if @anime_pos >= @animation.size
      n.times do
        update_animation(true)
      end
      @anime_pos -= 1
    end

    # Stop the animation
    # @note this method is used in the animation message Array (because animation loops)
    def stop_animation
      @animated = false
    end

    # Change the time to wait between each animation message
    # @param v [Integer]
    def anime_delta_set(v)
      @anime_delta = v
    end

    # Gets the opacity of the SpriteStack
    # @return [Integer]
    def opacity
      return 0 unless (sprite = @stack.first)
      return sprite.opacity
    end

    # Sets the opacity of the SpriteStack
    # @param value [Integer] the new opacity value
    def opacity=(value)
      @stack.each { |sprite| sprite.opacity = value if sprite.respond_to?(:opacity=) }
    end

    # Gets the z of the SpriteStack
    # @return [Numeric]
    def z
      return 0 unless (sprite = @stack.first)
      return sprite.z
    end

    # Sets the z of the SpriteStack
    def z=(value)
      @stack.each { |sprite| sprite.z = value }
    end
  end
end
