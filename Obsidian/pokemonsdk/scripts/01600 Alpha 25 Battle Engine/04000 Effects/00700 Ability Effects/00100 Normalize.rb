module Battle
  module Effects
    class Ability
      class Normalize < Ability
        # Function called when we try to get the definitive type of a move
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler] expected target
        # @param move [Battle::Move]
        # @param type [Integer] current type of the move (potentially after effects)
        # @return [Integer, nil] new type of the move
        def on_move_type_change(user, target, move, type)
          return if user != @target
          return if move.be_method == :s_weather_ball

          return GameData::Types::NORMAL
        end
      end
      register(:normalize, Normalize)
    end
  end
end
