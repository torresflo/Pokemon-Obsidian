module UI
  module Shop
    class PkmDesc < SpriteStack
      WHITE_COLOR = Color.new(255, 255, 255)
      # Initialize the item description window graphisms and texts
      # @param viewport [Viewport] the viewport in which the SpriteStack will be displayed
      def initialize(viewport)
        super(viewport, 7, 184)
        @item_desc_window = add_background('shop/pkm_desc_window')
        @item_desc_name = add_text(20, 9, 150, 9, nil.to_s)
        @item_desc_name.draw_shadow = false
        @item_desc_name.fill_color = WHITE_COLOR
        @item_desc_text = add_text(14, 26, 286, 16, nil.to_s)
        @item_desc_text.draw_shadow = false
        @item_desc_species = add_text(58, 26, 286, 16, nil.to_s)
        @item_desc_species.draw_shadow = false
        @item_in_stock = add_text(205, 27, 145, 13, nil.to_s, color: 10)
        @item_in_stock.draw_shadow = false
        self.z = 4
      end

      # Update the text of the item's name
      # @param name [String] the string of the item's name
      def name=(name)
        @item_desc_name.text = name
      end

      # Update the level text for the Pokemon
      # @param text [String] the string of the Pokemon's level
      def text=(text)
        @item_desc_text.text = parse_text(27, 29) + " #{text}"
      end

      # Update the species text for the Pokemon
      # @param species [String] the string of the Pokemon's species
      def species=(species)
        @item_desc_species.text = species
      end

      # Update the number of the Pokémon in stock
      # @param nb [Integer] the number of the currently shown item in stock
      def nb_in_stock=(nb)
        @item_in_stock.text = ext_text(9003, 0) + nb.to_s
      end
    end
  end
end
