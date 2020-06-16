module LiteRGSS
  class Plane < ShaderedSprite
    SHADER = <<~ENDOFSHADER
      // Viewport tone (required)
      uniform vec4 tone;
      // Viewport color (required)
      uniform vec4 color;
      // Zoom configuration
      uniform vec2 zoom;
      // Origin configuration
      uniform vec2 origin;
      // Texture size configuration
      uniform vec2 textureSize;
      // Texture source
      uniform sampler2D texture;
      // Plane Texture (what's zoomed origined etc...)
      uniform sampler2D planeTexture;
      // Screen size
      uniform vec2 screenSize;
      // Gray scale transformation vector
      const vec3 lumaF = vec3(.299, .587, .114);
      // Main process
      void main()
      {
        // Coordinate on the screen in pixel
        vec2 screenCoord = gl_TexCoord[0].xy * screenSize;
        // Coordinaet in the bitmap in pixel (including zoom)
        vec2 bmpCoord = mod(origin + screenCoord / zoom, textureSize) / textureSize;
        vec4 frag = texture2D(planeTexture, bmpCoord);
        // Tone&Color process
        frag.rgb = mix(frag.rgb, color.rgb, color.a);
        float luma = dot(frag.rgb, lumaF);
        frag.rgb += tone.rgb;
        frag.rgb = mix(frag.rgb, vec3(luma), tone.w);
        frag.a *= gl_Color.a;
        // Result
        gl_FragColor = frag * texture2D(texture, gl_TexCoord[0].xy);
      }
    ENDOFSHADER

    # Alias allowing to set the original bitmap, should be done before def bitmap=
    alias texture= bitmap=
    alias texture bitmap
    # Return the Bitmap of the plane
    # @return [Bitmap]
    attr_reader :bitmap

    # Return the visibility of the plane
    # @return [Boolean]
    attr_reader :visible

    # Return the color of the plane /!\ this is unlinked set() won't change the color
    # @return [Color]
    attr_reader :color

    # Return the tone of the plane /!\ this is unlinked set() won't change the color
    # @return [Tone]
    attr_reader :tone

    # Return the blend type
    # @return [Integer]
    attr_reader :blend_type

    # Create a new plane
    # @param viewport [Viewport]
    def initialize(viewport)
      super(viewport)
      self.shader = Shader.new(SHADER)
      self.texture = Plane.bitmap
      self.tone = Tone.new(0, 0, 0, 0)
      self.color = Color.new(255, 255, 255, 0)
      @blend_type = 0
      @bitmap = nil
      @origin = [0, 0]
      self.visible = true
      set_origin(0, 0)
      @zoom = [1, 1]
      self.zoom = 1
      shader.set_float_uniform('screenSize', [width, height])
    end

    # Set the bitmap of the plane
    # @param bitmap [Bitmap]
    def bitmap=(bitmap)
      @bitmap = bitmap
      if bitmap.is_a?(Bitmap)
        shader.set_texture_uniform('planeTexture', bitmap)
        shader.set_float_uniform('textureSize', [bitmap.width, bitmap.height])
      end
      self.visible = @visible
    end

    # Set the visibility of the plane
    # @param visible [Boolean]
    def visible=(visible)
      super(visible && @bitmap.is_a?(Bitmap) ? true : false)
      @visible = visible
    end

    # Set the zoom of the Plane
    # @param zoom [Float]
    def zoom=(zoom)
      @zoom[0] = @zoom[1] = zoom
      shader.set_float_uniform('zoom', @zoom)
    end

    # Set the zoom_x of the Plane
    # @param zoom [Float]
    def zoom_x=(zoom)
      @zoom[0] = zoom
      shader.set_float_uniform('zoom', @zoom)
    end

    # Get the zoom_x of the Plane
    # @return [Float]
    def zoom_x
      @zoom[0]
    end

    # Set the zoom_y of the Plane
    # @param zoom [Float]
    def zoom_y=(zoom)
      @zoom[1] = zoom
      shader.set_float_uniform('zoom', @zoom)
    end

    # Get the zoom_y of the Plane
    # @return [Float]
    def zoom_y
      @zoom[1]
    end

    # Set the origin of the Plane
    # @param ox [Float]
    # @param oy [Float]
    def set_origin(ox, oy)
      @origin[0] = ox
      @origin[1] = oy
      shader.set_float_uniform('origin', @origin)
    end

    # Set the ox of the Plane
    # @param origin [Float]
    def ox=(origin)
      @origin[0] = origin
      shader.set_float_uniform('origin', @origin)
    end

    # Get the ox of the Plane
    # @return [Float]
    def ox
      @origin[0]
    end

    # Set the oy of the Plane
    # @param origin [Float]
    def oy=(origin)
      @origin[1] = origin
      shader.set_float_uniform('origin', @origin)
    end

    # Get the oy of the Plane
    # @return [Float]
    def oy
      @origin[1]
    end

    # Set the color of the Plane
    # @param color [Color]
    def color=(color)
      if color != @color && color.is_a?(Color)
        shader.set_float_uniform('color', color)
        @color ||= color
        @color.set(color.red, color.green, color.blue, color.alpha)
      end
    end

    # Set the tone of the Plane
    # @param tone [Tone]
    def tone=(tone)
      if tone != @tone && tone.is_a?(Tone)
        shader.set_float_uniform('tone', tone)
        @tone ||= tone
        @tone.set(tone.red, tone.green, tone.blue, tone.gray)
      end
    end

    # Set the blend type
    # @param blend_type [Integer]
    def blend_type=(blend_type)
      shader.blend_type = blend_type
      @blend_type = blend_type
    end

    class << self
      # Get the generic plane bitmap
      # @return [Bitmap]
      def bitmap
        if !@bitmap || @bitmap.disposed?
          @bitmap = Bitmap.new(Graphics.width, Graphics.height)
          @bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(255, 255, 255, 255))
          @bitmap.update
        end
        return @bitmap
      end
    end

    undef x
    undef x=
    undef y
    undef y=
    undef set_position
  end
end
