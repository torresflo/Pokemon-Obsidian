#encoding: utf-8

#noyard

# Sound-based unsorted moves
module BattleEngine
  module_function

  # Uproar skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_uproar(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    skill.type2 = 0 if target.type_ghost?
    hp=_damage_calculation(launcher, target, skill).to_i
    skill.type2 = nil
    __s_hp_down_check(hp, target, true, false)
    unless launcher.battle_effect.has_forced_attack?
      _message_stack_push([:force_attack, launcher, target, skill, 3])
      #> Apply uproar's effects in States
    end
  end

  # Round skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_round(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    #> Check if the skill was used
    used = false
    get_ally(launcher).each do |i|
      if i.prepared_skill == skill.id && _attacking_before?(i, launcher)
        used = true
      end
    end
    skill.power2 = skill.power * 2 if used
    hp=_damage_calculation(launcher, target, skill).to_i
    skill.power2 = nil
    __s_hp_down_check(hp, target)
  end

  # Echo skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_echo(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    #>Vérifier si l'attaque a été utilisé (Un peu confus sur les conditions d'augmentation...)
    used = launcher.last_skill == skill.id
    get_battlers.each do |i|
      if i.prepared_skill == skill.id && i != launcher && _attacking_before?(i, launcher)
        used = true
      end
    end
    skill.power2 = skill.power + 40 if used
    skill.power2 = 200 if skill.power > 200
    hp=_damage_calculation(launcher, target, skill).to_i
    __s_hp_down_check(hp, target)
  end

  # Perish Song skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_perish_song(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    if msg_push
      i = nil
      #> If we can launch Perish Song
      @_State[:can_perish_song] = !get_battlers.any? do |i|
        if !i&.battle_effect.has_perish_song_effect?
          if Abilities.has_ability_usable(i, 52) #> Soundproof
            _mp([:ability_display, i])
            next(true)
          end
          next(false)
        end
      end
      if @_State[:can_perish_song]
        _message_stack_push([:msg, parse_text(18, 125)])
      else
        _mp(MSG_Fail)
      end
    end
    _message_stack_push([:perish_song, target]) if @_State[:can_perish_song]
  end

  # Snore skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_snore(launcher, target, skill, msg_push = true)
    if launcher.asleep?
      s_basic(launcher, target, skill)
    else
      _message_stack_push([:use_skill_msg, launcher, target, skill])
      _message_stack_push(MSG_Fail)
    end
  end


end