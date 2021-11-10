return unless PSDK_CONFIG.debug?

module InspectElements
  DEV_MENU_INSPECT_TIMER_SECONDS = 0.3

  module_function

  def setup_hotkeys
    is_reloading_show = false
    Scheduler.__remove_task(:on_update, :any, 'Inspect Stack elements scripts', 0)
    Scheduler.add_proc(:on_update, :any, 'Inspect Stack elements scripts', 0) do
      if !is_reloading_show && Input::Keyboard.press?(Input::Keyboard::F6)
        is_reloading_show = true
        display_show
        # Avoid F6 spamming
        timer = Thread.new { sleep DEV_MENU_INSPECT_TIMER_SECONDS; is_reloading_show = false }
      end

      if Input::Keyboard.press?(Input::Keyboard::F7)
        display_clear_screen
      end

      if Input::Keyboard.press?(Input::Keyboard::Tab)
        display_select_at(Mouse.x, Mouse.y)
      end

      offset_x = 0
      offset_y = 0
      offset_x -= 1 if Input::Keyboard.press?(Input::Keyboard::Left)
      offset_x += 1 if Input::Keyboard.press?(Input::Keyboard::Right)
      offset_y -= 1 if Input::Keyboard.press?(Input::Keyboard::Up)
      offset_y += 1 if Input::Keyboard.press?(Input::Keyboard::Down)
      display_move_selected(offset_x, offset_y) if offset_x != 0 || offset_y != 0

      if Input::Keyboard.press?(Input::Keyboard::Delete)
        display_hide_selected
      end
    end
  end

  setup_hotkeys
end
