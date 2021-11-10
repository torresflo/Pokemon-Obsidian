raise 'You did not loaded LiteRGSS2' unless defined?(LiteRGSS::DisplayWindow)

# Module responsive of showing graphics into the main window
module Graphics
  include Hooks
  extend Hooks
  # List of all task to call on start
  @on_start = []
  # List of all viewport currently shown in Graphics
  @viewports = []
  # Frozen state of the graphics. This variable will be decreased to 0 to automatically unfreeze graphics
  @frozen = 0
  # Current graphic framerate
  @frame_rate = 60
  # Current time
  @current_time = Time.new
  # Focus state of the window
  @has_focus = true
  # Frame counter
  @frame_count = 0
  # Flag telling if going fullscreen is allowed or not
  @fullscreen_toggle_enabled = true
  class << self
    # Get the game window
    # @return [LiteRGSS::DisplayWindow]
    attr_reader :window
    # Get the global frame count
    # @return [Integer]
    attr_accessor :frame_count
    # Get the framerate
    # @return [Integer]
    attr_accessor :frame_rate
    # Get the current time
    # @return [Time]
    attr_reader :current_time
    # Get the time when the last frame was executed
    # @return [Time]
    attr_reader :last_time
    # Tell if it is allowed to go fullscreen with ALT+ENTER
    attr_accessor :fullscreen_toggle_enabled

    # Tell if the graphics window has focus
    # @return [Boolean]
    def focus?
      return @has_focus
    end

    # Tell if the graphics are frozen
    # @return [Boolean]
    def frozen?
      @frozen > 0
    end

    # Tell how much time there was since last frame
    # @return [Float]
    def delta
      return @current_time - @last_time
    end

    # Get the brightness of the main game window
    # @return [Integer]
    def brightness
      return window&.brightness || 0
    end

    # Set the brightness of the main game window
    # @param brightness [Integer]
    def brightness=(brightness)
      window&.brightness = brightness
    end

    # Get the height of the graphics
    # @return [Integer]
    def height
      return window.height
    end

    # Get the width of the graphics
    # @return [Integer]
    def width
      return window.width
    end

    # Get the shader of the graphics
    # @return [Shader]
    def shader
      return window&.shader
    end

    # Set the shader of the graphics
    # @param shader [Shader, nil]
    def shader=(shader)
      window&.shader = shader
    end

    # Freeze the graphics
    def freeze
      return unless @window

      @frozen_sprite.dispose if @frozen_sprite && !@frozen_sprite.disposed?
      @frozen_sprite = LiteRGSS::ShaderedSprite.new(window)
      @frozen_sprite.bitmap = snap_to_bitmap
      @frozen = 10
    end

    # Resize the window screen
    # @param width [Integer]
    # @param height [Integer]
    def resize_screen(width, height)
      window&.resize_screen(width, height)
    end

    # Snap the graphics to bitmap
    # @return [LiteRGSS::Bitmap]
    def snap_to_bitmap
      all_viewport = viewports_in_order.select(&:visible)
      tmp = LiteRGSS::Viewport.new(window, 0, 0, width, height)
      bk = Image.new(width, height)
      bk.fill_rect(0, 0, width, height, Color.new(0, 0, 0, 255))
      sp = LiteRGSS::Sprite.new(tmp)
      sp.bitmap = LiteRGSS::Bitmap.new(width, height)
      bk.copy_to_bitmap(sp.bitmap)
      texture_to_dispose = all_viewport.map do |vp|
        shader = vp.shader
        vp.shader = nil
        texture = vp.snap_to_bitmap
        vp.shader = shader
        sprite = LiteRGSS::ShaderedSprite.new(tmp)
        sprite.shader = shader
        sprite.bitmap = texture
        sprite.set_position(vp.rect.x, vp.rect.y)
        next texture
      end
      texture_to_dispose << bk
      texture_to_dispose << sp.bitmap
      result_texture = tmp.snap_to_bitmap
      texture_to_dispose.each(&:dispose)
      tmp.dispose
      return result_texture
    end

    # Start the graphics
    def start
      return if @window

      @window = LiteRGSS::DisplayWindow.new(
        PSDK_CONFIG.game_title, *PSDK_CONFIG.choose_best_resolution, PSDK_CONFIG.window_scale,
        32, 0, PSDK_CONFIG.vsync_enabled, PSDK_CONFIG.running_in_full_screen, !PSDK_CONFIG.mouse_skin
      )
      @on_start.each(&:call)
      @on_start.clear
      @last_time = @current_time = Time.new
      Input.register_events(@window)
      Mouse.register_events(@window)
      @window.on_lost_focus = proc { @has_focus = false }
      @window.on_gained_focus = proc { @has_focus = true }
      @window.on_closed = proc do
        @window = nil
        next true
      end
      init_sprite
    end

    # Stop the graphics
    def stop
      window&.dispose
      @window = nil
    end

    # Transition the graphics between a scene to another
    # @param frame_count_or_sec [Integer, Float] integer = frames, float = seconds; duration of the transition
    # @param texture [Texture] texture used to perform the transition (optional)
    def transition(frame_count_or_sec = 8, texture = nil)
      return unless @window

      exec_hooks(Graphics, :transition, binding)
      return if frame_count_or_sec <= 0 || !@frozen_sprite

      transition_internal(frame_count_or_sec, texture)
      exec_hooks(Graphics, :post_transition, binding)
    rescue Hooks::ForceReturn => e
      return e.data
    ensure
      @frozen_sprite&.bitmap&.dispose
      @frozen_sprite&.shader = nil
      @frozen_sprite&.dispose
      @frozen_sprite = nil
      @frozen = 0
    end

    # Update graphics window content & events. This method might wait for vsync before updating events
    def update
      return unless @window
      return update_freeze if frozen?

      exec_hooks(Graphics, :update, bnd = binding)
      exec_hooks(Graphics, :pre_update_internal, bnd)
      Input.swap_states
      Mouse.swap_states
      window.update
      @last_time = @current_time
      @current_time = Time.new
      @frame_count += 1
      exec_hooks(Graphics, :post_update_internal, bnd)
    rescue Hooks::ForceReturn => e
      return e.data
    end

    # Update the graphics window content. This method might wait for vsync before returning
    def update_no_input
      return unless @window

      window.update_no_input
      @last_time = @current_time
      @current_time = Time.new
    end

    # Update the graphics window event without drawing anything.
    def update_only_input
      return unless @window

      Input.swap_states
      Mouse.swap_states
      window.update_only_input
      @last_time = @current_time
      @current_time = Time.new
    end

    # Make the graphics wait for an amout of time
    # @param frame_count_or_sec [Integer, Float] Integer => frames, Float = actual time
    # @yield
    def wait(frame_count_or_sec)
      return unless @window

      total_time = frame_count_or_sec.is_a?(Float) ? frame_count_or_sec : frame_count_or_sec.to_f / frame_rate
      initial_time = Graphics.current_time
      next_time = initial_time + total_time
      while Graphics.current_time < next_time
        Graphics.update
        yield if block_given?
      end
    end

    # Register an event on start of graphics
    # @param block [Proc]
    def on_start(&block)
      @on_start << block
    end

    # Register a viewport to the graphics (for special handling)
    # @param viewport [Viewport]
    # @return [self]
    def register_viewport(viewport)
      return self unless viewport.is_a?(Viewport)

      @viewports << viewport unless @viewports.include?(viewport)
      return self
    end

    # Unregister a viewport
    # @param viewport [Viewport]
    # @return [self]
    def unregitser_viewport(viewport)
      @viewports.delete(viewport)
      return self
    end

    # Reset frame counter (for FPS reason)
    def frame_reset
      exec_hooks(Graphics, :frame_reset, binding)
    end

    # Init the Sprite used by the Graphics module
    def init_sprite
      exec_hooks(Graphics, :init_sprite, binding)
    end

    # Sort the graphics in z
    def sort_z
      @window&.sort_z
    end

    # Swap the fullscreen state
    def swap_fullscreen
      settings = window.settings
      settings[7] = !settings[7]
      window.settings = settings
    end

    def screen_scale=(scale)
      settings = window.settings
      settings[3] = scale
      window.settings = settings
    end

    private

    # Update the frozen state of graphics
    def update_freeze
      return if @frozen <= 0

      @frozen -= 1
      if @frozen == 0
        log_error('Graphics were frozen for too long, calling transition...')
        transition
      else
        exec_hooks(Graphics, :update_freeze, binding)
      end
    end

    # Get the registered viewport in order
    # @return [Array<Viewport>]
    def viewports_in_order
      viewports = @viewports.reject(&:disposed?)
      viewports.sort! do |a, b|
        next a.z <=> b.z if a.z != b.z

        next a.__index__ <=> b.__index__
      end

      return viewports
    end

    # Actual execution of the transition internal
    # @param frame_count_or_sec [Integer, Float] integer = frames, float = seconds; duration of the transition
    # @param texture [Texture] texture used to perform the transition (optional)
    def transition_internal(frame_count_or_sec, texture)
      # Initialize state variables
      total_time = frame_count_or_sec.is_a?(Float) ? frame_count_or_sec : frame_count_or_sec.to_f / frame_rate
      initial_time = Graphics.current_time
      next_time = initial_time + total_time
      # Initialize shader
      @frozen_sprite.shader = Shader.create(texture ? :graphics_transition : :graphics_transition_static)
      @frozen_sprite.shader.set_texture_uniform('nextFrame', next_frame = snap_to_bitmap)
      @frozen_sprite.shader.set_texture_uniform('transition', texture) if texture
      # Hide all viewports
      viewports = viewports_in_order
      visibilities = viewports.map(&:visible)
      viewports.each { |v| v.visible = false }
      sort_z
      # Process
      while (current_time = Time.new) < next_time
        @frozen_sprite.shader.set_float_uniform('param', ((current_time - initial_time) / total_time).clamp(0, 1))
        exec_hooks(Graphics, :update_transition_internal, binding)
        window.update
        @last_time = @current_time
        @current_time = Time.new
      end
      # Show all previously visible viewport back
      viewports.each_with_index { |v, i| v.visible = visibilities[i] }
      next_frame.dispose
    end
  end

  # Shader used to perform transition
  TRANSITION_FRAG_SHADER = <<~EOFRAGMENT
    uniform float param;
    uniform sampler2D texture;
    uniform sampler2D transition;
    uniform sampler2D nextFrame;
    const float sensibilite = 0.05;
    const float scale = 1.0 + sensibilite;
    void main()
    {
      vec4 frag = texture2D(texture, gl_TexCoord[0].xy);
      vec4 tran = texture2D(transition, gl_TexCoord[0].xy);
      float pixel = max(max(tran.r, tran.g), tran.b);
      pixel -= (param * scale);
      if(pixel < sensibilite)
      {
        vec4 nextFrag = texture2D(nextFrame, gl_TexCoord[0].xy);
        frag = mix(frag, nextFrag, max(0.0, sensibilite + pixel / sensibilite));
      }
      gl_FragColor = frag;
    }
  EOFRAGMENT
  # Shader used to perform static transition
  STATIC_TRANSITION_FRAG_SHADER = <<~EOFRAGMENT
    uniform float param;
    uniform sampler2D texture;
    uniform sampler2D nextFrame;
    void main()
    {
      vec4 frag = texture2D(texture, gl_TexCoord[0].xy);
      vec4 nextFrag = texture2D(nextFrame, gl_TexCoord[0].xy);
      frag = mix(frag, nextFrag, max(0.0, param));
      gl_FragColor = frag;
    }
  EOFRAGMENT
end
