module Battle
  module Effects
    class Ability
      class MarvelScale < Ability
        # Give the move [Spe]def mutiplier
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def sp_def_multiplier(user, target, move)
          return 1 if target != @target
          return 1 unless user.can_be_lowered_or_canceled?
          return 1 if target.status_effect.instance_of?(Status)

          return move.physical? ? 1.5 : 1
        end
      end
      register(:marvel_scale, MarvelScale)
    end
  end
end
