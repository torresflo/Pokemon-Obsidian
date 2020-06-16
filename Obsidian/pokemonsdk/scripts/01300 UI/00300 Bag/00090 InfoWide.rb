module UI
  module Bag
    # Class that shows the full item info (descr)
    class InfoWide < SpriteStack
      # Mode of the bag
      # @return [Symbol]
      attr_reader :mode
      # Coordinate of the UI
      COORDINATES = 0, 33
      # Create a new InfoWide
      # @param viewport [Viewport]
      # @param mode [Symbol] mode of the bag scene
      def initialize(viewport, mode)
        super(viewport, *COORDINATES)
        @mode = mode
        init_sprite
      end

      # Change the item it shows
      # @param id [Integer] ID of the item to show
      def show_item(id)
        unless (self.visible = !id.nil?)
          @icon.data = 0
          @icon.visible = true
          return @stack.first.visible = true
        end
        item = GameData::Item[id]
        @icon.data = id
        @quantity.text = (id == 0 ? 0 : $bag.item_quantity(id)).to_s.to_pokemon_number
        @num_x.visible = @quantity.visible = item.limited
        @name.text = item.exact_name
        @descr.multiline_text = item.descr
        @fav_icon.visible = $bag.shortcuts.include?(id)
      end

      private

      def init_sprite
        create_background
        @icon = create_icon
        @num_x = create_cross
        @quantity = create_quantity_text
        @fav_icon = create_favorite_icon
        @name = create_name_text
        @descr = create_descr_text
      end

      def create_background
        add_background('bag/win_info_wide').set_z(4)
      end

      # @return [ItemSprite]
      def create_icon
        add_sprite(0, 3, NO_INITIAL_IMAGE, type: ItemSprite).set_z(5)
      end

      # @return [LiteRGSS::Sprite]
      def create_cross
        add_sprite(34, 7, 'bag/num_x').set_z(5)
      end

      # @return [LiteRGSS::Text]
      def create_quantity_text
        text = add_text(41, 1, 0, 13, nil.to_s, color: 10)
        text.z = 5
        return text
      end

      # @return [LiteRGSS::Sprite]
      def create_favorite_icon
        add_sprite(147, 6, 'bag/icon_fav').set_z(5)
      end

      # @return [LiteRGSS::Text]
      def create_name_text
        text = add_text(34, 17, 0, 13, nil.to_s, color: 24)
        text.z = 5
        return text
      end

      # @return [LiteRGSS::Text]
      def create_descr_text
        text = add_text(3, 37, 151, 16, nil.to_s)
        text.z = 5
        return text
      end
    end
  end
end
