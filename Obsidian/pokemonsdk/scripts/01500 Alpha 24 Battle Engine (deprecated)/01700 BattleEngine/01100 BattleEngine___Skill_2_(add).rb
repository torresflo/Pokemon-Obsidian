#encoding: utf-8

#noyard
module BattleEngine
	module_function
  #===
  #s_lock_on
  # Verrouillage
  #===
  def s_lock_on(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    _mp([:msg, parse_text_with_pokemon(19, 651, launcher, PKNICK[1] => target.given_name)])
    _mp([:apply_effect, launcher, :apply_lock_on, target])
  end

  #===
  #s_present
  # Cadeau
  #===
  Present_Powers = [40, 40, 40, 40, 80, 80, 80, 120]
  def s_present(launcher, target, skill, msg_push = true)
    v = rand(100)
    if(v < 80)
      skill.power2 = Present_Powers[v / 10]
      s_basic(launcher, target, skill)
      skill.power2 = nil
    else
      return unless __s_beg_step(launcher, target, skill, msg_push)
      _mp([:hp_up, target, 80])
    end
  end

  #===
  #s_trump_card
  # Atout
  #===
  TrumpCard_Powers = [0,200,80,60,50]
  def s_trump_card(launcher, target, skill, msg_push = true)
    if(skill.pp < 5)
      skill.power2 = TrumpCard_Powers[skill.pp]
    else
      skill.power2 = 40
    end
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end

  #===
  #s_torment
  # Tourmente
  #===
  def s_torment(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    target = _magic_coat(launcher, target, skill)
    unless target.battle_effect.has_torment_effect?
      _mp([:msg, parse_text_with_pokemon(19, 577, target)])
      _mp([:apply_effect, target, :apply_torment])
    else
      _mp([:msg_fail])
    end
  end

  #===
  #s_memento
  # Souvenir
  #===
  def s_memento(launcher, target, skill, msg_push = true)
    if s_ohko(launcher, launcher, skill)
      _mp([:change_atk, target, -2])
      _mp([:change_ats, target, -2])
    end
  end

  #===
  #s_facade
  # Façade
  #===
  def s_facade(launcher, target, skill, msg_push = true)
    skill.power2 = 140 if launcher.poisoned? || launcher.paralyzed? || launcher.burn?
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end

  #===
  #s_smelling_salt
  # Stimulant
  #===
  def s_smelling_salt(launcher, target, skill, msg_push = true)
    skill.power2 = 2 * skill.power if target.paralyzed?
    s_basic(launcher, target, skill)
    _mp([:status_cure, target]) if target.paralyzed?
    skill.power2 = nil
  end

  #===
  #s_wakeup_stap
  # Réveil Forcé
  #===
  def s_wakeup_stap(launcher, target, skill, msg_push = true)
    skill.power2 = 2 * skill.power if target.asleep?
    s_basic(launcher, target, skill)
    _mp([:status_cure, target]) if target.asleep?
    skill.power2 = nil
  end

  #===
  #s_helping_hand
  # Coup d’Main
  #===
  def s_helping_hand(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    if(launcher != target and !target.battle_effect.has_helping_hand_effect?)
      _mp([:apply_effect, target, :apply_helping_hand])
    else
      _mp([:msg_fail])
    end
  end

  #===
  #s_wish
  # Vœu
  #===
  def s_wish(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    target = _snatch_check(launcher, skill)
    unless(target.battle_effect.has_wish_effect?)
      _mp([:msg, parse_text_with_pokemon(21, 819, target, PKNAME[0] => launcher.given_name)])
      _mp([:apply_effect, target, :apply_wish, target])
    else
      _mp([:msg_fail])
    end
  end

  #===
  #s_ingrain
  # Racines
  #===
  #< Considérer les switch et les attaques qui affecteront
  def s_ingrain(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    target = _snatch_check(launcher, skill)
    unless(target.battle_effect.has_ingrain_effect?)
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

  #===
  #s_aqua_ring
  # Anneau Hydro
  #===
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

  #===
  #>s_yawn
  # Baillement
  #===
  def s_yawn(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    target = _magic_coat(launcher, target, skill)
    unless(target.battle_effect.has_yawn_effect? or target.battle_effect.has_safe_guard_effect?)
      _mp([:msg, parse_text_with_pokemon(19, 667, target, PKNICK[0] => target.given_name)])
      _mp([:apply_effect, target, :apply_yawn])
    else
      if(target.battle_effect.has_safe_guard_effect?) #> Rune protect
        _msgp(19, 842, target)
      else
        _mp([:msg_fail])
      end
    end
  end

  #===
  #>s_endeavor
  # Effort
  #===
  def s_endeavor(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    if(target.hp > launcher.hp)
      _mp([:hp_down, target, target.hp - launcher.hp])
    else
      _mp([:msg_fail])
    end
  end

  #===
  #>s_grudge
  # Rancune
  #===
  def s_grudge(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    unless(target.battle_effect.has_grudge_effect?)
      _mp([:msg, parse_text_with_pokemon(19, 632, target)])
      _mp([:apply_effect, target, :apply_grudge])
    else
      _mp([:msg_fail])
    end
  end

  #===
  #>s_snatch
  # Saisie
  #===
  def s_snatch(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    be = launcher.battle_effect
    unless(be.has_snatch_effect? and be.get_snatch_target == target)
      _mp([:msg, parse_text_with_pokemon(19, 751, launcher)])
      _mp([:apply_effect, launcher, :apply_snatch, target])
    else
      _mp([:msg_fail])
    end
  end

  #===
  #>s_gravity
  # Gravité
  #===
  def s_gravity(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)

    if(@_State[:gravity] <= 0)
      _mp([:set_state, :gravity, 5])
      _mp([:msg, parse_text(18,123)])
      get_battlers.each do |i|
        unless !i or _is_grounded(i) or i.dead?
          _mp([:msg, parse_text_with_pokemon(19, 1089, i)])
          if i.battle_effect.has_telekinesis_effect?
            _msgp(19, 1149, i)
            _mp([:apply_effect, i, :apply_telekinesis, 0])
          end
        end
      end
    else
      _mp(MSG_Fail)
    end
  end

  #===
  #>s_roost
  # Atterrissage
  #===
  def s_roost(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    target = _snatch_check(launcher, skill)
    if(target.hp < target.max_hp and !_is_grounded(target))
      _mp([:set_type, target, 1, 1]) if target.type1 == 10
      _mp([:set_type, target, 1, 2]) if target.type2 == 10
      _mp([:set_type, target, 1, 3]) if target.type3 == 10
      _mp([:hp_up, target, target.max_hp / 2]) #> Faire le "jusqu'à" plutôt que max/2
    else
      _mp(MSG_Fail)
    end
  end

  #===
  #>s_sleep_talk
  # Blabla dodo
  #===
  #< Attention aux attaques qui se relancent (faut relancer blabla dodo !)
  Sleep_Talk_NoMove = [214, 274, 448, 253, 130, 13, 76, 118, 119, 264, 382, 117, 383, 143, 291, 340, 467, 91, 19]
  def s_sleep_talk(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    target = launcher.battle_effect.last_attacking
    target = _random_target_selection(launcher, target) unless target and target != launcher
    if(launcher != target and launcher.asleep?)
      id = Sleep_Talk_NoMove[0]
      id = rand(GameData::Skill::LAST_ID) + 1 while(Sleep_Talk_NoMove.include?(id))
      skill = ::PFM::Skill.new(id)
      _launch_skill(launcher, target, skill)
    else
      _mp(MSG_Fail)
    end
  end

  #===
  #>s_judgment
  # Attaque Jugement
  #===
  JudgementPlates = [298, 299, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311, 312, 313, 644]
  def s_judgment(launcher, target, skill, msg_push = true)
    if(JudgementPlates.include?(@_State[:launcher_item]))
      imisc = GameData::Item[@_State[:launcher_item]].misc_data
      skill.type2 = imisc.powering_skill_type1 if imisc and imisc.powering_skill_type1
    end
    s_basic(launcher, target, skill)
    skill.type2 = nil
  end
  
  #===
  #>s_techno_blast
  # Techno-Buster
  #===
  def s_techno_blast(launcher, target, skill, msg_push = true)
    # Fails if it's not Genesect
    if launcher.id == 649
      technodrives = { 116 => 3, 117 => 4, 118 => 2, 119 => 6 }
      drive_check = false
      technodrives.each { |key, value| drive_check = true if key == @_State[:launcher_item] }
      skill.type2 = drive_check ? technodrives[@_State[:launcher_item]] : 1
      s_basic(launcher, target, skill)
      skill.type2 = nil
    else
      _mp(MSG_Fail)
    end
  end

  #===
  #>s_venoshock
  # Choc Venin
  #===
  def s_venoshock(launcher, target, skill, msg_push = true)
    if target.poisoned? or target.toxic?
      skill.power2 = skill.power * 2
    end
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end

  #===
  #>s_venom_drench
  # Piege Venin
  #===
  def s_venom_drench(launcher, target, skill, msg_push = true)
    if target.poisoned? or target.toxic?
	  return s_basic(launcher, target, skill)
    end
    __s_beg_step(launcher, target, skill, msg_push)
    _mp(MSG_Fail)
  end

  #===
  #>s_hex
  # Châtiment
  #===
  def s_hex(launcher, target, skill, msg_push = true)
    if target.status != 0
      skill.power2 = skill.power * 2
    end
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end

  #===
  #>s_fake_out
  # Bluff
  #===
  def s_fake_out(launcher, target, skill, msg_push = true)
    if(launcher.battle_effect.nb_of_turn_here == 1)
      s_status(launcher, target, skill)
    else
      __s_beg_step(launcher, target, skill, msg_push)
      _mp(MSG_Fail)
    end
  end

  #===
  #>s_incinerate
  # Calcination
  #===
  def s_incinerate(launcher, target, skill, msg_push = true)
    return unless s_basic(launcher, target, skill)
	  data = ::GameData::Item[target.battle_item].misc_data
    if(data and data.berry) # TODO Joyaux
      # TODO Fix msg parsing with plural
      # _mp([:msg, parse_text_with_pokemon(19, 1114, target, PKNICK[0] => target.given_name, ITEM2[1] => ::GameData::Item[target.battle_item].name)])
      _mp([:set_item, target, 0, true])
	end
  end

  #===
  #>s_secret_power
  # Force Cachée
  #===
  def s_secret_power(launcher, target, skill, msg_push = true)
    return unless s_basic(launcher, target, skill)
    return if rand(100) > skill.effect_chance.to_i
    if($env.very_tall_grass? or $env.tall_grass?)
      _mp([:status_sleep, target])
    elsif($env.cave? or $env.mount?)
      _mp([:effect_afraid, target])
    elsif($env.sand?)
      _mp([:change_acc, target, -1])
    elsif($env.building?)
      _mp([:status_paralyze, target])
    elsif($env.snow?)
      _mp([:status_frozen, target])
    else
      _mp([:change_atk, target, -1])
    end
  end

  #===
  #>s_camouflage
  # Camouflage
  #===
  def s_camouflage(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    target = _snatch_check(target, skill)
    if($env.very_tall_grass? or $env.tall_grass?)
      type = 5
    elsif($env.cave? or $env.mount?)
      type = 13
    elsif($env.building?)
      type = 1
    elsif($env.snow? or $env.ice?)
      type = 6
    elsif($env.sea? or $env.pond? or $env.under_water?)
      type = 3
    else
      type = 9
    end
    _mp([:set_type, target, type, 1])
    _mp([:set_type, target, 0, 2])
  end

  #===
  #>s_sucker_punch
  # Coup bas
  #===
  def s_sucker_punch(launcher, target, skill, msg_push = true)
    skill_id = target.prepared_skill
    if _attacking_before?(launcher, target) && skill_id && skill_id != 0 && GameData::Skill[skill_id].atk_class != 3
      s_basic(launcher, target, skill)
    elsif __s_beg_step(launcher, target, skill, msg_push)
      _mp(MSG_Fail)
    end
  end

  #===
  #>s_pursuit
  # Poursuite
  #===
  def s_pursuit(launcher, target, skill, msg_push = true)
    if(_attacking_before?(launcher, target) and target.attack_order != 255 and target.prepared_skill == 0)
      skill.power2 = skill.power * 2
    end
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end

  #===
  #>s_splash
  # Attaques sans effet
  #===
  def s_splash(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    return _msgp(18, 70) if skill.id == 150 # Trempette
    if skill.id == 606 # Célébration
      trainer = get_enemies!(launcher).compact[0].trainer_name
      _msgp(18, 267, nil, "[VAR TRNAME(0000)]" => trainer)
    end
  end

  #===
  #>s_feint
  # Ruse
  #===
  def s_feint(launcher, target, skill, msg_push = true)
    if(target.battle_effect.has_protect_effect?)
      s_basic(launcher, target, skill)
    else
      __s_beg_step(launcher, target, skill, msg_push)
      _mp(MSG_Fail)
    end
  end

  #===
  #>s_focus_punch
  # Mitra-Poing
  #===
  def s_focus_punch(launcher, target, skill, msg_push = true)
    be = launcher.battle_effect
    if be.has_focus_punch_effect?
      unless(be.took_damage)
        s_basic(launcher, target, skill)
      else
        _msgp(19, 366, launcher)
      end
    else
      _msgp(19, 745, launcher)
      _mp([:apply_effect, launcher, :apply_focus_punch])
    end
  end

  #===
  #>s_last_resort
  # Dernier recours
  #===
  def s_last_resort(launcher, target, skill, msg_push = true)
    if(launcher.skills_set.size > 1)
      i = nil
      count = 1
      launcher.skills_set.each do |i|
        if(i != skill and i.used)
          count += 1
        end
      end
      if(count == launcher.skills_set.size)
        return s_basic(launcher, target, skill)
      end
    end
    return unless __s_beg_step(launcher, target, skill, msg_push)
    _mp(MSG_Fail)
  end

  #===
  #>s_me_first
  # Moi d’Abord
  #===
  def s_me_first(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    if(_attacking_before?(launcher, target) and target.prepared_skill > 0)
      skill = ::PFM::Skill.new(target.prepared_skill)
      if(!skill.status?)
        _launch_skill(launcher, target, skill)
        return
      end
    end
    _mp(MSG_Fail)
  end

  #===
  #>s_miracle_eye
  # Œil Miracle
  #===
  def s_miracle_eye(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    if(target.battle_effect.has_miracle_eye_effect?)
      _mp(MSG_Fail)
    else
      _mp([:set_state, target, 5, 0])
      _mp([:apply_effect, target, :apply_miracle_eye])
    end
  end

  #===
  #>s_assist
  # Assistance
  #===
  NoAssist_Skill = [182, 495, 448, 214, 270, 18, 197, 525, 621, 166, 46, 343, 168, 165, 118, 119, 164, 382, 415, 383, 194, 509, 277, 467, 68, 364, 289, 203, 271, 243, 274]
  def s_assist(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    allies = (@_Actors.include?(launcher) ? @_Actors : @_Enemies)
    if allies.size > 1
      skill_set = []
      1.upto(allies.size - 1) do |i|
        skill_set += allies[i].skills_set.collect do |skill|
          !NoAssist_Skill.include?(skill.id)
        end
      end
      if(skills_set.size > 0)
        return _launch_skill(launcher, target, skills_set[rand(skills_set.size)])
      end
    end
    _mp(MSG_Fail)
  end

  #===
  #>s_imprison
  # Possessif
  #===
  def s_imprison(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    target = _snatch_check(target, skill)
    unless target.battle_effect.has_imprison_effect? or target == launcher
      common = false
      i = nil
      j = nil
      target.skills_set.each do |i|
        launcher.skills_set.each do |j|
          common = true if j.id == i.id
          break if common
        end
        break if common
      end
      if(common or !::GameData::Flag_4G)
        _mp([:apply_effect, target, :apply_imprison_effect, launcher.skills_set])
        _msgp(19, 586, launcher)
        return
      end
    end
    _mp(MSG_Fail)
  end

  #===
  #>s_beat_up
  # Baston
  #===
  def s_beat_up(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    result = true
    if(::GameData::Flag_4G)
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
  #===
  #> s_water_pledge
  # Attaque Aire d'eau
  #===
  def s_water_pledge(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    last_damaging = target.battle_effect.last_damaging_skill
    if(last_damaging and (last_damaging.id == 520 or last_damaging.id == 519)) #> Aire d'herbe / Aire de feu
      skill.power2 = 160
    end
    hp = _damage_calculation(launcher, target, skill).to_i
    return false if __s_hp_down_check(hp, target)
    skill.power2 = nil
    _is_enemy = target.position < 0
    if(last_damaging)
      if last_damaging.id == 520 #> Aire d'herbe
        symbol = _is_enemy ? :enn_swamp : :act_swamp
        unless @_State[symbol] > 0
          _mp([:set_state, symbol, 4])
          _msgp(18, _is_enemy ? 179 : 178)
        end
      elsif last_damaging.id == 519 #> Aire de feu
        symbol = _is_enemy ? :enn_rainbow : :act_rainbow
        unless @_State[symbol] > 0
          _mp([:set_state, symbol, 4])
          _msgp(18, _is_enemy ? 171 : 170)
        end
      end
    end
  end
  #===
  #> s_fire_pledge
  # Attaque Aire de feu
  #===
  def s_fire_pledge(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    last_damaging = target.battle_effect.last_damaging_skill
    if(last_damaging and (last_damaging.id == 520 or last_damaging.id == 518)) #> Aire d'herbe / Aire d'eau
      skill.power2 = 160
    end
    hp = _damage_calculation(launcher, target, skill).to_i
    return false if __s_hp_down_check(hp, target)
    skill.power2 = nil
    _is_enemy = target.position < 0
    if(last_damaging)
      if last_damaging.id == 520 #> Aire d'herbe
        symbol = _is_enemy ? :enn_firesea : :act_firesea
        unless @_State[symbol] > 0
          _mp([:set_state, symbol, 4])
          _msgp(18, _is_enemy ? 175 : 174)
        end
      elsif last_damaging.id == 518 #> Aire d'eau
        symbol = _is_enemy ? :enn_swamp : :act_swamp
        unless @_State[symbol] > 0
          _mp([:set_state, symbol, 4])
          _msgp(18, _is_enemy ? 179 : 178)
        end
      end
    end
  end
  #===
  #> s_grass_pledge
  # Attaque Aire d'herbe
  #===
  def s_grass_pledge(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    last_damaging = target.battle_effect.last_damaging_skill
    if(last_damaging and (last_damaging.id == 519 or last_damaging.id == 518)) #> Aire d'herbe / Aire d'eau
      skill.power2 = 160
    end
    hp = _damage_calculation(launcher, target, skill).to_i
    return false if __s_hp_down_check(hp, target)
    skill.power2 = nil
    _is_enemy = target.position < 0
    if(last_damaging)
      if last_damaging.id == 519 #> Aire de feu
        symbol = _is_enemy ? :enn_firesea : :act_firesea
        unless @_State[symbol] > 0
          _mp([:set_state, symbol, 4])
          _msgp(18, _is_enemy ? 175 : 174)
        end
      elsif last_damaging.id == 518 #> Aire d'eau
        symbol = _is_enemy ? :enn_rainbow : :act_rainbow
        unless @_State[symbol] > 0
          _mp([:set_state, symbol, 4])
          _msgp(18, _is_enemy ? 171 : 170)
        end
      end
    end
  end
  #===
  #> s_smack_down
  # Attaque Anti Air
  #===
  def s_smack_down(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    if(oor = target.battle_effect.get_out_of_reach and (oor == 2 or oor == 4))
      _msgp(19,1134,target)
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
  #===
  #>s_after_you
  # Après Vous
  #===
  def s_after_you(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    if _attacking_before?(target, launcher) || $game_temp.vs_type == 1
      _mp(MSG_Fail)
    else
      _mp([:after_you, target])
    end
  end
  #===
  #>s_quash
  # A la Queue
  #===
  def s_quash(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    # Fail if the target is already attacking last or if we are in a simple battle mode
    if _attacking_last?(target) || $game_temp.vs_type == 1
      _mp(MSG_Fail)
    else
      _mp([:quash, target])
    end
  end
  #===
  #>s_psycho_shift
  # Echange Psy
  #===
  Psycho_Shift = [[false, true, true, true, true, true, false, false, true],
  [nil, :can_be_poisoned?, :can_be_paralyzed?, :can_be_burn?, :can_be_asleep?, :can_be_frozen?, nil, nil, :can_be_poisoned?],
  [nil, :status_poison, :status_paralyze, :status_burn, :status_sleep, :status_frozen, nil, nil, :status_toxic]]
  def s_psycho_shift(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    if(Psycho_Shift[0][launcher.status] and launcher.status != target.status)
      status_check = Psycho_Shift[1][launcher.status]
      status = target.status
      target.status = 0
      status_check = target.send(status_check)
      target.status = status
      if(status_check)
        _mp([:set_status, target, 0])
        _mp([Psycho_Shift[2][launcher.status], target])
        if(Psycho_Shift[0][target.status])
          status_check = Psycho_Shift[1][target.status]
          status = launcher.status
          launcher.status = 0
          status_check = launcher.send(status_check)
          launcher.status = status
          if(status_check)
            _mp([:set_status, launcher, 0])
            _mp([Psycho_Shift[2][target.status], launcher])
            return
          end
        end
        _mp([:status_cure, launcher])
        return
      end
    end
    _mp(MSG_Fail)
  end

  #===
  #>s_geomancy
  # Définition d'un skill qui attaque en deux tours (load => hit)
  #---
  #E : <BE_Model1>
  #===
  def s_geomancy(launcher, target, skill, msg_push = true)
    #>Si il n'a pas fait le tour d'attente / Herbe Pouvoir
    unless(launcher.battle_effect.has_forced_attack? or _has_item(launcher, 271))
      id_txt = GameData::Skill.get_2turns_announce(skill.db_symbol)
      _message_stack_push([:msg, parse_text_with_pokemon(19, id_txt, launcher)]) if id_txt
      _message_stack_push([:force_attack, launcher, target, skill, 2])
      return
    end
    #> Herbe Pouvoir
    if(_has_item(launcher, 271))
      _mp([:set_item, launcher, 0, true])
    end
    s_stat(launcher, target, skill)
  end

  #===
  #>s_magnetic_flux
  # Magné-Contrôle
  #===
  MinusPlus = [96, 97]
  def s_magnetic_flux(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    allies = get_allies!(launcher)
    allies.each do |target|
      if MinusPlus.include?(target.ability) and Abilities.has_ability_usable(target, target.ability)
        _mp([:change_dfe, target, 1])
        _mp([:change_dfs, target, 1])
      end
    end
  end
end
