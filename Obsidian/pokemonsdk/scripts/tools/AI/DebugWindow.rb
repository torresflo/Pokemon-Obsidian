# This script purpose is to show a AI Debug Window
#
# To get access to this call :
#   ScriptLoader.load_tool('AI/DebugWindow')
#
# To convert project to YAML (in order to push it to git)
#   Debug::AiWindow.run
module Debug
  # Module handling the AI window
  module AiWindow
    ScriptLoader.load_tool('AI/AIInfo')
    class << self
      # Get the debug window
      # @return [LiteRGSS::DisplayWindow]
      attr_reader :window
      # Get the debug thread
      # @return [Thread]
      attr_reader :thread

      # Run the AiWindow
      def run
        if PSDK_RUNNING_UNDER_MAC
          log_error 'AI Window cannot run on MACOS'
          return
        end
        init_window unless window
      end

      # Function that resets the data
      def reset
        @data = []
        @need_reset = true
      end

      # Function that appends the data
      # @param ai [Battle::AI]
      # @param actions [Array]
      def append(ai, actions)
        @data ||= []
        @data << { ai: ai, actions: actions, turn: $game_temp.battle_turn }
        @need_update = true
      end

      private

      # Create the debug window
      def init_window
        return if window

        @thread = Thread.new do
          @window = LiteRGSS::DisplayWindow.new('AI Debug', 1280, 720, 1, 32, 0, false, false, true)
          @window.on_closed = proc { @thread = nil }
          create_events
          create_ui
          update_window while @thread
        ensure
          @window = nil
        end
      end

      # Update the window event
      def update_window
        @window.update
        sleep(0.1) unless @has_focus

        update_internal
        @was_clicking = @clicking
        sleep(0.01)
      rescue LiteRGSS::DisplayWindow::ClosedWindowError
        log_error('AI debug window closed')
        @thread = nil
      end

      # Internally update the debug window
      def update_internal
        update_graphics if @need_update || @need_reset
        update_scroll if @need_scroll
        update_click if clicking?
      end

      def update_graphics
        @ui.data = [] if @need_reset
        @ui.data = @data
        @ui.update_position
      ensure
        @need_reset = @need_update = false
      end

      def update_scroll
        @wheel = (@wheel * 16).clamp(0, @ui.max_scroll) / 16
        @ui.viewport.oy = @wheel * 16
      ensure
        @need_scroll = false
      end

      def update_click
        mx = @mouse_x
        my = @mouse_y
        clicking_win = @ui.stack.find { |win| win.simple_mouse_in?(mx, my) }
        return unless clicking_win

        clicking_win.toggle
        @ui.update_position
      end

      # Create the UI
      def create_ui
        @ui = AIInfo.new(@window)
      end

      # Create all the events
      def create_events
        @has_focus = true
        @clicking = false
        @was_clicking = false
        @mouse_x = -1000
        @mouse_y = -1000
        @wheel = 0
        @window.on_gained_focus = proc { @has_focus = true }
        @window.on_lost_focus = proc { @has_focus = false }
        @window.on_mouse_button_pressed = proc do |button|
          next if button != Sf::Mouse::LEFT

          @clicking = true
        end
        @window.on_mouse_button_released = proc do |button|
          next if button != Sf::Mouse::LEFT || !@has_focus

          @clicking = false
        end
        @window.on_mouse_moved = proc do |x, y|
          @mouse_x = x
          @mouse_y = y
        end
        @window.on_mouse_wheel_scrolled = proc do |w, d|
          next if w != Sf::Mouse::VerticalWheel || !@has_focus

          @wheel -= d
          @need_scroll = true
        end
      end

      # Tell if the mouse is clicking
      # @return [Boolean]
      def clicking?
        @clicking && !@was_clicking
      end
    end
  end
end

Hooks.register(Battle::AI::Base, :battle_action_for, 'Register AiWindow append') do |hook_binding|
  Debug::AiWindow.append(self, hook_binding.local_variable_get(:actions).compact)
end
Hooks.register(Battle::Scene, :create_ais, 'Register AiWindow reset') { Debug::AiWindow.reset }
