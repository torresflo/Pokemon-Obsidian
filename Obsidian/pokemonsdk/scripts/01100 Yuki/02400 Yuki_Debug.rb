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
      ::Config.instance_eval do
        remove_const :FullScreen
        const_set :FullScreen, false
        remove_const :ScreenScale
        const_set :ScreenScale, 1
      end
      Graphics.resize_screen(1280, 720)
      # Little trick to reset the Viewport view to the new Window size
      Graphics.instance_eval do
        @__elementtable.each { |element| element.rect.width = element.rect.width if element.is_a?(Viewport) }
      end
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
