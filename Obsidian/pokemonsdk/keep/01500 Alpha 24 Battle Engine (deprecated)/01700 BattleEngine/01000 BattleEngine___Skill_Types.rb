#encoding: utf-8

#noyard

# Types related skills
module BattleEngine
  module_function

  # Types related skills with Soak skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_add_type(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    #> Soak
    if skill.id == 487
      if target.type_water? && target.type2 == 0
        _message_stack_push(MSG_Fail)
      else
        _message_stack_push([:set_type, target, 3, 1])
        _message_stack_push([:set_type, target, 0, 2])
        _message_stack_push([:set_type, target, 0, 3])
      end
    elsif skill.id == 567 #>Halloween
      _message_stack_push([:set_type, target, 14, 3])
    elsif skill.id == 571 #>Maléfice sylvain
      _message_stack_push([:set_type, target, 5, 3])
    end
  end

  # Conversion skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_conversion(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    type = launcher.skills_set[0].type
    if type == launcher.type1
      _mp(MSG_Fail)
    else
      target = _snatch_check(target, skill)
      _mp([:set_type, target, type, 1])
      _mp([:msg, parse_text_with_pokemon(19,899,target, 
      '[VAR TYPE(0001)]' => GameData::Type[type].name)])
    end
  end

  # Conversion 2 skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_conversion2(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    id_skill = target.last_skill
    if id_skill != 0
      type = GameData::Skill[id_skill].type
    else
      type = launcher.type1
    end
    if type == launcher.type1
      _mp(MSG_Fail)
    else
      _mp([:set_type, launcher, type, 1])
      _mp([:msg, parse_text_with_pokemon(19,899,launcher, 
      '[VAR TYPE(0001)]' => GameData::Type[type].name)])
    end
  end

  # Magnet Rise skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_magnet_rise(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    target = _snatch_check(target, skill)
    _mp([:msg, parse_text_with_pokemon(19, 658, target)])
    _mp([:apply_effect, target, :apply_magnet_rise])
  end

  # Reflect type skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_reflect_type(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    target_types = [target.type1, target.type2, target.type3]
    # If the target has no type (Burn Up) or if the launcher has the Multitype (Multi-Type) ability
    if target_types[0] == 0 || Abilities.has_ability_usable(launcher, 122)
      _mp(MSG_Fail)
    # If the target has the same types as the launcher
    elsif target_types[0] == launcher.type1 && target_types[1] == launcher.type2 && target_types[2] == launcher.type3
      _mp(MSG_Fail)
    else
      target_types.each_index do |i|
        unless target_types[i] == 0
          _mp([:set_type, launcher, target_types[i], i + 1])
          _mp([:msg, parse_text_with_pokemon(19,899,launcher, 
          '[VAR TYPE(0001)]' => GameData::Type[target_types[i]].name)])
        else
          _mp([:set_type, launcher, target_types[i], i + 1])
        end
      end
    end
  end

  # Powder skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_powder(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    _message_stack_push([:powder_effect, target])
  end
end
