module UI
  module Bag
    # Class that shows the minimal item info
    class InfoCompact < SpriteStack
      # Create a new InfoCompact
      # @param viewport [Viewport]
      # @param mode [Symbol] mode of the bag scene
      def initialize(viewport, mode)
        super(viewport, 9, 145)
        add_background('bag/win_info_compact').set_z(1)
        @icon = add_sprite(1, 3, NO_INITIAL_IMAGE, type: ItemSprite).set_z(2)
        @num_x = add_sprite(35, 7, 'bag/num_x').set_z(2)
        @quantity = add_text(41, 1, 0, 13, nil.to_s, color: 10)
        @quantity.z = 2
        @name = add_text(36, 16, 0, 13, nil.to_s, color: 24)
        @name.z = 2
        @price_text = add_text(140, 1, 0, 13, nil.to_s, 2, color: 10) if mode == :shop
      end

      # Change the item it shows
      # @param id [Integer] ID of the item to show
      def show_item(id)
        unless (self.visible = !id.nil?)
          @icon.data = 0
          @icon.visible = true
          return @stack.first.visible = true
        end
        @icon.data = id
        @quantity.text = (id == 0 ? 0 : $bag.item_quantity(id)).to_s.to_pokemon_number
        @num_x.visible = @quantity.visible = GameData::Item.limited_use?(id)
        @name.text = GameData::Item.exact_name(id)
        @price_text&.text = parse_text(11, 9, /\[VAR NUM7[^\]]*\]/ => (GameData::Item.price(id) / 2).to_s)
      end
    end
  end
end
