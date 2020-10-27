module UI
  # Module containg all the storage UI
  module Storage
    # Sprite showing the current box mode
    class ModeSprite < SpriteSheet
      # Get the mode
      # @return [Symbol]
      attr_reader :mode
      # List of sheet index for all modes
      SHEET_INDEXES = { pokemon: 3, item: 4, battle: 6, box: 5 }
      # Constant telling how much section there's in the sprite
      SHEET_SIZE = [1, 7]
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
        if index.is_a?(Integer)
          self.sy = index
        else
          select(*index)
        end
      end

      private

      # Set the right sprite position
      def position_sprite
        set_position(84, 5)
        self.z = 31
      end

      # Load the texture
      def load_texture
        set_bitmap('pc/modes', :interface)
      end
    end
  end
end
