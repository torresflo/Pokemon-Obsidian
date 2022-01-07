module UI
  module Message
    # Module defining how the message transition to the screen
    module Transition
      # @!parse include Layout
      # @!parse include PFM::Message::State

      private

      # Initialize the fade-in operation
      def init_fade_in
        self.contents_opacity = 0 if text_stack.stack.empty?
        self.visible = true
        text_stack.dispose
        init_window
        yield if block_given?
        self.opacity = 255
        transition_duration = (255.0 - contents_opacity) / fade_in_opacity_speed
        @fade_in_animation = Yuki::Animation.scalar(transition_duration, self, :contents_opacity=, contents_opacity, 255)
        @fade_in_animation.parallel_play(Yuki::Animation.opacity_change(transition_duration, sub_stack, contents_opacity, 255))
        @fade_in_animation.start
        @fade_out_animation = nil
      end

      # Update the fade-in animation
      def update_fade_in
        return unless @fade_in_animation

        @fade_in_animation.update
        @fade_in_animation = nil if @fade_in_animation.done?
      end

      # Get the number of opacity unit per second for the fade in
      def fade_in_opacity_speed
        1440
      end

      # Initialize the fade-out operation
      def init_fade_out
        return $game_temp.message_window_showing = false if stay_visible && $game_temp.message_window_showing

        transition_duration = 255.0 / fade_out_opacity_speed
        @fade_out_animation = Yuki::Animation.opacity_change(transition_duration, self, 255, 0)
        @fade_out_animation.parallel_play(Yuki::Animation.opacity_change(transition_duration, sub_stack, 255, 0))
        @fade_out_animation.play_before(Yuki::Animation.send_command_to(self, :finalize_fade_out))
        @fade_out_animation.start
        @fade_in_animation = nil
      end

      # Finalize the fade-out operation
      def finalize_fade_out
        text_stack.dispose
        sub_stack.dispose
        self.visible = false
        self.opacity = 255
        reset_states
      end

      # Update the fade-out animation
      def update_fade_out
        return unless @fade_out_animation

        @fade_out_animation.update
        @fade_out_animation = nil if @fade_out_animation.done?
      end

      # Get the number of opacity unit per second for the fade in
      def fade_out_opacity_speed
        2880
      end

      def init_new_line_transition
        duration = default_line_height.to_f / new_line_transition_speed
        self.pause = true
        @line_transition_animation = create_pre_line_transition_animation
        @line_transition_animation.play_before(Yuki::Animation.scalar(duration, self, :oy=, oy, oy + default_line_height))
        @line_transition_animation.play_before(Yuki::Animation.send_command_to(self, :finalize_new_line_transition))
        @line_transition_animation.start
      end

      def create_pre_line_transition_animation
        return Yuki::Animation.wait_signal do
          if interacting?
            play_decision_se
            self.pause = false
          end
          next !pause
        end
      end

      # Test if the new line transition is done
      # @return [Boolean]
      def new_line_transition_done?
        return true unless @line_transition_animation

        return @line_transition_animation.done?
      end

      # Test if the new line transition is necessary
      # @return [Boolean]
      def need_new_line_transition?
        @text_y >= default_line_height * (line_number - 1)
      end

      # Update the new line transition
      def update_new_line_transition
        return unless @line_transition_animation

        @line_transition_animation.update
        @line_transition_animation = nil if new_line_transition_done?
      end

      # Execute the post process of the new line transition
      def finalize_new_line_transition
        self.oy = 0
        @text_y = default_line_height * (line_number - 1)
        text_stack.each do |text|
          text.y -= default_line_height
          text.dispose if text.y <= -default_line_height
        end
        text_stack.stack.delete_if(&:disposed?)
      end

      # Get the speed of the new line transition
      def new_line_transition_speed
        60
      end
    end
  end
end
