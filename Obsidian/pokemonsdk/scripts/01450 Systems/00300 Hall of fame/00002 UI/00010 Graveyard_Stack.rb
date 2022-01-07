module UI
  module Hall_of_Fame
    # Class that define the Graveyard Animation stack
    class Graveyard_Animation_Stack < SpriteStack
      # The array containing every ShaderedSprite
      # @return [Array<ShaderedSprite>]
      attr_accessor :sprites
      # The array containing every Dead_Pokemon_Text SpriteStack
      # @return [Array<UI::Hall_of_Fame::Dead_Pokemon_Text>]
      attr_accessor :text_boxes
      SPRITE_X_RIGHT = 422
      SPRITE_X_MIDDLE = 112
      SPRITE_X_LEFT = -198
      SPRITE_Y = 100
      BOX_X_RIGHT = 320
      BOX_X_MIDDLE = 10
      BOX_X_LEFT = -300
      BOX_Y = 80
      # Initialize the SpriteStack
      # @param viewport [Viewport]
      def initialize(viewport)
        super(viewport)
        @animation = nil
        @anim_count = 0
        @graveyard = PFM.game_state.nuzlocke.graveyard
        @sprites = Array.new(@graveyard.size) { add_sprite(*initial_pos_sprites, NO_INITIAL_IMAGE, type: ShaderedSprite) }
        @shader = Shader.create(:full_shader)
        @shader.set_float_uniform('color', [1, 1, 1, 0])
        @shader.set_float_uniform('tone', [0, 0, 0, 1])
        @sprites.each_with_index do |sprite, i|
          sprite.set_bitmap(@graveyard[i].battler_face)
          sprite.shader = @shader
        end
        @text_boxes = Array.new(@graveyard.size) { Dead_Pokemon_Text.new(viewport, *initial_pos_boxes) }
        @text_boxes.each_with_index do |box, i|
          box.text = @graveyard[i]
        end
      end

      private

      # The sprites initial coordinates
      # @return [Array<Integer>] the coordinates
      def initial_pos_sprites
        return SPRITE_X_RIGHT, SPRITE_Y
      end

      # The boxes initial coordinates
      # @return [Array<Integer>] the coordinates
      def initial_pos_boxes
        return BOX_X_RIGHT, BOX_Y
      end
    end
  end
end
