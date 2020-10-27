module Yuki
  # Display a choice Window
  # @author Nuri Yuri
  class ChoiceWindow < LiteRGSS::Window
    # Array of choice colors
    # @return [Array<Integer>]
    attr_accessor :colors
    # Current choix (0~choice_max-1)
    # @return [Integer]
    attr_accessor :index
    # Name of the cursor in Graphics/Windowskins/
    CursorSkin = 'Cursor'
    # Name of the windowskin in Graphics/Windowskins/
    WINDOW_SKIN = 'Message'
    # Number of choice shown until a relative display is generated
    MaxChoice = 9
    # Index that tells the system to scroll up or down everychoice (relative display)
    DeltaChoice = (MaxChoice / 2.0).round
    # Create a new Window_Choice with the right parameters
    # @param width [Integer, nil] width of the window; if nil => automatically calculated
    # @param choices [Array<String>] list of choices
    # @param viewport [Viewport, nil] viewport in which the window is displayed
    def initialize(width, choices, viewport = nil)
      super(viewport)
      @texts = UI::SpriteStack.new(self)
      @choices = choices
      @colors = Array.new(@choices.size, get_default_color)
      @index = $game_temp ? $game_temp.choice_start - 1 : 0
      @index = 0 if @index >= choices.size || @index < 0
      lock
      self.width = width if width
      @autocalc_width = !width
      self.cursorskin = RPG::Cache.windowskin(CursorSkin)
      define_cursor_rect
      self.windowskin = RPG::Cache.windowskin(current_windowskin)
      # Should be set at the end of the important ressources loading
      self.window_builder = current_window_builder
      self.active = true
      unlock
      @my = Mouse.y
    end

    # Retrieve the current layout configuration
    # @return [ScriptLoader::PSDKConfig::LayoutConfig::Choice]
    def current_layout
      config = PSDK_CONFIG.layout.choices
      return config[$scene.class.to_s] || config[:any]
    end

    # Update the choice, if player hit up or down the choice index changes
    def update
      if Input.repeat?(:DOWN)
        update_cursor_down
      elsif Input.repeat?(:UP)
        update_cursor_up
      elsif @my != Mouse.y || Mouse.wheel != 0
        update_mouse
      end
      super
    end

    # Translate the color according to the layout configuration
    # @param color [Integer] color to translate
    # @return [Integer] translated color
    def translate_color(color)
      current_layout.color_mapping[color] || color
    end

    # Return the default height of a text line
    # @return [Integer]
    def default_line_height
      Fonts.line_height(current_layout.default_font)
    end

    # Return the default text color
    # @return [Integer]
    def default_color
      return translate_color(current_layout.default_color)
    end
    alias get_default_color default_color

    # Return the disable text color
    # @return [Integer]
    def disable_color
      return translate_color(7)
    end
    alias get_disable_color disable_color

    # Update the mouse action
    def update_mouse
      @my = Mouse.y
      unless Mouse.wheel == 0
        Mouse.wheel > 0 ? update_cursor_up : update_cursor_down
        return Mouse.wheel = 0
      end
      return unless simple_mouse_in?

      @texts.stack.each_with_index do |text, i|
        next unless text.simple_mouse_in?

        if @index < i
          update_cursor_down while @index < i
        elsif @index > i
          update_cursor_up while @index > i
        end
        break
      end
    end

    # Update the choice display when player hit UP
    def update_cursor_up
      if @index == 0
        (@choices.size - 1).times { update_cursor_down }
        return
      end
      if @choices.size > MaxChoice
        self.oy -= default_line_height unless @index < DeltaChoice || @index > (@choices.size - DeltaChoice)
      end
      cursor_rect.y -= default_line_height
      @index -= 1
    end

    # Update the choice display when player hit DOWN
    def update_cursor_down
      @index += 1
      if @index >= @choices.size
        @index -= 1
        update_cursor_up until @index == 0
        return
      end
      if @choices.size > MaxChoice
        self.oy += default_line_height unless @index < DeltaChoice || @index > (@choices.size - DeltaChoice)
      end
      cursor_rect.y += default_line_height
    end

    # Change the window builder and rebuild the window
    # @param builder [Array] The new window builder
    def window_builder=(builder)
      super
      build_window
    end

    # Build the window : update the height of the window and draw the options
    def build_window
      max = @choices.size
      max = MaxChoice if max > MaxChoice
      self.height = max * default_line_height + window_builder[5] + window_builder[-1]
      refresh
    end

    # Draw the options
    def refresh
      max_width = 0
      @texts.dispose
      @choices.each_index do |i|
        text = PFM::Text.parse_string_for_messages(@choices[i]).dup
        text.gsub!(/\\[Cc]\[([0-9]+)\]/) do
          @colors[i] = translate_color($1.to_i)
          next(nil)
        end
        text.gsub!(/\\d\[(.*),(.*)\]/) { $daycare.parse_poke($1.to_i, $2.to_i) }
        real_width = add_choice_text(text, i)
        max_width = real_width if max_width < real_width
      end
      self.width = max_width + window_builder[4] + window_builder[-2] + cursor_rect.width + cursor_rect.x if @autocalc_width
      self.width += 10 if current_windowskin[0, 2].casecmp?('m_') #SkinHGSS
      @texts.stack.each { |text| text.width = max_width }
    end

    # Function that adds a choice text and manage various thing like getting the actual width of the text
    # @param text [String]
    # @param i [Integer] index in the loop
    # @return [Integer] the real width of the text
    def add_choice_text(text, i)
      if (captures = text.match(/(.+) (\$[0-9]+|[0-9]+\$)$/)&.captures)
        text_obj1 = @texts.add_text(cursor_rect.width + cursor_rect.x, i * default_line_height, 0, default_line_height,
                                    captures.first, color: @colors[i])
        text_obj2 = @texts.add_text(cursor_rect.width + cursor_rect.x, i * default_line_height, 0, default_line_height,
                                    captures.last, 2, color: translate_color(get_default_color))
        return text_obj1.real_width + text_obj2.real_width + 2 * Fonts.line_height(current_layout.default_font)
      end
      text_obj = @texts.add_text(cursor_rect.width + cursor_rect.x, i * default_line_height, 0, default_line_height,
                                 text, color: @colors[i])
      return text_obj.real_width
    end

    # Define the cursor rect
    def define_cursor_rect
      cursor_rect.set(-4, @index * default_line_height, cursorskin.width, cursorskin.height)
    end

    # Tells the choice is done
    # @return [Boolean]
    def validated?
      return (Input.trigger?(:A) || (Mouse.trigger?(:left) && simple_mouse_in?))
    end

    # Return the default horizontal margin
    # @return [Integer]
    def default_horizontal_margin
      return current_layout.border_spacing
    end

    # Return the default vertical margin
    # @return [Integer]
    def default_vertical_margin
      return current_layout.border_spacing
    end

    # Retrieve the current windowskin
    # @return [String]
    def current_windowskin
      current_layout.windowskin || $game_system.windowskin_name
    end

    # Retrieve the current window_builder
    # @return [Array]
    def current_window_builder
      return UI::Window.window_builder(current_windowskin)
    end

    # Function that creates a new ChoiceWindow for Yuki::Message
    # @param window [Game_Window] a window that has the right window_builder (to calculate the width)
    # @return [Window_Choice] the choice window.
    def self.generate_for_message(window)
      choice_window = new(nil, $game_temp.choices, window.viewport)
      choice_window.z = window.z + 1
      if $game_switches[::Yuki::Sw::MSG_ChoiceOnTop]
        choice_window.set_position(choice_window.default_horizontal_margin, choice_window.default_vertical_margin)
      else
        choice_window.x = window.x + window.width - choice_window.width
        if $game_system.message_position == 2
          choice_window.y = window.y - choice_window.height - choice_window.default_vertical_margin
        else
          choice_window.y = window.y + window.height + choice_window.default_vertical_margin
        end
      end
      window.viewport.sort_z
      return choice_window
    end
  end
end
