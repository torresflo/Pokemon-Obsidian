module Battle
  module Effects
    class Ability
      class SuperEffectivePowerReduction < Ability
        # Give the move mod3 mutiplier (after everything)
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def mod3_multiplier(user, target, move)
          return 1 if target != @target
          return 1 unless user.can_be_lowered_or_canceled? && move.super_effective?

          return 0.75
        end
      end
      register(:solid_rock, SuperEffectivePowerReduction)
      register(:filter, SuperEffectivePowerReduction)
      register(:prism_armor, SuperEffectivePowerReduction)
    end
  end
end
