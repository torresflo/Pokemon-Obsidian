module PFM
  class Pokemon
    # Return the list of EV the pokemon gives when beaten
    # @return [Array<Integer>] ev list (used in bonus functions) : [hp, atk, dfe, spd, ats, dfs]
    def battle_list
      data = get_data
      return [data.ev_hp, data.ev_atk, data.ev_dfe, data.ev_spd, data.ev_ats, data.ev_dfs]
    end

    # Add ev bonus to a Pokemon (with item interaction : x2)
    # @param list [Array<Integer>] an ev list  : [hp, atk, dfe, spd, ats, dfs]
    # @return [Boolean, nil] if the ev had totally been added or not (nil = couldn't be added at all)
    def add_bonus(list)
      return nil if egg?

      ev = GameData::EV
      # Bracelet Macho
      n = item_db_symbol == :macho_brace ? 2 : 1
      r = add_ev_hp(list[ev::HP] * n, total_ev)
      r &= add_ev_atk(list[ev::ATK] * n, total_ev)
      r &= add_ev_dfe(list[ev::DFE] * n, total_ev)
      r &= add_ev_spd(list[ev::SPD] * n, total_ev)
      r &= add_ev_ats(list[ev::ATS] * n, total_ev)
      r &= add_ev_dfs(list[ev::DFS] * n, total_ev)
      return r
    end

    # Add ev bonus to a Pokemon (without item interaction)
    # @param list [Array<Integer>] an ev list  : [hp, atk, dfe, spd, ats, dfs]
    # @return [Boolean, nil] if the ev had totally been added or not (nil = couldn't be added at all)
    def edit_bonus(list)
      return nil if egg?

      ev = GameData::EV
      r = add_ev_hp(list[ev::HP], total_ev)
      r &= add_ev_atk(list[ev::ATK], total_ev)
      r &= add_ev_dfe(list[ev::DFE], total_ev)
      r &= add_ev_spd(list[ev::SPD], total_ev)
      r &= add_ev_ats(list[ev::ATS], total_ev)
      r &= add_ev_dfs(list[ev::DFS], total_ev)
      return r
    end

    # Return the total amount of EV
    # @return [Integer]
    def total_ev
      return @ev_hp + @ev_atk + @ev_dfe + @ev_spd + @ev_ats + @ev_dfs
    end

    # Automatic ev adder using an index
    # @param index [Integer] ev index (see GameData::EV), should add 10. If index > 10 take index % 10 and add only 1 EV.
    # @param apply [Boolean] if the ev change is applied
    # @param count [Integer] number of EV to add
    # @return [Integer, false] if not false, the value of the current EV depending on the index
    def ev_check(index, apply = false, count = 1)
      evs = total_ev
      return false if evs >= GameData::EV::MAX_TOTAL_EV

      if index >= 10
        index = index % 10
        return (ev_var(index, evs, apply ? count : 0) < GameData::EV::MAX_STAT_EV)
      else
        return (ev_var(index, evs, apply ? 10 : 0) < 100)
      end
    end

    # Get and add EV
    # @param index [Integer] ev index (see GameData::EV)
    # @param evs [Integer] the total ev
    # @param value [Integer] the quantity of EV to add (if 0 no add)
    # @return [Integer]
    def ev_var(index, evs, value = 0)
      ev = GameData::EV
      case index
      when ev::HP
        add_ev_hp(value, evs) if value > 0
        return @ev_hp
      when ev::ATK
        add_ev_atk(value, evs) if value > 0
        return @ev_atk
      when ev::DFE
        add_ev_dfe(value, evs) if value > 0
        return @ev_dfe
      when ev::SPD
        add_ev_spd(value, evs) if value > 0
        return @ev_spd
      when ev::ATS
        add_ev_ats(value, evs) if value > 0
        return @ev_ats
      when ev::DFS
        add_ev_dfs(value, evs) if value > 0
        return @ev_dfs
      else
        return 0
      end
    end

    # Safely add HP EV
    # @param n [Integer] amount of EV to add
    # @param evs [Integer] total ev
    # @return [Boolean] if the ev has successfully been added
    def add_ev_hp(n, evs)
      return true if n == 0

      n -= 1 while (evs + n) > GameData::EV::MAX_TOTAL_EV
      return false if @ev_hp > GameData::EV::MAX_STAT_EV - 1

      @ev_hp += n
      @ev_hp.clamp(0, GameData::EV::MAX_STAT_EV)
      @hp = (@hp_rate * max_hp).round
      @hp_rate = @hp.to_f / max_hp
      return true
    end

    # Safely add ATK EV
    # @param n [Integer] amount of EV to add
    # @param evs [Integer] total ev
    # @return [Boolean] if the ev has successfully been added
    def add_ev_atk(n, evs)
      return true if n == 0

      n -= 1 while (evs + n) > GameData::EV::MAX_TOTAL_EV
      return false if @ev_atk > GameData::EV::MAX_STAT_EV - 1

      @ev_atk += n
      @ev_atk.clamp(0, GameData::EV::MAX_STAT_EV)
      return true
    end

    # Safely add DFE EV
    # @param n [Integer] amount of EV to add
    # @param evs [Integer] total ev
    # @return [Boolean] if the ev has successfully been added
    def add_ev_dfe(n, evs)
      return true if n == 0

      n -= 1 while (evs + n) > GameData::EV::MAX_TOTAL_EV
      return false if @ev_dfe > GameData::EV::MAX_STAT_EV - 1

      @ev_dfe += n
      @ev_dfe.clamp(0, GameData::EV::MAX_STAT_EV)
      return true
    end

    # Safely add SPD EV
    # @param n [Integer] amount of EV to add
    # @param evs [Integer] total ev
    # @return [Boolean] if the ev has successfully been added
    def add_ev_spd(n, evs)
      return true if n == 0

      n -= 1 while (evs + n) > GameData::EV::MAX_TOTAL_EV
      return false if @ev_spd > GameData::EV::MAX_STAT_EV - 1

      @ev_spd += n
      @ev_spd.clamp(0, GameData::EV::MAX_STAT_EV)
      return true
    end

    # Safely add ATS EV
    # @param n [Integer] amount of EV to add
    # @param evs [Integer] total ev
    # @return [Boolean] if the ev has successfully been added
    def add_ev_ats(n, evs)
      return true if n == 0

      n -= 1 while (evs + n) > GameData::EV::MAX_TOTAL_EV
      return false if @ev_ats > GameData::EV::MAX_STAT_EV - 1

      @ev_ats += n
      @ev_ats.clamp(0, GameData::EV::MAX_STAT_EV)
      return true
    end

    # Safely add DFS EV
    # @param n [Integer] amount of EV to add
    # @param evs [Integer] total ev
    # @return [Boolean] if the ev has successfully been added
    def add_ev_dfs(n, evs)
      return true if n == 0

      n -= 1 while (evs + n) > GameData::EV::MAX_TOTAL_EV
      return false if @ev_dfs > GameData::EV::MAX_STAT_EV - 1

      @ev_dfs += n
      @ev_dfs.clamp(0, GameData::EV::MAX_STAT_EV)
      return true
    end
  end
end
