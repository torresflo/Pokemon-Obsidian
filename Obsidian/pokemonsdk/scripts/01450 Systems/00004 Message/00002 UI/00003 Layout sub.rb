# frozen_string_literal: true

module UI
  module Message
    module Layout
      # @!parse include PFM::Message::State

      # Generate the choice window
      def generate_choice_window
        @choice_window = Yuki::ChoiceWindow.generate_for_message(self)
      end

      # Generate the number input window
      def generate_input_number_window
        @input_number_window = UI::InputNumber.new(viewport, $game_temp.num_input_digits_max)
        if $game_system.message_position == 0
          @input_number_window.y = y + height + 2
        else
          @input_number_window.y = y - @input_number_window.height - 2
        end
        @input_number_window.z = z + 1
        @input_number_window.max = $game_temp.num_input_start if $game_temp.num_input_start > 0
        @input_number_window.update
      end

      # Show a window that tells the player how much money he got
      def show_gold_window
        return if @gold_window && !@gold_window.disposed?

        @gold_window = UI::Window.from_metrics(viewport, 318, 2, 48, 32, position: 'top_right')
        @gold_window.z = z + 1
        @gold_window.sprite_stack.with_surface(0, 0, 44) do
          @gold_window.add_line(0, text_get(11, 6))
          @gold_window.add_line(1, PFM::Text.parse(11, 9, ::PFM::Text::NUM7R => PFM.game_state.money.to_s), 2)
        end
        @sub_stack.push_sprite(@gold_window)
      end

      # Function that test if sub window can be updated (choice / number)
      # @return [Boolean]
      def can_sub_window_be_updated?
        !Graphics::FPSBalancer.global.skipping? || Input.trigger?(:A) || Input.trigger?(:B) ||
          Input.repeat?(:DOWN) || Input.repeat?(:UP) || Input.repeat?(:RIGHT) || Input.repeat?(:LEFT)
      end

      # Show the name window
      def show_name_window
        return if @name_window && !@name_window.disposed?

        wb = current_window_builder
        name_y = y + (current_position == :top ? height + default_vertical_margin : (-wb[5] - wb[-1] - default_line_height - default_vertical_margin))
        text_width = width_computer.normal_width(properties.name)
        @name_window = UI::Window.from_metrics(viewport, x, name_y, text_width, default_line_height, skin: current_name_windowskin)
        @sub_stack.push_sprite(Text.new(0, @name_window, 0, -Text::Util::FOY, 0, default_line_height, properties.name))
        @sub_stack.push_sprite(@name_window)
      end

      # Show the city image
      def show_city_image
        @city_sprite = Sprite.new(viewport)
        @city_sprite.z = z + 1
        @city_sprite.load(properties.city_filename, :picture)
        @city_sprite.set_position(x + (wb = current_window_builder)[4], y + wb[5])
        @sub_stack.push_sprite(@city_sprite)
      end

      # Show a face
      # @param face [PFM::Message::Properties::Face]
      def show_face(face)
        sprite = Sprite.new(viewport)
        sprite.load(face.name, :battler)
        sprite.set_position(parse_speaker_position(face.position), face_speaker_y)
        sprite.set_origin(sprite.width / 2, sprite.height)
        def sprite.opacity=(v)
          return @opacity = v unless @opacity

          super(v * @opacity / 255)
        end
        sprite.opacity = face.opacity
        sprite.mirror = face.mirror
        @sub_stack.push_sprite(sprite)
      end

      # Function that translate the position to a coordinate
      # @param position [Integer] position given by the maker
      # @return [Integer] the x position
      def parse_speaker_position(position)
        position = viewport.rect.width + position if position < 0
        return position
      end

      # Return the face_speaker y position
      # @return [Integer]
      def face_speaker_y
        return viewport.rect.height # if position == :top
        # y
      end

      # Load the sub layout based on properties
      def load_sub_layout
        @sub_stack.dispose
        properties.faces.each { |face| show_face(face) }
        show_name_window if properties.name
        show_city_image if properties.city_filename
        show_gold_window if properties.show_gold_window
        properties.process_look_to
        viewport.sort_z
      end
    end
  end
end
