module UI
  class TextInput < Text
    CURSOR_DELAY = 60

    attr_reader :activated
    def initialize(font_id, viewport, x, y, width, height, str, **kwargs)
      @padding_left = kwargs.fetch(:padding_left, 0)
      @padding_right = kwargs.fetch(:padding_right, 0)
      @padding_top = kwargs.fetch(:padding_top, 0)
      @padding_bottom = kwargs.fetch(:padding_bottom, 0)
      create_background(viewport, x, y, width, height, kwargs.fetch(:windowskin, UI::Window::DEFAULT_SKIN))
      @counter = 0
      on_desactivate
      super(
        font_id,
        viewport,
        x + @padding_left,
        y + @padding_top,
        width - @padding_left - @padding_right,
        height - @padding_top - @padding_bottom,
        str,
        kwargs.fetch(:align, 0),
        kwargs.fetch(:outlinesize, nil),
        kwargs.fetch(:color_id, nil),
        kwargs.fetch(:size_id, nil)
      )
    end

    def create_background(viewport, x, y, width, height, skin)
      if skin && skin != :transparent
        @background = Window.new(viewport, x, y, width, height, skin: skin)
      end
    end

    def update
      @last_operation = nil
      if Mouse.trigger?(:left)
        if simple_mouse_in?
          on_activate
        else
          on_desactivate
        end
      end

      if @activated
        if (text = Input.get_text)
          update_keyboard(text)
        else
          @counter -= 1
          if @counter <= 0
            hide_cursor
            @counter = CURSOR_DELAY
          elsif @counter == CURSOR_DELAY / 2
            show_cursor
          end
        end
      end
    end

    def update_keyboard(text)
      hide_cursor
      text.split(//).each do |c|
        if c.getbyte(0) == 8
          erase_char
        elsif c.getbyte(0) == 13
          validate
        else
          add_char(c)
        end
      end
    end

    def modified?
      return @last_operation == :erase || @last_operation == :add
    end

    def validated?
      return @last_operation == :validate
    end

    def erase_char
      self.text = text[0..-2]
      @last_operation = :erase
    end

    def validate
      @last_operation = :validate
    end

    def add_char(char)
      self.text = text << char
      @last_operation = :add
    end

    def on_activate
      @activated = true
    end

    def on_desactivate
      @activated = false
      hide_cursor
    end

    def hide_cursor
      erase_char if @cursor_on
      @last_operation = nil
      @cursor_on = false
    end

    def show_cursor
      add_char('_') unless @cursor_on
      @last_operation = nil
      @cursor_on = true
    end
  end
end
