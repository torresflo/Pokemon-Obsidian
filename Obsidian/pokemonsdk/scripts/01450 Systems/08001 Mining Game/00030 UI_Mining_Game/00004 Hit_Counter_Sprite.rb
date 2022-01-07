module UI
  module MiningGame
    # Class that describes the Hit_Counter_Sprite
    class Hit_Counter_Sprite < SpriteSheet
      # @return [Integer] the current state
      attr_accessor :state
      # @return [Symbol] the symbol corresponding to the Hit_Counter_Sprite number (:first or :not_first)
      attr_accessor :reason

      # Create the Hit_Counter_Sprite
      # @param viewport [Viewport] the viewport of the scene
      # @param reason [Symbol] the symbol corresponding to the Hit_Counter_Sprite number
      def initialize(viewport, reason)
        @reason = reason
        super(viewport, number_of_image_x, number_of_image_y)
        set_bitmap(bitmap_filename, :interface)
        @state = -1
        set_visible
      end

      # Change the state of the Hit_Counter_Sprite
      def change_state
        @state += 1
        update_sheet
        set_visible unless @state > 0
      end

      # Return the number of images on a same column
      # @return [Integer]
      def number_of_image_y
        if @reason == :first
          return 9
        else
          return 7
        end
      end

      private

      # Return the number of images on a same line
      # @return [Integer]
      def number_of_image_x
        return 1
      end

      # Return the right image filename
      # @return [String]
      def bitmap_filename
        if @reason == :first
          return 'mining_game/crack_begin'
        else
          return 'mining_game/cracks'
        end
      end

      # Update the sheet appearance
      def update_sheet
        self.sy = @state
        update
      end

      # Set the visibility of the sprite
      def set_visible
        self.visible = (@state >= 0)
      end
    end
  end
end
