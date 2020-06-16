module LiteRGSS
  class Sprite
    # RGSS Compatibility "update" the sprite
    def update
    end
    # define the coordinates of the sprite
    # @param x [Numeric] x coordinate
    # @param y [Numeric] y coordinate
    # @param z [Integer] superiority
    # @return [self]
    def set_coordinates(x, y, z)
      self.x = x
      self.y = y
      self.z = z
      return self
    end

    # add value to sprite coordinates
    # @param x [Numeric] value to add to the x coordinate
    # @param y [Numeric] value to add to the y coordinate
    # @return [self]
    def add_xy(x, y)
      self.x += x
      self.y += y
      return self
    end

    # define the superiority of the sprite
    # @param z [Integer] superiority
    # @return [self]
    def set_z(z)
      self.z = z
      return self
    end

    # define the pixel of the bitmap that is shown at the coordinate of the sprite.
    # The width and the height is divided by ox and oy to determine the pixel
    # @param ox [Numeric] factor of division of width to get the origin x
    # @param oy [Numeric] factor of division of height to get the origin y
    # @return [self]
    def set_origin_div(ox, oy)
      self.ox = bitmap.width / ox
      self.oy = bitmap.height / oy
      return self
    end

    # Define the surface of the bitmap that is shown on the screen surface
    # @param x [Integer] x coordinate on the bitmap
    # @param y [Integer] y coordinate on the bitmap
    # @param width [Integer] width of the surface
    # @param height [Integer] height of the surface
    # @return [self]
    def set_rect(x, y, width, height)
      src_rect.set(x, y, width, height)
      return self
    end

    # Define the surface of the bitmap that is shown with division of it
    # @param x [Integer] the division index to show on x
    # @param y [Integer] the division index to show on y
    # @param width [Integer] the division of width of the bitmap to show
    # @param height [Integer] the division of height of the bitmap to show
    # @return [self]
    def set_rect_div(x, y, width, height)
      width = bitmap.width / width
      height = bitmap.height / height
      src_rect.set(x * width, y * height, width, height)
      return self
    end

    # Set the bitmap show on the screen surface
    # @overload set_bitmap(bmp)
    #   @param bmp [Bitmap, nil] the bitmap to show
    # @overload set_bitmap(filename, cache_symbol)
    #   @param filename [String] the name of the image
    #   @param cache_symbol [Symbol] the symbol method to call with filename argument in RPG::Cache
    # @return [self]
    def set_bitmap(bmp, cache = nil)
      if cache && bmp.is_a?(String)
        self.bitmap = RPG::Cache.send(cache, bmp)
      else
        self.bitmap = bmp
      end
      return self
    end
  end
end
