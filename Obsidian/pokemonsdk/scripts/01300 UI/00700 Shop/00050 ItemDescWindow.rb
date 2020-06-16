module UI
  module Shop
    class ItemDesc < SpriteStack
      # Initialize the item description window graphisms and texts
      # @param viewport [Viewport] the viewport in which the SpriteStack will be displayed
      def initialize(viewport)
        super(viewport, 7, 144)
        @item_desc_window = add_background('shop/item_desc_window')
        @item_desc_name = add_text(22, 8, 150, 9, nil.to_s)
        @item_desc_name.draw_shadow = false
        @item_desc_text = add_text(10, 22, 286, 16, nil.to_s)
        @item_desc_text.draw_shadow = false
        @item_in_stock = add_text(23, 73, 145, 13, nil.to_s, color: 10)
        @item_in_stock.draw_shadow = false
        @img_item_in_bag = add_sprite(256, 76, 'shop/img_item_in_bag')
        @nb_item_bag = add_text(276, 76, 23, 8, nil.to_s, color: 10)
        @nb_item_bag.draw_shadow = false
        self.z = 4
      end

      # Update the text of the item's name
      # @param name [String] the string of the item's name
      def name=(name)
        @item_desc_name.text = name
      end

      # Update the description text for the item
      # @param text [String] the string of the item's description
      def text=(text)
        @item_desc_text.multiline_text = text
      end

      # Update the number of currently possessed same item
      # @param nb [Integer] the number of the currrently shown item in the player bag
      def nb_item=(nb)
        @nb_item_bag.text = nb.to_s
      end

      # Update the number of the item in stock
      # @param nb [Integer] the number of the currently shown item in stock
      def nb_in_stock=(nb)
        @item_in_stock.text = ext_text(9003, 0) + nb.to_s
      end
    end
  end
end
