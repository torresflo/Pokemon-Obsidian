#encoding: utf-8

#noyard
module BattleEngine
  module_function

  # OHKO skills definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_ohko(launcher, target, skill, msg_push = true)
    #> Pokémon uses xxx!
    _message_stack_push([:use_skill_msg, launcher, target, skill])
    #> Sacrifices ?
    if launcher == target
      if (target.position < 0 ? $scene.enemy_party : $pokemon_party).pokemon_alive > $game_temp.vs_type
        _mp([:hp_down, target, target.hp])
      else
        _mp(MSG_Fail)
        return false
      end
      return true
    end
    #> Type check
    if _type_modifier_calculation(target, skill) == 0
      _message_stack_push([:useless_msg, target])
      return
    end
    #> Accuracy check
    unless launcher.level >= target.level && 
      _rand_check(launcher.level - target.level + 30, 100)
      _message_stack_push([:msg, parse_text(18, 74)])
      return
    end
    return if _target_protected(launcher, target, skill)
    _message_stack_push([:OHKO, target])
  end

  # Destiny Bound skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_destiny_bond(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    _message_stack_push([:msg, parse_text_with_pokemon(19, 626, launcher)])
  end

  # Final Gambit skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_final_gambit(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    __s_hp_down_check(launcher.hp, target)
    _mp([:hp_down, launcher, launcher.hp])
  end

  # Memento skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_memento(launcher, target, skill, msg_push = true)
    if s_ohko(launcher, launcher, skill)
      _mp([:change_atk, target, -2])
      _mp([:change_ats, target, -2])
    end
  end

end