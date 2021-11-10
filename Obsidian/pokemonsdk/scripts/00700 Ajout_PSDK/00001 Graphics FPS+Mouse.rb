module Graphics
  class << self
    # Function that resets the mouse viewport
    def reset_mouse_viewport
      @mouse_fps_viewport&.rect&.set(0, 0, width, height)
    end

    private

    def mouse_fps_create_graphics
      @mouse_fps_viewport = Viewport.new(0, 0, width, height, 999_999)
      unregitser_viewport(@mouse_fps_viewport)
    end
    Hooks.register(Graphics, :init_sprite, 'PSDK Graphics mouse_fps_create_graphics') { mouse_fps_create_graphics }

    def reset_fps_info
      @ruby_time = @current_time = @before_g_update = @last_fps_update_time = Time.new
      reset_gc_time
      reset_ruby_time
      @last_frame_count = Graphics.frame_count
    end
    Hooks.register(Graphics, :frame_reset, 'PSDK Graphics reset_fps_info') { reset_fps_info }

    def update_gc_time(delta_time)
      @gc_accu += delta_time
      @gc_count += 1
    end

    def reset_gc_time
      @gc_count = 0
      @gc_accu = 0.0
    end

    def update_ruby_time(delta_time)
      @ruby_accu += delta_time
      @ruby_count += 1
      @before_g_update = Time.new
    end

    def reset_ruby_time
      @ruby_count = 0
      @ruby_accu = 0.0
    end

    def init_fps_text
      @ingame_fps_text = Text.new(0, @mouse_fps_viewport, 0, 0, w = Graphics.width - 2, 13, '', 2, 1, 9)
      @gpu_fps_text = Text.new(0, @mouse_fps_viewport, 0, 16, w, 13, '', 2, 1, 9)
      @ruby_fps_text = Text.new(0, @mouse_fps_viewport, 0, 32, w, 13, '', 2, 1, 9)
      fps_visibility(PARGV[:"show-fps"])
    end
    Hooks.register(Graphics, :init_sprite, 'PSDK Graphics init_fps_text') { init_fps_text }

    def fps_visibility(visible)
      @ingame_fps_text.visible = @gpu_fps_text.visible = @ruby_fps_text.visible = visible
    end

    def fps_update
      update_ruby_time(Time.new - @ruby_time)
      fps_visibility(!@ingame_fps_text.visible) if !@last_f2 && Sf::Keyboard.press?(Sf::Keyboard::F2)
      @last_f2 = Sf::Keyboard.press?(Sf::Keyboard::F2)
      dt = @current_time - @last_fps_update_time
      if dt >= 1
        @last_fps_update_time = @current_time
        @ingame_fps_text.text = "FPS: #{((Graphics.frame_count - @last_frame_count) / dt).round}" if dt * 10 >= 1
        @last_frame_count = Graphics.frame_count
        @gpu_fps_text.text = "GPU FPS: #{(@gc_count / @gc_accu).round}" unless @gc_count == 0 || @gc_accu == 0
        @ruby_fps_text.text = "Ruby FPS: #{(@ruby_count / @ruby_accu).round}" unless @ruby_count == 0 || @ruby_accu == 0
        reset_gc_time
        reset_ruby_time
      end
    end
    Hooks.register(Graphics, :pre_update_internal, 'PSDK Graphics fps_update') { fps_update }
    Hooks.register(Graphics, :update_freeze, 'PSDK Graphics fps_update') { fps_update }
    Hooks.register(Graphics, :update_transition_internal, 'PSDK Graphics fps_update') { fps_update }
    Hooks.register(Graphics, :post_transition, 'PSDK Graphics reset_fps_info') { reset_fps_info }

    def fps_gpu_update
      update_gc_time(Time.new - @before_g_update)
      @ruby_time = Time.new
    end
    Hooks.register(Graphics, :post_update_internal, 'PSDK Graphics fps_gpu_update') { fps_gpu_update }

    def mouse_create_graphics
      return if (@no_mouse = (PSDK_CONFIG.mouse_disabled && !PARGV[:tags]))

      @mouse = Sprite.new(@mouse_fps_viewport)
      if (mouse_skin = PSDK_CONFIG.mouse_skin) && RPG::Cache.windowskin_exist?(mouse_skin)
        @mouse.bitmap = RPG::Cache.windowskin(mouse_skin)
      end
    end
    Hooks.register(Graphics, :init_sprite, 'PSDK Graphics mouse_create_graphics') { mouse_create_graphics }

    def mouse_update_graphics
      return if @no_mouse

      @mouse.visible = Mouse.in?
      return unless Mouse.moved

      @mouse.set_position(Mouse.x, Mouse.y)
    end
    Hooks.register(Graphics, :pre_update_internal, 'PSDK Graphics mouse_update_graphics') { mouse_update_graphics }
    Hooks.register(Graphics, :update_freeze, 'PSDK Graphics mouse_update_graphics') { mouse_update_graphics }
    Hooks.register(Graphics, :update_transition_internal, 'PSDK Graphics mouse_update_graphics') { mouse_update_graphics }
  end
  reset_fps_info
end
