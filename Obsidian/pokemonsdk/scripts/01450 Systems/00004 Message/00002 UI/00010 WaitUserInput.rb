module UI
  module Message
    # Module describing the whole user input process
    module WaitUserInput
      # @!parse include Window

      private

      # Process the wait user input phase
      def wait_user_input
        return update_choice if need_to_show_choice?
        return update_input_number if need_to_show_number_input?

        return update_wait_input
      end

      # Show the Input Number Window
      # @return [Boolean] if the update function skips
      def update_input_number
        generate_input_number_window unless @input_number_window
        @input_number_window.update if can_sub_window_be_updated?
        # Validate
        if interacting?
          play_decision_se
          $game_variables[$game_temp.num_input_variable_id] = @input_number_window.number
          $game_map.need_refresh = true
          @input_number_window.dispose
          @input_number_window = nil
          terminate_message
        end
      end

      # Show the choice during update
      # @return [Boolean] if the update function skips
      def update_choice
        generate_choice_window unless @choice_window
        @choice_window.update if can_sub_window_be_updated?
        # Cancelation
        if $game_temp.choice_cancel_type > 0 && cancelling?
          play_cancel_se
          $game_temp.choice_proc.call($game_temp.choice_cancel_type - 1)
        # Validation
        elsif @choice_window.validated?
          play_decision_se
          $game_temp.choice_proc.call(@choice_window.index)
        else
          return # If none of the condition were ok, we just don't terminate the message
        end
        terminate_message
        @choice_window.dispose
        @choice_window = nil
      end

      # Skip the update of wait input
      # @return [Boolean] if the update of wait input should be skipped
      def update_wait_input_skip
        return false
      end

      # Autoskip the wait input
      # @return [Boolean]
      def update_wait_input_auto_skip
        return @auto_skip
      end

      # Wait for the user to press enter before moving forward
      def update_wait_input
        return if update_wait_input_skip

        self.pause = true
        if interacting?
          $game_system.se_play($data_system.cursor_se)
          terminate_message
        elsif update_wait_input_auto_skip || panel_skip?
          terminate_message
        end
      end

      # Tell if the user is interacting
      def interacting?
        return Input.trigger?(:A) || (Mouse.trigger?(:left) && simple_mouse_in?)
      end

      # Tell if the user is cancelling
      def cancelling?
        return Input.trigger?(:B) || (Mouse.trigger?(:right) && simple_mouse_in?)
      end
    end
  end
end
