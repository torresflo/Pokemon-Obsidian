module Battle
  module Effects
    class Ability
      class Heatproof < Ability
        # Get the base power multiplier of this move
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler]
        # @param move [Battle::Move]
        # @return [Float]
        def base_power_multiplier(user, target, move)
          return 1 if target != self.target
          return 1 unless user.can_be_lowered_or_canceled?

          return move.type == GameData::Types::FIRE ? 0.5 : 1
        end
      end
      register(:heatproof, Heatproof)
    end
  end
end
