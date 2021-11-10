#encoding: utf-8

#noyard
module BattleEngine
  module_function

  # Bide skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_bide(launcher, target, skill, msg_push = true)
    counter = launcher.battle_effect.get_forced_attack_counter
    #> Inactive Bide
    if counter == 0
      _message_stack_push([:use_skill_msg, launcher, target, skill])
      _mp([:msg, parse_text_with_pokemon(19, 745, launcher)])
      _mp([:apply_effect, launcher, :apply_bide])
      _mp([:apply_effect, launcher, :apply_forced_attack, skill.id, rand(2)+3, target])
    elsif counter == 1
      _mp([:apply_effect, launcher, :apply_forced_attack, 0, 0, target])
      _mp([:msg, parse_text_with_pokemon(19, 748, launcher)])
      return false unless __s_beg_step(launcher, target, skill, false)
      hp = launcher.battle_effect.get_bide_power * 2
      if hp > 0
        _mp([:hp_down, target, hp])
      else
        _mp(MSG_Fail)
      end
      @_State[:ext_info] = true
    end
  end

  # Fury Cutter skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_fury_cutter(launcher, target, skill, msg_push = true)
    be = launcher.battle_effect
    if be.fury_cutter_power > 0
      skill.power2 = be.fury_cutter_power * 2
      skill.power2 = 160 if skill.power2 >= 160
    end
    if s_basic(launcher, target, skill)
      be.fury_cutter_power = skill.power
    else
      be.fury_cutter_power = 0
    end
    skill.power2 = nil
  end

  # Future Sight / Domm Desire skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_future_sight(launcher, target, skill, msg_push = true)
    skill.type2 = 0
    fail = !__s_beg_step(launcher, target, skill, msg_push)
    #> "Future Sight cannot be used on a target multiple times; it must complete before it may be used on a target again"
    if target.battle_effect.is_locked_by_future_skill? || launcher.battle_effect.has_future_skill?
      return _mp(MSG_Fail)
    end
    hp = _damage_calculation(launcher, target, skill).to_i
    hp*=0 if fail
    skill.type2 = nil
    if skill.id == 248 # Future Sight
      _message_stack_push([:msg, parse_text_with_pokemon(19, 1080, launcher)])
    else
      _message_stack_push([:msg, parse_text_with_pokemon(19, 1083, launcher)])
    end
    _message_stack_push([:future_skill, target, hp, 3, skill.id])
  end

  # Geomancy 2 turns skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_geomancy(launcher, target, skill, msg_push = true)
    #> If the Pokémon didn't wait / Power Herb
    unless(launcher.battle_effect.has_forced_attack? || _has_item(launcher, 271))
      id_txt = GameData::Skill.get_2turns_announce(skill.db_symbol)
      _message_stack_push([:msg, parse_text_with_pokemon(19, id_txt, launcher)]) if id_txt
      _message_stack_push([:force_attack, launcher, target, skill, 2])
      return
    end
    #> Power Herb
    if(_has_item(launcher, 271))
      _mp([:set_item, launcher, 0, true])
    end
    s_stat(launcher, target, skill)
  end
  
  # Outrage & Petal Danse definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_outrage(launcher, target, skill, msg_push = true)
    #> Petal Danse : random enemy
    if skill.id == 80
      target = _random_target_selection(launcher, target)
    end
    result = s_basic(launcher, target, skill)
    counter = launcher.battle_effect.get_forced_attack_counter
    #> Inactive Outrage
    if counter == 0
      return unless result
      _mp([:apply_effect, launcher, :apply_forced_attack, skill.id, rand(2)+2, target]) unless @_State[:ext_info]
      @_State[:ext_info] = true
    elsif counter == 1 || !result
      unless @_State[:ext_info]
        _mp([:apply_effect, launcher, :apply_forced_attack, 0, 0, target])
        _mp([:status_confuse, launcher, true, 360])
      end
      @_State[:ext_info] = true
    end
  end

  # Reload skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_reload(launcher, target, skill, msg_push = true)
    if launcher.battle_effect.must_reload
      _message_stack_push([:msg, parse_text_with_pokemon(19, 851, launcher)])
    else
      s_basic(launcher, target, skill)
      _message_stack_push([:set_reload_state, launcher])
    end
  end

  # Stockpile skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_stockpile(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    stockpile_counter = launcher.battle_effect.stockpile
    if stockpile_counter < 3
      stockpile_counter += 1
      _mp([:msg, parse_text_with_pokemon(19, 721, launcher, "[VAR NUM1(0001)]" => stockpile_counter.to_s)])
      _mp([:apply_effect, launcher, :stockpile=, stockpile_counter])
    else
      _mp(MSG_Fail)
    end
  end

  # Split Up skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_split_up(launcher, target, skill, msg_push = true)
    stockpile_counter = launcher.battle_effect.stockpile
    if stockpile_counter > 0
      skill.power2 = stockpile_counter * 100
      s_basic(launcher, target, skill)
      skill.power2 = nil
    else
      _message_stack_push([:use_skill_msg, launcher, target, skill]) if msg_push
      _mp(MSG_Fail)
    end
    _mp([:apply_effect, launcher, :stockpile=, 0])
  end

  # Swallow skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_swallow(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    stockpile_counter = launcher.battle_effect.stockpile
    target = _snatch_check(target, skill)
    if stockpile_counter > 0 && target.hp != target.max_hp
      hp = (launcher.max_hp * 2**(stockpile_counter - 3)).to_i
      _mp([:hp_up, target, hp])
    else
      _mp(MSG_Fail)
    end
    _mp([:apply_effect, launcher, :stockpile=, 0])
  end

  # Thrash skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_thrash(launcher, target, skill, msg_push = true)
    target = _random_target_selection(launcher, target)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    return _mp(MSG_Fail) if launcher == target
    hp=_damage_calculation(launcher, target, skill).to_i
    __s_hp_down_check(hp, target, true, false)
    if(launcher.battle_effect.get_forced_attack_counter == 1 && !launcher.battle_effect.thrash_incomplete)
      _message_stack_push([:status_confuse, launcher, true, 360])
    end
    unless launcher.battle_effect.has_forced_attack?
      _message_stack_push([:force_attack, launcher, launcher, skill, 2 + rand(2)])
    end
  end
  
end