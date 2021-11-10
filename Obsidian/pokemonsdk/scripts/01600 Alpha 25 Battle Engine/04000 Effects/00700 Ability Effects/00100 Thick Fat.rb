module Battle
  module Effects
    class Ability
      class ThickFat < Ability
        # List of types affected by thick fat
        THICK_FAT_TYPES = [GameData::Types::FIRE, GameData::Types::ICE]
        # Get the base power multiplier of this move
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler]
        # @param move [Battle::Move]
        # @return [Float]
        def base_power_multiplier(user, target, move)
          return 1 if target != self.target
          return 1 unless user.can_be_lowered_or_canceled?

          return THICK_FAT_TYPES.include?(move.type) ? 0.5 : 1
        end
      end
      register(:thick_fat, ThickFat)
    end
  end
end
