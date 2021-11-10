#encoding: utf-8

#noyard

# Items related skills
module BattleEngine
  module_function

  # Bestow skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_bestow(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    li = launcher.battle_item
    ti = target.battle_item
    # If the target already holds an item or is under substitute
    if ti > 0 || li == 0 || target.battle_effect.has_substitute_effect?
      _mp(MSG_Fail)
    else
      # TODO : Cristal Z - Mega Gemme - Orbs & ROM of Silvally can't be given
      _mp([:msg, parse_text_with_pokemon(19, 1117, launcher, PKNICK[0] => target.given_name, ITEM2[2] => ::GameData::Item[li].name, PKNICK[1] => launcher.given_name)])
      _mp([:set_item, target, li])
      _mp([:set_item, launcher, -1])
    end
  end

  # Embargo skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_embargo(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    target = _magic_coat(launcher, target, skill)
    _mp([:msg, parse_text_with_pokemon(19, 727, target)])
    _mp([:apply_effect, target, :apply_embargo])
  end

  # Fling skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_fling(launcher, target, skill, msg_push = true)
    if @_State[:launcher_item] > 0
      skill.power2 = GameData::Item[@_State[:launcher_item]].fling_power
      if s_basic(launcher, target, skill)
        case @_State[:launcher_item]
        when 273 #> Flamme Orb
          _message_stack_push([:status_burn, target, true])
        when 272 #> Toxic Orb
          _message_stack_push([:status_toxic, target, true])
        when 236 #> Light Ball
          _message_stack_push([:status_paralyze, target, true])
        when 219 #> Mental Herb
          #> Message 19, 941 - Plural
          _message_stack_push([:attract_effect, launcher, target, 0])
          _mp([:set_item, target, 0, true])
        when 214 #> White Herb
          _msgp(19, 195, launcher) # stat changes were removed
          _message_stack_push([:stat_reset_neg, target])
        when 245 #> Poison Barb
          _message_stack_push([:status_poison, target, true])
        when 327, 221 #> Rasor Fang & King's Rock
          _message_stack_push([:effect_afraid, target])
        end
      end
      skill.power2 = nil
    elsif __s_beg_step(launcher, target, skill, msg_push)
      _message_stack_push(MSG_Fail)
    end
  end

  JudgementPlates = [298, 299, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313, 644]
  # Judgment skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_judgment(launcher, target, skill, msg_push = true)
    if JudgementPlates.include?(@_State[:launcher_item])
      imisc = GameData::Item[@_State[:launcher_item]].misc_data
      skill.type2 = imisc.powering_skill_type1 if imisc&.powering_skill_type1
    end
    s_basic(launcher, target, skill)
    skill.type2 = nil
  end

  # Natural Gift skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_natural_gift(launcher, target, skill, msg_push = true)
    li = launcher.battle_item
    if li > 0
      data = ::GameData::Item[li].misc_data
      if data&.berry
        skill.power2 = data.berry[:power]
        skill.type2 = data.berry[:type]
        s_basic(launcher, target, skill)
        _mp([:set_item, launcher, 0, true])
        skill.power2 = nil
        skill.type2 = nil
        return
      end
    end
    if __s_beg_step(launcher, target, skill, msg_push)
      _mp(MSG_Fail)
    end
  end

  # Pluck & Bug Bite skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_pluck(launcher, target, skill, msg_push = true)
    return false unless s_basic(launcher, target, skill)
    ti = target.battle_item
    if ti > 0
      data = ::GameData::Item[ti].misc_data
      if data&.berry
        _mp([:msg, parse_text_with_pokemon(19, 776, launcher, ITEM2[1] => ::GameData::Item[ti].name)])
        _mp([:berry_pluck, launcher, target])
        _mp([:berry_cure, launcher, ::GameData::Item[ti].name])
      end
    end
  end

  # Recycle skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_recycle(launcher, target, skill, msg_push = true)
    return false unless s_basic(launcher, target, skill)
    ti = target.battle_item
    ie = target.battle_effect.item_held
    if ti == 0 && ie != 0 && !@_State[:knock_off].include?(target)
      target = _snatch_check(target, skill)
      _mp([:set_item, target, ie])
      _mp([:msg, parse_text_with_pokemon(19, 490, target, ITEM2[1] => ::GameData::Item[ie].name)])
    else
      _mp(MSG_Fail)
    end
  end

  # Trick / Switcheroo skills definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_trick(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)

    li = launcher.battle_item
    ti = target.battle_item
    return _mp(MSG_Fail) if ti == 0 || li == 0

    data_t = ::GameData::Item[ti].misc_data
    data_l = ::GameData::Item[li].misc_data

    # Glue
    return _mp(MSG_Fail) if Abilities.has_abilities(target, 45, 122)
    # Multi-type
    return _mp(MSG_Fail) if data_t && data_t.need_user_id == target.id || data_l && data_l.need_user_id == launcher.id

    # Execute the effect
    _mp([:msg, parse_text_with_pokemon(19, 682, launcher)])
    _mp([:set_item, target, li])
    _mp([:set_item, launcher, ti])

    return true
  end
end
