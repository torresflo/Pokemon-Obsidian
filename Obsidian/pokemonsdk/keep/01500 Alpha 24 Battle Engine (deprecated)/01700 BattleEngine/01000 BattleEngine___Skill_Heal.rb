#encoding: utf-8

#noyard
module BattleEngine
  module_function

  # Ingrain skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_ingrain(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    target = _snatch_check(launcher, skill)
    unless target.battle_effect.has_ingrain_effect?
      if target.battle_effect.has_telekinesis_effect?
        _msgp(19, 1149, target)
        _mp([:apply_effect, target, :apply_telekinesis, 0])
      end
      _mp([:msg, parse_text_with_pokemon(19, 736, target)])
      _mp([:apply_effect, target, :apply_ingrain])
    else
      _mp([:msg_fail])
    end
  end

  # Aqua Ring skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_aqua_ring(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    target = _snatch_check(launcher, skill)
    unless(target.battle_effect.has_aqua_ring_effect?)
      _mp([:msg, parse_text_with_pokemon(19, 601, target)])
      _mp([:apply_effect, target, :apply_aqua_ring])
    else
      _mp([:msg_fail])
    end
  end

  # Rest skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_rest(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    #> Insomia / Vital Spirit
    if(launcher.max_hp == launcher.hp || Abilities.has_ability_usable(launcher, 49) ||
      Abilities.has_ability_usable(launcher, 30))
      _message_stack_push(MSG_Fail)
    elsif target.battle_effect.has_heal_block_effect?
      _mp([:msg, parse_text_with_pokemon(19,893, launcher, MOVE[1] => skill.name)])
    else
      _message_stack_push([:status_cure, launcher])
      _message_stack_push([:status_sleep, launcher, Abilities.has_ability_usable(launcher, 41) ? 1 : 3])
      _message_stack_push([:hp_up, launcher, launcher.max_hp - launcher.hp])
    end
  end

  # Roost skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_roost(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    target = _snatch_check(launcher, skill)
    if target.hp < target.max_hp && !_is_grounded(target)
      _mp([:set_type, target, 1, 1]) if target.type1 == 10
      _mp([:set_type, target, 1, 2]) if target.type2 == 10
      _mp([:set_type, target, 1, 3]) if target.type3 == 10
      _mp([:hp_up, target, target.max_hp / 2]) #> TODO : Up to & not max_hp/2
    else
      _mp(MSG_Fail)
    end
  end

  # Shore Up skill definition
  # User regains up to half of it's max HP, or 2/3 of max HP if in a sandstorm.
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_shore_up(launcher, target, skill, msg_push=true)
    # Message that says Pokemon used move
    if launcher.hp != launcher.max_hp
      return false unless __s_beg_step(launcher, target, skill, msg_push)
      # If sandstorm heal 2/3 max HP
      if $env.sandstorm?
        hp = (launcher.max_hp * 2/3)
      else
      # If no sandstorm heal 1/2 max HP
        hp = (launcher.max_hp * 1/2)
      end
      # Message that says Pokemon gained HP
      _message_stack_push([:hp_up, launcher, hp])
      return true
    else
      # Gives fail message
      _message_stack_push([:use_skill_msg, launcher, target, skill]) if msg_push
      _message_stack_push(MSG_Fail)
      return false
    end
  end

  # Wish skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_wish(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    target = _snatch_check(launcher, skill)
    unless target.battle_effect.has_wish_effect?
      _mp([:msg, parse_text_with_pokemon(21, 819, target, PKNAME[0] => launcher.given_name)])
      _mp([:apply_effect, target, :apply_wish, target])
    else
      _mp([:msg_fail])
    end
  end

end