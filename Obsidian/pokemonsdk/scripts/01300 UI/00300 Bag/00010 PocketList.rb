module UI
  # Module containing all the bag related UI
  module Bag
    # Utility showing the pocket list
    class PocketList < SpriteStack
      # @return [Integer] index of the current selected pocket
      attr_reader :index
      # Base coordinate of the active items
      ACTIVE_BASE_COORDINATES = [0, 192]
      # Base coordinate of the inactive items
      INACTIVE_BASE_COORDINATES = [0, 198]
      # Offset between each sprites
      OFFSET_X = 20
      # Array translating real pocket id to sprite piece
      POCKET_TRANSLATION = [0, 0, 1, 3, 5, 4, 2, 6, 7]
      # Name of the active image
      ACTIVE_IMAGE = 'bag/pockets_active'
      # Name of the inactive image
      INACTIVE_IMAGE = 'bag/pockets_inactive'
      # Create a new pocket list
      # @param viewport [Viewport]
      # @param pocket_indexes [Array<Integer>] each shown pocket by the UI
      def initialize(viewport, pocket_indexes)
        super(viewport, *INACTIVE_BASE_COORDINATES)
        pocket_indexes.each do |pocket_id|
          add_pocket_sprite(pocket_id)
        end
        @last_sprite = @stack[0]
        @index = 0
        self.z = 1
      end

      # Set the index of the current selected pocket
      # @param index [Integer]
      def index=(index)
        @index = index.clamp(0, size - 1)
        @last_sprite.bitmap = RPG::Cache.interface(INACTIVE_IMAGE)
        @last_sprite.y = INACTIVE_BASE_COORDINATES.last
        (@last_sprite = @stack[@index]).bitmap = RPG::Cache.interface(ACTIVE_IMAGE)
        @last_sprite.y = ACTIVE_BASE_COORDINATES.last
      end

      private

      # Add a pocket sprite
      # @param pocket_id [Integer] real ID of the pocket
      # @return [Sprite]
      def add_pocket_sprite(pocket_id)
        add_sprite(size * OFFSET_X, 0, INACTIVE_IMAGE, POCKET_TRANSLATION.size - 1, 1, type: SpriteSheet)
          .sx = POCKET_TRANSLATION[pocket_id]
      end
    end
  end
end
