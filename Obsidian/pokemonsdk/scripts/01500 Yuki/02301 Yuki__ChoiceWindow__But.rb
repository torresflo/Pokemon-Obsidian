module Yuki
  class ChoiceWindow
    # Display a Choice "Window" but showing buttons instead of the common window
    class But < ChoiceWindow
      # Window Builder of this kind of choice window
      WindowBuilder = [11, 3, 100, 16, 12, 3]
      # Overwrite the current window_builder
      # @return [Array]
      def current_window_builder
        WindowBuilder
      end

      # Overwrite the windowskin setter
      # @param v [Texture] ignored
      def windowskin=(v)
        super(RPG::Cache.interface('team/select_button'))
      end
    end
  end
end
