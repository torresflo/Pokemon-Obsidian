module Battle
  module Effects
    class Ability
      class SandVeil < Ability
        # Return the chance of hit multiplier
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move]
        # @return [Float]
        def chance_of_hit_multiplier(user, target, move)
          return 1 if target != @target
          return 1 unless user.can_be_lowered_or_canceled?

          return $env.sandstorm? ? 0.8 : 1
        end
      end
      register(:sand_veil, SandVeil)
    end
  end
end
