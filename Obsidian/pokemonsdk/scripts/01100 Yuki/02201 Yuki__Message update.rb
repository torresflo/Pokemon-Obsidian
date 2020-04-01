module Yuki
  class Message
    # Update the Window_Message processing
    def update
      super
      return if update_fade_in
      # Prevent update if the text is already drawing
      return if @drawing_message
      # If we're entering a number
      return if update_input_number
      # If we're choosing an option
      return if update_choice
      # If we have to draw the text
      return if update_text_draw
      # If everything is done but we have to fade the window out
      return if update_fade_out
    end

    private

    # Update the scene and Graphics during the message draw processing. This allow the current scene to display all the animated stuff during the message processing. Make sure its update method returns when message_window.drawing_message is true
    def message_update_processing
      Graphics.update
      $scene&.update
    end

    # Show the fade in during the update
    # @return [Boolean] if the update function skips
    def update_fade_in
      if @fade_in
        update_windowskin if contents_opacity == 0
        self.contents_opacity += 24
        @name_window.contents_opacity += 24
        @city_sprite.opacity += 24 if @city_sprite
        self.face_opacity = opacity
        @fade_in = false if contents_opacity == 255
        return true
      end
      return false
    end

    # Show the Input Number Window
    # @return [Boolean] if the update function skips
    def update_input_number
      if @input_number_window
        @input_number_window.update
        # Validate
        if Input.trigger?(:A)
          $game_system.se_play($data_system.decision_se)
          $game_variables[$game_temp.num_input_variable_id] =
            @input_number_window.number
          $game_map.need_refresh = true
          @input_number_window.dispose
          @input_number_window = nil
          terminate_message
        end
        return true
      end
      return false
    end

    # Skip the choice during update
    # @return [Boolean] if the function skips
    def update_choice_skip
      return false
    end

    # Autoskip condition for the choice
    # @return [Boolean]
    def update_choice_auto_skip
      return @auto_skip
    end

    # Show the choice during update
    # @return [Boolean] if the update function skips
    def update_choice
      if @contents_showing
        return (terminate_message || true) if stop_message_process?
        @choice_window.update if @choice_window
        # If there's no choice
        if $game_temp.choice_max <= 0
          return true if update_choice_skip
          self.pause = true
          if Input.trigger?(:A) or (Mouse.trigger?(:left) and simple_mouse_in?)
            $game_system.se_play($data_system.cursor_se)
            terminate_message
          elsif update_choice_auto_skip || panel_skip?
            terminate_message
          end
        else
          # Cancelation
          if $game_temp.choice_cancel_type > 0 and Input.trigger?(:B)
            $game_system.se_play($data_system.cancel_se)
            $game_temp.choice_proc.call($game_temp.choice_cancel_type - 1)
            terminate_message
          # Validation
          elsif @choice_window.validated?
            $game_system.se_play($data_system.decision_se)
            $game_temp.choice_proc.call(@choice_window.index)
            terminate_message
          end
        end
        return true
      end
      return false
    end

    # Show the message text
    # @return [Boolean] if the update function skips
    def update_text_draw
      if @fade_out == false && !$game_temp.message_text.nil?
        @contents_showing = true
        $game_temp.message_window_showing = true
        @text_stack.dispose
        set_origin(0, 0)
        @fade_in = true
        self.visible = true
        init_window
        @name_window.contents_opacity = self.contents_opacity = 0
        @name_window.opacity = self.opacity = $game_temp.message_text.size == 0 ? 0 : 255
        refresh
        return true
      end
      return false
    end

    # Fade the window message out
    # @return [Boolean] if the update function skips
    def update_fade_out
      if visible and !@stay_visible
        @fade_out = true
        self.face_opacity = (self.opacity -= 48)
        @name_window.opacity -= 48
        @city_sprite.opacity -= 48 if @city_sprite
        if opacity == 0
          @text_stack.dispose
          @face_stack.dispose
          self.visible = false
          @name_window.visible = false
          self.opacity = 255
          @fade_out = false
          $game_temp.message_window_showing = false
        end
      elsif @stay_visible and $game_temp.message_window_showing
        $game_temp.message_window_showing = false
      end
      return false
    end

    # Tell the process method of message to stop processing
    # @return [Boolean]
    def stop_message_process?
      return ($scene.is_a?(Yuki::SoftReset) || $scene.nil?)
    end
  end
end
