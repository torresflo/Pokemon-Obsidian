module Battle
  class Scene
    # Message Window of the Battle
    class Message < Yuki::Message
      MAX_WAIT = 120
      WINDOW_SKIN = 'message_box'

      # @return [Boolean] if the message will wait user to validate the message forever
      attr_accessor :blocking
      # @return [Boolean] if the message wait for the user to press a key before skiping
      attr_accessor :wait_input

      # Initialize the window Parameter
      def init_window
        super
        # Make sure it's only done when called inside initialize
        return unless @waiter.nil?

        @wait_input = false
        @blocking = false
        @waiter = 0
      end

      # Retrieve the current window position
      # @note Always return :bottom if the battler interpreter is not running
      # @return [Symbol, Array]
      def current_position
        return super if $game_system.battle_interpreter.running?

        return :bottom
      end

      # Generate the choice window
      def generate_choice_window
        super
        @waiter = 0
      end

      # Show the Input Number Window
      # @return [Boolean] if the update function skips
      def update_input_number
        @waiter += 1 if @waiter < MAX_WAIT
        return super
      end

      # Skip the choice during update
      # @return [Boolean] if the function skips
      def update_choice_skip
        unless @wait_input
          terminate_message
          return true
        end
        return false
      end

      # Autoskip condition for the choice
      # @return [Boolean]
      def update_choice_auto_skip
        return (!$game_system.battle_interpreter.running? && @waiter >= MAX_WAIT && !@blocking)
      end

=begin
      # Show the message text
      # @return [Boolean] if the update function skips
      def update_text_draw
        unless $game_temp.message_text.nil?
          @contents_showing = true
          $game_temp.message_window_showing = true
          @text_stack.dispose
          set_origin(0, 0)
          self.visible = true
          init_window
          refresh
          return true
        end
        return false
      end
=end
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
