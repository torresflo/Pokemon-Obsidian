module UI
  # Class that display a bar on screen using the whole texture to display the bar component
  class Bar
    # Returns the rate of the bar
    # @return [Numeric] 0 ~ 1
    attr_reader :rate
    # Return the data source to get the rate info through data=
    attr_accessor :data_source
    # Create a new bar
    # @param viewport [LiteRGSS::Viewport] the viewport in which the bar is shown
    # @param x [Integer] the x position of the bar
    # @param y [Integer] the y position of the bar
    # @param bmp [LiteRGSS::Bitmap] the texture of the bar (including the bar states)
    # @param bw [Integer] the bar width (progress part)
    # @param bh [Integer] the bar height (progress part)
    # @param bx [Integer] the x position of the bar inside the sprite
    # @param by [Integer] the y position of the bar inside the sprite
    # @param nb_states [Integer] the number of state the bar has
    def initialize(viewport, x, y, bmp, bw, bh, bx, by, nb_states)
      @background = Sprite.new(viewport).set_bitmap(bmp)
      @background.src_rect.set(0, 0, nil, bmp.height - nb_states * bh)
      @bar = Sprite.new(viewport).set_bitmap(bmp)
      @bar.src_rect.set(0, @background.src_rect.height, 0, @bh = bh)
      @nb_states = nb_states
      @bx = bx
      @by = by
      @bw = bw
      @bar.x = (@background.x = x) + bx
      @bar.y = (@background.y = y) + by
      @rate = 0
      @data_source = nil
    end

    # Change the rate of the bar
    # @param value [Numeric] 0 ~ 1
    def rate=(value)
      value = 0 if value <= 0
      value = 1 if value >= 1
      @rate = value
      state = (value * @nb_states).to_i
      state = @nb_states - 1 if state >= @nb_states
      w = (@bw * value).ceil
      w = 1 if w == 0 and value != 0
      @bar.src_rect.set(nil, @background.src_rect.height + @bh * state, w, nil)
    end

    # Change the visible state of the bar
    # @param value [Boolean]
    def visible=(value)
      @bar.visible = @background.visible = value
    end

    # Returns the visible state of the bar
    # @return [Boolean]
    def visible
      return @bar.visible
    end

    # Returns the x position of the bar
    # @return [Integer]
    def x
      return @background.x
    end

    # Returns the y position of the bar
    # @return [Integer]
    def y
      return @background.y
    end

    # Change the x position of the bar
    # @param value [Integer]
    def x=(value)
      @background.x = value
      @bar.x = value + @bx
    end

    # Change the y position of the bar
    # @param value [Integer]
    def y=(value)
      @background.y = value
      @bar.y = value + @by
    end

    # Change the position of the bar
    # @param x [Integer]
    # @param y [Integer]
    def set_position(x, y)
      @background.set_position(x, y)
      @bar.set_position(x + @bx, y + @by)
    end

    # Returns the z position of the bar
    # @return [Integer]
    def z
      return @background.z
    end

    # Change the z position of the bar
    # @param value [Numeric]
    def z=(value)
      @background.z = value
      @bar.z = value
    end

    # Dispose the bar
    def dispose
      @background.dispose
      @bar.dispose
    end

    # Change the data value (for SpriteStack usage)
    # @param data [Object] the data where we'll call the @data_source to get the actual rate
    def data=(data)
      return unless @data_source
      self.rate = data.send(*@data_source) if (self.visible = data)
    end
  end
end
