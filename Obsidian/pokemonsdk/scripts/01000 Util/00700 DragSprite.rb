module Util
  # Helper that allow sprites to be dragged
  #
  # This helper can manage various sprites and each sprite can have 3 procs :
  #   - start_drag: a proc called with sprite as argument when a sprite starts being dragged
  #   - update_drag: a proc called with sprite as argument each time the mouse move (the sprite is moved automatically)
  #   - end_drag: a proc called when the sprite stops being dragged (usefull to put the sprite back to its regular pos)
  # @note Draggable stuff should respond to simple_mouse_in? and set_position
  class DragSprite
    # Return the sprite that is being dragged
    # @return [#simple_mouse_in?]
    attr_reader :dragging
    # Create the DragSprite interface
    def initialize
      @dragging = nil
      @last_x = 0
      @last_y = 0
      @sprites_to_drag = {}
    end

    # Update the draging process
    def update
      if (sprite = @dragging)
        return end_drag(sprite) unless Mouse.press?(:left)
        update_drag(sprite)
      else
        return unless Mouse.trigger?(:left)
        proc_to_call = nil
        @sprites_to_drag.each do |sprite2drag, procs|
          next unless sprite2drag.simple_mouse_in? # Start dragging only if the mouse is inside
          next if @dragging && @dragging.z >= sprite.z # Fix z-fighting
          proc_to_call = procs[:start_drag]
          # Put the sprite in dragging state
          @dragging = sprite2drag
        end
        if @dragging
          proc_to_call&.call(@dragging)
          # Save the @last_x and @last_y
          @last_x = Mouse.x
          @last_y = Mouse.y
        end
      end
    end

    # Add a sprite to drag
    # @param sprite [#simple_mouse_in?] The sprite to drag
    # @param start_drag [Proc(sprite)] the proc to call when the sprite start being dragged
    # @param update_drag [Proc(sprite)] the proc to call when the sprite is being dragged
    # @param end_drag [Proc(sprite)] the proc to call when the sprite stop being dragged
    def add(sprite, start_drag: nil, update_drag: nil, end_drag: nil)
      @sprites_to_drag[sprite] = { start_drag: start_drag, update_drag: update_drag, end_drag: end_drag }
    end

    private

    # End the drag process
    # @param sprite [#simple_mouse_in?]
    def end_drag(sprite)
      @dragging = nil
      return unless (procs = @sprites_to_drag[sprite])
      procs[:end_drag]&.call(sprite)
    end

    # Update the drag process of a sprite
    # @param sprite [#set_position]
    def update_drag(sprite)
      return @dragging = nil unless (procs = @sprites_to_drag[sprite])
      mx = Mouse.x.clamp(0, Graphics.width - 1)
      my = Mouse.y.clamp(0, Graphics.height - 1)
      dx = mx - @last_x
      dy = my - @last_y
      @last_x = mx
      @last_y = my
      return if dx == 0 && dy == 0
      sprite.set_position(sprite.x + dx, sprite.y + dy)
      procs[:update_drag]&.call(sprite)
    end
  end
end
