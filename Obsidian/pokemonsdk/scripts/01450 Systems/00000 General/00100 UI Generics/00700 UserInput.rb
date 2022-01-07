module UI
  # Class responsive of dealing with Keyboard user input (for search or other stuff like that).
  #
  # This is a Text that takes the same parameters as regular texts but has a `init` method allowing
  # to tell how much characters are allowed, what kind of character to use for empty chars and give the handler
  #
  # Example
  #   ```ruby
  #     @search = add_text(x, y, width, height, 'default_text', type: UI::UserInput)
  #     @search.init(25, '', on_new_char: method(:add_char), on_remove_char: method(:del_char))
  #     # ...
  #     def add_char(complete_string, new_char)
  #     # ...
  #     def del_char(complete_string, removed_char)
  #   ```
  class UserInput < ::Text
    # Code used to detect CTRL+V
    CTRL_V = "\u0016"
    # Code used to detect backspace
    BACK = "\b"
    # Init the user input
    # @param max_size [Integer] maximum size of the user input
    # @param empty_char [String] char used to replace all the remaining empty char
    # @param on_new_char [#call, nil] called when a char is added
    # @param on_remove_char [#call, nil] called when a char is removed
    def init(max_size, empty_char = '_', on_new_char: nil, on_remove_char: nil)
      @current_text = ''
      @max_size = max_size.abs
      @empty_char = empty_char
      @on_new_char = on_new_char
      @on_remove_char = on_remove_char
      load_text(text)
    end

    # Update the user input
    def update
      return unless @max_size
      return unless (text = Input.get_text)
      load_text(text)
    end

    private

    # Load the text from external source
    # @param text [String] external source
    def load_text(text)
      text = text.dup
      text.sub!(CTRL_V) { Yuki.get_clipboard }
      text.split(//).each do |char|
        if char == BACK
          last_char = @current_text[-1]
          @current_text.chop!
          @on_remove_char&.call(@current_text, last_char)
        elsif char.getbyte(0) >= 32 && @current_text.size < @max_size
          @current_text << char
          @on_new_char&.call(@current_text, char)
        end
      end
      self.text = (@empty_char.size > 0 ? @current_text.ljust(@max_size, @empty_char) : @current_text)
    end
  end
end
