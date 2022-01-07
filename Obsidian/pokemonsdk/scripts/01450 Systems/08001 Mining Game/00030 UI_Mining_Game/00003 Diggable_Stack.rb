module UI
  module MiningGame
    # Class that describes the Diggable_Stack
    class Diggable_Stack < SpriteStack
      # @return [Array<UI::MiningGame::Diggable_Sprite] the array containing every items' sprite
      attr_accessor :item_arr
      # @return [Array<UI::MiningGame::Diggable_Sprite] the array containing every irons' sprite
      attr_accessor :iron_arr

      # Create the Diggable_Stack
      # @param viewport [Viewport] the viewport of the scene
      # @param item_arr [Array<PFM::MiningGame::Diggable] the array containing the items to dig
      # @param iron_arr [Array<PFM::MiningGame::Diggable] the array containing the irons to not dig
      def initialize(viewport, item_arr, iron_arr)
        super(viewport, initial_x, initial_y)
        @item_arr = []
        @iron_arr = []
        item_arr.each { |item| @item_arr.push(Diggable_Sprite.new(@viewport, item)) }
        iron_arr.each { |obstacle| @iron_arr.push(Diggable_Sprite.new(@viewport, obstacle)) }
      end

      private

      # Return the x coordinate of the SpriteStack
      # @return [Integer]
      def initial_x
        return 0
      end

      # Return the y coordinate of the SpriteStack
      # @return [Integer]
      def initial_y
        return 32
      end
    end
  end
end
