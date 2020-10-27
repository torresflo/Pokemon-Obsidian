#encoding: utf-8

#noyard

# Money related skills
module BattleEngine
  module_function

  # Happy Hour skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_happy_hour(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    if @_State[:happy_hour]
      _mp(MSG_Fail)
    else
      _message_stack_push([:happy_hour, launcher])
    end
  end

  # Payday skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_payday(launcher, target, skill, msg_push = true)
    if s_basic(launcher, target, skill)
      _message_stack_push([:jackpot, launcher])
    end
  end

end