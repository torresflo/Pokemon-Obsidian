module Battle
  module Effects
    class Ability
      class TintedLens < Ability
        # Give the move mod3 mutiplier (after everything)
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def mod3_multiplier(user, target, move)
          return 1 if user != @target

          return move.not_very_effective? ? 2 : 1
        end
      end
      register(:tinted_lens, TintedLens)
    end
  end
end
