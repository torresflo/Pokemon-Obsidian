#encoding: utf-8

#noyard

# Switches related skills
module BattleEngine
  module_function

  # Pursuit skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_pursuit(launcher, target, skill, msg_push = true)
    if _attacking_before?(launcher, target) && target.attack_order != 255 && target.prepared_skill == 0
      skill.power2 = skill.power * 2
    end
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end

  # Teleport skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_teleport(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)

    if $game_temp.trainer_battle || $game_switches[Yuki::Sw::BT_NoEscape]
      _mp(MSG_Fail)
    else
      _mp([:msg, parse_text_with_pokemon(19, 767, launcher)])
      _mp([:roar, launcher])
    end
  end
end
