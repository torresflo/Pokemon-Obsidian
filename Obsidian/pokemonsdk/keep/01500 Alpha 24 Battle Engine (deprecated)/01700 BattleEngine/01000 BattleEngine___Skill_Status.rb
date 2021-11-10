#encoding: utf-8

#noyard

# Status related skills
module BattleEngine
  module_function

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