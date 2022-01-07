module PFM
  class Pokemon
    # Return the base HP
    # @return [Integer]
    def base_hp
      return data.base_hp
    end

    # Return the base ATK
    # @return [Integer]
    def base_atk
      return data.base_atk
    end

    # Return the base DFE
    # @return [Integer]
    def base_dfe
      return data.base_dfe
    end

    # Return the base SPD
    # @return [Integer]
    def base_spd
      return data.base_spd
    end

    # Return the base ATS
    # @return [Integer]
    def base_ats
      return data.base_ats
    end

    # Return the base DFS
    # @return [Integer]
    def base_dfs
      return data.base_dfs
    end

    # Return the max HP of the Pokemon
    # @return [Integer]
    def max_hp
      return 1 if db_symbol == :shedinja

      return ((@iv_hp + 2 * base_hp + @ev_hp / 4) * @level) / 100 + 10 + @level
    end

    # Return the current atk
    # @return [Integer]
    def atk
      return (atk_basis * atk_modifier).floor
    end

    # Return the current dfe
    # @return [Integer]
    def dfe
      return (dfe_basis * dfe_modifier).floor
    end

    # Return the current spd
    # @return [Integer]
    def spd
      return (spd_basis * spd_modifier).floor
    end

    # Return the current ats
    # @return [Integer]
    def ats
      return (ats_basis * ats_modifier).floor
    end

    # Return the current dfs
    # @return [Integer]
    def dfs
      return (dfs_basis * dfs_modifier).floor
    end

    # Return the atk stage
    # @return [Integer]
    def atk_stage
      return @battle_stage[0]
    end

    # Return the dfe stage
    # @return [Integer]
    def dfe_stage
      return @battle_stage[1]
    end

    # Return the spd stage
    # @return [Integer]
    def spd_stage
      return @battle_stage[2]
    end

    # Return the ats stage
    # @return [Integer]
    def ats_stage
      return @battle_stage[3]
    end

    # Return the dfs stage
    # @return [Integer]
    def dfs_stage
      return @battle_stage[4]
    end

    # Return the evasion stage
    # @return [Integer]
    def eva_stage
      return @battle_stage[5]
    end

    # Return the accuracy stage
    # @return [Integer]
    def acc_stage
      return @battle_stage[6]
    end

    # Change a stat stage
    # @param stat_id [Integer] id of the stat : 0 = atk, 1 = dfe, 2 = spd, 3 = ats, 4 = dfs, 5 = eva, 6 = acc
    # @param amount [Integer] the amount to change on the stat stage
    # @return [Integer] the difference between the current and the last stage value
    def change_stat(stat_id, amount)
      last_value = @battle_stage[stat_id]
      @battle_stage[stat_id] += amount
      if @battle_stage[stat_id] > 6
        @battle_stage[stat_id] = 6
      elsif @battle_stage[stat_id] < -6
        @battle_stage[stat_id] = -6
      end
      return @battle_stage[stat_id] - last_value
    end

    # Change the atk stage
    # @param amount [Integer] the amount to change on the stat stage
    # @return [Integer] the difference between the current and the last stage value
    def change_atk(amount)
      return change_stat(0, amount)
    end

    # Change the dfe stage
    # @param amount [Integer] the amount to change on the stat stage
    # @return [Integer] the difference between the current and the last stage value
    def change_dfe(amount)
      return change_stat(1, amount)
    end

    # Change the spd stage
    # @param amount [Integer] the amount to change on the stat stage
    # @return [Integer] the difference between the current and the last stage value
    def change_spd(amount)
      return change_stat(2, amount)
    end

    # Change the ats stage
    # @param amount [Integer] the amount to change on the stat stage
    # @return [Integer] the difference between the current and the last stage value
    def change_ats(amount)
      return change_stat(3, amount)
    end

    # Change the dfs stage
    # @param amount [Integer] the amount to change on the stat stage
    # @return [Integer] the difference between the current and the last stage value
    def change_dfs(amount)
      return change_stat(4, amount)
    end

    # Change the eva stage
    # @param amount [Integer] the amount to change on the stat stage
    # @return [Integer] the difference between the current and the last stage value
    def change_eva(amount)
      return change_stat(5, amount)
    end

    # Change the acc stage
    # @param amount [Integer] the amount to change on the stat stage
    # @return [Integer] the difference between the current and the last stage value
    def change_acc(amount)
      return change_stat(6, amount)
    end

    # Return the stage modifier (multiplier)
    # @param stage [Integer] the value of the stage
    # @return [Float] the multiplier
    def modifier_stage(stage)
      if stage >= 0
        return (2 + stage) / 2.0
      else
        return 2.0 / (2 - stage)
      end
    end

    # Return the atk modifier
    # @return [Float] the multiplier
    def atk_modifier
      return modifier_stage(atk_stage)
    end

    # Return the dfe modifier
    # @return [Float] the multiplier
    def dfe_modifier
      return modifier_stage(dfe_stage)
    end

    # Return the spd modifier
    # @return [Float] the multiplier
    def spd_modifier
      return modifier_stage(spd_stage)
    end

    # Return the ats modifier
    # @return [Float] the multiplier
    def ats_modifier
      return modifier_stage(ats_stage)
    end

    # Return the dfs modifier
    # @return [Float] the multiplier
    def dfs_modifier
      return modifier_stage(dfs_stage)
    end

    # Change the IV and update the statistics
    # @param list [Array<Integer>] list of new IV [hp, atk, dfe, spd, ats, dfs]
    def dv_modifier(list)
      @iv_hp = get_dv_value(list[0], @iv_hp)
      @iv_atk = get_dv_value(list[1], @iv_atk)
      @iv_dfe = get_dv_value(list[2], @iv_dfe)
      @iv_spd = get_dv_value(list[3], @iv_spd)
      @iv_ats = get_dv_value(list[4], @iv_ats)
      @iv_dfs = get_dv_value(list[5], @iv_dfs)
      @hp = max_hp
    end

    # Get the adjusted IV
    # @param value [Integer] the new value
    # @param old [Integer] the old value
    # @return [Integer] something between old and 31 (value in most case)
    def get_dv_value(value, old)
      if value < 0
        return old
      elsif value > 31
        return 31
      end
      return value
    end

    # Return the atk stat without battle modifier
    # @return [Integer]
    def atk_basis
      return calc_regular_stat(base_atk, @iv_atk, @ev_atk, 1)
    end

    # Return the dfe stat without battle modifier
    # @return [Integer]
    def dfe_basis
      return calc_regular_stat(base_dfe, @iv_dfe, @ev_dfe, 2)
    end

    # Return the spd stat without battle modifier
    # @return [Integer]
    def spd_basis
      return calc_regular_stat(base_spd, @iv_spd, @ev_spd, 3)
    end

    # Return the ats stat without battle modifier
    # @return [Integer]
    def ats_basis
      return calc_regular_stat(base_ats, @iv_ats, @ev_ats, 4)
    end

    # Return the dfs stat without battle modifier
    # @return [Integer]
    def dfs_basis
      return calc_regular_stat(base_dfs, @iv_dfs, @ev_dfs, 5)
    end

    # Change the HP value of the Pokemon
    # @note If v <= 0, the pokemon status become 0
    # @param v [Integer] the new HP value
    def hp=(v)
      if v <= 0
        @hp = 0
        @hp_rate = 0
        @status = 0
      elsif v >= max_hp
        @hp = max_hp
        @hp_rate = 1
      else
        @hp=v
        @hp_rate = v / max_hp.to_f
      end
    end

    # Return the EV HP text
    # @return [String]
    def ev_hp_text
      format(ev_text, ev_hp)
    end

    # Return the EV ATK text
    # @return [String]
    def ev_atk_text
      format(ev_text, ev_atk)
    end

    # Return the EV DFE text
    # @return [String]
    def ev_dfe_text
      format(ev_text, ev_dfe)
    end

    # Return the EV SPD text
    # @return [String]
    def ev_spd_text
      format(ev_text, ev_spd)
    end

    # Return the EV ATS text
    # @return [String]
    def ev_ats_text
      format(ev_text, ev_ats)
    end

    # Return the EV DFS text
    # @return [String]
    def ev_dfs_text
      format(ev_text, ev_dfs)
    end

    # Return the IV HP text
    # @return [String]
    def iv_hp_text
      format(iv_text, iv_hp)
    end

    # Return the IV ATK text
    # @return [String]
    def iv_atk_text
      format(iv_text, iv_atk)
    end

    # Return the IV DFE text
    # @return [String]
    def iv_dfe_text
      format(iv_text, iv_dfe)
    end

    # Return the IV SPD text
    # @return [String]
    def iv_spd_text
      format(iv_text, iv_spd)
    end

    # Return the IV ATS text
    # @return [String]
    def iv_ats_text
      format(iv_text, iv_ats)
    end

    # Return the IV DFS text
    # @return [String]
    def iv_dfs_text
      format(iv_text, iv_dfs)
    end

    private

    # Return the text "EV: %d"
    # @return [String]
    def ev_text
      'EV: %d'
    end

    # Return the text "IV: %d"
    # @return [String]
    def iv_text
      'IV: %d'
    end

    # Calculate the stat according to the stat formula
    # @param base [Integer] base of the stat
    # @param iv [Integer] IV of the stat
    # @param ev [Integer] EV of the stat
    # @param nature_index [Integer] Index of the nature modifier in the nature array
    def calc_regular_stat(base, iv, ev, nature_index)
      return (((2 * base + ev / 4 + iv) * @level / 100) + 5) * nature[nature_index] / 100
    end
  end
end
