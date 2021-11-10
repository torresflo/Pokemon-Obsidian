module UI
  class ScrollBar < SpriteStack
    # The default skin of the scrollbar.
    # @return [String]
    DEFAULT_SKIN = 'scrollbar_basic'

    # Initialize the scrollbar. Kwargs keys can be :
    # - direction : :horizontal or :vertical
    # - :position [Symbol] can be :top, :left, :right, :bottom
    # - :skin [String] the scrollbar skin basename
    # - :x, :y [Integer] the scrollbar position
    # - :min [Integer] the target minimum origin value
    # - :max [Integer] the target maximum origin value
    # - :size [Integer] the size of the scrollbar
    # - no_action [Boolean] indicate if the scrollbar cannot modify the target
    # - scroll_unit [Integer] the amount of pixel scrolled when scrollbar moved
    # - offset [Integer] the offset of display in pixel
    # @param viewport [Viewport] the viewport where the scrollbar is displayed
    # @param target [Viewport] the viewport scrollable
    # @param kwargs [Hash] the scrollbar parameters
    def initialize(viewport, target, **kwargs)
      # Retrieve infos
      @target = target
      @surface = target.rect.clone
      @direction = (kwargs.fetch(:direction, :vertical) == :horizontal ? Horizontal : Vertical)
      @position = kwargs.fetch(:position, :right)
      @skin = kwargs.fetch(:skin, DEFAULT_SKIN)
      @min = kwargs.fetch(:min, 0).to_f
      @max = kwargs.fetch(:max, 100).to_f
      @size = kwargs.fetch(:size, @direction.size(@surface))
      @no_action = kwargs.fetch(:no_action, false)
      @scroll_unit = kwargs.fetch(:scroll_unit, 8)
      @display_offset = kwargs.fetch(:offset, 0)
      # Initialize
      super(viewport, 0, 0, default_cache: :windowskin)
      create_sprites
    end

    # Setup the ranges of the scrollbar, useful when the target size had change
    # @param params [Hash] the parameters
    def change_ranges(params)
      @min = params.fetch(:min, 0).to_f
      @max = params.fetch(:max, 100).to_f
    end

    # Create and place the scrollbar sprites
    def create_sprites
      # Put bitmaps in cache
      cache_back_bmp = RPG::Cache.windowskin(image_filename('background'))
      cache_up_bmp = RPG::Cache.windowskin(image_filename('up'))
      cache_down_bmp = RPG::Cache.windowskin(image_filename('down'))
      cache_bar_bmp = RPG::Cache.windowskin(image_filename('slider'))
      # Create the background
      size = @size - (cache_down_bmp.height + cache_up_bmp.height) / 2
      create_background(cache_back_bmp, size)
      # Create the up button
      create_button_up(cache_up_bmp)
      # Create the down button
      create_button_down(cache_down_bmp)
      # Create the slider button
      create_button_slider(cache_bar_bmp)
      # Repositionning the sprites
      @direction.reset_sprites_position(
        @background_sprite,
        @button_down_sprite,
        @button_up_sprite,
        @button_slider_sprite,
        @position,
        @target,
        @size,
        @display_offset,
        @viewport
      )
    end

    # Create the background sprite
    # @param cache_back_bmp [Texture] the background bitmap
    # @param size [Integer] the size of the background sprite
    def create_background(cache_back_bmp, size)
      # Initialize variables
      bmp = Texture.new(cache_back_bmp.width, size)
      # Copy the pixels to have a background matching the viewport length
      base_y = 0
      while base_y < bmp.height
        bmp.blt(0, base_y, cache_back_bmp, cache_back_bmp.rect)
        base_y += cache_back_bmp.height
      end
      bmp.update
      # Create the sprite
      @background_sprite = push 0, 0, nil
      @background_sprite.set_bitmap(bmp)
    end

    # Create the button up sprite
    # @param cach_up_bmp [Texture] the button up bitmap
    def create_button_up(cache_up_bmp)
      @button_up_sprite = push 0, 0, nil
      @button_up_sprite.set_bitmap(cache_up_bmp).set_rect_div(0, 0, 1, 2)
    end

    # Create the button down sprite
    # @param cach_down_bmp [Texture] the button down bitmap
    def create_button_down(cache_down_bmp)
      @button_down_sprite = push 0, 0, nil
      @button_down_sprite.set_bitmap(cache_down_bmp).set_rect_div(0, 0, 1, 2)
    end

    # Create the sliding button sprite
    # @param cach_button_bmp [Texture]the sliding button bitmap
    def create_button_slider(cach_button_bmp)
      @button_slider_sprite = push 0, 0, nil
      @button_slider_sprite.set_bitmap(cach_button_bmp).set_rect_div(0, 0, 1, 2)
    end

    # Construct the image filename
    # @param ext [String] the file to get
    # @return [String]
    def image_filename(ext)
      return @skin + '/' + ext
    end

    # Update the position of the scrollbar and the input
    def update
      update_input
      update_position
    end

    # Update the inputs and move the scrollbar if there is action
    def update_input
      return if @no_action
      return if check_click

      unclick
    end

    # Check if the player clicked on scrollbar button
    # @return [Boolean]
    def check_click
      return false unless Mouse.press?(:left)

      # Get viewport coords
      mx, my = @viewport.translate_mouse_coords
      trigger = Mouse.trigger?(:left)
      # Process slider dragging
      return true if update_slider_dragging(mx, my, trigger)

      # Process buttons
      return update_buttons_input(mx, my, trigger)
    end

    # Update the mouse dragging the slider and return true if it is
    # @param mouse_x [Integer] the mouse x in the viewport
    # @param mouse_y [Integer] the mouse y in the viewport
    # @param trigger [Boolean] true if the mouse left button has been triggered
    # @return [Boolean]
    def update_slider_dragging(mouse_x, mouse_y, trigger)
      if trigger && @button_slider_sprite.simple_mouse_in?
        @dragging_slider = true
        @button_slider_sprite.set_rect_div(0, 1, 1, 2)
      end
      if @dragging_slider
        m_coord = @direction.select_coord(mouse_x, mouse_y)
        b_coord = @direction.select_coord(@background_sprite)
        diff = m_coord - b_coord
        b_size = @background_sprite.height - @button_slider_sprite.height
        value = (diff / b_size.to_f) * @max
        scroll(value, true)
        return true
      end
      return false
    end

    # Update the buttons of the scroll bar, return true if one has been clicked
    # @param mouse_x [Integer] the mouse x in the viewport
    # @param mouse_y [Integer] the mouse y in the viewport
    # @param trigger [Boolean] true if the mouse left button has been triggered
    # @return [Boolean]
    def update_buttons_input(mouse_x, mouse_y, trigger)
      if @button_up_sprite.simple_mouse_in?(mouse_x, mouse_y)
        scroll(-@scroll_unit)
        @button_up_sprite.set_rect_div(0, 1, 1, 2) if trigger
        return true
      elsif @button_down_sprite.simple_mouse_in?(mouse_x, mouse_y)
        scroll(@scroll_unit)
        @button_down_sprite.set_rect_div(0, 1, 1, 2) if trigger
        return true
      elsif @background_sprite.simple_mouse_in?(mouse_x, mouse_y) && !@button_slider_sprite.simple_mouse_in?(mouse_x, mouse_y)
        comp = @direction.compare_coords(mouse_x, mouse_y, @button_slider_sprite.x, @button_slider_sprite.y)
        scroll((comp ? 1 : -1) * @scroll_unit)
        @button_slider_sprite.set_rect_div(0, 1, 1, 2) if trigger
        return true
      end
      return false
    end

    # Reset the buttons display when no click on the scrollbar
    def unclick
      # Reset dragging slider
      @dragging_slider = false if @dragging_slider
      # Reset buttons
      @button_down_sprite.set_rect_div(0, 0, 1, 2) unless @button_down_sprite.src_rect.y == 0
      @button_up_sprite.set_rect_div(0, 0, 1, 2) unless @button_up_sprite.src_rect.y == 0
      @button_slider_sprite.set_rect_div(0, 0, 1, 2) unless @button_slider_sprite.src_rect.y == 0
    end

    # Update the scrollbar position
    def update_position
      # Calculate values
      target_pos = @direction.object_origin(@target) - @min # Retrieve target ox / oy
      bar_size = @background_sprite.height - @button_slider_sprite.height
      base = @direction.object_position(@background_sprite)
      value = base + (target_pos / (@max - @min)) * bar_size.to_f
      value = base if value.nan? || value < base
      value = base + bar_size if value > base + bar_size
      # Set the slider position
      @direction.set_object_position @button_slider_sprite, value
    end

    # Scroll the bar
    # @param value [Integer] the new position ofthe target
    # @param absolute [Boolean, false] false if value must be add to current position
    def scroll(value, absolute = false)
      new_value = value + (absolute ? 0 : @direction.object_origin(@target))
      new_value = @max if new_value > @max
      new_value = @min if new_value < @min
      @direction.set_object_origin @target, new_value
    end

    # Class that calculate the coordinates of a vertical scrollbar
    module Vertical
      module_function

      # Get the size of the rect
      # @param rect [Rect] the rectangle
      # @return [Integer]
      def size(rect)
        return rect.height
      end

      # Get the position of the object
      # @param obj [Object] object with x, y methods
      # @return [Integer]
      def object_position(obj)
        return obj.y
      end

      # Set the position of the object
      # @param obj [Object] object with x=, y= methods
      # @param value [Integer] the new position value
      def set_object_position(obj, value)
        obj.y = value
      end

      # Get the origin of the object
      # @param obj [Object] object with ox, oy methods
      # @return [Integer]
      def object_origin(obj)
        return obj.oy
      end

      # Get the origin of the object
      # @param obj [Object] object with ox, oy methods
      # @return [Integer]
      def set_object_origin(obj, value)
        obj.oy = value
      end

      # Compare the given coords
      # @param x1, y1 [Integer] the first point
      # @param x2, y2 [Integer] the second point
      # @return [Boolean]
      def compare_coords(_x1, y1, _x2, y2)
        return y1 > y2
      end

      # Select the coordinate
      # @param x [Integer, Object] a coord or an object with x, y methods
      # @param y [Integer, nil] a coord or nil if x is an object
      # @return [Boolean]
      def select_coord(x, y = nil)
        return y || x.y
      end

      # Set the sprites positions
      def reset_sprites_position(background_sprite, button_down_sprite, button_up_sprite, button_slider_sprite, position, target, size, offset, viewport)
        # Set the x for each sprite
        x = (position == :left ? target.rect.x - background_sprite.width : target.rect.x + target.rect.width)
        x -= viewport.rect.x
        background_sprite.x =
          button_down_sprite.x =
            button_up_sprite.x =
              button_slider_sprite.x = x

        # Set y for each sprite
        base_y = offset + target.rect.y + (target.rect.height - size) / 2 - viewport.rect.y
        background_sprite.y = base_y + button_up_sprite.height
        button_up_sprite.y = base_y
        button_down_sprite.y = base_y + button_up_sprite.height + background_sprite.height
        button_slider_sprite.y = base_y + button_up_sprite.height

        # Rotate each sprite
        background_sprite.angle =
          button_up_sprite.angle =
            button_down_sprite.angle =
              button_slider_sprite.angle = 0
      end
    end

    # Class that calculate the coordinates of a horizontal scrollbar
    module Horizontal
      module_function

      # Get the size of the rect
      # @param rect [Rect] the rectangle
      # @return [Integer]
      def size(rect)
        return rect.width
      end

      # Get the position of the object
      # @param obj [Object] object with x, y methods
      # @return [Integer]
      def object_position(obj)
        return obj.x
      end

      # Set the position of the object
      # @param obj [Object] object with x=, y= methods
      # @param value [Integer] the new position value
      def set_object_position(obj, value)
        obj.x = value
      end

      # Get the origin of the object
      # @param obj [Object] object with ox, oy methods
      # @return [Integer]
      def object_origin(obj)
        return obj.ox
      end

      # Set the origin of the object
      # @param obj [Object] object with ox=, oy= methods
      # @param value [Integer] the new origin value
      def set_object_origin(obj, value)
        obj.ox = value
      end

      # Compare the given coords
      # @param x1, y1 [Integer] the first point
      # @param x2, y2 [Integer] the second point
      # @return [Boolean]
      def compare_coords(x1, _y1, x2, _y2)
        return x1 > x2
      end

      # Select the coordinate
      # @param x [Integer, Object] a coord or an object with x, y methods
      # @param y [Integer, nil] a coord or nil if x is an object
      # @return [Boolean]
      def select_coord(x, y = nil)
        return (y ? x : x.x)
      end

      # Set the sprites positions
      def reset_sprites_position(background_sprite, button_down_sprite, button_up_sprite, button_slider_sprite, position, target, size, offset, viewport)
        # Set the y for each sprite
        y = (position == :top ? target.rect.y : target.rect.y + target.rect.height + background_sprite.width)
        y -= viewport.rect.y
        background_sprite.y =
          button_down_sprite.y =
            button_up_sprite.y =
              button_slider_sprite.y = y

        # Set x for each sprite
        base_x = offset + target.rect.x + (target.rect.width - size) / 2 - viewport.rect.x
        background_sprite.x = base_x + button_up_sprite.height
        button_up_sprite.x = base_x
        button_down_sprite.x = base_x + button_up_sprite.height + background_sprite.height
        button_slider_sprite.x = base_x + button_up_sprite.height

        # Rotate each sprite
        background_sprite.angle =
          button_up_sprite.angle =
            button_down_sprite.angle =
              button_slider_sprite.angle = 90

        # Correct origin to match the display
        background_sprite.ox =
          button_up_sprite.ox =
            button_down_sprite.ox =
              button_slider_sprite.ox = background_sprite.width
      end
    end
  end
end
