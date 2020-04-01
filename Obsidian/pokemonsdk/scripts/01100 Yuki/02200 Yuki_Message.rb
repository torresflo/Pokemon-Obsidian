module Yuki
  # Class that helps to show message on screen
  #
  # To make the message management easily this class will expose its main object through Yuki::Mesage.current with an optional argument to select the current parent
  #
  # List of functionalities of this class
  # - Showing the one who is speaking (name & faceset)
  # - Showing emotion of the one who is speaking
  # - Choosing the number of lines
  # - Choosing the skin of the various elements
  # - Choosing the position of the window & the various elements (speaker etc...)
  # - Choosing the speed of the text display
  class Message < LiteRGSS::Window
    # Name of the pause skin in Graphics/Windowskins/
    PauseSkin = 'Pause2'
    # Windowskin for the name window
    NAME_SKIN = 'message'
    # @return [Symbol, Array, nil] Overwrite the message position for the current message
    # @note Values can be : :top, :middle, :bottom, :left, :right, [x, y]
    attr_accessor :position_overwrite
    # @return [String, nil] Change the windowskin of the window
    attr_accessor :windowskin_overwrite
    # @return [String, nil] Change the windowskin of the name
    attr_accessor :nameskin_overwrite
    # @return [Integer, nil] Overwrite the number of line for the current message
    attr_accessor :line_number_overwrite
    # @return [Integer, nil] Overwrite the width of the window
    attr_accessor :width_overwrite
    # @return [Boolean] If the message is still drawing (block some processes in #update)
    attr_accessor :drawing_message
    # @return [Boolean] If the message doesn't wait the player to hit A to terminate
    attr_accessor :auto_skip
    # @return [Boolean] If the window message doesn't fade out
    attr_accessor :stay_visible
    # @return [GamePlay::InputNumber] Variable that holds the GamePlay::InputNumber object
    attr_accessor :input_number_window
    # @return [String, nil] the last text the window showed (used in battle to prevent redisplay of pokemon name)
    attr_reader :last_text

    # List of message instance (to allow the access to the current message)
    @@instances = {}

    # Return the actual instance of message
    # @param parent [GamePlay::Base, Scene_Map] parent scene we want the message window
    # @return [Message, nil]
    def self.current(parent = $scene)
      @@instances[parent]
    end

    # Create a new Message handler
    # @param viewport [LiteRGSS::Viewport]
    # @param parent [GamePlay::Base, Scene_Map]
    def initialize(viewport, parent = $scene)
      raise 'Viewport required to display message' unless viewport
      super(viewport)
      # Content of the message
      @text_stack = UI::SpriteStack.new(self)
      # Sprite of the one who are speaking
      @face_stack = UI::SpriteStack.new(viewport, default_cache: :battler)
      # Name of the one who is speaking
      @name_window = Window.new(viewport)
      @name_text = create_name_text
      reset_overwrites
      init_window
      self.visible = false
      @auto_skip = false
      @stay_visible = false
      @drawing_message = false
      @text_sample = create_sample_text
      @text_sample.visible = false
      @fade_out = false
      @fade_in = false
      # Register the window
      @@instances[@parent = parent] = self
    end

    # Change the Z coordinate of the Window
    # @param value [Integer] new z coordinate
    def z=(value)
      super(value = value.to_i)
      @face_stack.z = value + 1
      @name_window.z = value + 2
    end

    # Dispose the window
    # @param with_viewport [Boolean] tell to also dispose the viewport of the Window
    def dispose(with_viewport: false)
      @@instances.delete(@parent)
      vp = viewport
      super()
      @face_stack.dispose
      @name_window.dispose
      dispose_sub_elements
      vp.dispose if with_viewport
      $game_temp.message_window_showing = false
    end

    # Terminate the message display
    def terminate_message
      self.active = false
      self.pause = false
      @contents_showing = false
      $game_temp.message_proc&.call
      reset_game_temp_message_info
      dispose_sub_elements
      reset_overwrites
      @auto_skip = false
    end

    # Retrieve the current layout configuration
    # @return [ScriptLoader::PSDKConfig::LayoutConfig::Message]
    def current_layout
      config = PSDK_CONFIG.layout.messages
      return config[$scene.class.to_s] || config[:any]
    end

    private

    # Reset the $game_temp stuff
    def reset_game_temp_message_info
      $game_temp.message_text = nil
      $game_temp.message_proc = nil
      $game_temp.choice_start = 99
      $game_temp.choice_max = 0
      $game_temp.choice_cancel_type = 0
      $game_temp.choice_proc = nil
      $game_temp.num_input_start = -99
      $game_temp.num_input_variable_id = 0
      $game_temp.num_input_digits_max = 0
    end

    # Retrieve the current windowskin
    # @return [String]
    def current_windowskin
      @windowskin_overwrite || current_layout.windowskin || $game_system.windowskin_name
    end

    # Retrieve the current windowskin of the name window
    # @return [String]
    def current_name_windowskin
      @nameskin_overwrite || current_layout.name_windowskin || NAME_SKIN
    end

    # Dispose the sub element of the window (thing created during the message processing)
    def dispose_sub_elements
      @gold_window&.dispose
      @choice_window&.dispose
      @city_sprite&.dispose
      @city_sprite = @gold_window = @choice_window = nil
    end

    # Initialize the window Parameter
    def init_window
      self.z = 10_000
      lock
      @name_window.visible = false
      @name_window.lock
      @name_text.text = ''
      update_windowskin
      init_pause_coordinates
      self.pauseskin = RPG::Cache.windowskin(PauseSkin)
      self.back_opacity = ($game_system.message_frame == 0 ? 255 : 0)
      unlock
      @name_window.unlock
    end

    def init_pause_coordinates
      self.pause_x = width - 15 - default_horizontal_margin
      self.pause_y = height - 18 - default_vertical_margin
    end

    # Calculate the current window position
    def calculate_position
      x = default_horizontal_margin
      case current_position
      when :top
        y = default_vertical_margin
      when :middle
        y = (viewport.rect.height - height) / 2
      when :bottom, :left
        y = viewport.rect.height - default_vertical_margin - height
      when :right
        y = viewport.rect.height - default_vertical_margin - height
        x = viewport.rect.height - x - width
      end
      set_position(x, y)
    end

    # Retrieve the current window position
    # @return [Symbol, Array]
    def current_position
      position = @position_overwrite || $game_system.message_position
      case position
      when 0
        return :top
      when 1
        return :middle
      when 2
        return :bottom
      end
      position
    end

    # Retrieve the current window_builder
    # @return [Array]
    def current_window_builder
      return UI::Window.window_builder(current_windowskin)
    end

    # Update the windowskin
    def update_windowskin
      windowskin_name = current_windowskin
      return calculate_position if @windowskin_name == windowskin_name

      self.window_builder = current_window_builder
      self.windowskin = RPG::Cache.windowskin(@windowskin_name = windowskin_name)
      # Window size is dependant on the windowskin
      set_size(window_width, window_height)
      calculate_position # Recalculate the window position (dependant on the height)
      update_name_windowskin
    end

    # Retrieve the current window_builder of the name window
    # @return [Array]
    def current_name_window_builder
      return UI::Window.window_builder(current_name_windowskin)
    end

    # Update the name windowskin
    def update_name_windowskin
      windowskin_name = current_name_windowskin
      return if @name_windowskin_name == windowskin_name

      wb = @name_window.window_builder = current_name_window_builder
      @name_window.windowskin = RPG::Cache.windowskin(@name_windowskin_name = windowskin_name)
      @name_window.x = x
      if current_position != :top
        @name_window.y = y - wb[5] - wb[-1] - default_line_height - default_vertical_margin
      else
        @name_window.y = y + height + default_vertical_margin
      end
      @name_window.height = wb[5] + wb[-1] + default_line_height
    end

    # Wait the user input
    def wait_user_input
      self.pause = true
      until Input.trigger?(:A) || (Mouse.trigger?(:left) && simple_mouse_in?) || stop_message_process?
        message_update_processing
      end
      $game_system.se_play($data_system.cursor_se)
      self.pause = false
    end

    # Return the window width
    # @return [Integer]
    def window_width
      @width_overwrite || default_width
    end

    # Return the window height
    def window_height
      base_height = (wb = current_window_builder)[5] + wb[-1]
      base_height + default_line_height * line_number
    end

    # Return the number of lines
    def line_number
      @line_number_overwrite || default_line_number
    end

    # Return the default window width
    # @return [Integer]
    def default_width
      viewport.rect.width - default_horizontal_margin * 2
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

    # Return the default line number
    # @return [Integer]
    def default_line_number
      return current_layout.line_count
    end

    # Return the default line height
    def default_line_height
      return Fonts.line_height(current_layout.default_font)
    end

    # Return the default text color
    # @return [Integer]
    def default_color
      return current_layout.default_color
    end
    alias get_default_color default_color

    # Return the default text style
    # @return [Integer]
    def default_style
      return 0
    end
    alias get_default_style default_style

    # Reset all the overwrite when the message has been shown
    def reset_overwrites
      @position_overwrite = @windowskin_overwrite = @nameskin_overwrite = nil
      @line_number_overwrite = @width_overwrite = nil
    end

    # Create the name text
    def create_name_text
      Text.new(0, @name_window, 0, -Text::Util::FOY, 0, default_line_height, '')
    end

    # Create the sample text
    def create_sample_text
      Text.new(0, viewport, 0, 0, 0, 0, ' ')
    end

    # Is text displaying bigger (marker 4 compatibility)
    def bigger_text?
      @style.anybits?(0x04)
    end
  end
end
