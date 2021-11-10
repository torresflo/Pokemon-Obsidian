module Battle
  class Logic
    # List of critical rates according to the current critical count
    CRITICAL_RATES = {
      0 => 0,
      1 => 6_250,
      2 => 12_500,
      3 => 25_000,
      4 => 33_333,
      5 => 50_000
    }
    CRITICAL_RATES.default = 100_000
    # Calculate if the current action will be a critical hit
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @param initial_critical_count [Integer] Initial critical count of the move
    # @return [Boolean]
    def calc_critical_hit(user, target, initial_critical_count)
      return false if bank_effects[target.bank].has?(:lucky_chant)

      # 100_000 = 100%
      current_value = @move_critical_rng.rand(100_000)
      return current_value < CRITICAL_RATES[calc_critical_count(user, target, initial_critical_count)]
    end

    # List of ability preventing the critical hit from happening
    NO_CRITICAL_ABILITIES = %i[battle_armor shell_armor]
    # Calculate the critical count (to get the right critical propability)
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @param initial_critical_count [Integer] Initial critical count of the move
    # @return [Integer]
    def calc_critical_count(user, target, initial_critical_count)
      return 0 if user.can_be_lowered_or_canceled?(NO_CRITICAL_ABILITIES.include?(target.battle_ability_db_symbol))

      critical_count = initial_critical_count
      critical_count += 2 if user.effects.has?(:focus_energy)
      critical_count += 1 if user.has_ability?(:super_luck)
      critical_count += 1 if calc_critical_count_item(user)
      critical_count += 1 if user.effects.has?(:lansat_berry)
      return critical_count
    end

    UNCONDITIONAL_CRITICAL_ITEMS = %i[razor_claw scope_lens]
    # Tell if the user has an item that increase the critical count
    # @param user [PFM::PokemonBattler]
    # @return [Boolean]
    def calc_critical_count_item(user)
      item = user.battle_item_db_symbol
      return true if UNCONDITIONAL_CRITICAL_ITEMS.include?(item)
      return true if item == :leek && user.db_symbol == :farfetch_d
      return true if item == :lucky_punch && user.db_symbol == :chansey

      return false
    end
  end
end
