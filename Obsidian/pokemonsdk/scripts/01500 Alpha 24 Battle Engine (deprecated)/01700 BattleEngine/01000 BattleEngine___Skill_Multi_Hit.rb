#encoding: utf-8

#noyard
module BattleEngine
	module_function

  MULTI_HIT_CHANCES = [2, 2, 2, 3, 3, 5, 4, 3]
  # Multi hit skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_multi_hit(launcher, target, skill, msg_push = true)
    did_something = false
    hit2 = false
    criti = {:ch => false}
    return unless __s_beg_step(launcher, target, skill, msg_push)

    #> Move check
    if skill.power > 0
      #> Number of hits calculation
      if false || [68, 117].include?(target.prepared_skill) #> Counter, Bide
        nb_hit = 1
      elsif skill.symbol == :s_2hits
        nb_hit = 2
        hit2 = true if skill.id == 24 #> Only Double Kick
      elsif skill.id == 167 #> Triple Kick 3 hits
        nb_hit = 3
      elsif Abilities::has_ability_usable(launcher, 47) #> Skill Link
        nb_hit = 5
      else
        nb_hit = MULTI_HIT_CHANCES[rand(MULTI_HIT_CHANCES.size)]
      end
      hits = 0
      target_hp = target.hp
      nb_hit.times do
        hp = _damage_calculation(launcher, target, skill, criti).to_i
        if hp > 0
          target_hp -= hp
          #> 
          _mp([:skill_animation, launcher, target, skill]) if hits > 0
          _message_stack_push([:hp_down, target, hp])
          _skill_critical_push unless criti[:ch]
          #> Critical Hit for Double Kick
          ## criti[:ch] = true if hit2 and @_State[:last_critical_hit] > 1 # Cependant pendant la 1G, c'est pas la 1G :v
          did_something = true
          hits += 1
          break if target_hp <= 0 #>Condition d'arrêt
        elsif(@_State[:last_type_modifier] == 0)
          _message_stack_push([:useless_msg, target])
          return #> To prevent putting the effect. TODO: check if that works
        else #> If that failed we stop doing it
          break
        end
      end
      _message_stack_push([:msg, parse_text(18, 33, {NUMB[1] => hits.to_s})])
      _skill_efficiency_push
    end

    did_something |= __s_stat_us_step(launcher, target, skill)

    unless did_something
      _message_stack_push([:msg, parse_text(18, 74)])
    end
  end

  # 2 hits skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_2hits(launcher, target, skill, msg_push = true)
    s_multi_hit(launcher, target, skill)
  end

  # Beat Up skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_beat_up(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    result = true
    if ::GameData::Flag_4G
      skill.power2 = 10
      allies = (@_Actors.include?(launcher) ? @_Actors : @_Enemies)
      allies.each do |launcher|
        next if launcher.status != 0
        skill.type2 = launcher.type_dark? ? nil : 0
        hp = _damage_calculation(launcher, target, skill).to_i
        result &= __s_hp_down_check(hp, target)
      end
    else
      allies = (@_Actors.include?(launcher) ? @_Actors : @_Enemies)
      allies.each do |ally|
        skill.power2 = (ally.atk_basis / 10) + 5
        hp = _damage_calculation(launcher, target, skill).to_i
        result &= __s_hp_down_check(hp, target)
      end
    end
    skill.power2 = nil
    skill.type2 = nil
    _mp(MSG_Fail) unless result
  end

end