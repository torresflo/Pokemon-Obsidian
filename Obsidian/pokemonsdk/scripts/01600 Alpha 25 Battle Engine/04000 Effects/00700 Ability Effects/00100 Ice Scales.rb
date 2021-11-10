module Battle
  module Effects
    class Ability
      class IceScales < Ability
        # Get the base power multiplier of this move
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler]
        # @param move [Battle::Move]
        # @return [Float]
        def base_power_multiplier(user, target, move)
          return 1 if target != self.target
          return 0.5 if move.special? && user.can_be_lowered_or_canceled?

          return 1
        end
      end
      register(:ice_scales, IceScales)
    end
  end
end
