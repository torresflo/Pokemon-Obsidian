module Battle
  class Move
    # List of multiplier for the items
    ITEM_MULTIPLIER = Hash.new(:calc_item_no_multiplier).merge!(
      muscle_band: :calc_muscle_band_multiplier,
      wise_glasses: :calc_wise_glasses_multiplier,
      adamant_orb: :calc_adamant_orb_multiplier,
      lustrous_orb: :calc_lustrous_orb_multiplier,
      griseous_orb: :calc_griseous_orb_multiplier
    )
    # Type required by the adamant orb to give a boost
    ADAMANT_ORB_TYPES = [GameData::Types::DRAGON, GameData::Types::STEEL]
    # Type required by the lustrous orb to give a boost
    LUSTROUS_ORB_TYPES = [GameData::Types::DRAGON, GameData::Types::WATER]
    # Type required by the griseous orb to give a boost
    GRISEOUS_ORB_TYPES = [GameData::Types::DRAGON, GameData::Types::GHOST]
    # @return [Hash{Symbol => Integer}] list of item_db_symbol to type boosting item
    BOOSTING_TYPE_ITEMS = {
      sea_incense: GameData::Types::WATER,
      odd_incense: GameData::Types::PSYCHIC,
      rock_incense: GameData::Types::ROCK,
      wave_incense: GameData::Types::WATER,
      rose_incense: GameData::Types::GRASS,
      flame_plate: GameData::Types::FIRE,
      splash_plate: GameData::Types::WATER,
      zap_plate: GameData::Types::ELECTRIC,
      meadow_plate: GameData::Types::GRASS,
      icicle_plate: GameData::Types::ICE,
      fist_plate: GameData::Types::FIGHTING,
      toxic_plate: GameData::Types::POISON,
      earth_plate: GameData::Types::GROUND,
      sky_plate: GameData::Types::FLYING,
      mind_plate: GameData::Types::PSYCHIC,
      insect_plate: GameData::Types::BUG,
      stone_plate: GameData::Types::ROCK,
      spooky_plate: GameData::Types::GHOST,
      draco_plate: GameData::Types::DRAGON,
      dread_plate: GameData::Types::DARK,
      iron_plate: GameData::Types::STEEL,
      pixie_plate: GameData::Types::FAIRY
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
    def calc_item_no_multiplier(user, target)
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
