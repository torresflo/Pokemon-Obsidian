module Battle
  class Move
    # List of atk modifier method from ability
    ATK_ABILITY_MODIFIER = Hash.new(:calc_ua_1).merge!(
      pure_power: :calc_am_pure_power,
      huge_power: :calc_am_pure_power,
      flower_gift: :calc_am_flower_gift,
      guts: :calc_am_guts,
      hustle: :calc_am_hustle,
      slow_start: :calc_am_slow_start
    )
    # List of ats modifier method from ability
    ATS_ABILITY_MODIFIER = Hash.new(:calc_ua_1).merge!(
      solar_power: :calc_am_flower_gift,
      plus: :calc_am_plus_minus,
      minus: :calc_am_plus_minus
    )
    # List of atk modifier method from item
    ATK_ITEM_MODIFIER = Hash.new(:calc_ua_1).merge!(
      choice_band: :calc_im_choice_band,
      thick_club: :calc_im_thick_club
    )
    # List of ats modifier method from item
    ATS_ITEM_MODIFIER = Hash.new(:calc_ua_1).merge!(
      choice_specs: :calc_im_choice_band,
      soul_dew: :calc_im_soul_dew,
      deep_sea_tooth: :calc_im_deep_sea_tooth
    )
    # Pokemon that can hold the thick club and get the bonus
    THICK_CLUB_POKEMON = %i[cubone marowak]
    # Ability that interact with plus & minus
    PLUS_MINUS_ABILITIES = %i[plus minus]
    # Pokemon that can hold the soul dew and get the bonus
    SOUL_DEW_POKEMON = %i[latios latias]

    private

    # Pure Power ability multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_am_pure_power(user, target)
      2
    end

    # Flower Gift ability multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_am_flower_gift(user, target)
      $env.sunny? ? 1.5 : 1
    end

    # Guts ability multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_am_guts(user, target)
      return 1.5 if user.paralyzed? || user.poisoned? || user.toxic? || user.burn? || user.asleep?
      return 1
    end

    # Hustle ability multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_am_hustle(user, target)
      1.5
    end

    # Slow start ability multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_am_slow_start(user, target)
      VAL_0_5 if user.turn_count < 5
    end

    # Plus/Minus ability multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_am_plus_minus(user, target)
      return 1 unless PLUS_MINUS_ABILITIES.include?(user.ability_db_symbol)
      # The partner should have the other ability
      partner_expectation = user.ability_db_symbol == :plus ? :minus : :plus
      # Try all the adjacent partner
      (user.position - 1).step(user.position + 1, 2) do |position|
        partner = logic.battler(user.bank, position)
        return 1.5 if partner&.ability_db_symbol == partner_expectation
      end
      # No partner with the right ability => 1
      return 1
    end

    # Choice Band item multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_im_choice_band(user, target)
      1.5
    end

    # Thick Club item multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_im_thick_club(user, target)
      THICK_CLUB_POKEMON.include?(user.db_symbol) ? 2 : 1
    end

    # Soul Dew item multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_im_soul_dew(user, target)
      SOUL_DEW_POKEMON.include?(user.db_symbol) ? 1.5 : 1
    end

    # Deep Sea Tooth item multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_im_deep_sea_tooth(user, target)
      user.db_symbol == :clamperl ? 2 : 1
    end
  end
end
