raise 'You did not loaded LiteRGSS2' unless defined?(LiteRGSS::DisplayWindow)

# Module responsive of giving global state of mouse Inputs
#
# The buttons of the mouse are : :LEFT, :MIDDLE, :RIGHT, :X1, :X2
module Mouse
  # @type [Hash{ Symbol => Boolean }]
  @last_state = Hash.new { false }
  # @type [Hash{ Symbol => Boolean }]
  @current_state = Hash.new { false }
  # Mapping between button & symbols
  BUTTON_MAPPING = {
    Sf::Mouse::LEFT => :LEFT,
    Sf::Mouse::RIGHT => :RIGHT,
    Sf::Mouse::Middle => :MIDDLE,
    Sf::Mouse::XButton1 => :X1,
    Sf::Mouse::XButton2 => :X2
  }
  # List of alias button
  BUTTON_ALIAS = {
    left: :LEFT,
    right: :RIGHT,
    middle: :MIDDLE
  }
  # Mouse wheel position
  # @type [Integer]
  @wheel = 0
  # Mouse wheel delta
  # @return [Integer]
  @wheel_delta = 0
  # Mouse x position on the screen
  # @type [Integer]
  @x = -999_999
  # Mouse y position on the screen
  # @type [Integer]
  @y = -999_999
  # Tell if the mouse is on screen or not
  # @return [Boolean]
  @in_screen = true
  # Tell if the mouse moved since last frame
  # @return [Boolean]
  @moved = false

  class << self
    # Mouse wheel position
    # @return [Integer]
    attr_accessor :wheel
    # Mouse wheel delta
    # @return [Integer]
    attr_reader :wheel_delta
    # Get the mouse x position
    # @return [Integer]
    attr_reader :x
    # Get the mouse y position
    # @return [Integer]
    attr_reader :y
    # Get if the mouse moved since last frame
    # @return [Boolean]
    attr_reader :moved

    # Tell if a button is pressed on the mouse
    # @param button [Symbol]
    # @return [Boolean]
    def press?(button)
      button = BUTTON_ALIAS[button] || button
      return @current_state[button]
    end

    # Tell if a button was triggered on the mouse
    # @param button [Symbol]
    # @return [Boolean]
    def trigger?(button)
      button = BUTTON_ALIAS[button] || button
      return @current_state[button] && !@last_state[button]
    end

    # Tell if a button was released on the mouse
    # @param button [Symbol]
    # @return [Boolean]
    def released?(button)
      button = BUTTON_ALIAS[button] || button
      return @last_state[button] && !@current_state[button]
    end

    # Tell if the mouse is in the screen
    # @return [Boolean]
    def in?
      return @in_screen
    end

    # Swap the state of the mouse
    def swap_states
      @last_state.merge!(@current_state)
      @moved = false
      @wheel_delta = 0
    end

    # Register event related to the mouse
    # @param window [LiteRGSS::DisplayWindow]
    def register_events(window)
      return if PSDK_CONFIG.mouse_disabled

      window.on_mouse_wheel_scrolled = proc { |wheel, delta| on_wheel_scrolled(wheel, delta) }
      window.on_mouse_button_pressed = proc { |button| on_button_pressed(button) }
      window.on_mouse_button_released = proc { |button| on_button_released(button) }
      window.on_mouse_moved = proc { |x, y| on_mouse_moved(x, y) }
      window.on_mouse_entered = proc { on_mouse_entered }
      window.on_mouse_left = proc { on_mouse_left }
    end

    private

    # Update the mouse wheel state
    # @param wheel [Integer]
    # @param delta [Float]
    def on_wheel_scrolled(wheel, delta)
      return unless wheel == Sf::Mouse::VerticalWheel

      @wheel += delta.to_i
      @wheel_delta += delta.to_i
    end

    # Update the button state
    # @param button [Integer]
    def on_button_pressed(button)
      @current_state[BUTTON_MAPPING[button]] = true
    end

    # Update the button state
    # @param button [Integer]
    def on_button_released(button)
      @current_state[BUTTON_MAPPING[button]] = false
    end

    # Update the mouse position
    # @param x [Integer]
    # @param y [Integer]
    def on_mouse_moved(x, y)
      @x = (x / PSDK_CONFIG.window_scale).floor
      @y = (y / PSDK_CONFIG.window_scale).floor
      @moved = true
    end

    # Update the mouse status when it enters the screen
    def on_mouse_entered
      @in_screen = true
    end

    # Update the mouse status when it leaves the screen
    def on_mouse_left
      @in_screen = false
    end
  end
end
