#encoding: utf-8

#noyard

# Statistics related skills
module BattleEngine
  module_function

  # Statistics related skills definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  AcuperssionStat = [:change_atk, :change_ats, :change_dfe, :change_dfs, :change_eva, :change_acc, :change_spd]
  def s_stat_edit(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    id = skill.id
    if(id == 579) #> Leaf Guard
      get_battlers.each do |i|
        _message_stack_push([:change_dfe, i, 1]) if i.type_grass?
      end
    elsif(id == 384) #> Power Swap
      _message_stack_push([:msg, parse_text_with_pokemon(19, 676, launcher)])
      atk = launcher.atk_stage
      ats = launcher.ats_stage
      _message_stack_push([:stat_set, launcher, 0, target.atk_stage])
      _message_stack_push([:stat_set, launcher, 3, target.ats_stage])
      _message_stack_push([:stat_set, target, 0, atk])
      _message_stack_push([:stat_set, target, 3, ats])
    elsif(id == 385) #> Guard Swap
      _message_stack_push([:msg, parse_text_with_pokemon(19, 679, launcher)])
      dfe = launcher.dfe_stage
      dfs = launcher.dfs_stage
      _message_stack_push([:stat_set, launcher, 1, target.dfe_stage])
      _message_stack_push([:stat_set, launcher, 4, target.dfs_stage])
      _message_stack_push([:stat_set, target, 1, dfe])
      _message_stack_push([:stat_set, target, 4, dfs])
    elsif(id == 367) # Acupressure
      _message_stack_push([AcuperssionStat[rand(6)], target, 2])
    elsif(id == 391) # Heart Swap
      _message_stack_push([:msg,parse_text_with_pokemon(19, 673, launcher)])
      bs1 = launcher.battle_stage.clone
      bs2 = target.battle_stage
      bs2.each_index do |i|
        _message_stack_push([:stat_set, launcher, i, bs2[i]])
        _message_stack_push([:stat_set, target, i, bs1[i]])
      end
    elsif(id == 470) # Guard Split
      _message_stack_push([:msg,parse_text_with_pokemon(19, 1105, launcher)])
      dfe = (launcher.dfe_basis + target.dfe_basis) / 2
      _message_stack_push([:set_be_value, launcher, :dfe=, dfe])
      _message_stack_push([:set_be_value, target, :dfe=, dfe])
      dfs = (launcher.dfs_basis + target.dfs_basis) / 2
      _message_stack_push([:set_be_value, launcher, :dfs=, dfs])
      _message_stack_push([:set_be_value, target, :dfs=, dfs])
    elsif(id == 471) # Power Split
      _message_stack_push([:msg,parse_text_with_pokemon(19, 1102, launcher)])
      atk = (launcher.atk_basis + target.atk_basis) / 2
      _message_stack_push([:set_be_value, launcher, :atk=, atk])
      _message_stack_push([:set_be_value, target, :atk=, atk])
      ats = (launcher.ats_basis + target.ats_basis) / 2
      _message_stack_push([:set_be_value, launcher, :ats=, ats])
      _message_stack_push([:set_be_value, target, :ats=, ats])
    elsif(id == 379) # Power Trick
      _message_stack_push([:set_be_value, launcher, :atk=, launcher.dfe_basis])
      _message_stack_push([:set_be_value, launcher, :dfe=, launcher.atk_basis])
    end
  end

  # Autotomize skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_autotomize(launcher, target, skill, msg_push = true)
    return false unless s_stat(launcher, target, skill)
    target = _snatch_check(target, skill)
    _mp([:apply_effect, target, :apply_autotomize])
  end

  # Captivate skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_captivate(launcher, target, skill, msg_push = true)
    #>Benêt
    if ((target.gender * launcher.gender == 2) && !Abilities.has_ability_usable(target, 39))
      s_stat(launcher, target, skill)
    else
      return false unless __s_beg_step(launcher, target, skill, msg_push)

      _message_stack_push(MSG_Fail)
    end
  end

  # Feint skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_feint(launcher, target, skill, msg_push = true)
    if target.battle_effect.has_protect_effect?
      s_basic(launcher, target, skill)
    else
      __s_beg_step(launcher, target, skill, msg_push)
      _mp(MSG_Fail)
    end
  end

  # Fell Stinger skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_fell_stinger(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    hp=_damage_calculation(launcher, target, skill).to_i
    __s_hp_down_check(hp, target)
    if hp >= target.hp
      _message_stack_push([:change_atk, launcher, 2])
    end
  end

  # Growth skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_growth(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    if($env.sunny?)
      nb = 2
    else
      nb = 1
    end
    _message_stack_push([:change_atk, target, nb])
    _message_stack_push([:change_ats, target, nb])
  end

  # Haze skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_haze(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    if skill.id == 499 # Bain de Smog
      hp = _damage_calculation(launcher, target, skill).to_i
      return false if __s_hp_down_check(hp, target)
    end
    _message_stack_push([:msg, parse_text_with_pokemon(19, 195, target)])
    _message_stack_push([:stat_reset, target])
  end

  # Hidden Power skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  HP_Types = [7, 10, 8, 9, 13, 12, 14, 16, 2, 3, 5, 4, 11, 6, 15, 17]
  def s_hidden_power(launcher, target, skill, msg_push = true)
    type_index = (launcher.iv_hp & 1) | ((launcher.iv_atk & 1) << 1) | 
    ((launcher.iv_dfe & 1) << 2) | ((launcher.iv_spd & 1) << 3) | 
    ((launcher.iv_ats & 1) << 4) | ((launcher.iv_dfs & 1) << 5)
    skill.type2 = HP_Types[type_index * 15 / 63]
    s_basic(launcher, target, skill)
    skill.type2 = nil
  end

  # Parting Shot skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_parting_shot(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    unless launcher.position >= 0 && !_can_switch(launcher)
      _message_stack_push([:change_atk, target, -1])
      _message_stack_push([:change_ats, target, -1])
      _mp([:msg, parse_text_with_pokemon(19, 770, launcher, PKNICK[0] => launcher.given_name, TRNAME[1] => $trainer.name)])
      _mp([:switch_pokemon, launcher, nil])
    else
      _mp(MSG_Fail)
    end
  end

  # Psych Up skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_psych_up(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    _message_stack_push([:msg,parse_text_with_pokemon(19, 1053, launcher, PKNICK[1] => target.given_name)])
    launcher = _snatch_check(launcher, skill)
    _message_stack_push([:apply_effect, target, :apply_no_stat_change])
    unless(launcher.battle_effect.has_no_stat_change_effect?)
      _message_stack_push([:change_atk, target, target.atk_stage])
      _message_stack_push([:change_ats, target, target.ats_stage])
      _message_stack_push([:change_dfe, target, target.dfe_stage])
      _message_stack_push([:change_dfs, target, target.dfs_stage])
      _message_stack_push([:change_spd, target, target.spd_stage])
      _message_stack_push([:change_eva, target, target.eva_stage])
      _message_stack_push([:change_acc, target, target.acc_stage])
    else
      _message_stack_push(MSG_Fail)
    end
  end

  # Rage skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_rage(launcher, target, skill, msg_push = true)
    return false unless s_basic(launcher, target, skill)
    _mp([:apply_effect, launcher, :apply_rage])
  end

  # Rototillier skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_rotillier(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    if target.type_grass?
      _message_stack_push([:change_atk, target, 1])
      _message_stack_push([:change_ats, target, 1])
    end
  end

  # Strength Sap skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_strength_sap(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    
    #Checks if target's current attack is greater than it's max attack / 4 (Basically, if it's -6 attack the move fails)
    if target.atk >= (target.atk_basis / 4 + 1)
      #Sets hp gained to target's attack
      hp = (target.atk).to_i
      #If you have big root increase hp gained by 30%
      hp = hp*130/100 if(_has_item(launcher, 296))
      #If the target has liquid ooze
      if target.ability == 36
        _message_stack_push([:hp_down, launcher, hp])
        _message_stack_push([:msg, parse_text_with_pokemon(19, 457, launcher)])
      #Else if heal block is active
      elsif(!launcher.battle_effect.has_heal_block_effect?)
        #Checks the clone (I have no idea what that means. It's used in abosrb, though.)
        _message_stack_push([:hp_up, launcher, hp])
        _message_stack_push([:msg, parse_text_with_pokemon(19, 905, target)])
      else
        _mp([:msg, parse_text_with_pokemon(19,890, launcher)])
      end
      __s_stat_us_step(launcher, target, skill, nil, 100)
      #Lowers the target's attack by 1
      _message_stack_push([:change_atk, target, -1])
      return true
    #If the target's current attack is less than it's attack is -6 give fail message
    else
      #Gives fail message
      _message_stack_push(MSG_Fail)
      return false
    end
  end

  # Tailwind skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_tailwind(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    return if launcher != target #> To apply to the whole team and manage Snatch
    target = _snatch_check(launcher, skill) #> I only check the launcher because I don't know how it acts in 2v2 when it's not the launcher under Snatch
    _mp([:msg, parse_text(18, target.position < 0 ? 147 : 146)])
    _mp([:set_state, target.position < 0 ? :enn_tailwind : :act_tailwind, 4])
  end

  # Topsy Turvy skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_topsy_turvy(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    target = _magic_coat(launcher, target, skill)
    _message_stack_push([:msg,parse_text_with_pokemon(19, 1077, target)])
    #unless(launcher.battle_effect.has_no_stat_change_effect?) #>Vérifier si c'est bloqué
      bs = target.battle_stage
      bs.each_index do |i|
        _message_stack_push([:stat_set, target, -bs[i]])
      end
    #else
    #  _message_stack_push(MSG_Fail)
    #end
  end

  # Venom Drench skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_venom_drench(launcher, target, skill, msg_push = true)
    if target.poisoned? || target.toxic?
	    return s_basic(launcher, target, skill)
    end
    __s_beg_step(launcher, target, skill, msg_push)
    _mp(MSG_Fail)
  end

end