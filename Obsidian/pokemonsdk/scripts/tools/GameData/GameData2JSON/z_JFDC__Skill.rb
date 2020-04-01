module GameData
  class JSONFromDataCollection
    private

    # Convert a Skill collection
    # @return [Array]
    def convert_all_skill
      item_json = @data.collect { |item| convert_single_skill(item) }
      return item_json
    end

    # Convert a single skill to JSON Ruby object
    # @param skill [GameData::Skill]
    # @return [Hash]
    def convert_single_skill(skill)
      hash = {
        id: skill.id,
        db_symbol: skill.db_symbol,
        callCommonEvent: skill.map_use,
        battleEngineHandler: skill.be_method,
        type: skill.type,
        basePower: skill.power,
        baseAccuracy: skill.accuracy,
        ppCount: skill.pp_max,
        target: skill.target,
        class: skill.atk_class,
        criticalRateType: skill.critical_rate,
        priority: skill.priority,
        contact: skill.direct,
        effect_chance: skill.effect_chance,
        canBeBlocked: skill.blocable,
        isSnatchable: skill.snatchable,
        canBeMirrored: skill.mirror_move,
        canBeReflected: skill.magic_coat_affected,
        isFlyingMove: skill.gravity,
        isSoundMove: skill.sound_attack,
        canUnfreeze: skill.unfreeze,
        triggerKingRock: skill.king_rock_utility,
        stageIncrease: skill.battle_stage_mod
      }
      if skill.status && skill.status > 0
        hash[:inflict] = @no_symbol_conv ? skill.status : States.index(skill.status)
      end
      return hash
    end
  end

  class Skill
    class << self
      # Convert all the moves to a JSON file
      # @param filename [String] name of the file
      # @param use_id [Boolean] if the ID used in the various data part should not be converted to Symbol
      def to_json(filename, use_id = false)
        load if all.empty?
        JSONFromDataCollection.new(all, use_id).convert(filename)
      end
    end
  end
end
