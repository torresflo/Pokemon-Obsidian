return unless PSDK_CONFIG.debug?

module InspectElements
  class DisplayDataNode
    attr_reader :box
    attr_reader :original_box
    attr_reader :element

    @shapes = []
    @box = nil
    @original_pos = nil
    @element = nil
    @parent = nil
    @children = []
    @default_color = nil
    @selected = false
    @dirty = false
    @color = nil

    def initialize(parent, element, color)
      @element = element
      @parent = parent
      @children = []
      @shapes = []
      @default_color = color
      @color = color
      self.color=(@default_color)
      @parent&.register_stack_element(self)
      # Only register / unregister the roots
      InspectElements.register_display_data(self) if @parent.nil?
    end

    def hide
      if @element&.respond_to?(:visible) && @element&.visible
        @children.each(&:hide)
      end
      @element&.visible = false if @element&.respond_to?(:visible)
      destroy_shapes
      update_box_internal
    end

    def on_dispose
      # Only register / unregister the roots
      InspectElements.unregister_display_data(self) if @parent.nil?
      destroy_shapes
      @element = nil
      @children = []
      @parent&.unregister_stack_element(self)
    end

    def move(offset_x, offset_y)
      return if @element.nil?
      if @element.is_a?(Viewport)
        @element.rect.x += offset_x
        @element.rect.y += offset_y
      else
        @element.x += offset_x
        @element.y += offset_y
      end
      @shapes.each do |shape|
        shape.x += offset_x
        shape.y += offset_y
      end
      update_box_internal
    end

    def z
      return @element&.z
    end

    def to_s
      return @element&.to_s
    end

    def selected?
      return @selected
    end

    def draw
      destroy_shapes
      @box = build_box_element
      unless @box.nil?
        ShapeDrawer.create_annotated_outline_box(@shapes, @element.is_a?(Viewport) ? @element : @element.viewport, @box, 1, @color)
        # Stores the original box at first draw
        @original_box = @box.clone unless @dirty
      end
      @children.sort_by!(&:z)
      @children.each(&:draw)

      update_shape_text
    end

    def destroy_shapes
      @children.each(&:destroy_shapes)
      @shapes.each do |shape|
        shape.dispose
      end
      @shapes = []
    end

    def select
      self.color=(Color.new(255, 255, 255))
      if @shapes.length > 0
        @shapes.first.visible = true
        @shapes.last.visible = true
      end
      @selected = true
    end

    def unselect
      self.color=(@default_color) unless @default_color.nil?
      if @shapes.length > 0
        @shapes.first.visible = false
        @shapes.last.visible = false
      end
      @selected = false
    end

    def for_data_at(pos_x, pos_y, unselect_proc, &block)
      return false if !block_given? || @box.nil?
      check_x = pos_x >= @box.x && pos_x <= @box.x + @box.width
      check_y = pos_y >= @box.y && pos_y <= @box.y + @box.height
      child_marked = false
      intersect = check_x && check_y
      if intersect
        @children.reverse_each do |child|
          child_marked |= child.for_data_at(pos_x - @box.x, pos_y - @box.y, unselect_proc, &block)
        end
        if child_marked
          unselect_proc.(self) unless unselect_proc.nil?
        else
          yield(self)
        end
        return intersect
      end
      unselect_proc.(self) unless unselect_proc.nil?
      return intersect
    end

    def register_stack_element(child)
      @children << child
    end

    def unregister_stack_element(child)
      @children.delete(child)
    end

    def update_box_internal
      @box = build_box_element
      update_shape_text
      @dirty = @box != @original_box
      @children.each(&:update_box_internal)
    end

  private
    def update_shape_text
      return unless @shapes.length > 0 && !@box.nil? && @shapes[0].visible
      if !@original_box.nil? && (@original_box.x != @box.x || @original_box.y != @box.y)
        # Because we modified the UI, we force the shape to show it by displaying the difference in coords
        @shapes[0].text = "#{@original_box.x - @box.x}; #{@original_box.y - @box.y}"
        @shapes[0].fill_color = Color.new(255, 255, 100)
      elsif !@parent&.original_box.nil?
        @shapes[0].text = "#{@box.x - @parent.original_box.x}; #{@box.y - @parent.original_box.y}"
        @shapes[0].fill_color = Color.new(100, 200, 255)
      end
    end

    def color=(color)
      @color = color
      @shapes.each_with_index do |shape, index|
        next if index == 0 || index == @shapes.length - 1
        shape.color = color
      end
    end

    def build_box_element
      return nil unless @element.visible
      if @element.is_a?(Viewport)
        return @element.rect
      elsif @element.is_a?(Window)
        # Window
        return Rect.new(@element.x, @element.y, @element.width, @element.height)
      elsif @element.is_a?(Sprite) && !@element.is_a?(Plane)
        # Sprite
        return Rect.new(@element.x - @element.ox, @element.y - @element.oy, @element.width, @element.height)
      elsif @element.is_a?(Text)
        # Text
        offset_x = 0
        case @element.align
        when 1
          offset_x = -@element.real_width/2
        when 2
          offset_x = @element.real_width
        end
        return Rect.new(@element.x - offset_x, @element.y, @element.real_width, @element.size)
      end
      return nil
    end
  end
end
