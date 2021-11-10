raise 'You did not loaded LiteRGSS2' unless defined?(LiteRGSS::DisplayWindow)

# Class that describes a surface of the screen where texts and sprites are shown (with some global effect)
class Viewport < LiteRGSS::Viewport
  # Hash containing all the Viewport configuration (:main, :sub etc...)
  CONFIGS = {}
  # Global offset x applied to the viewports (Fullscreen use)
  @global_offset_x = nil
  # Global offset y applied to the viewports (Fullscreen use)
  @global_offset_y = nil
  # Filename for viewport compiled config
  VIEWPORT_CONF_COMP = 'Data/Viewport.rxdata'
  # Filename for viewport uncompiled config
  VIEWPORT_CONF_TEXT = 'Data/Viewport.json'
  # Tell if the viewport needs to sort
  # @return [Boolean]
  attr_accessor :need_to_sort

  # Create a new viewport
  # @param x [Integer] x coordinate of the viewport on screen
  # @param y [Integer] y coordinate of the viewport on screen
  # @param width [Integer] width of the viewport
  # @param height [Integer] height of the viewport
  # @param z [Integer] z coordinate of the viewport
  def initialize(x, y, width, height, z = nil)
    super(Graphics.window, x, y, width, height)
    self.z = z if z
    @need_to_sort = true
    Graphics.register_viewport(self)
  end

  # Dispose a viewport
  # @return [self]
  def dispose
    Graphics.unregitser_viewport(self)
    super
  end

  class << self
    # Generating a viewport with one line of code
    # @overload create(screen_name_symbol, z = nil)
    #   @param screen_name_symbol [:main, :sub] describe with screen surface the viewport is (loaded from maker options)
    #   @param z [Integer, nil] superiority of the viewport
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
    # @return [Viewport] the generated viewport
    def create(x, y = 0, width = 1, height = 1, z = 0)
      if x.is_a?(Hash)
        z = x[:z] || z
        y = x[:y] || 0
        width = x[:width] || PSDK_CONFIG.native_resolution.to_i
        height = x[:height] || PSDK_CONFIG.native_resolution.split('x')[1].to_i
        x = x[:x] || 0
      elsif x.is_a?(Symbol)
        return create(CONFIGS[x], 0, 1, 1, y)
      end
      gox = @global_offset_x || PSDK_CONFIG.viewport_offset_x || 0
      goy = @global_offset_y || PSDK_CONFIG.viewport_offset_y || 0
      v = Viewport.new(x + gox, y + goy, width, height, z)
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

Graphics.on_start { Viewport.load_configs }
