#encoding: utf-8

#noyard

# Copy related skills
module BattleEngine
  module_function

  # Metronome skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  MIRROR_NOMOVE = [555, 182, 511, 495, 274, 448, 214, 547, 102, 270, 557, 197, 553, 554, 267, 469, 166, 343, 168, 548, 165,
                   118, 119, 264, 382, 144, 266, 415, 516, 383, 476, 501, 194, 277, 68, 173, 364, 289, 546, 203, 271]
  def s_metronome(launcher, target, skill, msg_push = true)
    target = _random_target_selection(launcher, target)
    return false unless __s_beg_step(launcher, target, skill, msg_push)

    if skill.id == 267 #> Nature Power
      if $env.very_tall_grass?
        id = 75
      elsif $env.tall_grass?
        id = 78
      elsif $env.cave?
        id = 247
      elsif $env.mount?
        id = 157
      elsif $env.sand?
        id = 89
      elsif $env.pond?
        id = 61
      elsif $env.sea?
        id = 57
      elsif $env.under_water?
        id = 56
      else
        id = 129
      end
    else
      id = MIRROR_NOMOVE[0]
      id = rand(GameData::Skill::LAST_ID) + 1 while MIRROR_NOMOVE.include?(id)
    end
    skill = ::PFM::Skill.new(id)
    _msgp(18, skill.id == 267 ? 127 : 126, nil, MOVE[0] => skill.name)
    _launch_skill(launcher, target, skill)
  end

  # Mimic skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_mimic(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)

    ls = target.last_skill
    if ls > 0 && ls != 165 && ls != skill.id
      _mp([:msg, parse_text_with_pokemon(19, 688, launcher, MOVE[1] => ::GameData::Skill[ls].name)])
      _mp([:mimic, launcher, target, skill, ls])
    else
      _mp(MSG_Fail)
    end
  end

  # Mirror Move skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_mirror_move(launcher, target, skill, msg_push = true)
    return if skill.id == 119
    #> Potential target
    if skill.id == 383 #> Copycat, bugged in 2v2 !
      target = launcher.battle_effect.last_attacking
      target = _random_target_selection(launcher, target) unless target && target != launcher
      target = launcher if target.attack_order == 255
    else
      target = launcher.battle_effect.last_attacking
      target ||= launcher
    end
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    #> Fail if no target
    if target == launcher
      _mp(MSG_Fail)
      return false
    end
    #> Search for the last skill launched
    if skill.id == 383 #> Copycat
      skill = @_State[:last_skill]
    else
      skill = target.find_skill(target.last_skill)
      skill = nil unless skill&.mirror_move?
    end
    #> Skill use
    if skill&.symbol != :s_mirror_move && skill # && $scene.class == ::Scene_Battle
      _launch_skill(launcher, target, skill)
    else
      _message_stack_push(MSG_Fail)
    end
  end

  DAMP_MOVES = [120, 153]
  SKETCH_MOVES_CANT_COPY = [165, 166, 448]
  # Sketch skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_sketch(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    ls = target.last_skill
    #> Chatter / Struggle, Damp & Explosion / Self-Destruct
    if ls <= 0 || SKETCH_MOVES_CANT_COPY.include?(ls) || (!Abilities.has_ability_usable(target, 28) && DAMP_MOVES.include?(ls))
      _mp(MSG_Fail)
    else
      _mp([:msg, parse_text_with_pokemon(19, 691, launcher, MOVE[1] => ::GameData::Skill[ls].name)])
      _mp([:sketch, launcher, skill, ls])
    end
  end

  # Transform skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_transform(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)

    _mp([:morph, launcher, target])
    _mp([:switch_form, launcher])
    _mp([:msg, ::PFM::Text.parse_with_pokemons(19, 644, launcher, target)])
  end
end
