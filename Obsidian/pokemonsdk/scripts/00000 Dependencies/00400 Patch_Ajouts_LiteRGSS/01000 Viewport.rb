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

    # Sort the z sprites inside the viewport
    def sort_z
      return unless @need_to_sort || @__last_size != @__elementtable.size

      @__elementtable.sort_by!(&:z2)
      reload_stack
      @__last_size = @__elementtable.size
      @need_to_sort = false
    end

    # To_S
    def to_s
      return format('#<Vewport:%08x : %00d>', __id__, __index__)
    end
    alias inspect to_s

    # Flash the viewport
    # @param color [LiteRGSS::Color] the color used for the flash processing
    def flash(color, duration)
      color ||= Color.new(0, 0, 0)
      @viewport_color = self.color.clone
      @flash_color = color
      @flash_counter = 0
      @flash_duration = duration.to_f
      ## @flash_mid = duration / 2
    end

    # Update the viewport
    def update
      if @flash_color
        # alpha = (@flash_counter < @flash_mid ? @flash_counter : @flash_duration - @flash_counter)
        # alpha /= @flash_mid.to_f
        alpha = 1 - @flash_counter / @flash_duration
        # alpha2 = (1 - alpha)
        self.color = @flash_color
        color.alpha = @flash_color.alpha * alpha
=begin
      self.color.set(
        @viewport_color.red * alpha2 + @flash_color.red * alpha,
        @viewport_color.green * alpha2 + @flash_color.green * alpha,
        @viewport_color.blue * alpha2 + @flash_color.blue * alpha,
        @viewport_color.alpha * alpha2 + @flash_color.alpha * alpha
      )
=end
        @flash_counter += 1
        if @flash_counter >= @flash_duration
          self.color = @viewport_color
          @viewport_color = @flash_color = nil
        end
      end
    end
  end

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

LiteRGSS::Graphics.on_start { LiteRGSS::Viewport.load_configs }
