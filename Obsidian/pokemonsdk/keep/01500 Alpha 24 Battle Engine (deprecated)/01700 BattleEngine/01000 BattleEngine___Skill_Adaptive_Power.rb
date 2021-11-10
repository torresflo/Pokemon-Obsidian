#encoding: utf-8

#noyard

# Part of the Skills scripts with skills which power change according to statistics, items & stuff like that
module BattleEngine
  module_function

  # Acrobatics skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_acrobatics(launcher, target, skill, msg_push = true)
    skill.power2 = 2 * skill.power if launcher.battle_item == 0 || !_has_item(launcher, launcher.battle_item)
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end

  # Brine skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_brine(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)

    skill.power2 = skill.power * 2 if target.hp <= (target.max_hp / 2)
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end

  # Charge skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_charge(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)

    __s_stat_us_step(launcher, launcher, skill, nil, 100)
    _mp([:apply_effect, launcher, :apply_charge])
  end

  # Electro Ball skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_electro_ball(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)

    rate = 100 * target.spd / launcher.spd
    rate /= 2 if target.paralyzed?
    rate *= 2 if launcher.paralyzed?
    if rate <= 25
      skill.power2 = 150
    elsif rate <= 33
      skill.power2 = 120
    elsif rate <= 50
      skill.power2 = 80
    elsif rate <= 100
      skill.power2 = 60
    else
      skill.power2 = 40
    end
    hp = _damage_calculation(launcher, target, skill).to_i
    skill.power2 = nil
    __s_hp_down_check(hp, target)
  end

  # Water Spout & Eruption skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_eruption(launcher, target, skill, msg_push = true)
    skill.power2 = 150 * launcher.hp / launcher.max_hp
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end

  # Facade skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_facade(launcher, target, skill, msg_push = true)
    skill.power2 = 140 if launcher.poisoned? || launcher.paralyzed? || launcher.burn?
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end

  # Gyroball skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_gyro_ball(launcher, target, skill, msg_push = true)
    skill.power2 = 25 * target.spd / launcher.spd
    skill.power2 /= 2 if target.paralyzed?
    skill.power2 *= 2 if launcher.paralyzed?
    skill.power2 = 150 if skill.power2 > 150
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end

  HS_W = [20, 25, 33, 50]
  HS_POW = [120, 100, 80, 60, 40]
  # Heavy Slam / Heat Crash
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_heavy_slam(launcher, target, skill, msg_push = true)
    skill.power2 = HS_POW[_weight_test(target, @_State[:target_ability], @_State[:target_item], HS_W, launcher, @_State[:launcher_ability], @_State[:launcher_item])]
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end

  # Hex skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_hex(launcher, target, skill, msg_push = true)
    if target.status != 0
      skill.power2 = skill.power * 2
    end
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end

  LK_W = [10, 25, 50, 100, 200]
  LK_POW = [20, 40, 60, 80, 100, 120]
  # Low Kick skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_low_kick(launcher, target, skill, msg_push = true)
    skill.power2 = LK_POW[_weight_test(target, @_State[:target_ability], @_State[:target_item], LK_W)]
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end

  # Origin Pulse skill definition
  # Deals damage to all adjacent opponents. Its power is boosted by 50% when used by a Pokemon with the ability Mega Launcher
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_origin_pulse(launcher, target, skill, msg_push = true)
    #If the user has mega launcher ability
    if launcher.ability_db_symbol == :mega_launcher
      skill.power2 = skill.power * 1.5
    end
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end

  Present_Powers = [40, 40, 40, 40, 80, 80, 80, 120]
  # Present skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_present(launcher, target, skill, msg_push = true)
    v = rand(100)
    if v < 80
      skill.power2 = Present_Powers[v / 10]
      s_basic(launcher, target, skill)
      skill.power2 = nil
    else
      return unless __s_beg_step(launcher, target, skill, msg_push)

      _mp([:hp_up, target, 80])
    end
  end

  # Psywave skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_psywave(launcher, target, skill, msg_push = true)
    skill.power2 = launcher.level * (rand(10) + 5) / 10
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end

  # Return && Frustration
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_return(launcher, target, skill, msg_push = true)
    skill.power2 = (skill.id == 218 ? 255 - launcher.loyalty : launcher.loyalty) * 10 / 25
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end

  # Seismic Toss & Night Shade skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_hp_eq_level(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)

    type_mod = _type_modifier_calculation(target, skill)
    if type_mod != 0
      _message_stack_push([:hp_down, target, launcher.level])
    else
      _message_stack_push(MSG_Fail)
    end
  end

  # Smelling Salt skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_smelling_salt(launcher, target, skill, msg_push = true)
    skill.power2 = 2 * skill.power if target.paralyzed?
    s_basic(launcher, target, skill)
    _mp([:status_cure, target]) if target.paralyzed?
    skill.power2 = nil
  end

  # Wakeup Stap skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_wakeup_stap(launcher, target, skill, msg_push = true)
    skill.power2 = 2 * skill.power if target.asleep?
    s_basic(launcher, target, skill)
    _mp([:status_cure, target]) if target.asleep?
    skill.power2 = nil
  end

  # Stored Power & Punishment skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_stored_power(launcher, target, skill, msg_push = true)
    target = _magic_coat(launcher, target, skill)
    if skill.id == 386 #> Punishment
      bs = target.battle_stage
      pow = 60
      5.times { |i| pow += (20*bs[i]) if bs[i] > 0 }
      pow = 200 if pow > 200
    else
      bs = launcher.battle_stage
      pow = 20
      bs.each { |i| pow += (20*i) if i > 0 }
    end
    skill.power2 = pow
    s_basic(launcher,target, skill)
    skill.power2 = nil
  end

  # Trump Card skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  TrumpCard_Powers = [0, 200, 80, 60, 50]
  def s_trump_card(launcher, target, skill, msg_push = true)
    skill.power2 = skill.pp < 5 ? TrumpCard_Powers[skill.pp] : 40
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end

  # Venoshock skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_venoshock(launcher, target, skill, msg_push = true)
    if target.poisoned? || target.toxic?
      skill.power2 = skill.power * 2
    end
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end

  # Wring Out & Crush Grip skill definition
  # @param launcher [PFM::Pokemon] user of the move
  # @param target [PFM::Pokemon] target of the move
  # @param skill [PFM::Skill] move that is currently used
  def s_wring_out(launcher, target, skill, msg_push = true)
    skill.power2 = (skill.id == 462 ? 120 : 110) * target.hp / target.max_hp
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end
end
