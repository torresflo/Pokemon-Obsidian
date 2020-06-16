module UI
  module Shop
    class ShopBanner < Sprite
      FILENAME = 'shop/banner_'

      # Initialize the graphism for the shop banner
      # @param viewport [Viewport] viewport in which the Sprite will be displayed
      def initialize(viewport)
        super(viewport)
        set_bitmap(FILENAME, :interface)
        set_z(4)
      end
    end
  end
end