module Battle
  class Move
    # List of user ability multiplier
    USER_ABILITY_MULTIPLIER = Hash.new(:calc_ua_1).merge!(
      rivalry: :calc_ua_rivalry,
      reckless: :calc_ua_reckless,
      iron_fist: :calc_ua_iron_fist,
      technician: :calc_ua_technician
    )
    # List of ability that power specific move types when the user only has 1/3 (rounded down) of its HP
    POWERING_TYPE_USER_ABILITY = {
      blaze: GameData::Types::FIRE,
      overgrow: GameData::Types::GRASS,
      torrent: GameData::Types::WATER,
      swarm: GameData::Types::BUG
    }

    private

    # Default user ability multiplier (1)
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_ua_1(user, target)
      1
    end

    # Rivalry user ability multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_ua_rivalry(user, target)
      return 1 if (user.gender * target.gender) == 0
      return 1.25 if user.gender == target.gender
      return 0.75
    end

    # Reckless user ability multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_ua_reckless(user, target)
      recoil? ? 1.2 : 1
    end

    # Iron Fist user ability multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_ua_iron_fist(user, target)
      punching? ? 1.2 : 1
    end

    # Technicien user ability multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_ua_technician(user, target)
      power <= 60 ? 1.5 : 1
    end

    # Type on 1/3 hp user ability multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_ua_type_1_3(user, target)
      return 1 if user.hp > user.max_hp / 3
      return 1.5 if POWERING_TYPE_USER_ABILITY[user.ability_db_symbol] == type
      return 1
    end
    POWERING_TYPE_USER_ABILITY.each_key do |ability|
      USER_ABILITY_MULTIPLIER[ability] = :calc_ua_type_1_3
    end
  end
end
