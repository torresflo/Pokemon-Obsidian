module PFM
  class Pokemon
    # Return the current first type of the Pokemon
    # @return [Integer]
    def type1
      return @type1 || data.type1
    end

    # Return the current second type of the Pokemon
    # @return [Integer]
    def type2
      return @type2 || data.type2
    end

    # Return the current third type of the Pokemon
    # @return [Integer]
    def type3
      return @type3 || 0
    end

    # Is the Pokemon type normal ?
    # @return [Boolean]
    def type_normal?
      return type?(GameData::Types::NORMAL)
    end

    # Is the Pokemon type fire ?
    # @return [Boolean]
    def type_fire?
      return type?(GameData::Types::FIRE)
    end
    alias type_feu? type_fire?

    # Is the Pokemon type water ?
    # @return [Boolean]
    def type_water?
      return type?(GameData::Types::WATER)
    end
    alias type_eau? type_water?
    # Is the Pokemon type electric ?
    # @return [Boolean]
    def type_electric?
      return type?(GameData::Types::ELECTRIC)
    end
    alias type_electrique? type_electric?

    # Is the Pokemon type grass ?
    # @return [Boolean]
    def type_grass?
      return type?(GameData::Types::GRASS)
    end
    alias type_plante? type_grass?

    # Is the Pokemon type ice ?
    # @return [Boolean]
    def type_ice?
      return type?(GameData::Types::ICE)
    end
    alias type_glace? type_ice?

    # Is the Pokemon type fighting ?
    # @return [Boolean]
    def type_fighting?
      return type?(GameData::Types::FIGHTING)
    end
    alias type_combat? type_fighting?

    # Is the Pokemon type poison ?
    # @return [Boolean]
    def type_poison?
      return type?(GameData::Types::POISON)
    end

    # Is the Pokemon type ground ?
    # @return [Boolean]
    def type_ground?
      return type?(GameData::Types::GROUND)
    end
    alias type_sol? type_ground?

    # Is the Pokemon type fly ?
    # @return [Boolean]
    def type_flying?
      return type?(GameData::Types::FLYING)
    end
    alias type_vol? type_flying?
    alias type_fly? type_flying?

    # Is the Pokemon type psy ?
    # @return [Boolean]
    def type_psychic?
      return type?(GameData::Types::PSYCHIC)
    end
    alias type_psy? type_psychic?

    # Is the Pokemon type insect/bug ?
    # @return [Boolean]
    def type_bug?
      return type?(GameData::Types::BUG)
    end
    alias type_insect? type_bug?

    # Is the Pokemon type rock ?
    # @return [Boolean]
    def type_rock?
      return type?(GameData::Types::ROCK)
    end
    alias type_roche? type_rock?

    # Is the Pokemon type ghost ?
    # @return [Boolean]
    def type_ghost?
      return type?(GameData::Types::GHOST)
    end
    alias type_spectre? type_ghost?

    # Is the Pokemon type dragon ?
    # @return [Boolean]
    def type_dragon?
      return type?(GameData::Types::DRAGON)
    end

    # Is the Pokemon type steel ?
    # @return [Boolean]
    def type_steel?
      return type?(GameData::Types::STEEL)
    end
    alias type_acier? type_steel?

    # Is the Pokemon type dark ?
    # @return [Boolean]
    def type_dark?
      return type?(GameData::Types::DARK)
    end
    alias type_tenebre? type_dark?

    # Is the Pokemon type fairy ?
    # @return [Boolean]
    def type_fairy?
      return type?(GameData::Types::FAIRY)
    end
    alias type_fee? type_fairy?

    # Check the Pokemon type by the type ID
    # @param type [Integer] ID of the type in the database
    # @return [Boolean]
    def type?(type)
      return (type1 == type || type2 == type || type3 == type)
    end
  end
end
