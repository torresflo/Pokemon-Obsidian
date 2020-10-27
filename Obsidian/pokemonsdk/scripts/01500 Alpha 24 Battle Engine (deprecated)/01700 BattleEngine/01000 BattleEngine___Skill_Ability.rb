#encoding: utf-8

#noyard

# Abilities related skills
module BattleEngine
  module_function

  SIMPLEBEAM = [122, 90, 175, 99] #> Multitype, Truant, Stance Change, Steelworker
  ENTRAINMENT = [122, 90, 175, 148, 112, 69, 149, 160]
  SKILLSWAP = [122, 91] #> Multitype, Wonder Guard
  GASTROACID = [122] #> Every abilities having no effect during turns (turns' beginning excluded!)
  # Abilities related skills definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_ability(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)

    id = skill.id
    target = _magic_coat(launcher, target, skill)
    if id == 493 # Simple Beam
      unless SIMPLEBEAM.include?(target.ability)
        _mp([:msg, parse_text_with_pokemon(19,405, target, ABILITY[1] => ::GameData::Abilities.name(99))])
        _mp([:set_ability, target, 99]) #> Simple
      else
        _mp(MSG_Fail)
      end
    elsif id == 494 # Entrainment
      unless ENTRAINMENT.include?(target.ability) && launcher.ability != target.ability
        _mp([:msg, parse_text_with_pokemon(19,405, target, ABILITY[1] => launcher.ability_name)])
        _mp([:set_ability, target, launcher.ability])
      else
        _mp(MSG_Fail)
      end
    elsif id == 285 # Skill Swap
      unless SKILLSWAP.include?(target.ability) && launcher.ability != target.ability
        _mp([:msg, parse_text_with_pokemon(19,508, launcher)])
        ability = launcher.ability
        _mp([:set_ability, launcher, target.ability])
        _mp([:set_ability, target, ability])
      else
        _mp(MSG_Fail)
      end
    elsif id == 380 # Gastro Acid
      unless GASTROACID.include?(target.ability) || target.battle_effect.has_no_ability_effect?
        _mp([:msg, parse_text_with_pokemon(19,565, target)])
        _mp([:apply_effect, target, :apply_no_ability])
      else
        _mp(MSG_Fail)
      end
    end
  end

  # Role Play skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_role_play(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)

    # Wonder Guard / Multitype
    unless(Abilities.has_ability_usable(target, 17) || Abilities.has_ability_usable(target, 122))
      _message_stack_push([:msg, ::PFM::Text.parse_with_pokemons(19, 619, launcher, target, ::PFM::Text::ABILITY[2] => target.ability_name)])
      _message_stack_push([:set_ability, launcher, target.ability])
    else
      _message_stack_push(MSG_Fail)
    end
  end

  # Worry Seed skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_worry_seed(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)

    target = _magic_coat(launcher, target, skill)
    unless(Abilities.has_ability_usable(target, 17) || Abilities.has_ability_usable(target, 122))
      _message_stack_push([:msg, parse_text_with_pokemon(19, 405, launcher, PKNICK[0] => target.given_name, ::PFM::Text::ABILITY[1] => ::GameData::Abilities.name(49))])
      _message_stack_push([:set_ability, target, 49])
    else
      _message_stack_push(MSG_Fail)
    end
  end
end
