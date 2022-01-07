module Yuki
  class Debug
    # Main UI of the debugger
    class MainUI
      # @return [Integer] x position of the GUI on the screen
      SCREEN_X = 322

      # Create a new MainUI for the debug system
      # @param viewport [Viewport] viewport used to display the UI
      def initialize(viewport)
        @stack = UI::SpriteStack.new(viewport, SCREEN_X)
        @viewport = viewport
        create_class_text
        create_systag_ui
        create_groups_ui
      end

      # Update the gui
      def update
        update_class_text
        update_systag_ui
        update_groups_ui
      end

      private

      # Create the class text
      def create_class_text
        @class_text = @stack.add_text(0, 0, 320, 16, 'TEST', color: 9)
        @last_scene = nil
      end

      # Update the class text
      def update_class_text
        if $scene != @last_scene
          @last_scene = $scene
          @class_text.text = "Current scene : #{$scene.class}"
        end
      end

      # Create the systag UI
      def create_systag_ui
        @systag_ui = SystemTags.new(@viewport, @stack)
      end

      # Update the systag ui
      def update_systag_ui
        @systag_ui.update
      end

      # Create the groups UI
      def create_groups_ui
        @groups_ui = Groups.new(@viewport, @stack)
      end

      # Update the group UI
      def update_groups_ui
        @groups_ui.update
      end
    end
  end
end
