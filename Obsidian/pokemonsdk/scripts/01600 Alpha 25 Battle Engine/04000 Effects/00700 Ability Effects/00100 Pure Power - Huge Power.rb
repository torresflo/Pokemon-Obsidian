module Battle
  module Effects
    class Ability
      class PurePower < Ability
        # Give the move [Spe]atk mutiplier
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def sp_atk_multiplier(user, target, move)
          return 1 if user != @target

          return move.physical? ? 2 : 1
        end
      end
      register(:pure_power, PurePower)
      register(:huge_power, PurePower)
    end
  end
end
