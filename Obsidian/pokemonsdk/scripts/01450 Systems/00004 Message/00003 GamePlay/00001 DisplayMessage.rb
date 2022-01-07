module GamePlay
  # Module responsive of adding the display message functionality to a class
  module DisplayMessage
    # Message the displays when a GamePlay scene has been initialized without message processing and try to display a message
    MESSAGE_ERROR = 'This interface has no MessageWindow, you cannot call display_message'
    # Error message when display_message is called from "itself"
    MESSAGE_PROCESS_ERROR = 'display_message was called inside display_message. Please fix your scene update.'
    # The message window
    # @return [UI::Message::Window, nil]
    attr_reader :message_window

    # Prevent the update to process if the message are still processing
    # @return [Boolean]
    def message_processing?
      @message_window&.showing_message?
    end

    # Tell if the display_message function can be called
    # @return [Boolean]
    def can_display_message_be_called?
      !@still_in_display_message
    end

    # Force the message window to "close" (but does not update scene)
    # @yield yield to allow some process before updating the message window
    def close_message_window
      return unless @message_window

      while message_processing?
        Graphics.update
        yield if block_given?
        @message_window.update
      end
    end

    # Return the message class used
    # @return [Class<UI::Message::Window>]
    def message_class
      UI::Message::Window
    end

    # Set the visibility of message
    # @param visible [Boolean]
    def message_visible=(visible)
      return unless @message_window

      @message_window.viewport.visible = visible
    end

    # Get the visibility of message
    # @return [Boolean]
    def message_visible
      return false unless @message_window

      @message_window.viewport.visible
    end

    # Display a message with choice or not
    # @param message [String] the message to display
    # @param start [Integer] the start choice index (1..nb_choice)
    # @param choices [Array<String>] the list of choice options
    # @param block [Proc] block to call while message updates
    # @return [Integer, nil] the choice result
    def display_message(message, start = 1, *choices, &block)
      raise ScriptError, MESSAGE_ERROR unless @message_window
      raise ScriptError, MESSAGE_PROCESS_ERROR unless @message_done_processing && can_display_message_be_called?

      block ||= @__display_message_proc
      setup_message_display(message, start, choices)
      # Message update
      until @message_done_processing
        message_update_scene
        block&.call
      end
      Graphics.update
      return @message_choice
    ensure
      @still_in_display_message = false
    end

    # Display a message with choice or not. This method will wait the message window to disappear
    # @param message [String] the message to display
    # @param start [Integer] the start choice index (1..nb_choice)
    # @param choices [Array<String>] the list of choice options
    # @param block [Proc] block to call while message updates
    # @return [Integer, nil] the choice result
    def display_message_and_wait(message, start = 1, *choices, &block)
      block ||= @__display_message_proc
      choice = display_message(message, start, *choices, &block)
      @still_in_display_message = true
      close_message_window(&block)
      return choice
    ensure
      @still_in_display_message = false
    end

    private

    # Initialize the window related interface of the UI
    # @param no_message [Boolean] if the scene is created wihout the message management
    # @param message_z [Integer] the z superiority of the message
    # @param message_viewport_args [Array] if empty : [:main, message_z] will be used.
    def message_initialize(no_message, message_z, message_viewport_args)
      return if no_message

      message_viewport_args = [:main, message_z] if message_viewport_args.empty?
      @message_window = message_class.new(Viewport.create(*message_viewport_args), self)
      @message_window.z = message_z
      @message_done_processing = true
      @still_in_display_message = false
    end

    # Setup the message display
    # @param message [String]
    # @param start [Integer] the start choice index (1..nb_choice)
    # @param choices [Array<String>] the list of choice options
    def setup_message_display(message, start, choices)
      # Setup variables used to check if message is processing & which choice we do
      @message_done_processing = false
      @still_in_display_message = true
      @message_choice = nil
      $game_system.map_interpreter.instance_variable_set(:@message_waiting, true) if (was_scene_map = $scene.is_a?(Scene_Map))
      # Setup the game_temp variable to declare message is in progress
      $game_temp.message_text = message
      $game_temp.message_proc = proc do
        @message_done_processing = true
        $game_system.map_interpreter.instance_variable_set(:@message_waiting, false) if was_scene_map
      end
      # Setup the game_temp variables for the choice
      if choices.any?
        $game_temp.choice_max = choices.size
        $game_temp.choice_cancel_type = choices.size
        $game_temp.choice_proc = proc { |i| @message_choice = i }
        $game_temp.choice_start = start
        $game_temp.choices = choices
      end
    end

    # Update the message
    def message_update
      message_window&.update
    end

    # Update the scene inside the message waiting loop
    # @note this internally calls message_update
    def message_update_scene
      Graphics.update
      respond_to?(:update) ? update : message_update
    end

    # Dispose the message
    def message_dispose
      return unless @message_window

      @message_window.dispose(with_viewport: true)
      @message_window = nil
    end

    # Function performing some tests to prevent softlock from messages at certain points
    def message_soft_lock_prevent
      if $game_temp.message_window_showing
        log_error('Message were still showing!')
        $game_temp.message_window_showing = false
      end
    end
  end

  class Base
    include DisplayMessage
  end
end
