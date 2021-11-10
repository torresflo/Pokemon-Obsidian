#encoding: utf-8

#noyard
module BattleEngine
  module_function

  # Basic skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_basic(launcher, target, skill, msg_push = true)
    did_something = false
    return false unless __s_beg_step(launcher, target, skill, msg_push)

    #> Move check
    if skill.power > 0
      hp = _damage_calculation(launcher, target, skill).to_i
      return false if __s_hp_down_check(hp, target)

      did_something = true
    end
    did_something |= __s_stat_us_step(launcher, target, skill)
    unless did_something
      # But it failed!
      _message_stack_push([:msg, parse_text(18, 74)])
    end
    return did_something
  end

  NoAssist_Skill = [182, 495, 448, 214, 270, 18, 197, 525, 621, 166, 46, 343, 168, 165, 118, 119,
                    164, 382, 415, 383, 194, 509, 277, 467, 68, 364, 289, 203, 271, 243, 274]
  # Assist skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_assist(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)

    allies = (@_Actors.include?(launcher) ? @_Actors : @_Enemies)
    if allies.size > 1
      moves = allies.compact.flat_map { |pokemon| pokemon.skills_set.compact.reject { |move| NoAssist_Skill.include?(move.id) } }
      return _launch_skill(launcher, target, moves[rand(moves.size)]) if moves.any?
    end
    _mp(MSG_Fail)
  end

  # Endeavor skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_endeavor(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)

    if target.hp > launcher.hp
      _mp([:hp_down, target, target.hp - launcher.hp])
    else
      _mp([:msg_fail])
    end
  end

  # False Swipe & Hold Back skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_false_swipe(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)

    hp = _damage_calculation(launcher, target, skill).to_i
    if hp >= target.hp
      hp = target.hp - 1
    end
    __s_hp_down_check(hp, target)
  end

  # Helping Hand skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_helping_hand(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)

    if launcher != target && !target.battle_effect.has_helping_hand_effect?
      _mp([:apply_effect, target, :apply_helping_hand])
    else
      _mp([:msg_fail])
    end
  end

  # Last Resort skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_last_resort(launcher, target, skill, msg_push = true)
    if launcher.skills_set.size > 1
      count = 1
      launcher.skills_set.each { |i| count += 1 if i != skill && i.used }
      if count == launcher.skills_set.size
        return s_basic(launcher, target, skill)
      end
    end
    return unless __s_beg_step(launcher, target, skill, msg_push)

    _mp(MSG_Fail)
  end

  # Pain Split skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_pain_split(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)

    total_hp = (launcher.hp + target.hp) / 2
    _mp([:hp_up, launcher, total_hp - launcher.hp]) #> Check negatives values
    _mp([:hp_up, target, total_hp - target.hp]) #> Check negatives values
  end

  # Spite skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_spite(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)

    target = _magic_coat(launcher, target, skill)
    ls = target.last_skill
    skill = target.find_skill(ls) if ls
    pp = skill ? (skill.pp < 4 ? skill.pp : 4) : 0
    if ls && ls > 0 && ls != 165 && pp > 0
      _mp([:msg, parse_text_with_pokemon(19, 641, target, MOVE[1] => ::GameData::Skill[ls].name, '[VAR NUM1(0002)]' => pp.to_s)])
      _mp([:pp_down, target, skill, pp])
    else
      _mp(MSG_Fail)
    end
  end

  # Splash & moves like that without any effect
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_splash(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    return _msgp(18, 70) if skill.id == 150 # Splash

    if skill.id == 606 # Celebrate
      trainer = get_enemies!(launcher).compact[0].trainer_name
      _msgp(18, 267, nil, "[VAR TRNAME(0000)]" => trainer)
    end
  end

  # Struggle skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_struggle(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)

    skill.type2 = 0
    hp = _damage_calculation(launcher, target, skill).to_i
    skill.type2 = nil
    hp = 1 if hp == 0
    _message_stack_push([:hp_down, target, hp])
    _skill_critical_push
    _message_stack_push([:msg, parse_text_with_pokemon(19, 378, launcher)])
    _message_stack_push([:hp_down, launcher, (launcher.max_hp + 3) / 4])
  end
end
