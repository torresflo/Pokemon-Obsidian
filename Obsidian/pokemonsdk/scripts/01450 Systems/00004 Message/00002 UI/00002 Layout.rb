module UI
  module Message
    # Module defining the Message layout
    module Layout
      # Name of the pause skin in Graphics/Windowskins/
      PAUSE_SKIN = 'Pause2'
      # Windowskin for the name window
      NAME_SKIN = 'message'
      # Make [LiteRGSS::Window] visible to this module in editor
      # @!parse include LiteRGSS::Window
      include TemporaryOverwrites

      # Attribute that holds the UI::InputNumber object
      # @return [UI::InputNumber]
      attr_accessor :input_number_window
      # Get the text stack
      # @return [UI::SpriteStack]
      protected attr_reader :text_stack
      # Get the sub_stack
      # @return [UI::SpriteStack]
      protected attr_reader :sub_stack

      # Initialize the states
      def initialize(...)
        super(...) # Forward any arguments to original super ;)
        # Content of the message
        @text_stack = UI::SpriteStack.new(self)
        # Sub stack of sprites/window related to the Message layout
        @sub_stack = UI::SpriteStack.new(viewport)
        # Initialize the window
        init_window
        self.visible = false
      end

      # Retrieve the current layout configuration based on the scene
      # @return [ScriptLoader::PSDKConfig::LayoutConfig::Message]
      def current_layout
        config = PSDK_CONFIG.layout.messages
        return config[$scene.class.to_s] || config[:any]
      end

      # Dispose the layout
      # @param with_viewport [Boolean] tell to also dispose the viewport of the layout
      def dispose(with_viewport: false)
        vp = viewport
        super()
        @sub_stack.dispose
        vp.dispose if with_viewport
      end

      private

      # Initialize the window Parameter
      def init_window
        self.z = 10_000
        lock
        update_windowskin
        init_pause_coordinates
        self.pauseskin = RPG::Cache.windowskin(PAUSE_SKIN)
        self.back_opacity = ($game_system.message_frame == 0 ? 255 : 0)
        unlock
      end

      def init_pause_coordinates
        self.pause_x = width - 13
        self.pause_y = height - 16
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

      # Update the windowskin
      def update_windowskin
        windowskin_name = current_windowskin
        return calculate_position if @windowskin_name == windowskin_name

        self.window_builder = current_window_builder
        self.windowskin = RPG::Cache.windowskin(@windowskin_name = windowskin_name)
        # Window size is dependant on the windowskin
        set_size(window_width, window_height)
        calculate_position # Recalculate the window position (dependant on the height)
      end

      # Retrieve the current window position
      # @return [Symbol, Array]
      def current_position
        position = position_overwrite || $game_system.message_position
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

      # Retrieve the current windowskin
      # @return [String]
      def current_windowskin
        windowskin_overwrite || properties&.windowskin_overwrite || current_layout.windowskin || $game_system.windowskin_name
      end

      # Retrieve the current windowskin of the name window
      # @return [String]
      def current_name_windowskin
        nameskin_overwrite || current_layout.name_windowskin || NAME_SKIN
      end

      # Return the window width
      # @return [Integer]
      def window_width
        @width_overwrite || default_width
      end

      # Return the message width
      def message_width
        width = window_width - (wb = current_window_builder)[4] - wb[-2]
        return width - default_horizontal_margin - RPG::Cache.picture(properties.city_filename).width if properties&.city_filename

        return width
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

      # Is text displaying bigger (marker 4 compatibility)
      def bigger_text?
        @style.anybits?(0x04)
      end
    end
  end
end
