# SpriteSheet is a class that helps the maker to display a sprite from a Sprite Sheet on the screen
class SpriteSheet < ShaderedSprite
  # Return the number of sprite on the x axis of the sheet
  # @return [Integer]
  attr_reader :nb_x
  # Return the number of sprite on the y axis of the sheet
  # @return [Integer]
  attr_reader :nb_y
  # Return the x sprite index of the sheet
  # @return [Integer]
  attr_reader :sx
  # Return the y sprite index of the sheet
  # @return [Integer]
  attr_reader :sy
  # Create a new SpriteSheet
  # @param viewport [Viewport, nil] where to display the sprite
  # @param nb_x [Integer] the number of sprites on the x axis in the sheet
  # @param nb_y [Integer] the number of sprites on the y axis in the sheet
  def initialize(viewport, nb_x, nb_y)
    super(viewport)
    @nb_x = nb_x > 0 ? nb_x : 1
    @nb_y = nb_y > 0 ? nb_y : 1
    @sx = 0
    @sy = 0
  end

  # Change the bitmap of the sprite
  # @param value [Texture, nil]
  def bitmap=(value)
    ret = super(value)
    if value
      w = value.width /  @nb_x
      h = value.height / @nb_y
      src_rect.set(@sx * w, @sy * h, w, h)
    end
    return ret
  end

  # Change the x sprite index of the sheet
  # @param value [Integer] the x sprite index of the sheet
  def sx=(value)
    @sx = value % @nb_x
    src_rect.x = @sx * src_rect.width
  end

  # Change the y sprite index of the sheet
  # @param value [Integer] the y sprite index of the sheet
  def sy=(value)
    @sy = value % @nb_y
    src_rect.y = @sy * src_rect.height
  end

  # Select a sprite on the sheet according to its x and y index
  # @param sx [Integer] the x sprite index of the sheet
  # @param sy [Integer] the y sprite index of the sheet
  # @return [self]
  def select(sx, sy)
    @sx = sx % @nb_x
    @sy = sy % @nb_y
    src_rect.set(@sx * src_rect.width, @sy * src_rect.height, nil, nil)
    return self
  end
end
