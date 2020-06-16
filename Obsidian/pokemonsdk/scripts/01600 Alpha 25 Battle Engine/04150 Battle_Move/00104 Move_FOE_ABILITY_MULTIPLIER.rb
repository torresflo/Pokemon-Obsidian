module Battle
  class Move
    # List of ability multiplier for the foe
    FOE_ABILITY_MULTIPLIER = Hash.new(:calc_ua_1).merge!(
      thick_fat: :calc_fa_thick_fat,
      heatproof: :calc_fa_heatproof,
      dry_skin: :calc_fa_dry_skin
    )
    # Types required by thick fat to trigger the multiplier
    THICK_FAT_TYPES = [GameData::Types::FIRE, GameData::Types::ICE]

    private

    # Thick Fat foe ability multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_fa_thick_fat(user, target)
      THICK_FAT_TYPES.include?(type) ? VAL_0_5 : 1
    end

    # Heatproof foe ability multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_fa_heatproof(user, target)
      type == GameData::Types::FIRE ? VAL_0_5 : 1
    end

    # Dry Skin foe ability multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_fa_dry_skin(user, target)
      type == GameData::Types::FIRE ? 1.25 : 1
    end
  end
end
