module UI
  module Storage
    # Sprite showing the current selection mode
    class WinMode < SpriteSheet
      # Get the current mode
      # @return [Symbol] :pokemon, :item, :battle, :box
      attr_reader :mode
      # List of sheet index for all modes
      SHEET_INDEXES = { pokemon: 0, item: 1, battle: 2, box: nil }
      # Constant telling how much section there's in the sprite
      SHEET_SIZE = [1, 3]
      # Create a new ModeSprite
      # @param viewport [Viewport] viewport used to display the sprite
      # @param mode_handler [ModeHandler] class responsive of handling the mode
      def initialize(viewport, mode_handler)
        super(viewport, *SHEET_SIZE)
        load_texture
        mode_handler.add_mode_ui(self)
        position_sprite
      end

      # Set the mode
      # @param mode [Symbol]
      def mode=(mode)
        @mode = mode
        index = SHEET_INDEXES[mode]
        self.visible = !index.nil?
        if index.is_a?(Integer)
          self.sy = index
        elsif index.is_a?(Array)
          select(*index)
        end
      end

      private

      # Set the right sprite position
      def position_sprite
        self.z = 30
      end

      # Load the texture
      def load_texture
        set_bitmap('pc/win_modes', :interface)
      end
    end
  end
end
