#encoding: utf-8

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
    def status_poison(forcing=false)
      if((@status==0 or forcing) and !dead?)
        @status = GameData::States::POISONED
        return true
      end
      return false
    end
    # Can the Pokemon be poisoned ?
    # @return [Boolean]
    def can_be_poisoned?
      return false if type_poison? or type_steel?
      return false if @status != 0
      return true
    end
    # Return the Poison effect on HP of the Pokemon
    # @return [Integer] number of HP loosen
    def poison_effect
      return max_hp/8
    end
    # Is the Pokemon paralyzed?
    # @return [Boolean]
    def paralyzed?
      return @status == GameData::States::PARALYZED
    end
    # Paralyze the Pokemon
    # @param forcing [Boolean] force the new status
    # @return [Boolean] if the pokemon has been paralyzed
    def status_paralyze(forcing=false)
      if((@status==0 or forcing) and !dead?)
        @status = GameData::States::PARALYZED
        return true
      end
      return false
    end
    # Can the Pokemon be paralyzed?
    # @return [Boolean]
    def can_be_paralyzed?
      return false if @status != 0
      return false if !::GameData::Flag_4G and type_electric?
      return true
    end
    # Paralyze check rate that prevent the Pokemon from using a move
    Paralyze_Check_Rate = 0.25
    # Paralyz check rate that prevent the Pokemon from using a move (in %)
    Paralyze_check_rate = (100*Paralyze_Check_Rate).to_i
    # Check if the Pokemon cannot move
    # @return [Boolean]
    def paralysis_check
      return rand(100)<Paralyze_check_rate
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
    def status_burn(forcing=false)
      if((@status==0 or forcing) and !dead?)
        @status = GameData::States::BURN
        return true
      end
      return false
    end
    # Can the Pokemon be burnt?
    # @return [Boolean]
    def can_be_burn?
      return false if @status != 0 or type_fire?
      return true
    end
    # Return the burn effect on HP of the Pokemon
    # @return [Integer] number of HP loosen by burn
    def burn_effect
      return max_hp/8
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
    def status_sleep(forcing=false, nb_turn = nil)
      if((@status==0 or forcing) and !dead?)
        @status = GameData::States::ASLEEP
        @status_count = nb_turn ? nb_turn : rand(4) + 2
        #Vérifier la capacité qui réduit le nombre de tours du someil
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
      @status_count-=1
      if @status_count>0
        return true
      end
      @status=0
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
    def status_frozen(forcing=false)
      if((@status==0 or forcing) and !dead?)
        @status = GameData::States::FROZEN
        return true
      end
      return false
    end
    # Can the Pokemon be frozen?
    # @return [Boolean]
    def can_be_frozen?(skill_type = 0)
      return false if @status != 0 or (skill_type == 6 and type_ice?)
      return true
    end
    # Rate the Pokemon can be unfreeze
    Froze_Check_Rate = 0.1
    # Rate the Pokemon can be unfreeze in %
    Froze_check_rate = (100*Froze_Check_Rate).to_i
    # Check if the Pokemon is still frozen
    # @return [Boolean]
    def froze_check
      if(rand(100)<Froze_check_rate)
        @status=0
        return false
      end
      return true
    end
    # Is the Pokemon confused?
    # @return [Boolean]
    def confused?
      return @confuse
    end
    # Confuse the Pokemon
    # @param forcing [Boolean] force the new status
    # @return [Boolean] if the pokemon has been confused
    def status_confuse(forcing=false)
      if((!@confuse or forcing) and !dead?)
        @confuse=true
        @state_count=rand(4)+2
        return true
      end
      return false
    end
    # Check if the Pokemon is still confused
    # @return [Boolean, :cured] true = get confuse damage, :cured = not confuse anymore
    def confuse_check
      if @state_count > 0
        @state_count -= 1
        return rand(2) == 0
      end
      @confuse = false
      return :cured #Le pokémon est soigné de la confusion
    end
    # Return the amount of damage the Pokemon receive from confusion
    # @return [Integer]
    def confuse_damage
      return (((@level*2/5 + 2)*40*self.atk/self.dfe)/50).to_i
    end
    # Is the Pokemon in toxic state ?
    # @return [Boolean]
    def toxic?
      return @status == GameData::States::TOXIC
    end
    # Intoxicate the Pokemon
    # @param forcing [Boolean] force the new status
    # @return [Boolean] if the pokemon has been intoxicated
    def status_toxic(forcing=true)
      if((@status==0 or forcing) and !dead?)
        @status = GameData::States::TOXIC
        @status_count=0
        return true
      end
      return false
    end
    # Return the number of HP the Pokemon looses
    # @param no_count [Boolean] if the toxic counter doesn't increase
    # @return [Integer] number of HP loosen
    def toxic_effect(no_count = false)
      @status_count+=1 unless no_count
      return (max_hp*@status_count)/16
    end
  end
end
