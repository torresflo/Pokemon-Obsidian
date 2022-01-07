module PFM
  class Pokemon
    # Is the Pokemon not able to fight
    # @return [Boolean]
    def dead?
      return hp <= 0 || egg?
    end

    # Is the Pokemon able to fight
    # @return [Boolean]
    def alive?
      return hp > 0 && !egg?
    end

    # Is the pokemon affected by a status
    # @return [Boolean]
    def status?
      return @status != 0
    end

    # Cure the Pokemon from its statues modifications
    def cure
      @status = 0
      @status_count = 0
    end

    # Is the Pokemon poisoned?
    # @return [Boolean]
    def poisoned?
      return @status == GameData::States::POISONED
    end

    # Empoison the Pokemon
    # @param forcing [Boolean] force the new status
    # @return [Boolean] if the pokemon has been empoisoned
    def status_poison(forcing = false)
      if (@status == 0 || forcing) && !dead?
        @status = GameData::States::POISONED
        return true
      end
      return false
    end

    # Can the Pokemon be poisoned ?
    # @return [Boolean]
    def can_be_poisoned?
      return false if type_poison? || type_steel?
      return false if @status != 0

      return true
    end

    # Is the Pokemon paralyzed?
    # @return [Boolean]
    def paralyzed?
      return @status == GameData::States::PARALYZED
    end

    # Paralyze the Pokemon
    # @param forcing [Boolean] force the new status
    # @return [Boolean] if the pokemon has been paralyzed
    def status_paralyze(forcing = false)
      if (@status == 0 || forcing) && !dead?
        @status = GameData::States::PARALYZED
        return true
      end
      return false
    end

    # Can the Pokemon be paralyzed?
    # @return [Boolean]
    def can_be_paralyzed?
      return false if @status != 0
      return false if !::GameData::Flag_4G && type_electric?

      return true
    end

    # Is the Pokemon burnt?
    # @return [Boolean]
    def burn?
      return @status == GameData::States::BURN
    end
    alias burnt? burn?

    # Burn the Pokemon
    # @param forcing [Boolean] force the new status
    # @return [Boolean] if the pokemon has been burnt
    def status_burn(forcing = false)
      if (@status == 0 || forcing) && !dead?
        @status = GameData::States::BURN
        return true
      end
      return false
    end

    # Can the Pokemon be burnt?
    # @return [Boolean]
    def can_be_burn?
      return @status == 0 && !type_fire?
    end

    # Is the Pokemon asleep?
    # @return [Boolean]
    def asleep?
      return @status == GameData::States::ASLEEP
    end

    # Put the Pokemon to sleep
    # @param forcing [Boolean] force the new status
    # @param nb_turn [Integer, nil] number of turn the Pokemon will sleep
    # @return [Boolean] if the pokemon has been put to sleep
    def status_sleep(forcing = false, nb_turn = nil)
      if (@status == 0 || forcing) && !dead?
        @status = GameData::States::ASLEEP
        if nb_turn
          @status_count = nb_turn
        else
          @status_count = $scene.is_a?(Battle::Scene) ? $scene.logic.generic_rng.rand(2..5) : rand(2..5)
        end
        @status_count = (@status_count / 2).floor if $scene.is_a?(Battle::Scene) ? has_ability?(:early_bird) : ability_db_symbol == :early_bird
        return true
      end
      return false
    end

    # Can the Pokemon be asleep?
    # @return [Boolean]
    def can_be_asleep?
      return false if @status != 0

      return true
    end

    # Check if the Pokemon is still asleep
    # @return [Boolean] true = the Pokemon is still asleep
    def sleep_check
      @status_count -= 1
      return true if @status_count > 0

      @status = 0
      return false
    end

    # Is the Pokemon frozen?
    # @return [Boolean]
    def frozen?
      return @status == GameData::States::FROZEN
    end

    # Freeze the Pokemon
    # @param forcing [Boolean] force the new status
    # @return [Boolean] if the pokemon has been frozen
    def status_frozen(forcing = false)
      if (@status == 0 || forcing) && !dead?
        @status = GameData::States::FROZEN
        return true
      end
      return false
    end

    # Can the Pokemon be frozen?
    # @return [Boolean]
    def can_be_frozen?(skill_type = 0)
      return false if @status != 0 || (skill_type == 6 && type_ice?)

      return true
    end

    # Is the Pokemon in toxic state ?
    # @return [Boolean]
    def toxic?
      return @status == GameData::States::TOXIC
    end

    # Intoxicate the Pokemon
    # @param forcing [Boolean] force the new status
    # @return [Boolean] if the pokemon has been intoxicated
    def status_toxic(forcing = true)
      if (@status == 0 || forcing) && !dead?
        @status = GameData::States::TOXIC
        @status_count = 0
        return true
      end
      return false
    end
  end
end
