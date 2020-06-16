module Battle
  class Move
    private

    # Target ability that reduce the multiplier if the move is super effective
    SUPER_EFFECTIVE_REDUCTION = %i[solid_rock filter]
    # Mod3 calculation
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Numeric]
    def calc_mod3(user, target)
      # Mod3 = SRF * EB * TL * TRB
      result = 1
      if super_effective?
        # SRF
        result *= 0.75 if SUPER_EFFECTIVE_REDUCTION.include?(target.ability_db_symbol)
        # EB
        result *= 1.2 if user.item_db_symbol == :expert_belt
      elsif not_very_effective?
        # TL
        result *= 2 if user.ability_db_symbol == :tinted_lens
      end
      # TRB
      return result * calc_trb(target)
    end

    # TRB calculation
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Numeric]
    def calc_trb(target)
      return 1 if target.item_db_symbol == :__undef__
      return VAL_0_5 if type == GameData::Types::NORMAL && target.item_db_symbol == :chilan_berry
      if super_effective?
        item = GameData::Item[target.item_holding]
        if (berry = item&.misc_data&.berry)
          return VAL_0_5 if berry[:type] == type
        end
      end
      return 1
    end
  end
end
