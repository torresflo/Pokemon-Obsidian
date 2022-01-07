# frozen_string_literal: true

module PFM
  module Message
    # Module responsive of helping the message window with states
    #
    # In order to have everything working properly, the class including this module needs to define:
    # - message_width : Returns an integer telling the width of the message window we want to process (can use @properties)
    # - width_computer : Returns [PFM::Message::WidthComputer] object helping to compute the width of the words/texts
    module State
      # @!parse include UI::Message::Layout
      include Parser

      # If the message doesn't wait the player to hit A to terminate
      # @return [Boolean]
      attr_accessor :auto_skip
      # If the window message doesn't fade out
      # @return [Boolean]
      attr_accessor :stay_visible
      # The last unprocessed text the window has shown
      # @return [String, nil]
      attr_reader :last_text
      # Get the current instruction
      # @return [Instructions::Text, Instructions::Marker, Instructions::Marker, nil]
      protected attr_reader :current_instruction
      # Get the instructions
      # @return [Instructions]
      protected attr_reader :instructions
      # Get the properties
      # @return [Properties]
      protected attr_reader :properties

      # Initialize the states
      def initialize(...)
        @auto_skip = false
        @stay_visible = false
        @last_text = nil
        super(...) # Forward any arguments to original super ;)
      end

      # Tell if the message window need to show a message
      # @return [Boolean]
      def need_to_show_message?
        # If the window is showing a message and not done drawing it, no need to show the new message
        return false if showing_message? && @instructions

        # The message text needs to be String object in order to show a new message
        return $game_temp.message_text.is_a?(String)
      end

      # Tell if the message window need to wait for user input
      # @return [Boolean]
      def need_to_wait_user_input?
        return showing_message? && done_drawing_message? && !$game_temp.message_text.nil?
      end

      # Parse the new message and set the window into showing message state
      def parse_and_show_new_message
        @last_text = $game_temp.message_text
        @properties = convert_text_to_properties($game_temp.message_text)
        @instructions = make_instructions(@properties, message_width, width_computer)
        @instructions.start_processing
        @current_instruction = nil
        $game_temp.message_window_showing = true
      end

      # Load the next instruction
      def load_next_instruction
        @current_instruction = @instructions.get
      end

      # Test if we're at the end of the line
      # @return [Boolean]
      def at_end_of_line?
        return @current_instruction == Instructions::NewLine
      end

      # Test if we're done drawing the message
      # @return [Boolean]
      def done_drawing_message?
        return (@instructions&.done_processing? || !@instructions) && !current_instruction
      end

      # Tell if the message window is showing a message
      # @return [Boolean]
      def showing_message?
        return $game_temp.message_window_showing
      end

      # Tell if the message window need to show a choice
      # @return [Boolean]
      def need_to_show_choice?
        return $game_temp.choice_max > 0
      end

      # Tell if the message window need to show a number input
      # @return [Boolean]
      def need_to_show_number_input?
        return $game_temp.num_input_digits_max > 0
      end

      private

      # Terminate the message display
      def terminate_message
        self.active = false
        self.pause = false
        $game_temp.message_proc&.call
        reset_game_temp_message_info
        reset_overwrites
        init_fade_out
        @instructions = nil
        @auto_skip = false
      end

      # Reset all the states of the message_window
      def reset_states
        @properties = nil
        @instructions = nil
        @current_instruction = nil
        $game_temp.message_window_showing = false
      end

      # Reset the $game_temp stuff
      def reset_game_temp_message_info
        $game_temp.message_text = nil
        $game_temp.message_proc = nil
        $game_temp.choice_start = 99
        $game_temp.choice_max = 0
        $game_temp.choice_cancel_type = 0
        $game_temp.choice_proc = nil
        $game_temp.num_input_start = -99
        $game_temp.num_input_variable_id = 0
        $game_temp.num_input_digits_max = 0
      end
    end
  end
end
