return unless PSDK_CONFIG.debug?

module InspectElements
  class DisplayDataDetailsField
    SPACE_LABEL_VALUE_PX = 10
    FONT_SIZE = 12
    MARGIN_PX = 6

    def initialize(label, value, on_edit = nil)
      @label_str = label
      @value_str = value.nil? ? '' : value
      @on_edit = on_edit
      @box = nil
      @label_text = nil
      @value_text = nil
      @default_outline_color = nil
      @has_focus = false
      @shapes = []
    end

    def render(viewport, x, y)
      dispose
      @label_text = TextRaw.new(0, viewport, x, y, 0, 0, @label_str, 0, nil, 32, FONT_SIZE)
      @label_text.size = FONT_SIZE
      unless @on_edit.nil?
        @box = Rect.new(x + @label_text.real_width + SPACE_LABEL_VALUE_PX - MARGIN_PX / 2, y - MARGIN_PX / 2 - 2, 200 + MARGIN_PX / 2, FONT_SIZE + MARGIN_PX / 2)
        ShapeDrawer.create_outline_box(@shapes, viewport, @box, 1, Color.new(255, 255, 255))
      end
      @value_text = TextRaw.new(0, viewport, x + @label_text.real_width + SPACE_LABEL_VALUE_PX, y, 0, 0, @value_str, 0, nil, 32, FONT_SIZE)
      @default_outline_color = @value_text.outline_color
      @value_text.size = FONT_SIZE
    end

    def dispose
      @shapes.each(&:dispose)
      @shapes = []
      @value_text&.dispose
      @value_text = nil
      @label_text&.dispose
      @label_text = nil
    end

    def height
      return FONT_SIZE + MARGIN_PX
    end

    def focus_out
      @has_focus = false
      on_focus_change
    end

    def value_text
      return @value_str
    end

    def update_inputs(text)
      return if @on_edit.nil? || !@has_focus
      @value_str = text
      @value_text.text = text unless @value_text.nil?
      @on_edit.(text)
    end

    def update_focus(mouse_x, mouse_y)
      return false if @box.nil?
      @has_focus = @box.x <= mouse_x && @box.x + @box.width >= mouse_x && \
                   @box.y <= mouse_y && @box.y + @box.height >= mouse_y
      on_focus_change
      return @has_focus
    end

    private
    def on_focus_change
      @value_text.outline_color = @has_focus ? Color.new(255, 120, 120) : @default_outline_color
    end
  end
end
