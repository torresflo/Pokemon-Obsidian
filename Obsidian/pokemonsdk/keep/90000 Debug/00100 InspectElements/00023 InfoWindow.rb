return unless PSDK_CONFIG.debug?
module InspectElements
  class InfoWindow
    MAX_SCROLL = 1000

    def initialize
      self_ = self
      @to_refresh = false
      Hooks.register(InspectElements, :selected_elements, 'UI Inspect current selected elements') { self_.refresh }
      Hooks.register(InspectElements, :move_selected_elements, 'UI Inspect move selected elements') { self_.refresh }
    end

    def refresh
      init_window do
        @to_refresh = true
      end
    end

  private
    def init_window
      if @view
        yield if block_given?
        return
      end

      @thread = Thread.new do
        @window = LiteRGSS::DisplayWindow.new('UI Inspector', 960, 480, 1, 32, 20, false, false, true)
        @window.on_closed = proc { @thread = nil }
        create_events
        @model = InfoWindowModel.new()
        @view = InfoWindowView.new(@window, @model)
        @mouse_x = 0
        @mouse_y = 0
        yield if block_given?
        update_window while @thread
      ensure
        @view = nil
        @window = nil
      end
    end

    # Update the window event
    def update_window
      @window.update
      sleep(0.1) unless @has_focus

      update_internal
      sleep(0.01)
    rescue LiteRGSS::DisplayWindow::ClosedWindowError
      log_error('UI Inspector window closed')
      @thread = nil
    end

    # Internally update the debug window
    def update_internal
      update_scroll if @need_scroll
      if @to_refresh
        @model.data = InspectElements.selected_display_datas
        @view.refresh_view
        @to_refresh = false
      end
    end

    def update_scroll
      @wheel = (@wheel * 16).clamp(0, MAX_SCROLL) / 16
      #@ui.viewport.oy = @wheel * 16
    ensure
      @need_scroll = false
    end

    # Create all the events
    def create_events
      @has_focus = true
      @wheel = 0
      @window.on_gained_focus = proc { @has_focus = true }
      @window.on_lost_focus = proc { @has_focus = false }
      @window.on_mouse_wheel_scrolled = proc do |w, d|
        next if w != Sf::Mouse::VerticalWheel || !@has_focus
        @wheel -= d
        @need_scroll = true
      end
      @window.on_text_entered = proc do |text|
        text.split(//).each do |char|
          if char == "\b"
            @model.text_entered.chop!
          elsif char.getbyte(0) >= 32
            @model.text_entered << char
          end
        end
        @view.update_inputs
      end
      @window.on_mouse_button_pressed = proc { |button| @view.update_mouse_click(button, @mouse_x, @mouse_y) }
      @window.on_mouse_moved = proc { |x, y| @mouse_x = x; @mouse_y = y }
    end

  end

  @@info_window = InfoWindow.new
end