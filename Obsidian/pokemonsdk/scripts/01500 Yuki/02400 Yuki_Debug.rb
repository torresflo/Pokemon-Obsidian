module Yuki
  # Debugguer for PSDK (UI)
  class Debug
    # Create a new Debug instance
    def initialize
      reset_screen unless @viewport
      create_viewport
      create_main_ui
      Graphics.sort_z
    end

    # Update the debug each frame
    def update
      initialize if @viewport.disposed?
      @main_ui.update
    end

    private

    # Create the debugguer viewport
    def create_viewport
      @viewport = Viewport.new(0, 0, 1280, 720)
      @viewport.z = 0
    end

    # Create the main debugger UI
    def create_main_ui
      @main_ui = MainUI.new(@viewport)
    end

    # Reset the game screen in order to make the debugger (set the window size to 1280x720 and the scale to 1)
    def reset_screen
      settings = Graphics.window.settings
      settings[1] = 1280
      settings[2] = 720
      settings[3] = 1
      Graphics.window.settings = settings
      Graphics.reset_mouse_viewport
      PSDK_CONFIG.instance_variable_set(:@window_scale, 1)
    end

    # Self definition
    class << self
      # Create a new debugger instance and delete the related message
      def create_debugger
        @debugger = Debug.new
        Scheduler.__remove_task(:on_update, :any, 'Yuki::Debug', 0)
        Scheduler.add_message(:on_update, :any, 'Yuki::Debug', 0, @debugger, :update)
      end
    end
  end

  unless PSDK_CONFIG.release?
    Scheduler.add_proc(:on_update, :any, 'Yuki::Debug', 0) do
      Debug.create_debugger if Input::Keyboard.press?(Input::Keyboard::F9)
    end
  end
end
