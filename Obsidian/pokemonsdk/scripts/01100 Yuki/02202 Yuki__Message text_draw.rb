module Yuki
  class Message
    # Anti-slash character
    S_sl = "\\"
    # Protected Anti-Slash (special_command processing)
    S_000 = "\000"
    # Color change char
    S_001 = "\001"
    # Wait char
    S_002 = "\x02"
    # New Line char (add line_height to y)
    S_n = "\n"

    private

    # Generate the list of text refresh instruction
    # @param text [String]
    def generate_text_instructions(text)
      max_width = width - window_builder[4] - window_builder[-2]
      markers = []
      text.gsub!(/([\x01-\x0F])\[([0-9]+)\]/) { markers << [$1.getbyte(0), $2.to_i]; S_000 }
      texts = text.split(S_000)
      if texts.first.empty?
        texts.shift
      else # when blabla\c[1]blabla
        markers.insert(0, [1, get_default_color])
      end
      instructions = []
      x = origin_x
      texts.each { |sub_text| x = adjust_text_lines(x, max_width, sub_text, instructions) }
      @markers = markers
      @instructions = instructions
    end

    # Adjust the line of text by adding instructions to the stack
    # @param x [Integer] start x
    # @param max_width [Integer] width of the line
    # @param text [String] the text to display
    # @param instructions [Array] the instructions
    # @param no_split [Boolean] indicate the function calculates the line
    # @return [Integer] the new x
    # TODO : Clean this function (split in multiple fuction, remove the ; thing)
    def adjust_text_lines(x, max_width, text, instructions, no_split = false)
      if no_split
        sw = @text_sample.text_width(' ')
        sw = 1 if sw == 0
        words = text.getbyte(0) != 32 ? '' : ' '
        text.split(' ').each do |word|
          w = @text_sample.text_width(word)
          if x + w > max_width
            x = origin_x
            instructions << words unless words.empty?
            instructions << :new_line
            words = ''
          end
          words << word << ' '
          x += (w + sw)
        end
        x -= sw if text.getbyte(-1) != 32 && words.rstrip!
        instructions << words unless words.empty?
      else
        arr = []
        instructions << arr
        return x if text.empty?
        return (arr << :new_line; x) if text == S_n

        text.split(S_n).each_with_index do |line, i|
          (arr << :new_line; x = 0) if i > 0
          x = adjust_text_lines(x, max_width, line, arr, true)
        end
      end
      return x
    end

    # Progress in the text display
    # @param text [LiteRGSS::Text] the text element
    # @param str [String] the text shown
    # @param counter [Integer] the counter
    # @return [Integer] the new counter, if counter == -1, the user requested to skip the progress thing
    def progress(text, str, counter)
      speed = (@current_speed == 0 ? $options&.message_speed : @current_speed) || 1
      text.nchar_draw = 0
      text.opacity = contents_opacity
      until text.nchar_draw >= str.size
        break if stop_message_process?

        text.nchar_draw += 1
        counter += 1
        if Input.trigger?(:A) || (Mouse.trigger?(:left) && simple_mouse_in?) || panel_skip? # Skip request
          text.nchar_draw = str.size
          return -1
        end
        if counter >= speed
          message_update_processing
          counter = 0
        end
      end
      return counter
    end

    # Perform a line transition
    def line_transition
      default_line_height.times do
        return if stop_message_process?

        self.oy += 1
        @city_sprite&.y += 1
        message_update_processing
      end
    end

    # Get the text style code
    # @param str [String] text style b = Bold, i = Italic, r = Reset
    # @return [Integer] the style integer
    def get_style_code(str)
      return 0 if str.include?('r')

      code = str.include?('b') ? 1 : 0
      code |= str.include?('i') ? 2 : 0
      return code
    end

    # Set the text style
    # @param text [LiteRGSS::Text]
    # @param style [Integer] 1 = bold, 2 = italic, 3 = bold & italic
    def set_text_style(text, style)
      text.bold = true if (style & 1) != 0
      text.italic = true if (style & 2) != 0
      if bigger_text?
        @text.size = Font::FONT_SIZE
        @text.y += 4
      end
    end

    # Replace the message user code to message specific code in order to generate the right marker
    # @param text [String] text containing the message codes
    # @return [String]
    def replace_message_codes(text)
      text = ::PFM::Text.parse_string_for_messages(text)
      text.gsub!(/\\[Gg]/) { show_gold_window }
      text.gsub!(/\[WAIT ([0-9]+)\]/, "\x02[\\1]")
      text.gsub!(/\\[Cc]\[([0-9]+)\]/, "\x01[\\1]")
      text.gsub!(/\\[Ss]\[([bir]+)\]/) { "\x03[#{get_style_code($1)}]" }
      text.gsub!(/\\\^/) { "\x04[0]" }
      text.gsub!(/\\spd\[([0-9]+)\]/, "\x05[\\1]")
      text.sub!(/\:\[([^\]]+)\]\:/) { parse_speaker($1) }
      text.gsub!(S_000, S_sl)
      return text
    end

    # Translate the color according to the layout configuration
    # @param color [Integer] color to translate
    # @return [Integer] translated color
    def translate_color(color)
      current_layout.color_mapping[color] || color
    end

    # Draw the message
    # @param lineheight [Integer] height of the line
    def refresh(lineheight = default_line_height)
      return unless $game_temp.message_text

      @drawing_message = true
      set_origin(0, 0)
      @can_skip_message = false
      text = replace_message_codes($game_temp.message_text)
      @last_text = $game_temp.message_text
      @x = origin_x
      @y = 0
      @current_speed = 0
      @color = translate_color(get_default_color)
      @style = get_default_style
      generate_text_instructions(text)
      refresh_internal(lineheight)
      generate_choice_window
    end

    # Internally draw the message
    # @param lineheight [Integer] height of the line
    def refresh_internal(lineheight)
      skip = false
      counter = 0
      @instructions.each_with_index do |instr_arr, i|
        marker = @markers[i]
        call_marker_action(marker) if marker
        instr_arr.each do |instr|
          break if stop_message_process?

          if instr == :new_line
            @x = origin_x
            @y += lineheight
            if @y >= lineheight * line_number
              wait_user_input
              line_transition
            end
            next
          end
          @text = @text_stack.add_text(@x, @y, 1, lineheight, instr, 0, color: @color)
          set_text_style(@text, @style)
          @x += @text.real_width
          counter = progress(@text, instr, counter) unless skip
          skip = (counter == -1 || Input.trigger?(:A) || panel_skip?)
        end
      end
      @text = nil
    end

    # Return the origin x for the current message
    def origin_x
      @city_sprite ? @city_sprite.width : 0
    end

    # Test if the player is reading a pannel and skips by moving
    def panel_skip?
      @can_skip_message && Input.dir4 != 0 && Input.dir4 != $game_player.direction
    end

    # Call a marker action
    # @param maker [Array]
    def call_marker_action(marker)
      sym = :"execute_marker_#{marker.first}"
      send(sym, marker)
    end

    # Change the color
    # @param maker [Array]
    def execute_marker_1(marker)
      @color = translate_color(marker.last % GameData::Colors::COLOR_COUNT)
      marker_fix_x
    end

    # Try to fix the x error introduced with markers
    def marker_fix_x
      @x += 1 if @text && @text.text.getbyte(-1) != 32
    end

    # Wait
    # @param maker [Array]
    def execute_marker_2(marker)
      marker.last.times { message_update_processing }
      marker_fix_x
    end

    # Style
    # @param maker [Array]
    def execute_marker_3(marker)
      @style = marker.last
      marker_fix_x
    end

    # Bigger text
    # @param _maker [Array]
    def execute_marker_4(_marker)
      @style ^= 0x04
    end

    # Change the text speed
    # @param marker [Array]
    def execute_marker_5(marker)
      @current_speed = marker.last
    end
  end
end
