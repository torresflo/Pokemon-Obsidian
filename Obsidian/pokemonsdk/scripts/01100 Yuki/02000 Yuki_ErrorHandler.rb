module Yuki
  # Module that helps to display error to the user
  module ErrorHandler
    # Background color for Warning
    WARNING_COLOR = Color.new(90, 90, 0)
    # Background color for Error
    ERROR_COLOR = Color.new(120, 0, 0)
    # Height of a line
    LINE_HEIGHT = 16
    # List of errors that are treaten as warning in the critical section
    WARNINGS = [SyntaxError, NameError, RuntimeError]
    WARNINGS << FMOD::Error if defined?(FMOD)

    module_function

    # Display an error on screen and then raise it
    # @param klass [Class, StandardError] class or description of the error
    # @param message [String] Message of the error
    def error(klass, message)
      klass, exception = klass.class, klass if klass.is_a?(StandardError)
      begin
        init_graphics(ERROR_COLOR, klass, message)
        Text.new(0, @viewport, 8, Graphics.height - LINE_HEIGHT * 2 - 4, 0, LINE_HEIGHT, "Full error log will be stored inside Error.log").load_color(9)
        Graphics.update until Input::Keyboard.press?(Input::Keyboard::Enter)
        dispose
      rescue LiteRGSS::Graphics::StoppedError
        puts 'Window closed...'
      end
      raise exception if exception
      raise klass, message
    end

    # Display a warning on screen and then lets the game continue
    # @param klass [Class] class of the warning
    # @param message [String] Message of the warning
    def warning(klass, message)
      init_graphics(WARNING_COLOR, klass, message)
      Graphics.update until Input::Keyboard.press?(Input::Keyboard::Enter)
      dispose
      Graphics.wait(20)
    rescue LiteRGSS::Graphics::StoppedError
      puts 'Window closed...'
    end

    # Create the graphics of the error
    # @param color [Color] background color
    # @param klass [Class] class used for the warning/error
    # @param message [String] message of the warning/error
    def init_graphics(color, klass, message)
      @background_viewport = Viewport.create(0, 0, Graphics.width, Graphics.height, 999_999)
      @background_viewport.color = color
      @viewport = Viewport.create(0, 0, Graphics.width, Graphics.height, 999_999)
      Text.new(0, @viewport, 0, 0, Graphics.width, LINE_HEIGHT, klass.to_s, 1).load_color(9)
      Text.new(0, @viewport, 8, LINE_HEIGHT * 2, 0, LINE_HEIGHT, message.to_s).load_color(9)
      Text.new(0, @viewport, 8, Graphics.height - LINE_HEIGHT - 4, 0, LINE_HEIGHT, "Press enter to continue...").load_color(9)
      Graphics.transition
      Graphics.wait(20)
    end

    # Dispose the graphics of the error
    def dispose
      @background_viewport.dispose
      @viewport.dispose
    end

    # Function that yields the block and catch the error to show it to the user
    # @param extended_message [String, nil] message added to the error when it's a warning
    def critical_section(extended_message = nil)
      yield
    rescue Exception => exception
      # if WARNINGS.include?(exception.class)
      #   warning(exception.class, exception.message + "\n#{extended_message}")
      # else
      error(exception, exception.message + "\n#{extended_message}")
      # end
    end
  end
end
