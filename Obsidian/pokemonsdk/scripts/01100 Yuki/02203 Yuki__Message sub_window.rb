module Yuki
  class Message
    private

    # Generate the choice window
    def generate_choice_window
      if $game_temp.choice_max > 0
        @choice_window = ChoiceWindow.generate_for_message(self)
      elsif $game_temp.num_input_digits_max > 0
        @input_number_window = ::GamePlay::InputNumber.new($game_temp.num_input_digits_max)
        if $game_system.message_position != 0
          @input_number_window.y = y - @input_number_window.height - 2
        else
          @input_number_window.y = y + height + 2
        end
        @input_number_window.z = z + 1
        @input_number_window.update
      end
      @drawing_message = false
    end

    # Show a window that tells the player how much money he got
    def show_gold_window
      return if @gold_window

      @gold_window = UI::Window.from_metrics(viewport, 318, 2, 48, 32, position: 'top_right')
      @gold_window.z = z + 1
      @gold_window.sprite_stack.with_surface(0, 0, 44) do
        @gold_window.add_line(0, text_get(11, 6))
        @gold_window.add_line(1, PFM::Text.parse(11, 9, ::PFM::Text::NUM7R => $pokemon_party.money.to_s), 2)
      end

      # Ensure it doesn't shows in the message
      return nil
    end
  end
end
