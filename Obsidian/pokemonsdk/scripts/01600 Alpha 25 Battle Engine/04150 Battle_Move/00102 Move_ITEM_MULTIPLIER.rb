module Battle
  class Move
    # List of multiplier for the items
    ITEM_MULTIPLIER = Hash.new(:calc_item_no_multplier).merge!(
      muscle_band: :calc_muscle_band_multiplier,
      wise_glasses: :calc_wise_glasses_multiplier,
      adamant_orb: :calc_adamant_orb_multiplier,
      lustrous_orb: :calc_lustrous_orb_multiplier,
      griseous_orb: :calc_griseous_orb_multiplier
    )
    # Type required by the adamant orb to give a boost
    ADAMANT_ORB_TYPES = [15, 16]
    # Type required by the lustrous orb to give a boost
    LUSTROUS_ORB_TYPES = [15, 3]
    # Type required by the griseous orb to give a boost
    GRISEOUS_ORB_TYPES = [15, 14]
    # @return [Hash{Symbol => Integer}] list of item_db_symbol to type boosting item
    BOOSTING_TYPE_ITEMS = {
      sea_incense: 3,
      odd_incense: 11,
      rock_incense: 13,
      wave_incense: 3,
      rose_incense: 5,
      flame_plate: 2,
      splash_plate: 3,
      zap_plate: 4,
      meadow_plate: 5,
      icicle_plate: 6,
      fist_plate: 7,
      toxic_plate: 8,
      earth_plate: 9,
      sky_plate: 10,
      mind_plate: 11,
      insect_plate: 12,
      stone_plate: 13,
      spooky_plate: 14,
      draco_plate: 15,
      dread_plate: 17,
      iron_plate: 16,
      pixie_plate: 18
    }
    # Constant that contains 1.1
    VAL_1_1 = 1.1
    # Constant that contains 0.9
    VAL_0_9 = 0.9
    # Constant that contains 0.95
    VAL_0_95 = 0.95
    # Constant that contains 1.3
    VAL_1_3 = 1.3
    # Constant that contains 0.8
    VAL_0_8 = 0.8
    # Constant that contains 0.5
    VAL_0_5 = 0.5

    private

    # Default item multiplier
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Numeric]
    def calc_item_no_multplier(user, target)
      1
    end

    # Calc the Muscle Band multiplier
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Numeric]
    def calc_muscle_band_multiplier(user, target)
      physical? ? VAL_1_1 : 1
    end

    # Calc the Wise Glasses multiplier
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Numeric]
    def calc_wise_glasses_multiplier(user, target)
      special? ? VAL_1_1 : 1
    end

    # Calc the Adamant Orb multiplier
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Numeric]
    def calc_adamant_orb_multiplier(user, target)
      return 1 unless user.db_symbol == :dialga
      return ADAMANT_ORB_TYPES.include?(type) ? 1.2 : 1
    end

    # Calc the Lustrous Orb multiplier
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Numeric]
    def calc_lustrous_orb_multiplier(user, target)
      return 1 unless user.db_symbol == :palkia
      return LUSTROUS_ORB_TYPES.include?(type) ? 1.2 : 1
    end

    # Calc the Griseous Orb multiplier
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Numeric]
    def calc_griseous_orb_multiplier(user, target)
      return 1 unless user.db_symbol == :giratina
      return GRISEOUS_ORB_TYPES.include?(type) ? 1.2 : 1
    end

    # Calc the item boost multiplier
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Numeric]
    def calc_item_boost_type_multiplier(user, target)
      BOOSTING_TYPE_ITEMS[user.item_db_symbol] == type ? 1.2 : 1
    end
    BOOSTING_TYPE_ITEMS.each_key { |item| ITEM_MULTIPLIER[item] = :calc_item_boost_type_multiplier }
  end
end
