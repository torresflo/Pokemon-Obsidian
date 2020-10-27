module GamePlay
  # Scene responsive of showing the shortcut menu
  class Shortcut < BaseCleanUpdate
    include ::Util::Item
    # List of shortcut key by index
    SHORTCUT_KEYS = %i[UP LEFT DOWN RIGHT]
    # List of key => method used by automatic_input_update
    AIU_KEY2METHOD = { B: :action_b, Y: :action_b }
    # Actions on mouse ctrl
    ACTIONS = %i[action_b action_b action_b action_b]
    # Create the shortcut scene
    def initialize
      super
      @items = $bag.shortcuts
    end

    # Update the inputs of the scene
    def update_inputs
      return false unless automatic_input_update(AIU_KEY2METHOD)

      SHORTCUT_KEYS.each_with_index do |key, index|
        next unless Input.trigger?(key)

        break use(index)
      end
    end

    # Update the mouse interaction
    def update_mouse(moved)
      update_mouse_ctrl_buttons(@base_ui.ctrl, ACTIONS, true)
      if Mouse.trigger?(:LEFT)
        @shortcuts.each_with_index do |stack, index|
          use(index) if stack.simple_mouse_in?
        end
      end
    end

    private

    def action_b
      play_cancel_se
      @running = false
    end

    def use(index)
      item_id = @items[index]
      if item_id == 0 || !$bag.contain_item?(item_id)
        play_buzzer_se
        return
      end
      play_decision_se
      @running = false if util_item_useitem(item_id)
      close_message_window
    end

    def create_graphics
      create_viewport
      create_background
      create_base_ui
      create_elements
    end

    def create_background
      add_disposable UI::BlurScreenshot.new(@__last_scene)
    end

    def create_elements
      count = SHORTCUT_KEYS.size
      # @type [Array<UI::ShortcutElement>]
      @shortcuts = SHORTCUT_KEYS.each_with_index.map do |key, index|
        UI::ShortcutElement.new(@viewport, count - index, @items[index], key)
      end
    end

    # Create the base UI of the slot machine
    def create_base_ui
      @base_ui = UI::GenericBase.new(@viewport, button_texts)
      @base_ui.background.visible = false
    end

    # Get the button text for the generic UI
    # @return [Array<String>]
    def button_texts
      return [nil, nil, nil, ext_text(9000, 115)]
    end
  end
end
