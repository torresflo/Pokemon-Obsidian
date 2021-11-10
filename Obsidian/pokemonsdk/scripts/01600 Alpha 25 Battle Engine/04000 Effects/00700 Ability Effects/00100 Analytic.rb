module Battle
  module Effects
    class Ability
      class Analytic < Ability
        # Get the base power multiplier of this move
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler]
        # @param move [Battle::Move]
        # @return [Float]
        def base_power_multiplier(user, target, move)
          return 1 if user != self.target

          return move.logic.battler_attacks_last?(user) ? 1.3 : 1
        end
      end
      register(:analytic, Analytic)
    end
  end
end
