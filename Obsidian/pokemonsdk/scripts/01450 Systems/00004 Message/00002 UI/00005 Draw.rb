module UI
  module Message
    # Module defining the drawing methods of messages
    module Draw
      # @!parse include Transition

      private

      # Start to draw the message
      def start_drawing
        parse_and_show_new_message
        init_fade_in { load_sub_layout }
      end

      # Update the text drawing
      def update_draw
        init_text_drawing unless current_instruction
        until need_internal_drawing_update?
          load_next_instruction
          process_instruction
        end
        update_draw_internal
      end

      # Function that tells if the system needs an internal text drawing
      def need_internal_drawing_update?
        return instructions.done_processing? unless current_instruction
        return false if current_instruction.is_a?(PFM::Message::Instructions::Marker) && current_instruction.id != 2
        return !new_line_transition_done? if at_end_of_line?
        return !@text_animation.done? if current_instruction.is_a?(PFM::Message::Instructions::Text)
        return !@wait_animation.done? if @wait_animation

        return true
      end

      # Update the real drawing (animations) of the message
      def update_draw_internal
        return update_new_line_transition if at_end_of_line?

        @wait_animation&.update
        @text_animation.update
      end

      # Process the instructions
      def process_instruction
        return process_marker if current_instruction.is_a?(PFM::Message::Instructions::Marker)
        return start_text_animation if current_instruction.is_a?(PFM::Message::Instructions::Text)
        return process_end_of_line if at_end_of_line?
      end

      # Start the text animation
      def start_text_animation
        sizeid = bigger_text? ? 1 : current_layout.default_font
        text = text_stack.add_text(@text_x, @text_y, 0, default_line_height, current_instruction.text, color: @color, sizeid: sizeid)
        @text_x += current_instruction.width
        load_text_style(text)
        speed = (@current_speed == 0 ? $options&.message_speed : @current_speed) || 1
        text_updater = proc { |v| text.nchar_draw = v.to_i }
        duration = current_instruction.text.size / (speed * character_speed.to_f)
        @text_animation = Yuki::Animation.scalar(duration, text_updater, :call, 0, current_instruction.text.size)
        @text_animation.start
        @wait_animation = nil
      end

      # Test if the player is reading a pannel and skips by moving
      def panel_skip?
        properties.can_skip_message && Input.dir4 != 0 && Input.dir4 != $game_player.direction
      end

      # Process the end of line
      def process_end_of_line
        init_new_line_transition if need_new_line_transition?
        @text_x = initial_text_line_x
        @text_y += default_line_height
      end

      # Load the text style
      # @param text [Text]
      def load_text_style(text)
        text.bold = true if (@style & 1) != 0
        text.italic = true if (@style & 2) != 0
        if bigger_text?
          text.size = Fonts.get_default_size(1) # Font::FONT_SIZE
          text.y += 4
        end
      end

      # Get the character speed (number of character / seconds at lowest speed)
      def character_speed
        return 60
      end

      # Initialize the text drawing
      def init_text_drawing
        set_origin(0, 0)
        @text_y = 0
        @text_x = initial_text_line_x
        @current_speed = 0
        @color = translate_color(get_default_color)
        @style = get_default_style
        @last_instruction = nil
      end

      # Get the initial x position of the text for the current line
      # @return [Integer]
      def initial_text_line_x
        x_offset = @city_sprite && !@city_sprite.disposed? ? @city_sprite.width + default_horizontal_margin : 0
        case properties.align
        when :right
          return message_width - instructions.current_line_width
        when :center
          return x_offset + (message_width - x_offset - instructions.current_line_width) / 2
        else
          return x_offset
        end
      end

      # Translate the color according to the layout configuration
      # @param color [Integer] color to translate
      # @return [Integer] translated color
      def translate_color(color)
        current_layout.color_mapping[color] || color
      end
    end
  end
end
