# Class that helps to display a mosaic
class Plane
  # Get ox
  # @return [Numeric]
  attr_reader :ox
  # Get oy
  # @return [Numeric]
  attr_reader :oy
  # Get opacity
  # @return [Integer]
  attr_reader :opacity
  # Get visibility
  # @return [Boolean]
  attr_reader :visible
  # Get Bitmap
  # @return [Bitmap, nil]
  attr_reader :bitmap
  # Get z
  # @return [Integer]
  attr_reader :z
  # Get zoom_x
  # @return [Numeric]
  attr_reader :zoom_x
  # Get zoom_y
  # @return [Numeric]
  attr_reader :zoom_y
  # Get the tone
  # @return [Tone]
  attr_reader :tone
  # Get the blend type
  # @return [Integer]
  attr_reader :blend_type
  # Get Viewport
  # @return [LiteRGSS::Viewport]
  attr_reader :viewport
  # Create a new Plane
  # @param viewport [LiteRGSS::Viewport]
  def initialize(viewport)
    raise LiteRGSS::Error, 'Plane requires a viewport to be displayed.' unless viewport.is_a?(LiteRGSS::Viewport)
    @viewport = viewport
    @z = @ox = @oy = 0
    @opacity = 255
    @zoom_x = @zoom_y = 1.0
    @visible = true
    @bitmap = nil
    @sprites = []
    @width = 1
    @height = 1
    @disposed = false
    # @type [LiteRGSS::Shader]
    @shader = nil
    @tone = Tone.new(0, 0, 0, 0)
    @original_tone = Tone.new(0, 0, 0, 0)
    @class = ShaderedSprite
    @blend_type = 0
  end

  # Set ox
  # @param value [Numeric]
  def ox=(value)
    raise TypeError unless value.is_a?(Numeric)
    @ox = value
    value %= @width
    each_sprite { |sprite| sprite.ox = value }
  end

  # Set oy
  # @param value [Numeric]
  def oy=(value)
    raise TypeError unless value.is_a?(Numeric)
    @oy = value
    value %= @height
    each_sprite { |sprite| sprite.oy = value }
  end

  # Set z
  # @param value [Integer]
  def z=(value)
    raise TypeError unless value.is_a?(Integer)
    @z = value
    each_sprite { |sprite| sprite.z = value }
  end

  # Set the origin
  # @param ox [Numeric]
  # @param oy [Numeric]
  def set_origin(ox, oy)
    raise TypeError unless ox.is_a?(Numeric) && oy.is_a?(Numeric)
    @ox = ox
    @oy = oy
    ox %= @width
    oy %= @height
    each_sprite { |sprite| sprite.set_origin(ox, oy) }
  end

  # Set the opacity
  # @param value [Integer]
  def opacity=(value)
    raise TypeError unless value.is_a?(Integer)
    @opacity = value.clamp(0, 255)
    each_sprite { |sprite| sprite.opacity = value }
  end

  # Set the zoom_x
  # @param value [Numeric]
  def zoom_x=(value)
    raise TypeError unless value.is_a?(Numeric)
    return if value == @zoom_x
    @zoom_x = value.abs
    update_geometry
  end

  # Set the zoom_y
  # @param value [Numeric]
  def zoom_y=(value)
    raise TypeError unless value.is_a?(Numeric)
    return if value == @zoom_y
    @zoom_y = value.abs
    update_geometry
  end

  # Set the zoom
  # @param value [Numeric]
  def zoom=(value)
    raise TypeError unless value.is_a?(Numeric)
    return if value == @zoom_x && value == @zoom_y
    @zoom_y = @zoom_x = value.abs
    update_geometry
  end

  # Is the Plane disposed
  # @return [Boolean]
  def disposed?
    return @disposed
  end

  # Dispose the Plane
  def dispose
    return if @disposed
    each_sprite(&:dispose)
    @sprites.clear
    @disposed = true
  end

  # Change the bitmap
  # @param value [LiteRGSS::Bitmap]
  def bitmap=(value)
    return if @disposed
    if value.nil?
      @bitmap = nil
      dispose
      @disposed = false
      return
    end
    raise TypeError unless value.is_a?(LiteRGSS::Bitmap)
    @bitmap = value
    @width = value.width
    @height = value.height
    update_geometry
  end

  # Change the tone
  # @note This method can be a bit better, it's just a hot fix
  # @param tone [Tone] the new tone
  def tone=(tone)
    raise TypeError, 'Expected a Tone object' unless tone.is_a?(Tone)
    if @original_tone != tone
      copy_tone(tone, @original_tone)
      if need_shader?
        @shader ||= Shader.new(Sprite_Picture::SPRITE_SHADER)
        @shader.set_float_uniform('tone', tone)
        each_sprite { |sprite| sprite.shader ||= @shader }
      else
        @shader = nil
        each_sprite { |sprite| sprite.shader = nil }
      end
    end
    @tone = tone
  end

  # Change the blend_type
  # @param blend_type [Integer]
  def blend_type=(value)
    if need_shader?
      @shader ||= Shader.new(Sprite_Picture::SPRITE_SHADER)
      @shader.set_float_uniform('tone', tone)
      @shader.blend_type = value
      each_sprite { |sprite| sprite.shader ||= @shader }
    else
      @shader = nil
      each_sprite { |sprite| sprite.shader = nil }
    end
  end

  private

  # Copy the tone data
  # @param src [Tone]
  # @param dest [Tone]
  def copy_tone(src, dest)
    dest.set(src.red, src.green, src.blue, src.gray)
  end

  # Tell if the sprite needs a shader
  # @return [Boolean]
  def need_shader?
    return true if @blend_type != 0
    return @tone.red != 0 || @tone.green != 0 || @tone.blue != 0 || @tone.gray != 0
  end

  # Iterate something on each sprite
  def each_sprite
    @sprites.each do |row|
      row.each do |sprite|
        yield(sprite)
      end
    end
  end

  # Update the Geometry
  def update_geometry
    return unless (bmp = @bitmap)
    v = @viewport
    vw = v.rect.width
    vh = v.rect.height
    w = @width * @zoom_x
    h = @height * @zoom_y
    nb_sprite_x = (vw / w).round + 2
    nb_sprite_y = (vh / h).round + 2
    if nb_sprite_x * nb_sprite_y >= 1000
      raise LiteRGSS::Error, 'Your plane bitmap is a bit too small for the given configuration.'
    end
    puts "#{nb_sprite_x}, #{nb_sprite_y}"
    ox = @ox % @width
    oy = @oy % @height
    _zx = @zoom_x
    _zy = @zoom_y
    _z = @z
    _opacity = @opacity
    _visible = @visible
    each_sprite(&:dispose)
    @sprites.clear
    _class = @class
    @sprites = Array.new(nb_sprite_y) do |y|
      _y = y * h
      Array.new(nb_sprite_x) do |x|
        sp = _class.new(v).set_position(x * w, _y).set_origin(ox, oy)
        sp.z = _z
        sp.opacity = _opacity
        sp.visible = _visible
        sp.zoom_x = _zx
        sp.zoom_y = _zy
        sp.bitmap = bmp
        next(sp)
      end
    end
    v.sort_z
  end
end
