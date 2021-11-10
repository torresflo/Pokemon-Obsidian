module Battle
  class Move
    # Is the skill a specific type ?
    # @param type_id [Integer] ID of the type
    def type?(type_id)
      return type == type_id
    end

    # Is the skill type normal ?
    # @return [Boolean]
    def type_normal?
      return type?(GameData::Types::NORMAL)
    end

    # Is the skill type fire ?
    # @return [Boolean]
    def type_fire?
      return type?(GameData::Types::FIRE)
    end
    alias type_feu? type_fire?

    # Is the skill type water ?
    # @return [Boolean]
    def type_water?
      return type?(GameData::Types::WATER)
    end
    alias type_eau? type_water?

    # Is the skill type electric ?
    # @return [Boolean]
    def type_electric?
      return type?(GameData::Types::ELECTRIC)
    end
    alias type_electrique? type_electric?

    # Is the skill type grass ?
    # @return [Boolean]
    def type_grass?
      return type?(GameData::Types::GRASS)
    end
    alias type_plante? type_grass?

    # Is the skill type ice ?
    # @return [Boolean]
    def type_ice?
      return type?(GameData::Types::ICE)
    end
    alias type_glace? type_ice?

    # Is the skill type fighting ?
    # @return [Boolean]
    def type_fighting?
      return type?(GameData::Types::FIGHTING)
    end
    alias type_combat? type_fighting?

    # Is the skill type poison ?
    # @return [Boolean]
    def type_poison?
      return type?(GameData::Types::POISON)
    end

    # Is the skill type ground ?
    # @return [Boolean]
    def type_ground?
      return type?(GameData::Types::GROUND)
    end
    alias type_sol? type_ground?

    # Is the skill type fly ?
    # @return [Boolean]
    def type_flying?
      return type?(GameData::Types::FLYING)
    end
    alias type_vol? type_flying?
    alias type_fly? type_flying?

    # Is the skill type psy ?
    # @return [Boolean]
    def type_psychic?
      return type?(GameData::Types::PSYCHIC)
    end
    alias type_psy? type_psychic?

    # Is the skill type insect/bug ?
    # @return [Boolean]
    def type_insect?
      return type?(GameData::Types::BUG)
    end
    alias type_bug? type_insect?

    # Is the skill type rock ?
    # @return [Boolean]
    def type_rock?
      return type?(GameData::Types::ROCK)
    end
    alias type_roche? type_rock?

    # Is the skill type ghost ?
    # @return [Boolean]
    def type_ghost?
      return type?(GameData::Types::GHOST)
    end
    alias type_spectre? type_ghost?

    # Is the skill type dragon ?
    # @return [Boolean]
    def type_dragon?
      return type?(GameData::Types::DRAGON)
    end

    # Is the skill type steel ?
    # @return [Boolean]
    def type_steel?
      return type?(GameData::Types::STEEL)
    end
    alias type_acier? type_steel?

    # Is the skill type dark ?
    # @return [Boolean]
    def type_dark?
      return type?(GameData::Types::DARK)
    end
    alias type_tenebre? type_dark?

    # Is the skill type fairy ?
    # @return [Boolean]
    def type_fairy?
      return type?(GameData::Types::FAIRY)
    end
    alias type_fee? type_fairy?

  end
end
