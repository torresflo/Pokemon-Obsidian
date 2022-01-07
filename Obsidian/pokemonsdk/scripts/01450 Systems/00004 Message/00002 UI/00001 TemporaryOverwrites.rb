module UI
  # Module responsive of holding the whole message ui aspect
  module Message
    # Module implementing the overwrite functionality
    module TemporaryOverwrites
      # @return [Symbol, Array, nil] Overwrite the message position for the current message
      # @note Values can be : :top, :middle, :bottom, :left, :right, [x, y]
      attr_accessor :position_overwrite
      # @return [String, nil] Change the windowskin of the window
      attr_accessor :windowskin_overwrite
      # @return [String, nil] Change the windowskin of the name
      attr_accessor :nameskin_overwrite
      # @return [Integer, nil] Overwrite the number of line for the current message
      attr_accessor :line_number_overwrite
      # @return [Integer, nil] Overwrite the width of the window
      attr_accessor :width_overwrite

      # Initialize the overwrites
      def initialize(...)
        reset_overwrites
        super(...) # Forward any arguments to original super ;)
      end

      # Reset all the overwrite when the message has been shown
      def reset_overwrites
        @position_overwrite = @windowskin_overwrite = @nameskin_overwrite = nil
        @line_number_overwrite = @width_overwrite = nil
      end
    end
  end
end
