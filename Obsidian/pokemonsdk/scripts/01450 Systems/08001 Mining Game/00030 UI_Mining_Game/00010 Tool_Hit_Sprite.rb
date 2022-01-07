module UI
  module MiningGame
    # Class that describes the Tool_Hit_Sprite object
    class Tool_Hit_Sprite < Tool_Sprite

      # Create the Tool_Hit_Sprite
      # @param viewport [Viewport] the viewport of the scene
      def initialize(viewport)
        super(viewport)
      end

      # Number of images on the same line
      # @return [Integer]
      def number_image_x
        return 5
      end

      # Set the new image of the sheet
      def change_image
        set_bitmap("mining_game/#{tool}_anim", :interface) if GamePlay::MiningGame::TOOLS.include? tool
      end
    end
  end
end
