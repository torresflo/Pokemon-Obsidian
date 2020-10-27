module LiteRGSS
  class Viewport
    # Hash containing all the Viewport configuration (:main, :sub etc...)
    CONFIGS = {}
    # Global offset x applied to the viewports (Fullscreen use)
    GLOBAL_OFFSET_X = PSDK_CONFIG.viewport_offset_x
    # Global offset y applied to the viewports (Fullscreen use)
    GLOBAL_OFFSET_Y = PSDK_CONFIG.viewport_offset_y
    # Filename for viewport compiled config
    VIEWPORT_CONF_COMP = 'Data/Viewport.rxdata'
    # Filename for viewport uncompiled config
    VIEWPORT_CONF_TEXT = 'Data/Viewport.json'
    # Test telling if PSDK runs under LiteRGSS2
    RUNNING_UNDER_LITERGSS2 = !public_method_defined?(:color=)
    # Tell if the viewport needs to sort
    # @return [Boolean]
    attr_accessor :need_to_sort

    class << self
      # Generating a viewport with one line of code
      # @overload create(x, y = 0, width = 1, height = 1, z = nil)
      #   @param x [Integer] x coordinate of the viewport
      #   @param y [Integer] y coordinate of the viewport
      #   @param width [Integer] width of the viewport
      #   @param height [Integer] height of the viewport
      #   @param z [Integer, nil] superiority of the viewport
      # @overload create(opts)
      #   @param opts [Hash] opts of the viewport definition
      #   @option opts [Integer] :x (0) x coordinate of the viewport
      #   @option opts [Integer] :y (0) y coordinate of the viewport
      #   @option opts [Integer] :width (320) width of the viewport
      #   @option opts [Integer] :height (240) height of the viewport
      #   @option opts [Integer, nil] :z (nil) superiority of the viewport
      # @overload create(screen_name_symbol, z = nil)
      #   @param screen_name_symbol [:main, :sub] describe with screen surface the viewport is (loaded from maker options)
      #   @param z [Integer, nil] superiority of the viewport
      # @return [Viewport] the generated viewport
      def create(x, y = 0, width = 1, height = 1, z = 0)
        if x.is_a?(Hash)
          z = x[:z] || z
          y = x[:y] || 0
          width = x[:width] || Config::ScreenWidth
          height = x[:height] || Config::ScreenHeight
          x = x[:x] || 0
        elsif x.is_a?(Symbol)
          return create(CONFIGS[x], 0, 1, 1, y)
        end
        v = Viewport.new(x + GLOBAL_OFFSET_X, y + GLOBAL_OFFSET_Y, width, height)
        v.z = z if z
        v.need_to_sort = true
        return v
      end

      # Load the viewport configs
      def load_configs
        unless PSDK_CONFIG.release?
          unless File.exist?(VIEWPORT_CONF_COMP) && File.exist?(VIEWPORT_CONF_TEXT)
            if File.exist?(VIEWPORT_CONF_TEXT)
              save_data(JSON.parse(File.read(VIEWPORT_CONF_TEXT), symbolize_names: true), VIEWPORT_CONF_COMP)
            else
              vp_conf = { main: { x: 0, y: 0, width: 320, height: 240 } }
              File.write(VIEWPORT_CONF_TEXT, vp_conf.to_json)
              sleep(1)
              save_data(vp_conf, VIEWPORT_CONF_COMP)
            end
          end
          # Load json conf if newer than binary conf
          if File.mtime(VIEWPORT_CONF_TEXT) > File.mtime(VIEWPORT_CONF_COMP)
            log_debug('Updating Viewport Configuration...')
            save_data(JSON.parse(File.read(VIEWPORT_CONF_TEXT), symbolize_names: true), VIEWPORT_CONF_COMP)
          end
        end
        CONFIGS.merge!(load_data(VIEWPORT_CONF_COMP))
      end
    end

    unless RUNNING_UNDER_LITERGSS2
      # Sort the z sprites inside the viewport
      def sort_z
        return unless @need_to_sort || @__last_size != @__elementtable.size

        @__elementtable.sort_by!(&:z2)
        reload_stack
        @__last_size = @__elementtable.size
        @need_to_sort = false
      end
    end

    def to_s
      return format('#<Vewport:%08x : %00d>', __id__, __index__)
    end
    alias inspect to_s

    # Flash the viewport
    # @param color [LiteRGSS::Color] the color used for the flash processing
    def flash(color, duration)
      self.shader ||= Shader.create(:color_shader_with_background)
      color ||= Color.new(0, 0, 0)
      @flash_color = color
      @flash_color_running = color.dup
      @flash_counter = 0
      @flash_duration = duration.to_f
    end

    # Update the viewport
    def update
      if @flash_color
        alpha = 1 - @flash_counter / @flash_duration
        @flash_color_running.alpha = @flash_color.alpha * alpha
        self.shader.set_float_uniform('color', @flash_color_running)
        @flash_counter += 1
        if @flash_counter >= @flash_duration
          self.shader.set_float_uniform('color', [0, 0, 0, 0])
          @flash_color_running = @flash_color = nil
        end
      end
    end

    undef color
    undef color=
    undef tone
    undef tone=

    module WithToneAndColors
      class Tone < LiteRGSS::Tone
        def initialize(viewport, r, g, b, g2)
          @viewport = viewport
          super(r, g, b, g2)
          update_viewport
        end

        def set(*args)
          r = red
          g = green
          b = blue
          g2 = gray
          super
          update_viewport if r != red || g != green || b != blue || g2 != gray
        end

        def green=(v)
          return if v == green

          super
          update_viewport
        end

        def blue=(v)
          return if v == blue

          super
          update_viewport
        end

        def gray=(v)
          return if v == gray

          super
          update_viewport
        end

        private

        def update_viewport
          @viewport.shader&.set_float_uniform('tone', self)
        end
      end

      class Color < LiteRGSS::Color
        def initialize(viewport, r, g, b, a)
          @viewport = viewport
          super(r, g, b, a)
          update_viewport
        end

        def set(*args)
          r = red
          g = green
          b = blue
          a = alpha
          super
          update_viewport if r != red || g != green || b != blue || a != alpha
        end

        def green=(v)
          return if v == green

          super
          update_viewport
        end

        def blue=(v)
          return if v == blue

          super
          update_viewport
        end

        def alpha=(v)
          return if v == alpha

          super
          update_viewport
        end

        private

        def update_viewport
          @viewport.shader&.set_float_uniform('color', self)
        end
      end
      # Set color of the viewport
      # @param value [Color]
      def color=(value)
        color.set(value.red, value.green, value.blue, value.alpha)
      end

      # Color of the viewport
      # @return [Color]
      def color
        @color ||= Color.new(self, 0, 0, 0, 0)
      end

      # Set the tone
      # @param value [Tone]
      def tone=(value)
        tone.set(value.red, value.green, value.blue, value.gray)
      end

      # Tone of the viewport
      # @return [Tone]
      def tone
        @tone ||= Tone.new(self, 0, 0, 0, 0)
      end
    end
  end

  unless Viewport::RUNNING_UNDER_LITERGSS2
    class Drawable
      def z2
        @z2 ||= z * 10_000 + __index__
      end
    end

    class Sprite
      alias old_z_set z=
      def z=(v)
        return if z == v

        viewport&.need_to_sort = true
        old_z_set(v)
        @z2 = v * 10_000 + __index__
      end
    end

    class Shape
      alias old_z_set z=
      def z=(v)
        return if z == v

        viewport&.need_to_sort = true
        old_z_set(v)
        @z2 = v * 10_000 + __index__
      end
    end

    class Text
      alias old_z_set z=
      def z=(v)
        return if z == v

        viewport&.need_to_sort = true
        old_z_set(v)
        @z2 = v * 10_000 + __index__
      end
    end

    class SpriteMap
      alias old_z_set z=
      def z=(v)
        return if z == v

        viewport&.need_to_sort = true
        old_z_set(v)
        @z2 = v * 10_000 + __index__
      end
    end

    class Window
      # Dummy attribute to prevent crash when sprites request sorting
      attr_accessor :need_to_sort
      alias old_z_set z=
      def z=(v)
        return if z == v

        viewport&.need_to_sort = true
        old_z_set(v)
        @z2 = v * 10_000 + __index__
      end
    end
  end
end

LiteRGSS::Graphics.on_start { LiteRGSS::Viewport.load_configs }
