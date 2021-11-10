#encoding: utf-8

#noyard

# Environment related skills (weather, areas, environment, tags...)
module BattleEngine
  module_function

  # Camouflage skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_camouflage(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)

    target = _snatch_check(target, skill)
    if $env.very_tall_grass? || $env.tall_grass?
      type = 5
    elsif $env.cave? || $env.mount?
      type = 13
    elsif $env.building?
      type = 1
    elsif $env.snow? || $env.ice?
      type = 6
    elsif $env.sea? || $env.pond? || $env.under_water?
      type = 3
    else
      type = 9
    end
    _mp([:set_type, target, type, 1])
    _mp([:set_type, target, 0, 2])
  end

  SCREENS_TEXTS = [[136, 137], [132, 133], [140, 141], [144, 145]]
  SCREENS_SYMBOLS = [[:act_light_screen, :enn_light_screen], [:act_reflect, :enn_reflect],
                    [:act_safe_guard, :enn_safe_guard], [:act_mist, :enn_mist]]
  # Defog skill definition
  # Don't forget to add both Texts & Symbols entries
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_defog(launcher, target, skill, msg_push = true)
    be = target.battle_effect
    _mp([:entry_hazards_remove, target])
    # Screens removed
    SCREENS_SYMBOLS.each_with_index do |symbols, i|
      sym = target.position < 0 ? symbols[1] : symbols[0]
      if @_State[sym] > 0
        text_id = SCREENS_TEXTS.dig(i, target.position < 0 ? 1 : 0)
        _mp([:msg, parse_text(18, text_id)]) if text_id
        _mp([:set_state, sym, 0])
      end
    end
    if $env.current_weather == 5 #> Fog
      _mp([:weather_change, nil]) #> Weather removed
      _msgp(18, 96, nil)
    end
    s_stat(launcher, target, skill)
  end

  # Mist skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_mist(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    if launcher == target
      _message_stack_push([:msg, parse_text(18, target.position < 0 ? 143 : 142)])
    end
    _message_stack_push([:apply_effect, target, :apply_mist])
  end

  # Water Pledge skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_water_pledge(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    last_damaging = target.battle_effect.last_damaging_skill
    if(last_damaging && (last_damaging.id == 520 || last_damaging.id == 519)) #> Grass Pledge / Fire Pledge
      skill.power2 = 160
    end
    hp = _damage_calculation(launcher, target, skill).to_i
    return false if __s_hp_down_check(hp, target)
    skill.power2 = nil
    _is_enemy = target.position < 0
    if last_damaging
      if last_damaging.id == 520 #> Grass Pledge
        symbol = _is_enemy ? :enn_swamp : :act_swamp
        unless @_State[symbol] > 0
          _mp([:set_state, symbol, 4])
          _msgp(18, _is_enemy ? 179 : 178)
        end
      elsif last_damaging.id == 519 #> Fire Pledge
        symbol = _is_enemy ? :enn_rainbow : :act_rainbow
        unless @_State[symbol] > 0
          _mp([:set_state, symbol, 4])
          _msgp(18, _is_enemy ? 171 : 170)
        end
      end
    end
  end

  # Fire Pledge skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_fire_pledge(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    last_damaging = target.battle_effect.last_damaging_skill
    if(last_damaging && (last_damaging.id == 520 || last_damaging.id == 518)) #> Grass Pledge / Water Pledge
      skill.power2 = 160
    end
    hp = _damage_calculation(launcher, target, skill).to_i
    return false if __s_hp_down_check(hp, target)
    skill.power2 = nil
    _is_enemy = target.position < 0
    if last_damaging
      if last_damaging.id == 520 #> Grass Pledge
        symbol = _is_enemy ? :enn_firesea : :act_firesea
        unless @_State[symbol] > 0
          _mp([:set_state, symbol, 4])
          _msgp(18, _is_enemy ? 175 : 174)
        end
      elsif last_damaging.id == 518 #> Water Pledge
        symbol = _is_enemy ? :enn_swamp : :act_swamp
        unless @_State[symbol] > 0
          _mp([:set_state, symbol, 4])
          _msgp(18, _is_enemy ? 179 : 178)
        end
      end
    end
  end

  # Grass Pledge skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_grass_pledge(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)

    last_damaging = target.battle_effect.last_damaging_skill
    if(last_damaging && (last_damaging.id == 519 || last_damaging.id == 518)) #> Fire Pledge / Water Pledge
      skill.power2 = 160
    end
    hp = _damage_calculation(launcher, target, skill).to_i
    return false if __s_hp_down_check(hp, target)

    skill.power2 = nil
    _is_enemy = target.position < 0
    if last_damaging
      if last_damaging.id == 519 #> Fire Pledge
        symbol = _is_enemy ? :enn_firesea : :act_firesea
        unless @_State[symbol] > 0
          _mp([:set_state, symbol, 4])
          _msgp(18, _is_enemy ? 175 : 174)
        end
      elsif last_damaging.id == 518 #> Water Pledge
        symbol = _is_enemy ? :enn_rainbow : :act_rainbow
        unless @_State[symbol] > 0
          _mp([:set_state, symbol, 4])
          _msgp(18, _is_enemy ? 171 : 170)
        end
      end
    end
  end

  # Rapid Spin skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_rapid_spin(launcher, target, skill, msg_push = true)
    return false unless s_basic(launcher, target, skill)
    _mp([:entry_hazards_remove, launcher])
    _mp([:apply_effect, launcher, :apply_leech_seed, false])
    _mp([:apply_effect, launcher, :apply_bind, 0, skill.name, launcher])
    _mp([:apply_effect, launcher, :apply_taunt, 0])
  end

  # Secret Power skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_secret_power(launcher, target, skill, msg_push = true)
    return unless s_basic(launcher, target, skill)
    return if rand(100) > skill.effect_chance.to_i
    if $env.very_tall_grass? || $env.tall_grass?
      _mp([:status_sleep, target])
    elsif $env.cave? || $env.mount?
      _mp([:effect_afraid, target])
    elsif $env.sand?
      _mp([:change_acc, target, -1])
    elsif $env.building?
      _mp([:status_paralyze, target])
    elsif $env.snow?
      _mp([:status_frozen, target])
    else
      _mp([:change_atk, target, -1])
    end
  end

  # Smack Down skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_smack_down(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    if [2, 4].include? target.battle_effect.get_out_of_reach
      _msgp(19, 1134, target)
      _message_stack_push([:apply_out_of_reach, launcher, 0])
      _message_stack_push([:cancel_attack, target])
    end
    hp = _damage_calculation(launcher, target, skill).to_i
    return false if __s_hp_down_check(hp, target)

    be = target.battle_effect
    if be.has_magnet_rise_effect?
      _msgp(19, 661, target)
      _mp([:apply_effect, target, :apply_magnet_rise, 0])
    end
    if be.has_telekinesis_effect?
      _msgp(19, 1149, target)
      _mp([:apply_effect, target, :apply_telekinesis, 0])
    end
  end

  # Spike skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_spike(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)

    if (ability_user = Abilities.enemy_has_ability_usable(launcher, 17)) #> Garde Magik
      _mp([:ability_display, ability_user, proc {ability_user.hp > 0}])
      _msgp(19, 466, ability_user, "[VAR MOVE(0001)]"=>skill.name)
      target = launcher
    end
    _is_enemy = target.position < 0
    symbol = _is_enemy ? :enn_spikes : :act_spikes
    if @_State[symbol] > 2
      _message_stack_push(MSG_Fail)
    else
      _mp([:set_state, symbol, @_State[symbol] + 1])
      _message_stack_push([:msg, parse_text(18, _is_enemy ? 155 : 154)])
    end
  end

  # Stealth Rock skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_stealth_rock(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    if(ability_user = Abilities.enemy_has_ability_usable(launcher, 17)) #> Garde Magik
      _mp([:ability_display, ability_user, proc {ability_user.hp > 0}])
      _msgp(19, 466, ability_user, "[VAR MOVE(0001)]"=>skill.name)
      target = launcher
    end
    _is_enemy = target.position < 0
    symbol = _is_enemy ? :enn_stealth_rock : :act_stealth_rock
    if @_State[symbol]
      _message_stack_push(MSG_Fail)
    else
      _mp([:set_state, symbol, true])
      _message_stack_push([:msg, parse_text(18, _is_enemy ? 163 : 162)])
    end
  end

  # Sticky Web skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_sticky_web(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    if(ability_user = Abilities.enemy_has_ability_usable(launcher, 17)) #> Garde Magik
      _mp([:ability_display, ability_user, proc {ability_user.hp > 0}])
      _msgp(19, 466, ability_user, "[VAR MOVE(0001)]"=>skill.name)
      target = launcher
    end
    _is_enemy = target.position < 0
    symbol = _is_enemy ? :enn_sticky_web : :act_sticky_web
    if @_State[symbol]
      _message_stack_push(MSG_Fail)
    else
      _mp([:set_state, symbol, true])
      _message_stack_push([:msg, parse_text(18, _is_enemy ? 215 : 214)])
    end
  end

  # Toxic spikes skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_toxic_spike(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    if(ability_user = Abilities.enemy_has_ability_usable(launcher, 17)) #> Garde Magik
      _mp([:ability_display, ability_user, proc {ability_user.hp > 0}])
      _msgp(19, 466, ability_user, "[VAR MOVE(0001)]"=>skill.name)
      target = launcher
    end
    _is_enemy = target.position < 0
    symbol = _is_enemy ? :enn_toxic_spikes : :act_toxic_spikes
    if @_State[symbol] > 1
      _message_stack_push(MSG_Fail)
    else
      _mp([:set_state, symbol, @_State[symbol] + 1])
      _message_stack_push([:msg, parse_text(18, _is_enemy ? 159 : 158)])
    end
  end

  # Telekinesis skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_telekinesis(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    if @_State[:gravity] > 0 || (target.battle_effect.has_ingrain_effect? && !target.type_ghost?) || _has_item(target, 278) # Gravity, Ingrain, Iron Ball
      _mp([:msg_fail])
    else
      _mp([:apply_effect, target, :apply_telekinesis])
      _mp([:msg, parse_text_with_pokemon(19, 1146, target)])
    end
  end

  # Weather related skills
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_weather(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    #>Petite sécurité pour empêcher au système de réussir deux s_weather identiques conjoint
    st = @_State[:air_lock]
    @_State[:air_lock] = false
    case skill.id
    when 240 #>Danse Pluie
      _message_stack_push($env.rain? ? MSG_Fail : [:weather_change, :rain, _has_item(launcher, 285) ? 8 : 5])
    when 241 #>Zénith
      _message_stack_push($env.sunny? ? MSG_Fail : [:weather_change, :sunny, _has_item(launcher, 284) ? 8 : 5])
    when 258 #>Grêle
      _message_stack_push($env.hail? ? MSG_Fail : [:weather_change, :hail, _has_item(launcher, 282) ? 8 : 5])
    when 201 #>Tempête sable
      _message_stack_push($env.sandstorm? ? MSG_Fail : [:weather_change, :sandstorm, _has_item(launcher, 283) ? 8 : 5])
    end
    @_State[:air_lock] = st
  end

  # Weather Ball skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  MeteoType = [1, 3, 2, 13, 6, 1]
  def s_weather_ball(launcher, target, skill, msg_push = true)
    skill.power2 = skill.power * 2 if $env.fog? or $env.sandstorm?
    unless @_State[:air_lock]
      skill.type2 = MeteoType[$env.current_weather].to_i
    end
    s_basic(launcher, target, skill)
    skill.power2 = nil
    skill.type2 = nil
  end

  # Magic & Wonder Room skills definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_wonder_room(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    return unless msg_push
    if skill.id == 472 # Wonder Room
      sym = :wonder_room
      add = 0
    else
      sym = :magic_room
      add = 2
    end
    if @_State[sym] > 0
      _mp([:msg, parse_text(18, 185 + add)])
      _mp([:set_state, sym, 0])
    else
      _mp([:msg, parse_text(18, 184 + add)])
      _mp([:set_state, sym, 5])
    end
  end

end
