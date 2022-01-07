module UI
  module Storage
    # Class responsive of handling the mode for the PC UI
    class ModeHandler
      # Get the current mode
      # @return [Symbol] :pokemon, :item, :battle, :box
      attr_reader :mode
      # List the available modes
      AVAILABLE_MODES = %i[pokemon item battle] # box mode disabled for now
      # Get the current selection mode
      # @return [Symbol] :detailed, :fast, :grouped
      attr_reader :selection_mode
      # List the available modes
      AVAILABLE_SELECTION_MODES = %i[detailed fast grouped]
      # Create a new Mode Handler
      # @param selection_mode [Symbol] :detailed, :fast or :grouped
      def initialize(mode, selection_mode)
        # @type [Array<#mode=>]
        @mode_uis = []
        # @type [Array<#selection_mode=>]
        @select_mode_uis = []
        self.mode = mode
        self.selection_mode = selection_mode
      end

      # Add a mode ui
      # @param mode_ui [#mode=]
      def add_mode_ui(mode_ui)
        @mode_uis << mode_ui
        mode_ui.mode = @mode
      end

      # Add a selection mode ui
      # @param selection_mode_ui [#selection_mode=]
      def add_selection_mode_ui(selection_mode_ui)
        @select_mode_uis << selection_mode_ui
        selection_mode_ui.selection_mode = @selection_mode
      end

      # Set the mode of the UIs
      # @param mode [Symbol]
      def mode=(mode)
        raise "Bad mode got #{mode} expected #{AVAILABLE_MODES.join(',')}" unless AVAILABLE_MODES.include?(mode)

        @mode = mode
        @mode_uis.each { |ui| ui.mode = mode }
      end

      # Set the mode of the UIs
      # @param selection_mode [Symbol]
      def selection_mode=(selection_mode)
        unless AVAILABLE_SELECTION_MODES.include?(selection_mode)
          raise "Bad selection mode got #{selection_mode} expected #{AVAILABLE_SELECTION_MODES.join(',')}"
        end

        @selection_mode = selection_mode
        @select_mode_uis.each { |ui| ui.selection_mode = selection_mode }
      end

      # Swap the mode
      # @return [Symbol]
      def swap_mode
        self.mode = AVAILABLE_MODES[AVAILABLE_MODES.index(@mode) + 1] || AVAILABLE_MODES.first
      end

      # Swap the selection mode
      # @return [Symbol]
      def swap_selection_mode
        self.selection_mode = AVAILABLE_SELECTION_MODES[AVAILABLE_SELECTION_MODES.index(@selection_mode) + 1] || AVAILABLE_SELECTION_MODES.first
      end
    end
  end
end
