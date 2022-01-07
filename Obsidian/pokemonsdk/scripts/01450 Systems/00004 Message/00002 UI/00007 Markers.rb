module UI
  module Message
    module Draw
      # Function that process the markers of the message (property modifier)
      def process_marker
        # @type [PFM::Message::Instructions::Marker]
        marker = current_instruction
        marker_method = :"process_marker#{marker.id}"
        send(marker_method, marker) if respond_to?(marker_method)
        @text_x += marker.width
      end

      # Process the color marker
      # @param marker [PFM::Message::Instructions::Marker]
      def process_color_marker(marker)
        @color = translate_color(marker.data.to_i)
      end
      alias process_marker1 process_color_marker

      # Process the wait marker
      # @param marker [PFM::Message::Instructions::Marker]
      def process_wait_marker(marker)
        @wait_animation = Yuki::Animation.wait(marker.data.to_f / 60)
        @wait_animation.start
      end
      alias process_marker2 process_wait_marker

      # Process the style marker
      # @param marker [PFM::Message::Instructions::Marker]
      def process_style_marker(marker)
        style = marker.data.to_i
        @style = @style & 0x04 | style
      end
      alias process_marker3 process_style_marker

      # Process the big text marker
      # @param marker [PFM::Message::Instructions::Marker]
      def process_big_text_marker(marker)
        @style |= 0x04
      end
      alias process_marker4 process_big_text_marker

      # Process the speed marker
      # @param marker [PFM::Message::Instructions::Marker]
      def process_speed_marker(marker)
        @current_speed = marker.data.to_i
      end
      alias process_marker5 process_speed_marker

      # Process the picture marker
      # @param marker [PFM::Message::Instructions::Marker]
      def process_picture_marker(marker)
        filename, cache, dx, dy = marker.data.split(',')
        sprite = Sprite.new(self)
        sprite.set_position(@text_x + dx.to_i, @text_y + dy.to_i)
        sprite.load(filename, cache.to_sym)
        text_stack.push_sprite(sprite)
      end
      alias process_marker15 process_picture_marker
    end
  end
end
