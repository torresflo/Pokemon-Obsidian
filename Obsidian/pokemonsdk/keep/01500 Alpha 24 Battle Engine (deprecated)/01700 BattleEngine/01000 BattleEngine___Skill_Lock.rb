#encoding: utf-8

#noyard

# Lock related skills
module BattleEngine
  module_function

  # Bind skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_bind(launcher, target, skill, msg_push = true)
    if s_basic(launcher, target, skill)
      #>Accro Griffe
      if(_has_item(launcher, 286))
        nb_turn = 5
      else
        nb_turn = 4+rand(2)
      end
      _message_stack_push([:bind, target, nb_turn, skill, launcher])
    end
  end

  # Fairy Lock / Block / Mean Look / Spider Web / Thousand Waves skills definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_cantflee(launcher, target, skill, msg_push = true)
    if(skill.id != 615) #> Thousand Waves
      return false unless __s_beg_step(launcher, target, skill, msg_push)
    else
      return false unless s_basic(launcher, target, skill)
    end
    target = _magic_coat(launcher, target, skill)
    return _mp(MSG_Fail) if target.type_ghost? #> Can't be blocked
    if skill.id == 587 #> Fairy Lock
      _msgp(18, 258) # "No one will be able to run away during the next turn!"
      _mp([:apply_effect,target, :apply_cant_flee, launcher])
      _mp([:apply_effect,launcher, :apply_cant_flee, launcher]) if msg_push
    else
      _mp([:msg, parse_text_with_pokemon(19, 875, target)])
      _mp([:apply_effect,target, :apply_cant_flee, launcher])
    end
  end

  # Disable skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_disable(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    target = _magic_coat(launcher, target, skill)
    ls = target.last_skill
    if(ls > 0 and !target.battle_effect.has_disable_effect?)
      _mp([:msg, parse_text_with_pokemon(19, 592, launcher, MOVE[1] => ::GameData::Skill[ls].name)])
      _mp([:apply_effect, target, :apply_disable, ls])
    else
      _mp(MSG_Fail)
    end
  end

  # Encore skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_encore(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    target = _magic_coat(launcher, target, skill)
    ls = target.last_skill
    if(ls > 0 && ls != skill.id && ls != 165)
      _mp([:msg, parse_text_with_pokemon(19, 559, target, MOVE[1] => ::GameData::Skill[ls].name)])
      _mp([:apply_effect, target, :apply_encore, target.find_skill(ls)])
    else
      _mp(MSG_Fail)
    end
  end

  # Follow Me skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_follow_me(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    sym = target.position < 0 ? :enn_follow_me : :act_follow_me
    _message_stack_push([:set_state, sym, launcher])
    _message_stack_push([:msg, parse_text_with_pokemon(19, 670, launcher)])
  end

  # Imprison skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_imprison(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    target = _snatch_check(target, skill)
    unless target.battle_effect.has_imprison_effect? or target == launcher
      common = false
      i = nil
      j = nil
      target.skills_set.each do |i|
        launcher.skills_set.each do |j|
          common = true if j.id == i.id
          break if common
        end
        break if common
      end
      if common || !::GameData::Flag_4G
        _mp([:apply_effect, target, :apply_imprison_effect, launcher, launcher.skills_set])
        _msgp(19, 586, launcher)
        return
      end
    end
    _mp(MSG_Fail)
  end

  # Mind Reader skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_mind_reader(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    _mp([:apply_effect, launcher, :apply_mind_reader, target])
    _mp([:msg, ::PFM::Text.parse_with_pokemons(19, 651, launcher, target)])
  end

  # Snatch skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_snatch(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    be = launcher.battle_effect
    unless be.has_snatch_effect? && be.get_snatch_target == target
      _mp([:msg, parse_text_with_pokemon(19, 751, launcher)])
      _mp([:apply_effect, launcher, :apply_snatch, target])
    else
      _mp([:msg_fail])
    end
  end

  # Spirit Shackle skill definition
  # This move inflicts damage and prevents foes from fleeing or switching out UNLESS they have wimp out, emergency exit or holding a
  # red card, shed shell, or eject button
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_spirit_shackle(launcher, target, skill, msg_push=true)
    # If it does damage
    if s_basic(launcher, target, skill)
      # If they have these moves or abilities it won't trap
      unless target.ability_db_symbol == :wimp_out || target.ability_db_symbol == :emergency_exit || target.item_db_symbol == :red_card ||
             target.item_db_symbol == :shed_shell || target.item_db_symbol == :eject_button
        _mp([:apply_effect,target, :apply_cant_flee, launcher])
      end
    end
  end

  # Taunt skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_taunt(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    target = _magic_coat(launcher, target, skill)
    _message_stack_push([:apply_effect, target, :apply_taunt, 2])
    _message_stack_push([:msg, parse_text_with_pokemon(19, 568, target)])
  end

  # Torment skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_torment(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    target = _magic_coat(launcher, target, skill)
    unless target.battle_effect.has_torment_effect?
      _mp([:msg, parse_text_with_pokemon(19, 577, target)])
      _mp([:apply_effect, target, :apply_torment])
    else
      _mp([:msg_fail])
    end
  end

end