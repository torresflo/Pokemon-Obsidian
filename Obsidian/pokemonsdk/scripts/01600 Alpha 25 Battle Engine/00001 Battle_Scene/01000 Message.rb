module Battle
  class Scene
    # Message Window of the Battle
    class Message < UI::Message::Window
      # Number of 60th of second to wait while message does not wait for user input
      MAX_WAIT = 120
      # Default windowskin of the message
      WINDOW_SKIN = 'message_box'
      # If the message will wait user to validate the message forever
      # @return [Boolean]
      attr_accessor :blocking
      # If the message wait for the user to press a key before skiping
      # @return [Boolean]
      attr_accessor :wait_input

      # Create a new window
      def initialize(...)
        super(...)
        @wait_input = false
        @blocking = false
        @skipper_wait_animation = nil
      end

      # Process the wait user input phase
      def wait_user_input
        create_skipper_wait_animation unless @skipper_wait_animation
        @skipper_wait_animation&.update
        super
      end

      # Skip the update of wait input
      # @return [Boolean] if the update of wait input should be skipped
      def update_wait_input_skip
        return super if @wait_input

        terminate_message
        return true
      end

      # Autoskip the wait input
      # @return [Boolean]
      def update_wait_input_auto_skip
        return super || (!$game_system.battle_interpreter.running? && @skipper_wait_animation&.done? && !@blocking)
      end

      # Terminate the message display
      def terminate_message
        super
        @skipper_wait_animation = nil
      end

      # Function that create the skipper wait animation
      def create_skipper_wait_animation
        @skipper_wait_animation = Yuki::Animation.wait(MAX_WAIT / 60.0)
        @skipper_wait_animation.start
      end

      # Retrieve the current window position
      # @note Always return :bottom if the battler interpreter is not running
      # @return [Symbol, Array]
      def current_position
        return super if $game_system.battle_interpreter.running?

        return :bottom
      end

      # Battle Windowskin
      # @return [String]
      def current_windowskin
        @windowskin_overwrite || WINDOW_SKIN
      end

      # Retrieve the current window_builder
      # @return [Array]
      def current_window_builder
        return [16, 10, 288, 30, 16, 10] if current_windowskin == WINDOW_SKIN

        return super
      end

      # Translate the color according to the layout configuration
      # @param color [Integer] color to translate
      # @return [Integer] translated color
      def translate_color(color)
        return current_layout.color_mapping[color] || 10 + color if current_windowskin == WINDOW_SKIN

        return super
      end

      # Return the default horizontal margin
      # @return [Integer]
      def default_horizontal_margin
        return 0 if current_windowskin == WINDOW_SKIN

        return super
      end

      # Return the default vertical margin
      # @return [Integer]
      def default_vertical_margin
        return 0 if current_windowskin == WINDOW_SKIN

        return super
      end
    end
  end
end
