module Battle
  module Effects
    class Ability
      class StrongJaw < Ability
        # Give the move mod3 mutiplier (after everything)
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def mod3_multiplier(user, target, move)
          return 1 if user != @target

          return move.bite? ? 1.5 : 1
        end
      end
      register(:strong_jaw, StrongJaw)
    end
  end
end
