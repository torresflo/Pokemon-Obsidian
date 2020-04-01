module GameData
  class JSONFromDataCollection
    private

    # Convert a Item collection
    # @return [Array]
    def convert_all_item
      item_json = @data.collect { |item| convert_single_item(item) }
      return item_json
    end

    # Convert a single item to JSON Ruby object
    # @param item [GameData::Item]
    # @return [Hash]
    def convert_single_item(item)
      hash = {
        id: item.id,
        db_symbol: item.db_symbol,
        icon: item.icon,
        price: item.price,
        socket: item.socket,
        sortPosition: item.position,
        battleUsable: item.battle_usable,
        mapUsable: item.map_usable,
        limiteUse: item.limited,
        holdable: item.holdable,
        flingPower: item.fling_power
      }
      hash[:healData] = convert_single_heal_data(item.heal_data) if item.heal_data
      hash[:ballData] = convert_single_ball_data(item.ball_data) if item.ball_data
      hash[:miscData] = convert_single_misc_data(item.misc_data) if item.misc_data
      return hash
    end

    # Convert a single heal data to JSON Ruby Object
    # @param data [GameData::ItemHeal]
    # @return [Hash]
    def convert_single_heal_data(data)
      hash = {
        hp: data.hp,
        hpRate: data.hp_rate
      }
      hash[:ppOnOneMove] = data.pp if data.pp
      hash[:ppOnAllMove] = data.all_pp if data.all_pp
      if data.add_pp
        hash[:OnePPIncrease] = data.add_pp == 1
        hash[:FullPPIncrease] = data.add_pp == 2
      end
      hash[:healStates] = data.states.collect { |state| States.index(state) } if data.states
      hash[:happinessIncrease] = data.loyalty if data.loyalty
      if data.boost_stat
        if data.boost_stat > 10
          hash[:addOneEVOn] = EV.index(data.boost_stat % 10)
        else
          hash[:addTenEVOn] = EV.index(data.boost_stat)
        end
      end
      hash[:levelUp] = data.level if data.level
      hash[:addStageOn] = Stages.index(data.battle_boost) if data.battle_boost
      return hash
    end

    # Convert a single ball data to a JSON Ruby Object
    # @param data [GameData::BallData]
    # @return [Hash]
    def convert_single_ball_data(data)
      hash = {
        battleImage: data.img,
        catchRate: data.catch_rate
      }
      hash[:specialCatchRate] = data.special_catch if data.special_catch
      return hash
    end

    # Convert a single item misc data to a JSON Ruby Object
    # @param data [GameData::ItemMisc]
    # @return [Hash]
    def convert_single_misc_data(data)
      hash = {
        callCommonEvent: data.event_id,
        isEvolveStone: data.stone,
        isFleeItem: data.flee
      }
      hash[:repelCount] = data.repel_count if data.repel_count
      if data.skill_learn
        hash[data.cs_id ? :HM : :TM] = data.cs_id || data.ct_id.to_i
        hash[:learnMove] = @no_symbol_conv ? data.skill_learn : Skill.db_symbol(data.skill_learn)
      end
      if data.need_user_id
        hash[:requireUser] = @no_symbol_conv ? data.need_user_id : Pokemon.db_symbol(data.need_user_id)
      end
      hash[:powerMoveClass] = data.check_atk_class if data.check_atk_class
      if data.powering_skill_type1
        hash[:powerMoveType1] = @no_symbol_conv ? data.powering_skill_type1 : Skill.db_symbol(data.powering_skill_type1)
      end
      if data.powering_skill_type2
        hash[:powerMoveType2] = @no_symbol_conv ? data.powering_skill_type2 : Skill.db_symbol(data.powering_skill_type2)
      end
      if (moves = data.need_ids_ph_2)
        moves = moves.collect { |move| Skill.db_symbol(move) } unless @no_symbol_conv
        hash[:powerPhysicalMovesOf] = moves
      end
      if (moves = data.need_ids_sp_2)
        moves = moves.collect { |move| Skill.db_symbol(move) } unless @no_symbol_conv
        hash[:powerSpecialMovesOf] = moves
      end
      if (moves = data.need_ids_sp_1_5)
        moves = moves.collect { |move| Skill.db_symbol(move) } unless @no_symbol_conv
        hash[:poweraLittleSpecialMovesOf] = moves
      end
      hash[:accuracyFactor] = data.acc if data.acc
      hash[:evasionFactor] = data.eva if data.eva
      hash[:berryData] = data.berry if data.berry
      return hash
    end
  end

  class Item
    class << self
      # Convert all the items to a JSON file
      # @param filename [String] name of the file
      # @param use_id [Boolean] if the ID used in the various data part should not be converted to Symbol
      def to_json(filename, use_id = false)
        load if all.empty?
        JSONFromDataCollection.new(all, use_id).convert(filename)
      end
    end
  end
end
