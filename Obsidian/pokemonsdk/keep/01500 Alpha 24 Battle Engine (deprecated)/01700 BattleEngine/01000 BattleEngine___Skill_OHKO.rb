#encoding: utf-8

#noyard
module BattleEngine
  module_function

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
end
