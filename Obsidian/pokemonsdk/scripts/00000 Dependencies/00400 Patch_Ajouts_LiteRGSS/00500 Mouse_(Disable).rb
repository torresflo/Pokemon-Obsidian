if PSDK_CONFIG.mouse_disabled &&
   !(PARGV[:tags] || PARGV[:worldmap] || PARGV[:"animation-editor"])
  # Module helps to get the mouse informations
  module Mouse
    module_function

    # X position of the mouse on the InGame screen
    # @return [Integer]
    def x
      return -256
    end

    # Y position of the mouse on the InGame Screen
    # @return [Integer]
    def y
      return -256
    end

    # Wheel position of the mouse
    # @return [Integer]
    def wheel
      return 0
    end

    # If a key is being pressed on the mouse
    # @return [Boolean]
    def press?(*)
      return false
    end

    # If a key has been pressed on the mouse
    # @return [Boolean]
    def trigger?(*)
      return false
    end

    # If a key has been released on the mouse
    # @return [Boolean]
    def released?(*)
      return false
    end
  end
end

class << Mouse
  # @return [Boolean] Telling if the mouse moved
  attr_accessor :moved
end
