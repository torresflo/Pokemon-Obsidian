module UI
  module Storage
    class PokemonIcon < UI::PokemonIconSprite
      def initialize(viewport, index)
        super(viewport, false)
        @index = index
      end

      # Set the box data
      # @param box [PFM::Storage::Box]
      def data=(box)
        super(box.content[@index])
      end

      # Tell if the mouse is in the sprite
      def simple_mouse_in?(mouse_x = Mouse.x, mouse_y = Mouse.y)
        mx, my = translate_mouse_coords(mouse_x, mouse_y)
        return mx.between?(0, 31) && my.between?(0, 31)
      end
    end

    class PokemonItemIcon < UI::ItemSprite
      def initialize(viewport, index)
        super(viewport)
        @index = index
        self.opacity = 0
      end

      # Set the box data
      # @param box [PFM::Storage::Box]
      def data=(box)
        item_id = box.content[@index]&.item_db_symbol
        super(item_id) if (self.visible = (item_id && item_id != :__undef__))
      end
    end
  end
end
