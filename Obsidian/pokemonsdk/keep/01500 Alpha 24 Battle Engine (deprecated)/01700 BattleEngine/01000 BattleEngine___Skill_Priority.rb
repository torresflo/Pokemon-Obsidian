#encoding: utf-8

#noyard

# Priority related skills
module BattleEngine
  module_function

  # After you skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_after_you(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    if _attacking_before?(target, launcher) || $game_temp.vs_type == 1
      _mp(MSG_Fail)
    else
      _mp([:after_you, target])
    end
  end

  # First Impression skill definition
  # The move has priority of +2, first impression fails if used after first turn.
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_first_impression(launcher, target, skill, msg_push=true)
    # Message that says Pokemon used move
    if launcher.battle_effect.nb_of_turn_here == 1
      s_basic(launcher, target, skill)
      return true
    else
      # Gives fail message
      _message_stack_push([:use_skill_msg, launcher, target, skill]) if msg_push
      _message_stack_push(MSG_Fail)
      return false
    end
  end

  # Focus Punch skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_focus_punch(launcher, target, skill, msg_push = true)
    be = launcher.battle_effect
    if be.has_focus_punch_effect?
      unless be.took_damage
        s_basic(launcher, target, skill)
      else
        _msgp(19, 366, launcher) # "lost its focus and couldn’t move!"
      end
    else
      _msgp(19, 745, launcher) # "is storing energy!"
      _mp([:apply_effect, launcher, :apply_focus_punch])
    end
  end

  # Quash skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  #===
  def s_quash(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    # Fail if the target is already attacking last or if we are in a simple battle mode
    if _attacking_last?(target) || $game_temp.vs_type == 1
      _mp(MSG_Fail)
    else
      _mp([:quash, target])
    end
  end

  # Me First skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_me_first(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    if _attacking_before?(launcher, target) && target&.prepared_skill > 0
      skill = ::PFM::Skill.new(target&.prepared_skill)
      unless skill.status?
        _launch_skill(launcher, target, skill)
        return
      end
    end
    _mp(MSG_Fail)
  end

  # Sucker Punch skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_sucker_punch(launcher, target, skill, msg_push = true)
    skill_id = target&.prepared_skill
    if _attacking_before?(launcher, target) && skill_id && skill_id != 0 && GameData::Skill[skill_id].atk_class != 3
      s_basic(launcher, target, skill)
    elsif __s_beg_step(launcher, target, skill, msg_push)
      _mp(MSG_Fail)
    end
  end

end