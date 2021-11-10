#encoding: utf-8

#noyard
module BattleEngine
  module_function

  # Recoil skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  Recoil_3 = [394, 38, 344, 452, 413]
  def s_recoil(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)

    #> Skill check
    if skill.power > 0
      if Abilities.has_ability_usable(launcher, 54) #> Reckless
        skill.power2 = skill.power * 120 / 100
      end
      hp = _damage_calculation(launcher, target, skill).to_i
      hp = target.max_hp if hp > target.max_hp
      skill.power2 = nil
      return false if __s_hp_down_check(hp, target)
      #> Recoil : Rock Head / Magic Guard
      unless Abilities.has_abilities(launcher, 38, 17)
        n = Recoil_3.include?(skill.id) ? 3 : 4
        n = 2 if skill.id == 457 || skill.id == 617 #> Head Smash / Light of Ruin
        _message_stack_push([:hp_down, launcher, hp / n])
        _message_stack_push([:msg, parse_text_with_pokemon(19, 378, launcher)])
      end
      did_something = true
    end
    did_something |= __s_stat_us_step(launcher, target, skill)
    unless did_something
      _message_stack_push(MSG_Fail)
    end
    return did_something
  end

  # Explosion skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_explosion(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    if Abilities.has_ability_usable(launcher, 28) #> Damp
      if msg_push
        _mp([:ability_display, target])
        _mp(MSG_Fail)
      end
      return
    end
    if Abilities.has_ability_usable(target, 28) #> Damp
      _mp([:ability_display, target])
    else
      _message_stack_push([:hp_down, launcher, launcher.max_hp]) if msg_push
      hp=_damage_calculation(launcher, target, skill).to_i
      __s_hp_down_check(hp, target)
    end
  end

  # Flame Burst skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_flame_burst(launcher, target, skill, msg_push = true)
    return false unless s_basic(launcher, target, skill)
    # If the target has the Flash Fire (Torche) ability, no side effect
    unless Abilities.has_abilities(target, 18)
      # Launcher's adjacents allies take damages
      get_ally(launcher).each { |i| _mp([:hp_down, i, i.max_hp/16]) }
    end
  end

  # Jump Kick skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_jump_kick(launcher, target, skill, msg_push = true)
    if Abilities.has_ability_usable(launcher, 54) #> Reckless
      skill.power2 = skill.power * 120 / 100
    end
    failed = !s_basic(launcher, target, skill)
    skill.power2 = nil
    if failed
      _message_stack_push([:msg, parse_text_with_pokemon(19, 908, launcher)])
      _message_stack_push([:hp_down, launcher, launcher.max_hp / 2])
    end
  end

  # Grudge skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_grudge(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    unless target.battle_effect.has_grudge_effect?
      _mp([:msg, parse_text_with_pokemon(19, 632, target)])
      _mp([:apply_effect, target, :apply_grudge])
    else
      _mp([:msg_fail])
    end
  end

end