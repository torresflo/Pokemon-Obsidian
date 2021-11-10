module GamePlay
  class Load
    # CTRL button actions
    ACTIONS = %i[action_a action_a action_a action_b]

    def update_inputs
      return false unless @signs.first.done?

      rotate_signs if @mode == :rotating
      if Input.trigger?(:A)
        action_a
      elsif Input.trigger?(:B)
        action_b
      elsif Input.repeat?(:LEFT)
        action_left
      elsif Input.repeat?(:RIGHT)
        action_right
      end
    end

    def update_mouse(*)
      if Mouse.wheel_delta > 0
        action_left
      elsif Mouse.wheel_delta < 0
        action_right
      elsif Mouse.trigger?(:LEFT) && @signs[1].simple_mouse_in?
        action_a
      elsif Mouse.trigger?(:RIGHT)
        action_b
      else
        update_mouse_ctrl_buttons(@base_ui.ctrl, ACTIONS)
        return
      end
      Mouse.wheel = 0
    end

    private

    def rotate_signs
      @signs.rotate!(@signs.first.visual_index == 0 ? -1 : 1)
      load_sign_data
      @mode = :waiting_input
    end

    def action_left
      return if @index == 0

      play_cursor_se
      @index -= 1
      @mode = :rotating
      @signs.each do |sign|
        sign.move_to_visual_index(sign.visual_index == 3 ? -1 : sign.visual_index + 1)
      end
    end

    def action_right
      return if @index >= @all_saves.size
      return if !Configs.save_config.unlimited_saves? && (@index + 1) >= Configs.save_config.maximum_save_count

      play_cursor_se
      @index += 1
      @mode = :rotating
      @signs.each do |sign|
        sign.move_to_visual_index(sign.visual_index == -1 ? 3 : sign.visual_index - 1)
      end
    end

    def action_b
      play_decision_se
      @running = false
      $scene = Scheduler.get_boot_scene
    end

    def action_a
      play_decision_se
      Save.save_index = Configs.save_config.single_save? ? 0 : @index + 1
      if @index < @all_saves.size && @all_saves[@index]
        load_game
      else
        create_new_game
      end
    end
  end
end
