module Battle
  module Effects
    class Ability
      class SnowCloak < Ability
        # Return the chance of hit multiplier
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move]
        # @return [Float]
        def chance_of_hit_multiplier(user, target, move)
          return 1 if target != @target
          return 1 unless user.can_be_lowered_or_canceled?

          return $env.hail? ? 0.8 : 1
        end
      end
      register(:snow_cloak, SnowCloak)
    end
  end
end
