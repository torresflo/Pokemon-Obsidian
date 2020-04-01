module UI
  module Bag
    # Class that shows the full item info (descr)
    class InfoWide < SpriteStack
      # Create a new InfoWide
      # @param viewport [Viewport]
      # @param mode [Symbol] mode of the bag scene
      def initialize(viewport, mode)
        super(viewport, 0, 33)
        add_background('bag/win_info_wide').set_z(4)
        @icon = add_sprite(0, 3, NO_INITIAL_IMAGE, type: ItemSprite).set_z(5)
        @num_x = add_sprite(34, 7, 'bag/num_x').set_z(5)
        @quantity = add_text(41, 1, 0, 13, nil.to_s, color: 10)
        @quantity.z = 5
        @fav_icon = add_sprite(147, 6, 'bag/icon_fav').set_z(5)
        @name = add_text(34, 17, 0, 13, nil.to_s, color: 24)
        @name.z = 5
        @descr = add_text(3, 37, 151, 16, nil.to_s)
        @descr.z = 5
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
        @descr.multiline_text = GameData::Item.descr(id)
        @fav_icon.visible = $bag.shortcuts.include?(id)
      end
    end
  end
end
