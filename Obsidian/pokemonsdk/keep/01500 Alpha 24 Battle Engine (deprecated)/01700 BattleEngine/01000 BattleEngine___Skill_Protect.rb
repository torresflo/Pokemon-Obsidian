#encoding: utf-8

#noyard

# Protection related skills
module BattleEngine
  module_function
  
  # Protect related skills definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_protect(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    #> Tatamigaeshi
    if skill.id == 561 && launcher.battle_effect.nb_of_turn_here > 1
      _mp(MSG_Fail) if target == launcher
      return false
    end
    #> Procédure générale
    target = _snatch_check(target, skill)
    protect_acc = target.battle_effect.get_protect_accuracy
    if _rand_check(protect_acc,1000)
      _mp([:apply_effect, target, (skill.id == 203 ? :apply_endure : :apply_protect)]) #> Reckless
    else
      _mp([:msg_fail, target == launcher ? nil : target]) #>Indiquer sur qui ça fail (Tatamigaeshi)
    end
  end

  # Brick Break skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_brick_break(launcher, target, skill, msg_push = true)
    skill.type2 = 0 if target.type_spectre?
    result = s_basic(launcher, target, skill)
    skill.type2 = nil
    return false unless result
    sym = target.position < 0 ? :enn_light_screen : :act_light_screen
    if(@_State[sym] > 0)
      _mp([:msg, parse_text(18, target.position < 0 ? 137 : 136)])
      _mp([:set_state, sym, 0])
    end
    sym = target.position < 0 ? :enn_reflect : :act_reflect
    if(@_State[sym] > 0)
      _mp([:msg, parse_text(18, target.position < 0 ? 133 : 132)])
      _mp([:set_state, sym, 0])
    end
  end

  # Lucky Chant skill definition
  # The whole team is protected against Critical Hits during 5 turns even if the launcher is switched
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_lucky_chant(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    return if launcher != target #> To apply to the whole team and manage Snatch
    target = _snatch_check(launcher, skill) #> I only check the launcher because I don't know how it acts in 2v2 when it's not the launcher under Snatch
    _mp([:msg, parse_text(18, target.position < 0 ? 151 : 150)])
    _mp([:set_state, target.position < 0 ? :enn_lucky_chant : :act_lucky_chant, 5])
  end

  # Reflect & Light Screen skills definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_reflect(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    return if launcher != target #> Team & Snatch
    nb_turn = _has_item(launcher, 269) ? 8 : 5 #> Lumargile
    target = _snatch_check(launcher, skill) #> Actuellement je ne vérifie que le lanceur car je ne sais pas comment ça agit en 2v2 quand c'est pas le lanceur sous saisie :<
    if skill.id == 113 #> Light Screen
      sym = target.position < 0 ? :enn_light_screen : :act_light_screen
      unless @_State[sym] > 0
        _mp([:msg, parse_text(18, target.position < 0 ? 135 : 134)])
        _mp([:set_state, sym, nb_turn])
      else
        _mp(MSG_Fail)
      end
    else #>Protection
      sym = target.position < 0 ? :enn_reflect : :act_reflect
      unless @_State[sym] > 0
        _mp([:msg, parse_text(18, target.position < 0 ? 131 : 130)])
        _mp([:set_state, sym, nb_turn])
      else
        _mp(MSG_Fail)
      end
    end
  end

  # Safe Guard skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_safe_guard(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    target = _snatch_check(target, skill)
    _mp([:apply_affect, target, :apply_safe_guard])
  end

  # Substitute skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_substitute(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    hp = launcher.max_hp/4
    if launcher.battle_effect.has_substitute_effect?
      _mp([:msg, parse_text_with_pokemon(19, 788, launcher)])
    elsif launcher.hp > hp
      _mp([:hp_down, launcher, hp])
      _mp([:msg, parse_text_with_pokemon(19, 785, launcher)])
      target = _snatch_check(target, skill)
      _mp([:apply_effect, launcher, :apply_substitute, hp])
      _mp([:switch_form, launcher])
    else
      _mp([:msg, parse_text(18,129)])
    end
  end

end