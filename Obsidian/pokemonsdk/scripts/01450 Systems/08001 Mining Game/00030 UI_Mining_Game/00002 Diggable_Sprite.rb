module UI
  module MiningGame
    # Class that describes the Diggable_Sprite object
    class Diggable_Sprite < ShaderedSprite
      # Create the Diggable_Sprite
      # @param viewport [Viewport] the viewport of the scene
      # @param item [PFM::MiningGame::Diggable] the item/iron object
      def initialize(viewport, item)
        super(viewport)
        @item = item
        set_bitmap(image_path + @item.symbol.to_s, :interface)
        self.angle = (4 - @item.rotation) * 90 unless @item.rotation == 0
        set_origin(*correct_origin)
        self.x = @item.x * 16
        self.y = @item.y * 16 + 32
      end

      private

      # Return the correct pathname for the image
      # @return [String]
      def image_path
        str = "mining_game/"
        str += @item.is_an_item == true ? "items/" : "irons/"
        return str
      end

      # Return the correct origin point for after rotating the image
      # @return [Array<Integer>]
      def correct_origin
        case @item.rotation
        when 0
          return 0, 0
        when 1
          return 0, height
        when 2
          return width, height
        when 3
          return width, 0
        end
      end
    end
  end
end
