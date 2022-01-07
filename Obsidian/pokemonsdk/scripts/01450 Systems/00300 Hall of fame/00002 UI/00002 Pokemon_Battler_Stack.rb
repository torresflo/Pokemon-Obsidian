module UI
  module Hall_of_Fame
    # Class that define the stack containing the Pokemon's battlers
    class Pokemon_Battler_Stack < SpriteStack
      COLORS = [[0, 0, 0, 255], [188, 187, 187, 255], [224, 56, 24, 255], [8, 124, 248, 255],
                [248, 208, 64, 255], [32, 192, 80, 255], [125, 186, 228, 255], [190, 74, 39, 255],
                [178, 74, 155, 255], [183, 122, 36, 255], [78, 176, 228, 255], [212, 108, 170, 255],
                [176, 213, 115, 255], [173, 126, 94, 255], [136, 111, 186, 255], [75, 155, 217, 255],
                [172, 178, 188, 255], [184, 85, 140, 255], [221, 139, 180, 255]]
      X_LEFT = -48
      X_RIGHT = 78
      X_COLOR_RIGHT = 88
      # The Array containing every back sprites of the player team
      # @return [Array<UI::PokemonBackSprite>]
      attr_accessor :battlebacks
      # The Array containing every front sprites of the player team
      # @return [Array<UI::PokemonFaceSprite>]
      attr_accessor :battlefronts
      # The Array containing every colored back sprites of the player team
      # @return [Array<Sprite::WithColor>]
      attr_accessor :withcolorbacks
      # Initialize the SpriteStack
      # @param viewport [Viewport]
      def initialize(viewport)
        super(viewport)
        @withcolorbacks = Array.new($actors.size) { add_sprite(*withcolor_initial_pos, NO_INITIAL_IMAGE, type: Sprite::WithColor) }
        @battlebacks = Array.new($actors.size) { add_sprite(*back_initial_pos, NO_INITIAL_IMAGE, type: PokemonBackSprite) }
        @battlefronts = Array.new($actors.size) { add_sprite(*front_initial_pos, NO_INITIAL_IMAGE, type: PokemonFaceSprite) }
        $actors.each_with_index do |pkm, index|
          @battlebacks[index].data = pkm
          @battlefronts[index].data = pkm
          @withcolorbacks[index].set_bitmap(@battlefronts[index].bitmap)
          set_origin_withcolorbacks
          r, g, b, a = COLORS[pkm.type1]
          @withcolorbacks[index].set_color(Color.new(r, g, b, a))
        end
      end

      private

      # The initial position of the back battlers
      # @return [Array<Integer>] the coordinates
      def back_initial_pos
        return 368, 220
      end

      # The initial position of the front battlers
      # @return [Array<Integer>] the coordinates
      def front_initial_pos
        return -48, 220
      end

      # The initial position of the colored shadows
      # @return [Array<Integer>] the coordinates
      def withcolor_initial_pos
        return -96, 220
      end

      # Set the correct origin for each Sprite::WithColor
      def set_origin_withcolorbacks
        @withcolorbacks.each_with_index do |sprite, index|
          sprite.set_origin(@battlefronts[index].ox, @battlefronts[index].oy)
        end
      end
    end
  end
end
