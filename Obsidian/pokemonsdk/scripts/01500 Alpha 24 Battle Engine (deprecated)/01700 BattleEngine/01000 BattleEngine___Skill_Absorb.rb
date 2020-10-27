#encoding: utf-8

#noyard

# Absorb related skills
module BattleEngine
  module_function

  # Absorb skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_absorb(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)

    hp = _damage_calculation(launcher, target, skill).to_i
    hp = target.max_hp if hp > target.max_hp
    return false if __s_hp_down_check(hp, target)

    #> Big Root
    hp = hp * 130 / 100 if _has_item(launcher, 296)
    #> Draining Kiss
    hp = hp * 150 / 100 if skill.id == 577
    hp = 2 if hp < 2 #> To get 1HP if that deals less than 2HP damages
    #> Liquid Ooze
    if target.ability == 36
      _message_stack_push([:hp_down, launcher, hp / 2])
      _message_stack_push([:msg, parse_text_with_pokemon(19, 457, launcher)])
    elsif !launcher.battle_effect.has_heal_block_effect? #> Heal Block
      #> Check the substitute!
      _message_stack_push([:hp_up, launcher, hp / 2])
      _message_stack_push([:msg, parse_text_with_pokemon(19, 905, target)])
    else
      _mp([:msg, parse_text_with_pokemon(19, 890, launcher)])
    end

    __s_stat_us_step(launcher, target, skill)
    return true
  end

  # Dream Eater skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_dream_eater(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)

    unless target.asleep?
      _message_stack_push(MSG_Fail)
      return false
    end
    hp = _damage_calculation(launcher, target, skill).to_i
    return false if __s_hp_down_check(hp, target)

    if launcher.battle_effect.has_heal_block_effect?
      _message_stack_push([:msg, parse_text_with_pokemon(19, 890, launcher)])
      return
    end

    hp = 2 if hp < 2 #>Recover only 1 HP if the move dealt less than 2 HP of damage
    #>Verify the clone !
    _message_stack_push([:hp_up, launcher, hp / 2])
    _message_stack_push([:msg, parse_text_with_pokemon(19, 905, target)])

    __s_stat_us_step(launcher, target, skill)
    return true
  end

  # Leech Seed skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_leech_seed(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)

    if target.battle_effect.has_leech_seed_effect? || target.type_grass? #> Immunity
      _message_stack_push(MSG_Fail)
    else
      _message_stack_push([:leech_seed, target, launcher])
    end
  end
end
