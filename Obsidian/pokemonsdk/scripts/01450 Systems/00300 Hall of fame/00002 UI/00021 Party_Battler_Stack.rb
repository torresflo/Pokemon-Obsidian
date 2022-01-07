module UI
  module Hall_of_Fame
    # Class that define the Party Battler stack
    class Party_Battler_Stack < SpriteStack
      # The Array containing the front battlers of the Pokemon
      # @return [Array<UI::PokemonFaceSprite>]
      attr_accessor :pokemon_arr
      # The trainer battler
      # @return [Sprite]
      attr_accessor :trainer_battler
      X_PARTY = [99, 221, 69, 251, 38, 282]
      Y_PARTY = [180, 150, 120]
      Y_TRAINER = 102
      PLAYER_SPRITE_NAME = { true => 'hall_of_fame/female', false => 'hall_of_fame/male' }
      # Initialize the SpriteStack
      # @param viewport [Viewport]
      def initialize(viewport)
        super(viewport)
        @pokemon_arr = Array.new($actors.size) { |i| add_sprite(*pkm_initial_coordinates(i), NO_INITIAL_IMAGE, type: PokemonFaceSprite) }
        @pokemon_arr.reverse!
        @trainer_battler = add_sprite(*trainer_initial_coordinates, PLAYER_SPRITE_NAME[$trainer.playing_girl])
        @pokemon_arr.each_with_index { |sprite, index| sprite.data = ($actors[index]) }
      end

      # The Pokemon initial coordinates
      # @return [Array<Integer>] the coordinates
      def pkm_initial_coordinates(index)
        x = index.even? ? -48 : 368
        y = Y_PARTY[index / 2]
        return x, y
      end

      # The trainer sprite initial coordinates
      # @return [Array<Integer>] the coordinates
      def trainer_initial_coordinates
        return 112, -96
      end
    end
  end
end
