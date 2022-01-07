module Battle
  class Move
    # Range of the R random factor
    R_RANGE = 85..100

    # Method calculating the damages done by the actual move
    # @note : I used the 4th Gen formula : https://www.smogon.com/dp/articles/damage_formula
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @note The formula is the following:
    #       (((((((Level * 2 / 5) + 2) * BasePower * [Sp]Atk / 50) / [Sp]Def) * Mod1) + 2) *
    #         CH * Mod2 * R / 100) * STAB * Type1 * Type2 * Mod3)
    # @return [Integer]
    def damages(user, target)
      # rubocop:disable Layout/ExtraSpacing
      # rubocop:disable Style/Semicolon
      # rubocop:disable Style/SpaceBeforeSemicolon
      log_data("# damages(#{user}, #{target}) for #{db_symbol}")
      # Reset the effectiveness
      @effectiveness = 1
      @critical = logic.calc_critical_hit(user, target, critical_rate)        ; log_data("@critical = #{@critical} # critical_rate = #{critical_rate}")
      damage = user.level * 2 / 5 + 2                                         ; log_data("damage = #{damage} # #{user.level} * 2 / 5 + 2")
      damage = (damage * calc_base_power(user, target)).floor                 ; log_data("damage = #{damage} # after calc_base_power")
      damage = (damage * calc_sp_atk(user, target)).floor / 50                ; log_data("damage = #{damage} # after calc_sp_atk / 50")
      damage = (damage / calc_sp_def(user, target)).floor                     ; log_data("damage = #{damage} # after calc_sp_def")
      damage = (damage * calc_mod1(user, target)).floor + 2                   ; log_data("damage = #{damage} # after calc_mod1 + 2")
      damage = (damage * calc_ch(user, target)).floor                         ; log_data("damage = #{damage} # after calc_ch")
      damage = (damage * calc_mod2(user, target)).floor                       ; log_data("damage = #{damage} # after calc_mod2")
      damage *= logic.move_damage_rng.rand(calc_r_range)
      damage /= 100                                                           ; log_data("damage = #{damage} # after rng")
      types = definitive_types(user, target)
      damage = (damage * calc_stab(user, types)).floor                        ; log_data("damage = #{damage} # after stab")
      damage = (damage * calc_type_n_multiplier(target, :type1, types)).floor ; log_data("damage = #{damage} # after type1")
      damage = (damage * calc_type_n_multiplier(target, :type2, types)).floor ; log_data("damage = #{damage} # after type2")
      damage = (damage * calc_type_n_multiplier(target, :type3, types)).floor ; log_data("damage = #{damage} # after type3")
      damage = (damage * calc_mod3(user, target)).floor                       ; log_data("damage = #{damage} # after mod3")
      damage = damage.clamp(1, target.hp)                                     ; log_data("damage = #{damage} # after clamp")
      return damage
      # rubocop:enable Layout/ExtraSpacing
      # rubocop:enable Style/Semicolon
      # rubocop:enable Style/SpaceBeforeSemicolon
    end

    # Get the real base power of the move (taking in account all parameter)
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Integer]
    def real_base_power(user, target)
      return power
    end

    private

    # Base power calculation
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Integer]
    def calc_base_power(user, target)
      base_power = real_base_power(user, target)
      # Effects
      return logic.each_effects(user, target).reduce(base_power) do |product, e|
        (product * e.base_power_multiplier(user, target, self)).floor
      end
    end

    # [Spe]atk calculation
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Integer]
    def calc_sp_atk(user, target)
      # [Sp]Atk = Stat * SM * AM * IM
      ph_move = physical?
      # Stat
      result = calc_sp_atk_basis(user, target, ph_move)
      # SM (Only if non-critical hit)
      result = (result * calc_atk_stat_modifier(user, target, ph_move)).floor
      # Effects
      logic.each_effects(user, target) do |e|
        result = (result * e.sp_atk_multiplier(user, target, self)).floor
      end
      return result
    end

    # Get the basis atk for the move
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @param ph_move [Boolean] true: physical, false: special
    # @return [Integer]
    def calc_sp_atk_basis(user, target, ph_move)
      return ph_move ? user.atk_basis : user.ats_basis
    end

    # Statistic modifier calculation: ATK/ATS
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @param ph_move [Boolean] true: physical, false: special
    # @return [Integer]
    def calc_atk_stat_modifier(user, target, ph_move)
      return 1 if critical_hit?

      return ph_move ? user.atk_modifier : user.ats_modifier
    end

    EXPLOSION_SELF_DESTRUCT_MOVE = %i[explosion self_destruct]
    # [Spe]def calculation
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Integer]
    def calc_sp_def(user, target)
      # [Sp]Def = Stat * SM * Mod * SX
      ph_move = physical?
      # Stat
      result = calc_sp_def_basis(user, target, ph_move)
      # SM (Only if non-critical hit)
      result = (result * calc_def_stat_modifier(user, target, ph_move)).floor
      # Effects
      logic.each_effects(user, target) do |e|
        result = (result * e.sp_def_multiplier(user, target, self)).floor
      end
      # SX
      result = (result * 0.5).floor if EXPLOSION_SELF_DESTRUCT_MOVE.include?(db_symbol)
      return result
    end

    # Get the basis dfe/dfs for the move
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @param ph_move [Boolean] true: physical, false: special
    # @return [Integer]
    def calc_sp_def_basis(user, target, ph_move)
      return ph_move ? target.dfe_basis : target.dfs_basis
    end

    # Statistic modifier calculation: DFE/DFS
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @param ph_move [Boolean] true: physical, false: special
    # @return [Integer]
    def calc_def_stat_modifier(user, target, ph_move)
      return 1 if critical_hit?

      return ph_move ? target.dfe_modifier : target.dfs_modifier
    end

    # CH calculation
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Numeric]
    def calc_ch(user, target)
      crit_dmg_rate = 1
      crit_dmg_rate *= 1.5 if critical_hit?
      crit_dmg_rate *= 1.5 if critical_hit? && user.has_ability?(:sniper)
      return crit_dmg_rate
    end

    # Mod1 multiplier calculation
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Numeric]
    def calc_mod1(user, target)
      result = 1
      # Effects
      logic.each_effects(user, target) do |e|
        result *= e.mod1_multiplier(user, target, self)
      end
      # Mod1 = BRN × RL × TVT × SR × FF
      # TVT
      result *= calc_mod1_tvt(target)
      return result
    end

    # Calculate the TVT mod
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Numeric]
    def calc_mod1_tvt(target)
      return 1 if one_target? || $game_temp.vs_type == 1

      if self.target == :all_foe
        count = logic.allies_of(target).size + 1
      else
        count = logic.adjacent_allies_of(target).size + 1
      end
      return count > 1 ? 0.75 : 1
    end

    # Mod2 multiplier calculation
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Numeric]
    def calc_mod2(user, target)
      update_use_count(user)
      result = 1
      # Effects
      logic.each_effects(user, target) do |e|
        result *= e.mod2_multiplier(user, target, self)
      end
      return result
    end

    # Update the move use count
    # @param user [PFM::PokemonBattler] user of the move
    def update_use_count(user)
      if user.last_successfull_move_is?(db_symbol)
        @consecutive_use_count += 1
      else
        @consecutive_use_count = 0
      end
    end

    # "Calc" the R range value
    # @return [Range]
    def calc_r_range
      R_RANGE
    end

    # Mod3 calculation
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Numeric]
    def calc_mod3(user, target)
      # Mod3 = SRF * EB * TL * TRB
      result = 1
      # Effects
      logic.each_effects(user, target) do |e|
        result *= e.mod3_multiplier(user, target, self)
      end
      return result
    end
  end
end
