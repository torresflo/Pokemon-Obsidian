module UI
  module Bag
    # Class that shows the minimal item info
    class InfoCompact < SpriteStack
      # Mode of the bag
      # @return [Symbol]
      attr_reader :mode
      # Coordinate of the UI
      COORDINATES = 9, 145
      # Create a new InfoCompact
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
        @price_text&.text = parse_text(11, 9, /\[VAR NUM7[^\]]*\]/ => (item.price / 2).to_s)
      end

      private

      def init_sprite
        create_background
        @icon = create_icon
        @num_x = create_cross
        @quantity = create_quantity_text
        @name = create_name_text
        @price_text = create_price_text
      end

      def create_background
        add_background('bag/win_info_compact').set_z(1)
      end

      # @return [ItemSprite]
      def create_icon
        add_sprite(1, 3, NO_INITIAL_IMAGE, type: ItemSprite).set_z(2)
      end

      # @return [LiteRGSS::Sprite]
      def create_cross
        add_sprite(35, 7, 'bag/num_x').set_z(2)
      end

      # @return [LiteRGSS::Text]
      def create_quantity_text
        text = add_text(41, 1, 0, 13, nil.to_s, color: 10)
        text.z = 2
        return text
      end

      # @return [LiteRGSS::Text]
      def create_name_text
        text = add_text(36, 16, 0, 13, nil.to_s, color: 24)
        text.z = 2
        return text
      end

      # @return [LiteRGSS::Text, nil]
      def create_price_text
        return nil if mode != :shop

        return add_text(140, 1, 0, 13, nil.to_s, 2, color: 10)
      end
    end
  end
end
