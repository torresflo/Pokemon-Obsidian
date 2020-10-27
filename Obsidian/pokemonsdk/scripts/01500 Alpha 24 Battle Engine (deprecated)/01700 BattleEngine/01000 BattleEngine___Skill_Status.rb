#encoding: utf-8

#noyard

# Status related skills
module BattleEngine
  module_function

  # Status related skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_status(launcher, target, skill, msg_push = true)
    did_something = false
    return unless __s_beg_step(launcher, target, skill, msg_push)
    #> Immunity to seeds & others
    unless target.type_grass? && ImmuGrass.include?(skill.id)
      #> Move check
      if skill.power > 0
        hp = _damage_calculation(launcher, target, skill).to_i
        return if __s_hp_down_check(hp, target)
        did_something = true
      end
      did_something |= __s_stat_us_step(launcher, target, skill, 100)
    end
    unless did_something
      _message_stack_push([:msg, parse_text(18, 70)])
    end
  end

  # Self status skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_self_statut(launcher, target, skill, msg_push = true)
    did_something = false
    return unless __s_beg_step(launcher, target, skill, msg_push)
    #> Move check
    if skill.power > 0
      hp = _damage_calculation(launcher, target, skill).to_i
      return if __s_hp_down_check(hp, target)
      did_something = true
    end
    did_something |= __s_stat_us_step(launcher, launcher, skill, 100, nil)
    unless did_something
      _message_stack_push([:msg, parse_text(18, 70)])
    end
  end

  # Attract skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_attract(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    _message_stack_push([:attract_effect, launcher, target])
  end

  # Fangs skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_a_fang(launcher, target, skill, msg_push = true)
    return unless s_basic(launcher, target, skill)
    if _attacking_first?(launcher) and _chance(10, launcher, target, skill)
      _message_stack_push([:effect_afraid, target])
    end
  end

  # Fake Out skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_fake_out(launcher, target, skill, msg_push = true)
    if launcher.battle_effect.nb_of_turn_here == 1
      s_status(launcher, target, skill)
    else
      __s_beg_step(launcher, target, skill, msg_push)
      _mp(MSG_Fail)
    end
  end

  # Magnetic Flux skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  MinusPlus = [96, 97]
  def s_magnetic_flux(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)

    allies = get_ally!(launcher)
    allies.each do |target|
      if MinusPlus.include?(target.ability) && Abilities.has_ability_usable(target, target.ability)
        _mp([:change_dfe, target, 1])
        _mp([:change_dfs, target, 1])
      end
    end
  end

  # Nightmare
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_nightmare(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    if(target.asleep?)
      _message_stack_push([:apply_effect, target, :apply_nightmare])
      _message_stack_push([:msg, parse_text_with_pokemon(19, 321, target)])
    else
      _message_stack_push(MSG_Fail)
    end
  end

  Psycho_Shift = [[false, true, true, true, true, true, false, false, true],
  [nil, :can_be_poisoned?, :can_be_paralyzed?, :can_be_burn?, :can_be_asleep?, :can_be_frozen?, nil, nil, :can_be_poisoned?],
  [nil, :status_poison, :status_paralyze, :status_burn, :status_sleep, :status_frozen, nil, nil, :status_toxic]]
  # Psycho Shift skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_psycho_shift(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    if Psycho_Shift[0][launcher.status] && launcher.status != target.status
      status_check = Psycho_Shift[1][launcher.status]
      status = target.status
      target.status = 0
      status_check = target.send(status_check)
      target.status = status
      if status_check
        _mp([:set_status, target, 0])
        _mp([Psycho_Shift[2][launcher.status], target])
        if Psycho_Shift[0][target.status]
          status_check = Psycho_Shift[1][target.status]
          status = launcher.status
          launcher.status = 0
          status_check = launcher.send(status_check)
          launcher.status = status
          if status_check
            _mp([:set_status, launcher, 0])
            _mp([Psycho_Shift[2][target.status], launcher])
            return
          end
        end
        _mp([:status_cure, launcher])
        return
      end
    end
    _mp(MSG_Fail)
  end

  Sleep_Talk_NoMove = [214, 274, 448, 253, 130, 13, 76, 118, 119, 264, 382, 117, 383, 143, 291, 340, 467, 91, 19]
  # Sleep Talk skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_sleep_talk(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    target = launcher.battle_effect.last_attacking
    target = _random_target_selection(launcher, target) unless target && target != launcher
    if launcher != target && launcher.asleep?
      id = Sleep_Talk_NoMove[0]
      id = rand(GameData::Skill::LAST_ID) + 1 while(Sleep_Talk_NoMove.include?(id))
      skill = ::PFM::Skill.new(id)
      _launch_skill(launcher, target, skill)
    else
      _mp(MSG_Fail)
    end
  end

  # Sparkling Aria skill definition
  # This move inflicts damage to everyone around you (this includes allies) and cures burn if hit. If Pokémon hit has soundproof, dry skin,
  # storm drain, or water absorbed they are not affected (burns do not get cured).
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_sparkling_aria(launcher, target, skill, msg_push=true)
    if s_basic(launcher, target, skill) & target.burn?
      _mp([:status_cure, target])
    end
  end

  # Toxic Thread skill definition
  # Lowers the target's speed stat by one and poisons the target. If the target can't be poisoned (steel type, poison type, or 
  # has a status condition already) it will still lower the speed and vice-versa. If speed can't be lowered because of clear body 
  # or speed is already -6 it can still poison.
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_toxic_thread(launcher, target, skill, msg_push=true)
    # Checks if target's speed is already -6 or has a status already
    if target.spd >= (target.spd_basis / 4 + 1) && !Abilities.has_ability_usable(target, 29) # Clear Body
      __s_stat_us_step(launcher, target, skill, nil, 100)
      # Lowers the target's speed by 1
      _message_stack_push([:change_spd, target, -1])
    end
    # Checks if target has no status
    if target.status == 0
      # Applies toxic status
      _mp([:status_poison, target])
    end
    #If target speed is -6 and has a status move fails
    if target.spd <= (target.spd_basis / 4 + 1) && target.status != 0
      #Gives fail message
      _message_stack_push(MSG_Fail)
      return false
    end
  end

  # Tri Attack skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_tri_attack(launcher, target, skill, msg_push = true)
    if s_basic(launcher, target, skill) && _status_chance(20, launcher, target, skill)
      target = _magic_coat(launcher, target, skill)
      v = rand(3)
      case v
      when 0
        _message_stack_push([:status_burn, target]) if target.can_be_burn?
      when 1
        _message_stack_push([:status_paralyze, target]) if target.can_be_paralyzed?
      when 2
        _message_stack_push([:status_frozen, target]) if target.can_be_frozen?
      end
    end
  end

  # Yawn skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_yawn(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    target = _magic_coat(launcher, target, skill)
    unless target.battle_effect.has_yawn_effect? || target.battle_effect.has_safe_guard_effect?
      _mp([:msg, parse_text_with_pokemon(19, 667, target, PKNICK[0] => target.given_name)])
      _mp([:apply_effect, target, :apply_yawn])
    else
      if target.battle_effect.has_safe_guard_effect? #> Safe Guard
        _msgp(19, 842, target)
      else
        _mp([:msg_fail])
      end
    end
  end

end