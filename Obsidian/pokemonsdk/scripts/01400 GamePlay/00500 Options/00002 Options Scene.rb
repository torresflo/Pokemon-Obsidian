module GamePlay
  class Options
    # List of action the mouse can perform with ctrl button
    ACTIONS = %i[save_options save_options save_options save_options]
    # Maximum number of button shown in the UI for options (used to calculate arrow position)
    MAX_BUTTON_SHOWN = 4
    # List of options that were modifies
    # @return [Array<Symbol>]
    attr_reader :modified_options

    # Create a new Options scene
    def initialize
      super
      # @type [Hash{Symbol => Helper}]
      @options = {}
      @order = PSDK_CONFIG.options.order
      @order.delete(:language) unless PSDK_CONFIG.choosable_language_code&.any?
      load_options
      @modified_options = []
      @index = 0
      @max_index = 0
      @options_copy = $options.clone
    end

    def update_inputs
      if index_changed!(:@index, :UP, :DOWN, @max_index)
        play_cursor_se
        update_list
        @description.data = current_option
        return false
      end
      if Input.trigger?(:A) && @order[@index] == :message_frame
        display_message(@buttons[@index].value_text)
        return false
      end
      return save_options if Input.trigger?(:B)
      return update_input_option_value
    end

    # Update the mouse interactions
    # @param moved [Boolean] if the mouse moved durring the frame
    # @return [Boolean] if the thing after can update
    def update_mouse(moved)
      update_mouse_ctrl_buttons(@base_ui.ctrl, ACTIONS, true)
      return false
    end

    def update_graphics
      @base_ui&.update_background_animation
      @arrow&.update
    end

    private

    def load_options
      PSDK_CONFIG.options.options.each do |option|
        add_option(*option)
      end
    end

    def create_graphics
      create_viewport
      create_base_ui
      create_description
      create_buttons
      create_frame
    end

    def create_viewport
      super
      rect = @viewport.rect
      x = rect.x + 160
      y = rect.y + 45
      @button_viewport = Viewport.create(x, y, 156, 156, 10_000)
    end

    def create_base_ui
      @base_ui = UI::GenericBase.new(@viewport, button_texts)
    end

    # Get the button text for the generic UI
    # @return [Array<String>]
    def button_texts
      return [nil, nil, nil, ext_text(9000, 115)]
    end

    def create_description
      @description = UI::Options::Description.new(@viewport)
      @description.data = @options[@order.first]
    end

    def create_buttons
      @buttons = @order.map.with_index do |sym, index|
        next nil unless @options[sym]

        UI::Options::Button.new(@button_viewport, index, @options[sym])
      end.compact
      @arrow = UI::Options::Arrow.new(@button_viewport)
      @arrow.oy -= (@buttons.first&.stack&.first&.height || 0) / 2
      @max_index = @buttons.size - 1
    end

    def create_frame
      @frame = Sprite.new(@viewport).set_bitmap('options/frame', :interface)
    end

    def update_list
      @arrow.y = @buttons[@index].stack.first.y
      @button_viewport.oy = 0
      return unless (@max_index + 1) > MAX_BUTTON_SHOWN
      return if @index < MAX_BUTTON_SHOWN / 2

      offset_y = (@index - MAX_BUTTON_SHOWN / 2 + 1).clamp(0, @buttons.size - MAX_BUTTON_SHOWN)
      @button_viewport.oy = offset_y * UI::Options::Button::OPTION_OFFSET_Y
    end

    # Function that try to update the option value
    # @return [Boolean]
    def update_input_option_value
      new_value = nil
      if Input.repeat?(:RIGHT)
        new_value = current_option.next_value
      elsif Input.repeat?(:LEFT)
        new_value = current_option.prev_value
      end
      return true if new_value.nil?
      if new_value != current_option.current_value
        play_cursor_se
        @buttons[@index].value = new_value
        current_option.update_value(new_value)
      else
        play_buzzer_se
      end
      return false
    end

    # Method that save the options and quit the scene
    # @return [false]
    def save_options
      @modified_options = @order.select do |option_symbol|
        option = @options[option_symbol]
        next @options_copy.send(option.getter) != option.current_value
      end
      return @running = false
    end

    # Return the current option
    # @return [GamePlay::Options::Helper]
    def current_option
      @options[@order[@index]]
    end
  end
end
