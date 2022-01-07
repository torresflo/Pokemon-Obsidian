module GamePlay
  class MiningGame
    private

    # Check if the mouse was used to click on a tile or on a button
    # @param _moved [Boolean] if the mouse moved
    # @return [Boolean]
    def update_mouse(_moved)
      return false unless Mouse.moved || Mouse.trigger?(:left) # Safety preventing index conflict
      return false unless @ui_state == :mouse

      @tiles_stack.tile_array.each_with_index do |line, index_y|
        line.each_with_index do |tile, index_x|
          next unless tile.simple_mouse_in?

          if Mouse.trigger?(:left)
            tile_click(index_x, index_y)
            return true
          end
        end
      end
      @tool_buttons.buttons.each_with_index do |button, index|
        next unless button.simple_mouse_in?

        if Mouse.trigger?(:left)
          @current_tool = @tool_buttons.change_buttons_state(index)
          return true
        end
      end
      return false
    end
  end
end
