# Module that manage the general graphic display
module Graphics
  @update = method(:update)
  @stop = method(:stop)
  @start = method(:start)
  @freeze = method(:freeze)
  @transition = method(:transition)
  @on_start = []
  @last_scene = nil
  @fps_balancing = true

  module_function

  # Define a block that should be called when Graphics.start has been called
  # @param block [Proc] the block to call
  def on_start(&block)
    @on_start << block
  end

  # Start the Graphic module (show the Window and call some things)
  def start
    @start.call
    @on_start.each(&:call)
    @on_start.clear
    io_initialize
    frame_reset
    @no_mouse = (PSDK_CONFIG.mouse_disabled && !PARGV[:tags])
    init_sprite
  end

  # Update the screen with the current frame state
  def update
    ::Scheduler.start(:on_update)
    if @last_scene != $scene
      sort_z
      @last_scene = $scene
    end
    # Internal update management
    update_manage
    unless @no_mouse
      Mouse.moved = (@mouse.x != Mouse.x || @mouse.y != Mouse.y)
      @mouse.x = Mouse.x
      @mouse.y = Mouse.y
    end
    Audio.update
    update_cmd_eval if @__cmd_to_eval
  rescue LiteRGSS::Error
    puts 'Graphics stopped but did not raised the `LiteRGSS::Graphics::ClosedWindowError` exception'
    raise LiteRGSS::Graphics::ClosedWindowError, 'Temporary fix'
  end

  # Stop the Graphic display
  def stop
    dispose_fps_text
    @mouse.dispose unless !@mouse || @mouse.disposed?
    @cmd_thread&.kill
    @stop.call
  rescue LiteRGSS::Graphics::StoppedError
    puts 'Graphics already stopped.'
  end

  # Make the Game wait n frames
  # @param n [Integer]
  # @yield [] a block performing action after each Graphics.update (optionnal)
  def wait(n)
    n.times do
      update
      yield if block_given?
    end
  end

  # Make the Graphics freeze
  def freeze
    @mouse.visible = false unless @no_mouse
    set_fps_color(1)
    wait(6)
    @freeze.call
  end

  # Perform a Transition
  # @param args [Array<Integer, LiteRGSS::Bitmap>] number of frame to perform the transition and the bitmap to use if needed
  def transition(*args)
    Scheduler.start(:on_transition)
    sort_z
    @transition.call(*args)
    set_fps_color(9)
    @mouse.visible = true unless @no_mouse
    @ruby_time = Time.new
  end

  # Init the Sprite used by the Graphics module
  def init_sprite
    return if @mouse && !@mouse.disposed?
    init_fps_text
    return if @no_mouse
    @mouse = Sprite.new
    @mouse.z = 200_001
    mouse_skin = PSDK_CONFIG.mouse_skin || (Config.const_defined?(:MouseSkin) && Config::MouseSkin)
    if mouse_skin && RPG::Cache.windowskin_exist?(mouse_skin)
      @mouse.bitmap = RPG::Cache.windowskin(mouse_skin)
    else
      @mouse.bitmap = Bitmap.new("\x89PNG\r\n\x1A\n\x00\x00\x00\rIHDR\x00\x00\x00\n\x00\x00\x00\x11\x04\x03\x00\x00\x00\x16\r \xD6\x00\x00\x00\x0FPLTENNN\xA3I\xA4\xE5\xE5\xE5\xD3\xD3\xD3\xC3\xC3\xC3RUt6\x00\x00\x00\x02tRNS\xFF\x00\xE5\xB70J\x00\x00\x00GIDATx\x015\xCA\xC1\t\xC40\fD\xD1/[\x05\xAC:XH\x03\x01\xA7\x00\x1F\xA6\xFF\x9A2\x16D\x87\a\x9F\x11Q>h\xC7\t\xC6\xBF\xBD\x1C\xCCu\xB7+\xDA}|\x14LI\x9B\x94\x80D^\xA9\xF4\x1Am\xD5\xCF?\x9F\xEE\x17sz\a\xBD\xEBds/\x00\x00\x00\x00IEND\xAEB`\x82", true)
    end

    detect_gl_version
  end

  # Sort the Graphical element by their z coordinate (in the Graphic Stack)
  def sort_z
    @__elementtable.sort! do |a, b|
      s = a.z <=> b.z
      next(a.__index__ <=> b.__index__) if s == 0
      next(s)
    end
    reload_stack
  end

  # Eval a command from the console
  def update_cmd_eval
    cmd = @__cmd_to_eval
    @__cmd_to_eval = nil
    begin
      if cmd.match?(/^Game /i)
        system(PSDK_RUNNING_UNDER_WINDOWS ? "start #{cmd}" : cmd)
        exit!
      end
      puts Object.instance_eval(cmd)
    rescue StandardError, SyntaxError
      print "\r"
      puts "#{$!.class} : #{$!.message}"
      puts $!.backtrace
    end
    @cmd_thread&.wakeup
  end

  # Initialize the IO related stuff of Graphics
  def io_initialize
    STDOUT.sync = true unless STDOUT.tty?
    return if PSDK_CONFIG.release?
    @cmd_thread = create_command_thread
  rescue StandardError
    puts 'Failed to initialize IO related things'
  end

  # Create the Command thread
  def create_command_thread
    Thread.new do
      loop do
        log_info('Type help to get a list of the commands you can use.')
        print 'Commande : '
        @__cmd_to_eval = STDIN.gets.chomp
        sleep
      rescue StandardError
        @cmd_thread = nil
        @__cmd_to_eval = nil
        break
      end
    end
  end

  def detect_gl_version
    version = openGL_version.join('.')
    if version < '3.1'
      vp = Viewport.create(:main)
      st = UI::SpriteStack.new(vp)
      st.with_surface(8, 8, vp.rect.width - 16) do
        st.add_line(0, "ERROR: Bad OpenGL Version (#{version})", 1, color: 10)
        st.add_line(3, 'PSDK needs the following specification to run properly:', color: 10)
        st.add_line(4, '  OpenGL Version : 3.1 minimum', color: 10)
        st.add_line(5, '  Minimal CPU Requirement: i3-4005U / i7-4500U', color: 10)
        st.add_line(6, '  Medium CPU Requirement: AMD Ryzen 5 2600', color: 10)
        st.add_line(7, '  RAM: 2GB free (8GB installed on a Windows PC)', color: 10)
        st.add_line(9, 'Please, upgrade your hardware...', color: 10)
      end
      Graphics.update until Input.trigger?(:A)
      vp.dispose
    end
  end
end
