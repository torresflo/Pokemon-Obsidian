raise 'You did not loaded LiteRGSS2' unless defined?(LiteRGSS::DisplayWindow)

# Class that describe a sprite shown on the screen or inside a viewport
class Sprite < LiteRGSS::ShaderedSprite
  # RGSS Compatibility "update" the sprite
  def update
    return nil
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

  # Set the texture show on the screen surface
  # @overload load(filename, cache_symbol)
  #   @param filename [String] the name of the image
  #   @param cache_symbol [Symbol] the symbol method to call with filename argument in RPG::Cache
  #   @param auto_rect [Boolean] if the rect should be automatically set
  # @overload load(bmp)
  #   @param texture [Texture, nil] the bitmap to show
  # @return [self]
  def load(texture, cache = nil, auto_rect = false)
    if cache && texture.is_a?(String)
      self.bitmap = RPG::Cache.send(cache, texture)
      set_rect_div(0, 0, 4, 4) if auto_rect && cache == :character
    else
      self.bitmap = texture
    end
    return self
  end
  alias set_bitmap load

  # Define a sprite that mix with a color
  class WithColor < Sprite
    # Create a new Sprite::WithColor
    # @param viewport [LiteRGSS::Viewport, nil]
    def initialize(viewport = nil)
      super(viewport)
      self.shader = Shader.create(:color_shader)
    end

    # Set the Sprite color
    # @param array [Array(Numeric, Numeric, Numeric, Numeric), LiteRGSS::Color] the color (values : 0~1.0)
    # @return [self]
    def color=(array)
      shader.set_float_uniform('color', array)
      return self
    end
    alias set_color color=
  end
end

# @deprecated Please use Sprite directly
class ShaderedSprite < Sprite

end
