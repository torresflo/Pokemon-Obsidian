module Battle
  class Move
    # Range of the R random factor
    R_RANGE = 85..100

    # Method calculating the damages done by the actual move
    # @note : I used the 4th Gen formula : https://www.smogon.com/dp/articles/damage_formula
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @param rng [Random] random generator used for the move
    # @return [Integer]
    def damages(user, target, rng)
      @critical = logic.calc_critical_hit(user, target, critical_rate)
      # Reset the effectiveness
      @effectiveness = 1
      # (((((((Level * 2 / 5) + 2) * BasePower * [Sp]Atk / 50) / [Sp]Def) * Mod1) + 2) *
      # CH * Mod2 * R / 100) * STAB * Type1 * Type2 * Mod3)
      damage = user.level * 2 / 5 + 2
      damage = (damage * calc_base_power(user, target)).floor
      damage = (damage * calc_sp_atk(user, target)).floor
      damage /= 50
      damage = (damage / calc_sp_def(user, target)).floor
      damage = (damage * calc_mod1(user, target)).floor
      damage += 2
      damage = (damage * calc_ch(user)).floor
      damage = (damage * calc_mod2(user, target)).floor
      damage *= rng.rand(calc_r_range)
      damage /= 100
      damage = (damage * calc_stab(user)).floor
      damage = (damage * calc_type_n_multiplier(target, :type1)).floor
      damage = (damage * calc_type_n_multiplier(target, :type2)).floor
      damage = (damage * calc_type_n_multiplier(target, :type3)).floor
      return (damage * calc_mod3(user, target)).floor
    end

    private

    # Base power calculation
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Integer]
    def calc_base_power(user, target)
      # HH * BP * IT * CHG * MS * WS * UA * FA
      # BP
      result = power
      # HH
      result *= 1.5 if user.helping_hand?
      result = result.floor # Round down between each multiplication, the first two can be reverted.
      # IT
      result = (result * send(ITEM_MULTIPLIER[user.item_db_symbol], user, target)).floor
      # CHG
      result *= user.last_successfull_move == :charge && type == GameData::Types::ELECTRIC ? 2 : 1
      # MS
      result = (result * VAL_0_5).floor if logic.global_mud_sport? && type == GameData::Types::ELECTRIC
      # WS
      result = (result * VAL_0_5).floor if logic.global_water_sport? && type == GameData::Types::FIRE
      # UA
      result = (result * send(USER_ABILITY_MULTIPLIER[user.ability_db_symbol], user, target)).floor
      # FA
      return (result * send(FOE_ABILITY_MULTIPLIER[target.ability_db_symbol], user, target)).floor
    end

    # [Spe]atk calculation
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Integer]
    def calc_sp_atk(user, target)
      # [Sp]Atk = Stat * SM * AM * IM
      ph_move = physical?
      # Stat
      result = ph_move ? user.atk_basis : user.ats_basis
      # SM
      result = (result * (ph_move ? user.atk_modifier : user.ats_modifier)).floor
      # AM
      am = send((ph_move ? ATK_ABILITY_MODIFIER : ATS_ABILITY_MODIFIER)[user.ability_db_symbol], user, target)
      result = (result * am).floor
      # IM
      return (result * send((ph_move ? ATK_ITEM_MODIFIER : ATS_ITEM_MODIFIER)[user.item_db_symbol], user, target)).floor
    end

    EXPLOSION_SELF_DESTRUCT_MOVE = %i[explosion self-destruct]
    # [Spe]def calculation
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Integer]
    def calc_sp_def(user, target)
      # [Sp]Def = Stat * SM * Mod * SX
      ph_move = physical?
      # Stat
      result = ph_move ? target.dfe_basis : target.dfs_basis
      # SM
      result = (result * (ph_move ? target.dfe_modifier : target.dfs_modifier)).floor
      # Mod
      result = (result * 1.5).floor if !ph_move && $env.sandstorm? && target.type_rock?
      mod = send((ph_move ? DFE_ABILITY_MODIFIER : DFS_ABILITY_MODIFIER)[target.ability_db_symbol], user, target)
      result = (result * mod).floor
      mod = send((ph_move ? DFE_ITEM_MODIFIER : DFS_ITEM_MODIFIER)[target.item_db_symbol], user, target)
      result = (result * mod).floor
      # SX
      result = (result * VAL_0_5).floor if EXPLOSION_SELF_DESTRUCT_MOVE.include?(db_symbol)
      return result
    end

    # CH calculation
    # @param user [PFM::PokemonBattler] user of the move
    # @return [Numeric]
    def calc_ch(user)
      return 1 unless critical_hit?
      return 3 if user.ability_db_symbol == :sniper
      return 2
    end

    # STAB calculation
    # @param user [PFM::PokemonBattler] user of the move
    # @return [Numeric]
    def calc_stab(user)
      if user.type1 == type || user.type2 == type || user.type3 == type
        return 2 if user.ability_db_symbol == :adaptability
        return 1.5
      end
      return 1
    end

    # Calc TypeN multiplier of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @param type_to_check [Symbol] type to check on the target
    # @return [Numeric]
    def calc_type_n_multiplier(target, type_to_check)
      user_type = target.send(type_to_check)
      result = GameData::Type[user_type].hit_by(type)
      @effectiveness *= result
      return result
    end

    # "Calc" the R range value
    # @return [Range]
    def calc_r_range
      R_RANGE
    end
  end
end
