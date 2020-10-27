#encoding: utf-8

#noyard

# Skill that responds to a move by increasing or decreasing their power, returning the move, effects or damages.
module BattleEngine
  module_function

  # Assurance & Revenge skills definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_assurance(launcher, target, skill, msg_push = true)
    skill.power2 = skill.power * 2 if launcher.battle_effect.took_damage
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end

  # Counter, Mirror Coat & Metal Burst skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_counter(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)

    damages = launcher.battle_effect.get_taken_damages_from(target)
    if damages > 0 && skill.id == 68 #> Damages & Physical
      _message_stack_push([:hp_down, target, 2 * damages])
    elsif damages < 0 && skill.id == 243
      _message_stack_push([:hp_down, target, -2 * damages])
    elsif damages != 0 && skill.id == 368
      _message_stack_push([:hp_down, target, damages.abs * 3 / 2])
    else
      _message_stack_push(MSG_Fail)
    end
  end

  # Payback skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_payback(launcher, target, skill, msg_push = true)
    skill.power2 = skill.power * 2 if launcher.battle_effect.get_taken_damages_from(target) != 0
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end
end
