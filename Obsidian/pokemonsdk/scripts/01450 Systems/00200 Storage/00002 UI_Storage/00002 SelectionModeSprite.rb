module UI
  module Storage
    # Sprite showing the current selection mode
    class SelectionModeSprite < SpriteSheet
      # Get the current mode
      # @return [Symbol] :detailed, :fast, :grouped
      attr_reader :selection_mode
      # List of sheet index for all modes
      SHEET_INDEXES = { detailed: 0, fast: 1, grouped: 2 }
      # Constant telling how much section there's in the sprite
      SHEET_SIZE = [1, 7]
      # Create a new SelectionModeSprite
      # @param viewport [Viewport] viewport used to display the sprite
      # @param mode_handler [ModeHandler] class responsive of handling the mode
      def initialize(viewport, mode_handler)
        super(viewport, *SHEET_SIZE)
        load_texture
        mode_handler.add_selection_mode_ui(self)
        position_sprite
      end

      # Set the selection_mode
      # @param selection_mode [Symbol]
      def selection_mode=(selection_mode)
        @selection_mode = selection_mode
        index = SHEET_INDEXES[selection_mode]
        if index.is_a?(Integer)
          self.sy = index
        else
          select(*index)
        end
      end

      private

      # Set the right sprite position
      def position_sprite
        set_position(25, 5)
        self.z = 31
      end

      # Load the texture
      def load_texture
        set_bitmap('pc/modes', :interface)
      end
    end
  end
end
