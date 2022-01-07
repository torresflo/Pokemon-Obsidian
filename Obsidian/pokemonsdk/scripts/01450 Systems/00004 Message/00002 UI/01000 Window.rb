module UI
  module Message
    class Window < ::Window
      include Layout
      include Transition
      include Draw
      include WaitUserInput
      include PFM::Message::Parser
      include PFM::Message::State

      # Update the window
      def update
        super unless Graphics::FPSBalancer.global.skipping?
        return update_fade_out if done_drawing_message? && $game_temp.message_text.nil?
        return start_drawing if need_to_show_message?
        return wait_user_input if need_to_wait_user_input?

        update_draw
      ensure
        update_fade_in
      end

      private

      # Get the width computer of this window
      # @return [PFM::Message::WidthComputer]
      def width_computer
        if !@width_computer || @width_computer.disposed?
          normal_text = Text.new(current_layout.default_font, viewport, 0, 0, 0, default_line_height, ' ')
          big_text = Text.new(1, viewport, 0, 0, 0, default_line_height * 2, ' ')
          @width_computer = PFM::Message::WidthComputer.new(normal_text, big_text)
        end
        return @width_computer
      end
    end
  end
end
