module UI
  module MiningGame
    # Class describing the Tool_Sprite object
    class Tool_Sprite < SpriteSheet
      # @return [Symbol] the symbol of the currently used tool
      attr_accessor :tool
      # Create the Tool_Sprite
      def initialize(viewport)
        super(viewport, number_image_x, number_image_y)
        change_tool(GamePlay::MiningGame::TOOLS[0])
        self.visible = false
      end

      # Increase x attribute by nb
      # @param nb [Integer]
      def add_to_x(nb)
        self.x = x + nb
      end

      # Decrease x attribute by nb
      # @param nb [Integer]
      def sub_to_x(nb)
        self.x = x - nb
      end

      # Increase y attribute by nb
      # @param nb [Integer]
      def add_to_y(nb)
        self.y = y + nb
      end

      # Decrease y attribute by nb
      # @param nb [Integer]
      def sub_to_y(nb)
        self.y = y - nb
      end

      # Set the next frame of the sheet
      def new_frame
        if sx + 1 == nb_x
          self.sx = 0
        else
          self.sx += 1
        end
        update
      end

      # Change the tool image
      # @param sym_tool [Symbol] the symbol of the currently used tool
      def change_tool(sym_tool)
        self.tool = sym_tool
        change_image
      end

      private

      # Return the number of images on a same line
      # @return [Integer]
      def number_image_x
        return 2
      end

      # Return the number of images on a same column
      # @return [Integer]
      def number_image_y
        return 1
      end

      # Set the new image of the sheet
      def change_image
        set_bitmap("mining_game/#{tool}_sprite", :interface) if GamePlay::MiningGame::TOOLS.include? tool
      end
    end
  end
end
