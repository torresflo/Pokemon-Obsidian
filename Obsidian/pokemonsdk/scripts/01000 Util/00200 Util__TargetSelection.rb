#encoding: utf-8

module Util
  # Helper for target Pokemon selection (in Battle)
  # @author Nuri Yuri
  module TargetSelection
    # Get the adjacent Pokemon
    # @param launcher [PFM::Pokemon] the launcher of the attack
    # @return [Array<PFM::Pokemon>] the possible targets
    def util_targetselection_adjacent_pokemon(launcher)
      enemies = ::BattleEngine.get_enemies!(launcher)
      allies = ::BattleEngine.get_ally!(launcher)
      arr = []
      position = -launcher.position-1
      other = nil
      enemies.each do |other|
        unless !other or other.dead?
          arr << other if (other.position-position).abs <= 1
        end
      end
      position = launcher.position
      allies.each do |other|
        unless !other or other.dead?
          arr << other if (other.position-position).abs == 1
        end
      end
      return arr
    end
    # Get the adjacent foe
    # @param launcher [PFM::Pokemon] the launcher of the attack
    # @return [Array<PFM::Pokemon>] the possible targets
    def util_targetselection_adjacent_foe(launcher)
      enemies = ::BattleEngine.get_enemies!(launcher)
      position = -launcher.position-1
      other = nil
      arr = []
      enemies.each do |other|
        unless !other or other.dead?
          arr << other if (other.position-position).abs <= 1
        end
      end
      return arr
    end
    # Get the adjacent ally
    # @param launcher [PFM::Pokemon] the launcher of the attack
    # @return [Array<PFM::Pokemon>] the possible targets
    def util_targetselection_adjacent_ally(launcher)
      allies = ::BattleEngine.get_ally!(launcher)
      other = nil
      arr = []
      position = launcher.position
      allies.each do |other|
        unless !other or other.dead?
          arr << other if (other.position-position).abs == 1
        end
      end
      return arr
    end
    # Automatically select a target
    # @param launcher [PFM::Pokemon] the launcher of the attack
    # @param skill [PFM::Skill] the skill that will be used
    # @return [Array<PFM::Pokemon>] the possible targets
    def util_targetselection_automatic(launcher, skill)
      case skill.target
      when :adjacent_pokemon      #  eo eo ex / ux ao ax
        arr = util_targetselection_adjacent_foe(launcher)
        return [arr[rand(arr.size)]] if arr.size > 0
      when :adjacent_foe          #  eo eo ex / ux ax ax
        arr = util_targetselection_adjacent_foe(launcher)
        return [arr[rand(arr.size)]] if arr.size > 0
      when :adjacent_all_foe      #  e! e! ex / ux ax ax
        return util_targetselection_adjacent_foe(launcher)
      when :all_foe               #  e! e! e! / ux ax ax
        return ::BattleEngine.get_enemies!(launcher)
      when :adjacent_all_pokemon  #  e! e! ex / ux a! ax
        return util_targetselection_adjacent_pokemon(launcher)
      when :all_pokemon           #  e! e! e! / u! a! a!
        return ::BattleEngine.get_enemies!(launcher) + ::BattleEngine.get_ally!(launcher)
      when :user                  #  ex ex ex / u! ax ax
        return [launcher]
      when :user_or_adjacent_ally #  ex ex ex / uo ao ax
        arr = [launcher]+util_targetselection_adjacent_ally(launcher)
        return [arr[rand(arr.size)]] if arr.size > 0
      when :adjacent_ally         #  ex ex ex / ux ao ax
        arr = util_targetselection_adjacent_ally(launcher)
        return [arr[rand(arr.size)]] if arr.size > 0
      when :all_ally              #  ex ex ex / u! a! a!
        return ::BattleEngine.get_ally!(launcher)
      when :any_other_pokemon     #  ex ex ex / uo ax ax
        arr = ::BattleEngine.get_enemies!(launcher)
        arr += util_targetselection_adjacent_ally(launcher)
        return [arr[rand(arr.size)]] if arr.size > 0
      when :random_foe            #  e? e? e? / ux ax ax
        arr = ::BattleEngine.get_enemies!(launcher)
        return [arr[rand(arr.size)]] if arr.size > 0
      end
      return [launcher]
    end
    # Get the list of possible target
    # @param launcher [PFM::Pokemon] the launcher of the attack
    # @param skill [PFM::Skill] the skill that will be used
    # @return [Array<PFM::Pokemon>, nil] the possible targets
    def util_targetselection_get_possible(launcher,skill)
      if launcher.position < 0
        arr = []
        util_targetselection_adjacent_pokemon(launcher).each do |target|
          arr << target if seviper_zangoose_detect(launcher, target)
        end
        return arr if arr.size > 0
      end
      case skill.target
      when :adjacent_pokemon      #  eo eo ex / ux ao ax
        return util_targetselection_adjacent_pokemon(launcher)
      when :adjacent_foe          #  eo eo ex / ux ax ax
        return util_targetselection_adjacent_foe(launcher)
      when :user_or_adjacent_ally #  ex ex ex / uo ao ax
        return [launcher]+util_targetselection_adjacent_ally(launcher)
      when :adjacent_ally         #  ex ex ex / ux ao ax
        return util_targetselection_adjacent_ally(launcher)
      when :any_other_pokemon     #  ex ex ex / uo ax ax
        arr = ::BattleEngine.get_enemies!(launcher)
        arr += util_targetselection_adjacent_ally(launcher)
        return arr
      end
      return nil
    end
    # Detect if two pokemon are naturally enemies
    # @param launcher [PFM::Pokemon] the Pokemon that should launch the attack
    # @param target [PFM::Pokemon] the Pokemon that can receive the attack
    def seviper_zangoose_detect(launcher, target)
      case launcher.db_symbol
      when :zangoose # Zangoose
        return true if target.db_symbol == :seviper
      when :seviper # Seviper
        return true if target.db_symbol == :zangoose
      end
      return false
    end
    #====
  end
end
