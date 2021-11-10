module Battle
  module Effects
    class Ability
      class FurCoat < Ability
        # Give the move [Spe]def mutiplier
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def sp_def_multiplier(user, target, move)
          return 1 if target != @target
          return 1 unless user.can_be_lowered_or_canceled?

          return move.physical? ? 2 : 1
        end
      end
      register(:fur_coat, FurCoat)
    end
  end
end
