#encoding: utf-8

#noyard
module BattleEngine
	module_function
  #===
  #>s_attract
  # Définition de l'attaque attraction
  #---
  #E : <BE_Model1>
  #===
  def s_attract(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    _message_stack_push([:attract_effect, launcher, target])
  end
  #===
  #>s_powder
  # Définition de l'attaque Nuée de Poudre
  #---
  #E : <BE_Model1>
  #===
  def s_powder(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    _message_stack_push([:powder_effect, target])
  end
  #===
  #>s_uproar
  # Définition de l'attaque Brouhaha
  #---
  #E : <BE_Model1>
  #===
  def s_uproar(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    skill.type2 = 0 if(target.type_ghost?)
    hp=_damage_calculation(launcher, target, skill).to_i
    skill.type2 = nil
    __s_hp_down_check(hp, target, true, false)
    unless launcher.battle_effect.has_forced_attack?
      _message_stack_push([:force_attack, launcher, target, skill, 3])
      #>Appliquer les effets de brouhaha dans les états !
    end
  end
  #===
  #>s_round
  # Définition de l'attaque Chant canon
  #---
  #E : <BE_Model1>
  #===
  def s_round(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    #>Vérifier si l'attaque a été utilisé
    used = false
    get_ally(launcher).each do |i|
      if(i.prepared_skill == skill.id and _attacking_before?(i, launcher))
        used = true
      end
    end
    skill.power2 = skill.power * 2 if used
    hp=_damage_calculation(launcher, target, skill).to_i
    skill.power2 = nil
    __s_hp_down_check(hp, target)
  end
  #===
  #>s_echo
  # Définition de l'attaque Echo
  #---
  #E : <BE_Model1>
  #===
  def s_echo(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    #>Vérifier si l'attaque a été utilisé (Un peu confus sur les conditions d'augmentation...)
    used = launcher.last_skill == skill.id
    get_battlers.each do |i|
      if(i.prepared_skill == skill.id and i != launcher and _attacking_before?(i, launcher))
        used = true
      end
    end
    skill.power2 = skill.power + 40 if used
    skill.power2 = 200 if skill.power > 200
    hp=_damage_calculation(launcher, target, skill).to_i
    __s_hp_down_check(hp, target)
  end
  #===
  #>s_heal_bell
  # Définition de l'attaque Glas de soin et Régénération
  #---
  #E : <BE_Model1>
  #===
  def s_heal_bell(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    target = _snatch_check(target, skill)
    _message_stack_push([:status_cure, target])
  end
  #===
  #>s_roar
  # Définition de l'attaque Hurlement / Cyclone
  #---
  #E : <BE_Model1>
  #===
  def s_roar(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    target = _magic_coat(launcher, target, skill)
    #>Combat de sauvage
    unless $game_temp.trainer_battle
      return if(launcher.position < 0 and target.position < 0)
      #>Si non sauvage
      if(launcher.position >= 0)
        if(Abilities.has_ability_usable(target, 84)) #>Ventouse
          _mp([:msg, parse_text_with_pokemon(19,454,target)])
        elsif(target.battle_effect.has_ingrain_effect?) #>Racines
          _mp([:msg, parse_text_with_pokemon(19,742,target)])
        elsif(launcher.level > target.level && !$game_switches[Yuki::Sw::BT_NoEscape])
          _mp([:msg, parse_text_with_pokemon(19, 767, launcher)])
          _message_stack_push([:roar, target])
        else
          _message_stack_push([:msg_fail, target])
        end
        return
      end
    end
    #>Vérification provenant de Draco-queue peut être redondante par rapport à la précédente ^^
    unless(launcher.position >= 0 and !$game_temp.trainer_battle)
      party = (target.position < 0 ? $scene.enemy_party : $pokemon_party)
      if party.pokemon_alive > $game_temp.vs_type
        party = (target.position < 0 ? @_Enemies : @_Actors)
        n_party = Array.new
        $game_temp.vs_type.upto(party.size-1) do |i|
          n_party<<party[i] unless party[i].dead? # if party[i].hp > 0
        end
        if(Abilities.has_ability_usable(target, 84)) #>Ventouse
          _mp([:msg, parse_text_with_pokemon(19,454,target)])
        elsif(false) #>Racines
          _mp([:msg, parse_text_with_pokemon(19,742,target)])
        else
          _mp([:switch_pokemon, target, n_party[rand(n_party.size)]]) if n_party.size > 0 #>Redondance
        end
        return
      end
    end
    _mp([:msg_fail, target])
  end
  #===
  #>s_perish_song
  # Définition de l'attaque Requiem
  #---
  #E : <BE_Model1>
  #===
  def s_perish_song(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    if msg_push
      i = nil
      #> Vérification de la possibilité de lancer perish_song
      @_State[:can_perish_song] = !get_battlers.any? do |i|
        if(i and !i.battle_effect.has_perish_song_effect?)
          if(Abilities.has_ability_usable(i, 52)) #> Anti-Bruit
            _mp([:ability_display, i])
            next(true)
          end
          next(false)
        end
      end
      if(@_State[:can_perish_song])
        _message_stack_push([:msg, parse_text(18, 125)])
      else
        _mp(MSG_Fail)
      end
    end
    _message_stack_push([:perish_song, target]) if @_State[:can_perish_song]
  end
  #===
  #>s_snore
  # Définition de l'attaque ronflement
  #---
  #E : <BE_Model1>
  #===
  def s_snore(launcher, target, skill, msg_push = true)
    if(launcher.asleep?)
      s_basic(launcher, target, skill)
    else
      _message_stack_push([:use_skill_msg, launcher, target, skill])
      _message_stack_push(MSG_Fail)
    end
  end
  #===
  #>s_payday
  # Définition de l'attaque Jackpot
  #---
  #E : <BE_Model1>
  #===
  def s_payday(launcher, target, skill, msg_push = true)
    if s_basic(launcher, target, skill)
      _message_stack_push([:jackpot, launcher])
    end
  end
  #===
  #>s_happy_hour
  # Définition de l'attaque Étrennes
  #---
  #E : <BE_Model1>
  #===
  def s_happy_hour(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    if @_State[:happy_hour]
      _mp(MSG_Fail)
    else
      _message_stack_push([:happy_hour, launcher])
    end
  end
  #===
  #>s_bind
  # Définition de l'attaque Etreinte
  #---
  #E : <BE_Model1>
  #===
  def s_bind(launcher, target, skill, msg_push = true)
    if s_basic(launcher, target, skill)
      #>Accro Griffe
      if(_has_item(launcher, 286))
        nb_turn = 5
      else
        nb_turn = 4+rand(2)
      end
      _message_stack_push([:bind, target, nb_turn, skill, launcher])
    end
  end
  #===
  #>s_thrash
  # Définition de l'attaque Mania
  #---
  #E : <BE_Model1>
  #===
  def s_thrash(launcher, target, skill, msg_push = true)
    target = _random_target_selection(launcher, target)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    return _mp(MSG_Fail) if launcher == target
    hp=_damage_calculation(launcher, target, skill).to_i
    __s_hp_down_check(hp, target, true, false)
    if(launcher.battle_effect.get_forced_attack_counter == 1 and !launcher.battle_effect.thrash_incomplete)
      _message_stack_push([:status_confuse, launcher, true, 360])
    end
    unless launcher.battle_effect.has_forced_attack?
      _message_stack_push([:force_attack, launcher, launcher, skill, 2+rand(2)])
    end
  end
  #===
  #>s_absorb
  # Définition de l'attaque Vol-Vie
  #---
  #E : <BE_Model1>
  #===
  def s_absorb(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)

    hp=_damage_calculation(launcher, target, skill).to_i
    hp = target.max_hp if hp > target.max_hp
    return false if __s_hp_down_check(hp, target)
    #>Grosse racine
    hp = hp*130/100 if(_has_item(launcher, 296))
    #>Vampibaiser
    hp = hp*150/100 if(skill.id == 577)

    hp = 2 if hp < 2 #>Pour récupérer 1 hp si ça a fait moins de 2 hp de dégas
    #>Suintement
    if target.ability == 36
      _message_stack_push([:hp_down, launcher, hp/2])
      _message_stack_push([:msg, parse_text_with_pokemon(19, 457, launcher)])
    elsif(!launcher.battle_effect.has_heal_block_effect?) #>Anti-Soin
      #>Vérifier le clone !
      _message_stack_push([:hp_up, launcher, hp/2])
      _message_stack_push([:msg, parse_text_with_pokemon(19, 905, target)])
    else
      _mp([:msg, parse_text_with_pokemon(19,890, launcher)])
    end

    __s_stat_us_step(launcher, target, skill)
    return true
  end
  #===
  #>s_dream_eater
  # Définition de l'attaque Dévorêve
  #---
  #E : <BE_Model1>
  #===
  def s_dream_eater(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)

    unless(target.asleep?)
      _message_stack_push(MSG_Fail)
      return false
    end

    hp=_damage_calculation(launcher, target, skill).to_i
    return false if __s_hp_down_check(hp, target)

    if(launcher.battle_effect.has_heal_block_effect?)
      BattleEngine::_message_stack_push([:msg, parse_text_with_pokemon(19,890, launcher)])
      return
    end

    hp = 2 if hp < 2 #>Pour récupérer 1 hp si ça a fait moins de 2 hp de dégats
    #>Vérifier le clone !
    _message_stack_push([:hp_up, launcher, hp/2])
    _message_stack_push([:msg, parse_text_with_pokemon(19, 905, target)])

    __s_stat_us_step(launcher, target, skill)
    return true
  end
  #===
  #>s_growth
  # Définition de l'attaque croissance
  #===
  def s_growth(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    if($env.sunny?)
      nb = 2
    else
      nb = 1
    end
    _message_stack_push([:change_atk, target, nb])
    _message_stack_push([:change_ats, target, nb])
  end
  #===
  #>s_leech_seed
  # Définition de l'attaque vampigraine
  #===
  def s_leech_seed(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    if(target.battle_effect.has_leech_seed_effect? or target.type_grass?) #> Immunité
      _message_stack_push(MSG_Fail)
    else
      _message_stack_push([:leech_seed, target, launcher])
    end
  end
  #===
  #>s_future_sight
  # Définition de Prescience / Carnareket
  #===
  def s_future_sight(launcher, target, skill, msg_push = true)
    skill.type2 = 0
    fail = !__s_beg_step(launcher, target, skill, msg_push)
    #> "Future Sight cannot be used on a target multiple times; it must complete before it may be used on a target again"
    if target.battle_effect.is_locked_by_future_skill? or launcher.battle_effect.has_future_skill?
      return _mp(MSG_Fail)
    end
    hp = _damage_calculation(launcher, target, skill).to_i
    hp*=0 if fail
    skill.type2 = nil
    if(skill.id == 248) #Préscience
      _message_stack_push([:msg, parse_text_with_pokemon(19, 1080, launcher)])
    else
      _message_stack_push([:msg, parse_text_with_pokemon(19, 1083, launcher)])
    end
    _message_stack_push([:future_skill, target, hp, 3, skill.id])
  end
  #===
  #>s_spike
  # Définition de picots
  #===
  def s_spike(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    if(ability_user = Abilities.enemy_has_ability_usable(launcher, 17)) #> Garde Magik
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
  #===
  #>s_toxic_spike
  # Définition de Pics Toxik
  #===
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
  #===
  #>s_stealth_rock
  # Définition de Piège de roc
  #===
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
  #===
  #>s_sticky_web
  # Définition de Toile Gluante
  #===
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
  #===
  #>s_minimize
  # Défition de l'attaque lilliput
  #===
  def s_minimize(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    if __s_stat_us_step(launcher, launcher, skill, nil, 100)
      _message_stack_push([:apply_effect, target, :apply_minimize])
    else
      _message_stack_push(MSG_Fail)
    end
  end
  #===
  #>s_mist
  # Définition de brume
  #===
  def s_mist(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    if(launcher == target) #>Sinon faire avec state pp == 1
      _message_stack_push([:msg, parse_text(18, target.position < 0 ? 143 : 142)])
    end
    _message_stack_push([:apply_effect, target, :apply_mist])
  end
  #===
  #>s_rest
  # Définition de repos
  #===
  def s_rest(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    #> Insomia / Esprit Vital
    if(launcher.max_hp == launcher.hp or Abilities.has_ability_usable(launcher, 49) or
      Abilities.has_ability_usable(launcher, 30))
      _message_stack_push(MSG_Fail)
    elsif(target.battle_effect.has_heal_block_effect?)
      _mp([:msg, parse_text_with_pokemon(19,893, launcher, MOVE[1] => skill.name)])
    else
      _message_stack_push([:status_cure, launcher])
      _message_stack_push([:status_sleep, launcher, Abilities.has_ability_usable(launcher, 41) ? 1 : 3])
      _message_stack_push([:hp_up, launcher, launcher.max_hp - launcher.hp])
    end
  end
  #===
  #>s_explosion
  # Définition de explosion
  #===
  def s_explosion(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    if Abilities.has_ability_usable(launcher, 28)
      if msg_push
        _mp([:ability_display, target])
        _mp(MSG_Fail)
      end
      return
    end
    if(Abilities.has_ability_usable(target, 28)) #>Moiteur
      _mp([:ability_display, target])
    else
      _message_stack_push([:hp_down, launcher, launcher.max_hp]) if msg_push
      hp=_damage_calculation(launcher, target, skill).to_i
      __s_hp_down_check(hp, target)
    end
  end
  #===
  #>s_mirror_move
  # Définition de l'attaque Mimique
  #===
  def s_mirror_move(launcher, target, skill, msg_push = true)
    return if skill.id == 119
    #>Récupération de la cible potentielle
    if skill.id == 383 #>Photocopie
      #>Photocopie buggué en 2v2 !
      target = launcher.battle_effect.last_attacking
      target = _random_target_selection(launcher, target) unless target and target != launcher
      target = launcher if target.attack_order == 255
    else
      target = launcher.battle_effect.last_attacking
      target = launcher unless target
    end
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    #>Echec si pas de cible
    if(target == launcher)
      _mp(MSG_Fail)
      return false
    end
    #>Recherche de la dernière attaque réalisé
    if skill.id == 383 #>Photocopie
      skill = @_State[:last_skill]
    else
      skill = target.find_skill(target.last_skill)
      skill = nil unless skill and skill.mirror_move?
    end
    #> Utilisation de l'attaque
    if(skill and skill.symbol != :s_mirror_move)#and $scene.class == ::Scene_Battle)
      _launch_skill(launcher, target, skill)
    else
      _message_stack_push(MSG_Fail)
    end
  end
  #===
  #>s_metronome
  # Définition de l'attaque Métronome
  #===
  Mirror_noMove = [555, 182, 511, 495, 274, 448, 214, 547, 102, 270, 557, 197, 553, 554, 267, 469, 166, 343, 168, 548, 165, 118, 119, 264, 382, 144, 266, 415, 516, 383, 476, 501, 194, 277, 68, 173, 364, 289, 546, 203, 271]
  def s_metronome(launcher, target, skill, msg_push = true)
    target = _random_target_selection(launcher, target)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    if(skill.id == 267) #> Force-Nature
      if($env.very_tall_grass?)
        id = 75
      elsif($env.tall_grass?)
        id = 78
      elsif($env.cave?)
        id = 247
      elsif($env.mount?)
        id = 157
      elsif($env.sand?)
        id = 89
      elsif($env.pond?)
        id = 61
      elsif($env.sea?)
        id = 57
      elsif($env.under_water?)
        id = 56
      else
        id = 129
      end
    else
      id = Mirror_noMove[0]
      id = rand(GameData::Skill::LAST_ID) + 1 while(Mirror_noMove.include?(id))
    end
    skill = ::PFM::Skill.new(id)
    _msgp(18, skill.id == 267 ? 127 : 126, nil, MOVE[0] => skill.name)
    _launch_skill(launcher, target, skill)
  end
  #===
  #>s_heal_weather
  # Définition des attaques qui heal en fonction de la météo : Aurore / Rayon Lune / Synthèse
  #===
  def s_heal_weather(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    target = _snatch_check(target, skill)
    if(target.battle_effect.has_heal_block_effect?)
      _mp([:msg, parse_text_with_pokemon(19,890, target)])
      return
    elsif(target.hp == target.max_hp)
      _mp(MSG_Fail)
      return
    end
    if($env.normal?)
      hp = target.max_hp / 2
    elsif($env.sunny?)
      hp = target.max_hp * 2 / 3
    else
      hp = target.max_hp / 4
    end
    _message_stack_push([:hp_up, target, hp])
    _message_stack_push([:msg, parse_text_with_pokemon(19, 387, target)])
  end
  #===
  #>s_heal
  # Définition des attaques qui soignent le demi des hp
  #===
  def s_heal(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    target = _snatch_check(target, skill)
    if(target.battle_effect.has_heal_block_effect?)
      _mp([:msg, parse_text_with_pokemon(19,890, target)])
      return
    elsif(target.hp == target.max_hp)
      _mp(MSG_Fail)
      return
    # Heal Pulse fails if the target has a substitute
    elsif(target.battle_effect.has_substitute_effect? && skill.id == 505)
      _mp(MSG_Fail)
      return
    end
    # Vibra Soin & Méga Blaster
    if skill.id == 505 && Abilities.has_ability_usable(launcher, 177)
      hp = target.max_hp * 3 / 4
    else
      hp = target.max_hp / 2
    end
    _message_stack_push([:hp_up, target, hp])
    _message_stack_push([:msg, parse_text_with_pokemon(19, 387, target)])
  end
  #===
  #>s_weather_ball
  # Ball'Météo
  #===
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
  #===
  #>s_captivate
  # Séduction
  #===
  def s_captivate(launcher, target, skill, msg_push = true)
    #>Benêt
    if((target.gender * @launcher.gender == 2) and !Abilities.has_ability_usable(target, 39))
      s_stat(launcher, target, skill)
    else
      return false unless __s_beg_step(launcher, target, skill, msg_push)
      _message_stack_push(MSG_Fail)
    end
  end
  #===
  #>s_add_type
  # Attaque du genre Halloween avec supplément de détrempage
  #===
  def s_add_type(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    #>Cas de détrempage
    if(skill.id == 487)
      if(target.type_water? and target.type2 == 0)
        _message_stack_push(MSG_Fail)
      else
        _message_stack_push([:set_type, target, 3, 1])
        _message_stack_push([:set_type, target, 0, 2])
        _message_stack_push([:set_type, target, 0, 3])
      end
    elsif(skill.id == 567) #>Halloween
      _message_stack_push([:set_type, target, 14, 3])
    elsif(skill.id == 571) #>Maléfice sylvain
      _message_stack_push([:set_type, target, 5, 3])
    end
  end
  #===
  #>s_role_play
  # Imitation
  #===
  def s_role_play(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    #Garde magik / Multi-type
    unless(Abilities.has_ability_usable(target, 17) or Abilities.has_ability_usable(target, 122))
      _message_stack_push([:msg, ::PFM::Text.parse_with_pokemons(19, 619, launcher, target, ::PFM::Text::ABILITY[2] => target.ability_name)])
      _message_stack_push([:set_ability, launcher, target.ability])
    else
      _message_stack_push(MSG_Fail)
    end
  end
  #===
  #>s_worry_seed
  # Souci Graine
  #===
  def s_worry_seed(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    target = _magic_coat(launcher, target, skill)
    unless(Abilities.has_ability_usable(target, 17) or Abilities.has_ability_usable(target, 122))
      _message_stack_push([:msg, parse_text_with_pokemon(19, 405, launcher, PKNICK[0] => target.given_name, ::PFM::Text::ABILITY[1] => ::GameData::Abilities.name(49))])
      _message_stack_push([:set_ability, target, 49])
    else
      _message_stack_push(MSG_Fail)
    end
  end
  #===
  #>s_haze
  # Buée noire
  #===
  def s_haze(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    if skill.id == 499 # Bain de Smog
      hp = _damage_calculation(launcher, target, skill).to_i
      return false if __s_hp_down_check(hp, target)
    end
    _message_stack_push([:msg, parse_text_with_pokemon(19, 195, target)])
    _message_stack_push([:stat_reset, target])
  end
  #===
  #>s_nightmare
  # Cauchemard
  #===
  def s_nightmare(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    if(target.asleep?)
      _message_stack_push([:apply_effect, target, :apply_nightmare])
      _message_stack_push([:msg, parse_text_with_pokemon(19, 321, target)])
    else
      _message_stack_push(MSG_Fail)
    end
  end
  #===
  #>s_weather
  # Attaque déclanchant une météo
  #===
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
  #===
  #>s_rototillier
  # Attaque fertilisation
  #===
  def s_rotillier(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    if(target.type_grass?)
      _message_stack_push([:change_atk, target, 1])
      _message_stack_push([:change_ats, target, 1])
    end
  end
  #===
  #>s_focus_energy
  # Puissance
  #===
  def s_focus_energy(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    target = _snatch_check(target, skill)
    _message_stack_push([:msg, parse_text_with_pokemon(19, 616, target)])
    _message_stack_push([:apply_effect, target, :apply_focus_energy])
  end
  #===
  #>s_curse
  # Malédiction / Cognobidon
  #===
  def s_curse(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    if(skill.id == 187)
      target = _snatch_check(target, skill)
      _message_stack_push([:hp_down, launcher, launcher.max_hp / 2])
      _message_stack_push([:change_atk, target, 6])
      return
    end
    if(launcher.type_ghost?)
      #target = _random_target_selection(launcher, target)
      #return _mp(MSG_Fail) if target == launcher
      _message_stack_push([:hp_down, launcher, launcher.max_hp / 2])
      _message_stack_push([:msg, ::PFM::Text.parse_with_pokemons(19, 1070, launcher, target)])
      _message_stack_push([:apply_effect, target, :apply_curse])
    else
      _message_stack_push([:change_atk, launcher, 1])
      _message_stack_push([:change_dfe, launcher, 1])
      _message_stack_push([:change_spd, launcher, -1])
    end
  end
  #===
  #>s_psych_up
  # Boost
  #===
  def s_psych_up(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    _message_stack_push([:msg,parse_text_with_pokemon(19, 1053, launcher, PKNICK[1] => target.given_name)])
    launcher = _snatch_check(launcher, skill)
    _message_stack_push([:apply_effect, target, :apply_no_stat_change])
    unless(launcher.battle_effect.has_no_stat_change_effect?)
      _message_stack_push([:change_atk, target, target.atk_stage])
      _message_stack_push([:change_ats, target, target.ats_stage])
      _message_stack_push([:change_dfe, target, target.dfe_stage])
      _message_stack_push([:change_dfs, target, target.dfs_stage])
      _message_stack_push([:change_spd, target, target.spd_stage])
      _message_stack_push([:change_eva, target, target.eva_stage])
      _message_stack_push([:change_acc, target, target.acc_stage])
    else
      _message_stack_push(MSG_Fail)
    end
  end
  #===
  #>s_topsy_turvy
  # Renversement
  #===
  def s_topsy_turvy(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    target = _magic_coat(launcher, target, skill)
    _message_stack_push([:msg,parse_text_with_pokemon(19, 1077, target)])
    #unless(launcher.battle_effect.has_no_stat_change_effect?) #>Vérifier si c'est bloqué
      bs = target.battle_stage
      bs.each_index do |i|
        _message_stack_push([:stat_set, target, -bs[i]])
      end
    #else
    #  _message_stack_push(MSG_Fail)
    #end
  end
  #===
  #>s_stat_edit
  # Attaques ayant des implications sur les statistiques
  #===
  AcuperssionStat = [:change_atk, :change_ats, :change_dfe, :change_dfs, :change_eva, :change_acc, :change_spd]
  def s_stat_edit(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    id = skill.id
    if(id == 579) #>Garde florale
      get_battlers.each do |i|
        _message_stack_push([:change_dfe, i, 1]) if i.type_grass?
      end
    elsif(id == 384) #>Permuforce
      _message_stack_push([:msg, parse_text_with_pokemon(19, 676, launcher)])
      atk = launcher.atk_stage
      ats = launcher.ats_stage
      _message_stack_push([:stat_set, launcher, 0, target.atk_stage])
      _message_stack_push([:stat_set, launcher, 3, target.ats_stage])
      _message_stack_push([:stat_set, target, 0, atk])
      _message_stack_push([:stat_set, target, 3, ats])
    elsif(id == 385) #>Permugarde
      _message_stack_push([:msg, parse_text_with_pokemon(19, 679, launcher)])
      dfe = launcher.dfe_stage
      dfs = launcher.dfs_stage
      _message_stack_push([:stat_set, launcher, 1, target.dfe_stage])
      _message_stack_push([:stat_set, launcher, 4, target.dfs_stage])
      _message_stack_push([:stat_set, target, 1, dfe])
      _message_stack_push([:stat_set, target, 4, dfs])
    elsif(id == 367) #Acupression
      _message_stack_push([AcuperssionStat[rand(6)], target, 2])
    elsif(id == 391) #Permucoeur
      _message_stack_push([:msg,parse_text_with_pokemon(19, 673, launcher)])
      bs1 = launcher.battle_stage.clone
      bs2 = target.battle_stage
      bs2.each_index do |i|
        _message_stack_push([:stat_set, launcher, i, bs2[i]])
        _message_stack_push([:stat_set, target, i, bs1[i]])
      end
    elsif(id == 470) #Partage garde
      _message_stack_push([:msg,parse_text_with_pokemon(19, 1105, launcher)])
      dfe = (launcher.dfe_basis + target.dfe_basis) / 2
      _message_stack_push([:set_be_value, launcher, :dfe=, dfe])
      _message_stack_push([:set_be_value, target, :dfe=, dfe])
      dfs = (launcher.dfs_basis + target.dfs_basis) / 2
      _message_stack_push([:set_be_value, launcher, :dfs=, dfs])
      _message_stack_push([:set_be_value, target, :dfs=, dfs])
    elsif(id == 471) #Partage force
      _message_stack_push([:msg,parse_text_with_pokemon(19, 1102, launcher)])
      atk = (launcher.atk_basis + target.atk_basis) / 2
      _message_stack_push([:set_be_value, launcher, :atk=, atk])
      _message_stack_push([:set_be_value, target, :atk=, atk])
      ats = (launcher.ats_basis + target.ats_basis) / 2
      _message_stack_push([:set_be_value, launcher, :ats=, ats])
      _message_stack_push([:set_be_value, target, :ats=, ats])
    elsif(id == 379) #Astuce force
      _message_stack_push([:set_be_value, launcher, :atk=, launcher.dfe_basis])
      _message_stack_push([:set_be_value, launcher, :dfe=, launcher.atk_basis])
    end
  end
  #===
  #>s_ability
  # Attaques relative au talent
  #===
  SimpleBeam = [122, 90, 175, 99] #>Multi-Type, Absentéisme, Déclic Tactique
  Entrainment = [122, 90, 175, 148, 112, 69, 149, 160]
  SkillSwap = [122, 91] #>Multi-Type, Garde Mystik
  GastroAcid = [122] #>Tous les talents ayant aucun effet en combat pendant les tours. (Début de tour exclu !)
  def s_ability(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    id = skill.id
    target = _magic_coat(launcher, target, skill)
    if(id == 493) #Rayon simple
      unless(SimpleBeam.include?(target.ability))
        _mp([:msg, parse_text_with_pokemon(19,405, target, ABILITY[1] => ::GameData::Abilities.name(99))])
        _mp([:set_ability, target, 99]) #>Simple
      else
        _mp(MSG_Fail)
      end
    elsif(id == 494) #Ten-danse
      unless(Entrainment.include?(target.ability) and launcher.ability != target.ability)
        _mp([:msg, parse_text_with_pokemon(19,405, target, ABILITY[1] => launcher.ability_name)])
        _mp([:set_ability, target, launcher.ability])
      else
        _mp(MSG_Fail)
      end
    elsif(id == 285) #Echange
      unless(SkillSwap.include?(target.ability) and launcher.ability != target.ability)
        _mp([:msg, parse_text_with_pokemon(19,508, launcher)])
        ability = launcher.ability
        _mp([:set_ability, launcher, target.ability])
        _mp([:set_ability, target, ability])
      else
        _mp(MSG_Fail)
      end
    elsif(id == 380) #Suc Digestif
      unless(GastroAcid.include?(target.ability) or target.battle_effect.has_no_ability_effect?)
        _mp([:msg, parse_text_with_pokemon(19,565, target)])
        _mp([:apply_effect, target, :apply_no_ability])
      else
        _mp(MSG_Fail)
      end
    end
  end
  #===
  #>s_reflect
  # Protection et Mur Lumière
  #===
  def s_reflect(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    return if launcher != target #>Pour appliquer à tout l'équipe et gérer saisie
    nb_turn = _has_item(launcher, 269) ? 8 : 5 #> Lumargile
    target = _snatch_check(launcher, skill) #>Actuellement je ne vérifie que le lanceur car je ne sais pas comment ça agit en 2v2 quand c'est pas le lanceur sous saisie :<
    if(skill.id == 113) #>Mur Lumière
      sym = target.position < 0 ? :enn_light_screen : :act_light_screen
      unless(@_State[sym] > 0)
        _mp([:msg, parse_text(18, target.position < 0 ? 135 : 134)])
        _mp([:set_state, sym, nb_turn])
      else
        _mp(MSG_Fail)
      end
    else #>Protection
      sym = target.position < 0 ? :enn_reflect : :act_reflect
      unless(@_State[sym] > 0)
        _mp([:msg, parse_text(18, target.position < 0 ? 131 : 130)])
        _mp([:set_state, sym, nb_turn])
      else
        _mp(MSG_Fail)
      end
    end
  end
  #===
  #>s_safe_guard
  # Rune Protect
  #===
  def s_safe_guard(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    target = _snatch_check(target, skill)
    _mp([:apply_affect, target, :apply_safe_guard])
  end
  #===
  #>s_magic_coat
  # Reflet Magik
  #===
  def s_magic_coat(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    _mp([:msg, parse_text_with_pokemon(19, 761, launcher)])
    _mp([:apply_effect, launcher, :apply_magic_coat])
  end
  #===
  #>s_brick_break
  # Casse-Brique
  #===
  def s_brick_break(launcher, target, skill, msg_push = true)
    skill.type2 = 0 if target.type_spectre?
    result = s_basic(launcher, target, skill)
    skill.type2 = nil
    return false unless result
    sym = target.position < 0 ? :enn_light_screen : :act_light_screen
    if(@_State[sym] > 0)
      _mp([:msg, parse_text(18, target.position < 0 ? 137 : 136)])
      _mp([:set_state, sym, 0])
    end
    sym = target.position < 0 ? :enn_reflect : :act_reflect
    if(@_State[sym] > 0)
      _mp([:msg, parse_text(18, target.position < 0 ? 133 : 132)])
      _mp([:set_state, sym, 0])
    end
  end
  #===
  #>s_tailwind
  # Vent arrière
  #===
  def s_tailwind(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    return if launcher != target #>Pour appliquer à tout l'équipe et gérer saisie
    target = _snatch_check(launcher, skill) #>Actuellement je ne vérifie que le lanceur car je ne sais pas comment ça agit en 2v2 quand c'est pas le lanceur sous saisie :<
    _mp([:msg, parse_text(18, target.position < 0 ? 147 : 146)])
    _mp([:set_state, target.position < 0 ? :enn_tailwind : :act_tailwind, 4])
  end
  #===
  #>s_lucky_chant
  # Air Veinard
  #===
  def s_lucky_chant(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    return if launcher != target #>Pour appliquer à tout l'équipe et gérer saisie
    target = _snatch_check(launcher, skill) #>Actuellement je ne vérifie que le lanceur car je ne sais pas comment ça agit en 2v2 quand c'est pas le lanceur sous saisie :<
    _mp([:msg, parse_text(18, target.position < 0 ? 151 : 150)])
    _mp([:set_state, target.position < 0 ? :enn_lucky_chant : :act_lucky_chant, 5])
  end
  #===
  #>s_heal_block
  # Anti-Soin
  #===
  def s_heal_block(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    target = _magic_coat(launcher, target, skill)
    _mp([:apply_effect, target, :apply_heal_block])
  end
  #===
  #>s_magnet_rise
  # Vol Magnetique
  #===
  def s_magnet_rise(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    target = _snatch_check(target, skill)
    _mp([:msg, parse_text_with_pokemon(19, 658, target)])
    _mp([:apply_effect, target, :apply_magnet_rise])
  end
  #===
  #>s_protect
  # Abri and co
  #===
  def s_protect(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    #>Tatamigaeshi
    if(skill.id == 561 and launcher.battle_effect.nb_of_turn_here > 1)
      _mp(MSG_Fail) if target == launcher
      return false
    end
    #>Procédure générale
    target = _snatch_check(target, skill)
    protect_acc = target.battle_effect.get_protect_accuracy
    if(_rand_check(protect_acc,1000))
      _mp([:apply_effect, target, (skill.id == 203 ? :apply_endure : :apply_protect)]) #>Ténacité
    else
      _mp([:msg_fail, target == launcher ? nil : target]) #>Indiquer sur qui ça fail (Tatamigaeshi)
    end
  end
  #===
  #>s_thing_sport
  # Lance-Boue / Tourniquet
  #===
  def s_thing_sport(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    return false if launcher != target
    #>Tourniquet
    if(skill.id == 346)
      _mp([:msg, parse_text(18,118)])
      _mp([:set_state, :water_sport, 5])
    else
      _mp([:msg, parse_text(18,120)])
      _mp([:set_state, :mud_sport, 5])
    end
  end
  #===
  #>s_foresight
  # Flair / Clairevoyance
  #===
  def s_foresight(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    target = _magic_coat(launcher, target, skill)
    _mp([:stat_set, target, 5, 0]) #>Reset de l'esquive
    _mp([:apply_effect, target, :apply_foresight])
  end
  #===
  #>s_u_turn
  # Demi-Tour / Change Eclair / Relais
  #===
  def s_u_turn(launcher, target, skill, msg_push = true)
    return unless skill.id == 226 || s_basic(launcher, target, skill)
    unless(launcher.position < 0 && !$game_temp.trainer_battle)
      _mp([:switch_pokemon, launcher, nil])
    end
  end
  #===
  #>s_parting_shot
  # Dernier Mot
  #===
  def s_parting_shot(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    unless(launcher.position >= 0 && !_can_switch(launcher))
      _message_stack_push([:change_atk, target, -1])
      _message_stack_push([:change_ats, target, -1])
      _mp([:msg, parse_text_with_pokemon(19, 770, launcher, PKNICK[0] => launcher.given_name, TRNAME[1] => $trainer.name)])
      _mp([:switch_pokemon, launcher, nil])
    else
      _mp(MSG_Fail)
    end
  end
  #===
  #>s_dragon_tail
  # Projection / Draco-Queue
  #===
  def s_dragon_tail(launcher, target, skill, msg_push = true)
    return unless s_basic(launcher, target, skill)
    unless(launcher.position >= 0 and !$game_temp.trainer_battle)
      party = (target.position < 0 ? $scene.enemy_party : $pokemon_party)
      if party.pokemon_alive > $game_temp.vs_type
        party = (target.position < 0 ? @_Enemies : @_Actors)
        n_party = Array.new
        $game_temp.vs_type.upto(party.size-1) do |i|
          n_party<<party[i] if party[i].hp > 0
        end
        if(Abilities.has_ability_usable(target, 84)) #>Ventouse
          _mp([:msg, parse_text_with_pokemon(19,454,target)])
        elsif(false) #>Racines
          _mp([:msg, parse_text_with_pokemon(19,742,target)])
        else
          _mp([:switch_pokemon, target, n_party[rand(n_party.size)]]) if n_party.size > 0 #>Redondance
        end
        return
      end
    end
  end
  #===
  #>s_sketch
  # Gribouille
  #===
  def s_sketch(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    ls = target.last_skill
    #>Babil / Lutte, Moiteur + Explosion/Destruction
    if(ls <= 0 or ls == skill.id or ls == 448 or ls == 165 or (!Abilities.has_ability_usable(target, 28) and (ls == 153 or ls == 120)))
      _mp(MSG_Fail)
    else
      _mp([:msg, parse_text_with_pokemon(19, 691, launcher, MOVE[1] => ::GameData::Skill[ls].name)])
      _mp([:sketch, launcher, skill, ls])
    end
  end
  #===
  #>s_disable
  # Entrave
  #===
  def s_disable(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    target = _magic_coat(launcher, target, skill)
    ls = target.last_skill
    if(ls > 0 and !target.battle_effect.has_disable_effect?)
      _mp([:msg, parse_text_with_pokemon(19, 592, launcher, MOVE[1] => ::GameData::Skill[ls].name)])
      _mp([:apply_effect, target, :apply_disable, ls])
    else
      _mp(MSG_Fail)
    end
  end
  #===
  #>s_mimic
  # Copie
  #===
  def s_mimic(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    ls = target.last_skill
    if(ls > 0 and ls != 165 and ls != skill.id)
      _mp([:msg, parse_text_with_pokemon(19, 688, launcher, MOVE[1] => ::GameData::Skill[ls].name)])
      _mp([:mimic, launcher, target, skill, ls])
    else
      _mp(MSG_Fail)
    end
  end
  #===
  #>s_encore
  # Encore
  #===
  def s_encore(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    target = _magic_coat(launcher, target, skill)
    ls = target.last_skill
    if(ls > 0 and ls != skill.id and ls != 165)
      _mp([:msg, parse_text_with_pokemon(19, 559, target, MOVE[1] => ::GameData::Skill[ls].name)])
      _mp([:apply_effect, target, :apply_encore, target.find_skill(ls)])
    else
      _mp(MSG_Fail)
    end
  end
  #===
  #>s_spite
  # Dépit
  #===
  def s_spite(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    target = _magic_coat(launcher, target, skill)
    ls = target.last_skill
    skill = target.find_skill(ls)
    pp = skill ? (skill.pp < 4 ? skill.pp : 4) : 0
    if(ls > 0 and ls != 165 and pp > 0)
      _mp([:msg, parse_text_with_pokemon(19, 641, target, MOVE[1] => ::GameData::Skill[ls].name, "[VAR NUM1(0002)]" => pp.to_s)])
      _mp([:pp_down, target, skill, pp])
    else
      _mp(MSG_Fail)
    end
  end
  #===
  #>s_cantflee
  # Verrou Enchanté / Barrage / Regard Noir / Toile / Myria-Vagues
  #===
  def s_cantflee(launcher, target, skill, msg_push = true)
    if(skill.id != 615) #> Myria-Vagues
      return false unless __s_beg_step(launcher, target, skill, msg_push)
    else
      return false unless s_basic(launcher, target, skill)
    end
    target = _magic_coat(launcher, target, skill)
    return _mp(MSG_Fail) if target.type_ghost? #> Peut pas être bloqué
    if(skill.id == 587) #>Verrou Enchanté
      #>Message ?

      _mp([:apply_effect,target, :apply_cant_flee, launcher])
      _mp([:apply_effect,launcher, :apply_cant_flee, launcher]) if msg_push
    else
      _mp([:msg, parse_text_with_pokemon(19, 875, target)])
      _mp([:apply_effect,target, :apply_cant_flee, launcher])
    end
  end
  #===
  #>s_teleport
  # Téléport
  #===
  def s_teleport(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    if($game_temp.trainer_battle || $game_switches[Yuki::Sw::BT_NoEscape])
      _mp(MSG_Fail)
    else
      _mp([:msg, parse_text_with_pokemon(19, 767, launcher)])
      _mp([:roar, launcher])
    end
  end
  #===
  #>s_trick
  # Tourmagik / Passe-Passe
  #===
  def s_trick(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    li = launcher.battle_item
    ti = target.battle_item
    #>Les mega Gemme devront spéficier un utilisateur !
    if(ti > 0 and li > 0)
      data = ::GameData::Item[ti].misc_data
      #> Glue / Multi-type
      if(data and data.need_user_id != target.id and !Abilities.has_abilities(target, 45, 122))
        data = ::GameData::Item[li].misc_data
        if(data and data.need_user_id != launcher.id)
          _mp([:msg, parse_text_with_pokemon(19, 682, launcher)])
          _mp([:set_item, target, li])
          _mp([:set_item, launcher, ti])
          return true
        end
      end
    end
    _mp(MSG_Fail)
  end
  #===
  #>s_bestow
  # Passe-Cadeau
  #===
  def s_bestow(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    li = launcher.battle_item
    ti = target.battle_item
    # If the target already holds an item or is under substitute
    if ti > 0 || li == 0 || target.battle_effect.has_substitute_effect?
      _mp(MSG_Fail)
    else
      # TODO : Cristal Z - Mega Gemme - Orbes et ROM de Silvallier impossible à donner
      _mp([:msg, parse_text_with_pokemon(19, 1117, launcher, PKNICK[0] => target.given_name, ITEM2[2] => ::GameData::Item[li].name, PKNICK[1] => launcher.given_name)])
      _mp([:set_item, target, li])
      _mp([:set_item, launcher, -1])
    end
  end
  #===
  #>s_embargo
  # Embargo
  #===
  def s_embargo(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    target = _magic_coat(launcher, target, skill)
    _mp([:msg, parse_text_with_pokemon(19, 727, target)])
    _mp([:apply_effect, target, :apply_embargo])
  end
  #===
  #>s_thief
  # Larcin / Larcin
  #===
  def s_thief(launcher, target, skill, msg_push = true)
    return false unless s_basic(launcher, target, skill)
    ti = target.battle_item
    #>Les mega Gemme devront spéficier un utilisateur !
    if(ti > 0 and ($game_temp.trainer_battle or launcher.position > 0))
      data = ::GameData::Item[ti].misc_data
      #> Glue / Multi-type
      if(data and data.need_user_id != target.id and !Abilities.has_abilities(target, 45, 122))
        _mp([:msg, ::PFM::Text.parse_with_pokemons(19, 1063, launcher, target, ITEM2[2] => target.item_name)])
        _mp([:set_item, target, -1])
        if(launcher.battle_item <= 0)
          _mp([:set_item, launcher, ti, launcher.item_holding == 0])
        end
      else
        _mp([:msg, parse_text_with_pokemon(19, 493, target)])
      end
    end
  end
  #===
  #>s_knock_off
  # Sabotage
  #===
  def s_knock_off(launcher, target, skill, msg_push = true)
    return false unless s_basic(launcher, target, skill)
    ti = target.battle_item
    #>Les mega Gemme devront spéficier un utilisateur !
    if(ti > 0)
      data = ::GameData::Item[ti].misc_data
      #> Glue / Multi-Type
      if(data and data.need_user_id != target.id and !Abilities.has_abilities(target, 45, 122))
        _mp([:msg, ::PFM::Text.parse_with_pokemons(19, 1056, launcher, target, ITEM2[2] => target.item_name)])
        _mp([:send_state, :knock_off, :push, target])
        return
      end
    end
    _mp(MSG_Fail)
  end
  #===
  #>s_recycle
  # Recyclage 
  #Note: J'ai fait récupérer l'objet ancienne porté par la cible de saisie, est-ce que ça risque pas d'être "mauvais" ?
  #===
  def s_recycle(launcher, target, skill, msg_push = true)
    return false unless s_basic(launcher, target, skill)
    ti = target.battle_item
    ie = target.battle_effect.item_held
    if(ti == 0 and ie != 0 and !@_State[:knock_off].include?(target))
      target = _snatch_check(target, skill)
      _mp([:set_item, target, ie])
      _mp([:msg, parse_text_with_pokemon(19, 490, target, ITEM2[1] => ::GameData::Item[ie].name)])
    else
      _mp(MSG_Fail)
    end
  end
  #===
  #>s_pluck
  # Picore / Piqûre
  #===
  def s_pluck(launcher, target, skill, msg_push = true)
    return false unless s_basic(launcher, target, skill)
    ti = target.battle_item
    if(ti > 0)
      data = ::GameData::Item[ti].misc_data
      if(data and data.berry)
        _mp([:msg, parse_text_with_pokemon(19, 776, launcher, ITEM2[1] => ::GameData::Item[ti].name)])
        _mp([:berry_pluck, launcher, target])
        _mp([:berry_cure, launcher, ::GameData::Item[ti].name])
      end
    end
  end
  #===
  #>s_autotomize
  # Allègement
  #===
  def s_autotomize(launcher, target, skill, msg_push = true)
    return false unless s_stat(launcher, target, skill)
    target = _snatch_check(target, skill)
    _mp([:apply_effect, target, :apply_autotomize])
  end
  #===
  #>s_trick_room
  # Distorsion
  #===
  def s_trick_room(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    return unless msg_push
    sym = :trick_room
    if(@_State[sym] > 0)
      _mp([:msg, parse_text(18, 122)])
      _mp([:set_state, sym, 0])
    else
      _mp([:msg, parse_text_with_pokemon(19, 860, launcher)])
      _mp([:set_state, sym, 5])
    end
  end
  #===
  #>s_wonder_room
  # Zone Magique / Etrange
  #===
  def s_wonder_room(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    return unless msg_push
    if skill.id == 472 # Zone Etrange
      sym = :wonder_room
      add = 0
    else
      sym = :magic_room
      add = 2
    end
    if(@_State[sym] > 0)
      _mp([:msg, parse_text(18, 185 + add)])
      _mp([:set_state, sym, 0])
    else
      _mp([:msg, parse_text(18, 184 + add)])
      _mp([:set_state, sym, 5])
    end
  end
  #===
  #>s_taunt
  # Provoc
  #===
  def s_taunt(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    target = _magic_coat(launcher, target, skill)
    _message_stack_push([:apply_effect, target, :apply_taunt, 2])
    _message_stack_push([:msg, parse_text_with_pokemon(19, 568, target)])
  end
  #===
  #>s_follow_me
  # Par Ici, Poudre Fureur
  #===
  def s_follow_me(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    sym = target.position < 0 ? :enn_follow_me : :act_follow_me
    _message_stack_push([:set_state, sym, launcher])
    _message_stack_push([:msg, parse_text_with_pokemon(19, 670, launcher)])
  end
  #===
  #>s_substitute
  # Clonage
  #===
  def s_substitute(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    hp = launcher.max_hp/4
    if(launcher.battle_effect.has_substitute_effect?)
      _mp([:msg, parse_text_with_pokemon(19, 788, launcher)])
    elsif(launcher.hp > hp)
      _mp([:hp_down, launcher, hp])
      _mp([:msg, parse_text_with_pokemon(19, 785, launcher)])
      target = _snatch_check(target, skill)
      _mp([:apply_effect, launcher, :apply_substitute, hp])
      _mp([:switch_form, launcher])
    else
      _mp([:msg, parse_text(18,129)])
    end
  end
  #===
  #>s_rapid_spin
  # Tour Rapide
  #===
  def s_rapid_spin(launcher, target, skill, msg_push = true)
    return false unless s_basic(launcher, target, skill)
    _mp([:entry_hazards_remove, launcher])
    _mp([:apply_effect, launcher, :apply_leech_seed, false])
    _mp([:apply_effect, launcher, :apply_bind, 0, skill.name, launcher])
    _mp([:apply_effect, launcher, :apply_taunt, 0])
  end
  #===
  #>s_defog
  # Anti-Brume
  #===
  def s_defog(launcher, target, skill, msg_push = true)
    be = target.battle_effect
    _mp([:entry_hazards_remove, target])
    sym = target.position < 0 ? :enn_light_screen : :act_light_screen
    if(@_State[sym] > 0)
      _mp([:msg, parse_text(18, target.position < 0 ? 137 : 136)])
      _mp([:set_state, sym, 0])
    end
    sym = target.position < 0 ? :enn_reflect : :act_reflect
    if(@_State[sym] > 0)
      _mp([:msg, parse_text(18, target.position < 0 ? 133 : 132)])
      _mp([:set_state, sym, 0])
    end
    if(be.has_mist_effect?)
      _mp([:apply_effect, target, :apply_mist, 0])
    end
    if(be.has_safe_guard_effect?)
      _mp([:apply_effect, target, :apply_safe_guard, false])
    end
    if($env.current_weather == 5) #> (Fog)
      _mp([:weather_change, nil]) #> Suppression de la météo
      _msgp(18, 96, nil)
    end
    s_stat(launcher, target, skill)
  end
  #===
  #>s_rage
  # Frénésie
  #===
  def s_rage(launcher, target, skill, msg_push = true)
    return false unless s_basic(launcher, target, skill)
    _mp([:apply_effect, launcher, :apply_rage])
  end
  #===
  #>s_pain_split
  # Balance
  #===
  def s_pain_split(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    total_hp = (launcher.hp + target.hp) / 2
    _mp([:hp_up, launcher, total_hp - launcher.hp]) #>Vérifier les valeurs négatives
    _mp([:hp_up, target, total_hp - target.hp]) #>Vérifier les valeurs négatives
  end
  #===
  #>s_stockpile
  # Stockage
  #===
  def s_stockpile(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    stockpile_counter = launcher.battle_effect.stockpile
    if(stockpile_counter < 3)
      stockpile_counter += 1
      _mp([:msg, parse_text_with_pokemon(19, 721, launcher, "[VAR NUM1(0001)]" => stockpile_counter.to_s)])
      _mp([:apply_effect, launcher, :stockpile=, stockpile_counter])
    else
      _mp(MSG_Fail)
    end
  end
  #===
  #>s_split_up
  # Relâche
  #===
  def s_split_up(launcher, target, skill, msg_push = true)
    stockpile_counter = launcher.battle_effect.stockpile
    if(stockpile_counter > 0)
      skill.power2 = stockpile_counter*100
      s_basic(launcher, target, skill)
      skill.power2 = nil
    else
      _message_stack_push([:use_skill_msg, launcher, target, skill]) if msg_push
      _mp(MSG_Fail)
    end
    _mp([:apply_effect, launcher, :stockpile=, 0])
  end
  #===
  #>s_swallow
  # Avale
  #===
  def s_swallow(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    stockpile_counter = launcher.battle_effect.stockpile
    target = _snatch_check(target, skill)
    if(stockpile_counter > 0 and target.hp != target.max_hp)
      hp = (launcher.max_hp * 2**(stockpile_counter - 3)).to_i
      _mp([:hp_up, target, hp])
    else
      _mp(MSG_Fail)
    end
    _mp([:apply_effect, launcher, :stockpile=, 0])
  end
  #===
  #>s_charge
  # Chargeur
  #===
  def s_charge(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    __s_stat_us_step(launcher, launcher, skill, nil, 100)
    _mp([:apply_effect, launcher, :apply_charge])
  end
  #===
  #>s_transform
  # Morphing
  #===
  def s_transform(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    _mp([:morph, launcher, target])
    _mp([:switch_form, launcher])
    _mp([:msg, ::PFM::Text.parse_with_pokemons(19, 644, launcher, target)])
  end
  #===
  #>s_conversion
  # Conversion
  #===
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
  #===
  #>s_conversion2
  # Conversion 2
  #===
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
    #===
  #>s_reflect_type
  # Copie Type
  #===
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
  #===
  #>s_mind_reader
  # Lire-Esprit
  #===
  def s_mind_reader(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    _mp([:apply_effect, launcher, :apply_mind_reader, target])
    _mp([:msg, ::PFM::Text.parse_with_pokemons(19, 651, launcher, target)])
  end
  #===
  # s_defog
  # Anti-Brume
  #===
  def s_defog(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    # Retrait des Entry Hazards
    _State_remove(:enn_spikes, 157)
    _State_remove(:act_spikes, 156)
    _State_remove(:enn_toxic_spikes, 161)
    _State_remove(:act_toxic_spikes, 160)
    _State_remove(:enn_stealth_rock, 165)
    _State_remove(:act_stealth_rock, 164)
    _State_remove(:enn_sticky_web, 217)
    _State_remove(:act_sticky_web, 216)
    # Retrait des screens
    _is_enemy = target.position < 0
    symbol = _is_enemy ? :enn_light_screen : :act_light_screen
    _State_remove(symbol, _is_enemy ? 137 : 136) # Mur Lumière
    symbol = _is_enemy ? :enn_reflect : :act_reflect
    _State_remove(symbol, _is_enemy ? 133 : 132) # Protection
    symbol = _is_enemy ? :enn_safe_guard : :act_safe_guard
    _State_remove(symbol, _is_enemy ? 141 : 140) # Rune Protect
    symbol = _is_enemy ? :enn_mist : :act_mist
    _State_remove(symbol, _is_enemy ? 145 : 144) # Brume
  end
  #===
  #>s_telekinesis
  # Lévikinésie
  #===
  def s_telekinesis(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    if @_State[:gravity] > 0 or target.battle_effect.has_ingrain_effect? or _has_item(target, 278) # Gravité, Racines, Balle Fer 
      _mp([:msg_fail])
    else
      _mp([:apply_effect, target, :apply_telekinesis])
      _mp([:msg, parse_text_with_pokemon(19, 1146, target)])
    end
  end
  #===
  #>s_flame_burst
  # Rebondifeu
  #===
  def s_flame_burst(launcher, target, skill, msg_push = true)
    return false unless s_basic(launcher, target, skill)
    # If the target has the Flash Fire (Torche) ability, no side effect
    unless(Abilities.has_abilities(target, 18))
      # launcher's adjacents allies take damages
      get_ally(launcher).each { |i| _mp([:hp_down, i, i.max_hp/16]) }
    end
  end
  #==
  #>s_origin_pulse
  #--
  #E : <BE_Modell>
  #--
  # Deals damage to all adjacent opponents. It's power is boosted by 50% when used by a Pokémon with the ability Mega Launcher
  #--
  def s_origin_pulse(launcher, target, skill, msg_push = true)
    
    #If the user has mega launcher ability
    if launcher.ability_db_symbol == :mega_launcher
      skill.power2 = skill.power * 1.5
    end
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end
  
  #==
  #>s_shore_up
  #--
  #E : <BE_Modell>
  #--
  # User regains up to half of it's max HP, or 2/3 of max HP if in a sandstorm.
  #--
  def s_shore_up(launcher, target, skill, msg_push=true)
    #Message that says Pokemon used move
    if launcher.hp != launcher.max_hp
      return false unless __s_beg_step(launcher, target, skill, msg_push)
      #If sandstorm heal 2/3 max HP
      if $env.sandstorm?
        hp = (launcher.max_hp * 2/3)
      else
      #If no sandstorm heal 1/2 max HP
        hp = (launcher.max_hp * 1/2)
      end
      #Message that says Pokemon gained HP
      _message_stack_push([:hp_up, launcher, hp])
      return true
    else
      #Gives fail message
      _message_stack_push([:use_skill_msg, launcher, target, skill]) if msg_push
      _message_stack_push(MSG_Fail)
      return false
    end
  end
  
  #==
  #>s_first_impression
  #--
  #E : <BE_Modell>
  #--
  # The move has priority of +2, first impression fails if used after first turn.
  #--
  def s_first_impression(launcher, target, skill, msg_push=true)
    #Message that says Pokemon used move
    if(launcher.battle_effect.nb_of_turn_here == 1)
      s_basic(launcher, target, skill)
      return true
    else
      #Gives fail message
      _message_stack_push([:use_skill_msg, launcher, target, skill]) if msg_push
      _message_stack_push(MSG_Fail)
      return false
    end
  end
  
  #==
  #>s_spirit_shackle
  #--
  #E : <BE_Modell>
  #--
  # This move inflicts damage and prevents foes from fleeing or switching out UNLESS they have wimp out, emergency exit or holding a
  # red card, shed shell, or eject button
  #==
  def s_spirit_shackle(launcher, target, skill, msg_push=true)
    #If it does damage
    if s_basic(launcher, target, skill)
      #If they have these moves or abilities it won't trap
      unless target.ability_db_symbol == :wimp_out || target.ability_db_symbol == :emergency_exit || target.item_db_symbol == :red_card ||
             target.item_db_symbol == :shed_shell || target.item_db_symbol == :eject_button
        #Trap if they don't have moves and abilities above
        _mp([:apply_effect,target, :apply_cant_flee, launcher])
      end
    end
  end
  
  #==
  #>s_sparkling_aria
  #--
  #E : <BE_Modell>
  #--
  # This move inflicts damage to everyone around you (this includes allies) and cures burn if hit. If Pokémon hit has soundproof, dry skin,
  # storm drain, or water absorbed they are not affected (burns do not get cured).
  #==
  def s_sparkling_aria(launcher, target, skill, msg_push=true)
    #If it does damage
    if s_basic(launcher, target, skill)
      #If the target is burned
      if target.status == 3
        #Set status to 0 (none)
        #target.status = 0
        #Give the cure message
        _mp([:status_cure, target])
      end
    end
  end
  
  #==
  #>s_strength_sap
  #--
  #E : <BE_Modell>
  #==
  def s_strength_sap(launcher, target, skill, msg_push = true)
	return false unless __s_beg_step(launcher, target, skill, msg_push)
	
	#Checks if target's current attack is greater than it's max attack / 4 (Basically, if it's -6 attack the move fails)
	if target.atk >= (target.atk_basis / 4 + 1)
		#Sets hp gained to target's attack
		hp = (target.atk).to_i
		
		#If you have big root increase hp gained by 30%
		hp = hp*130/100 if(_has_item(launcher, 296))
		
		#If the target has liquid ooze
		if target.ability == 36
		  _message_stack_push([:hp_down, launcher, hp])
		  _message_stack_push([:msg, parse_text_with_pokemon(19, 457, launcher)])
		#Else if heal block is active
		elsif(!launcher.battle_effect.has_heal_block_effect?)
		  #Checks the clone (I have no idea what that means. It's used in abosrb, though.)
		  _message_stack_push([:hp_up, launcher, hp])
		  _message_stack_push([:msg, parse_text_with_pokemon(19, 905, target)])
		else
		  _mp([:msg, parse_text_with_pokemon(19,890, launcher)])
		end
		__s_stat_us_step(launcher, target, skill, nil, 100)
		#Lowers the target's attack by 1
		_message_stack_push([:change_atk, target, -1])
		return true
	#If the target's current attack is less than it's attack is -6 give fail message
	else
		#Gives fail message
		_message_stack_push(MSG_Fail)
        return false
	end	
  end

  #==
  #>s_toxic_thread
  #--
  #E : <Be_Modell>
  #--
  # Lowers the target's speed stat by one and poisons the target. If the target can't be poisoned (steel type, poison type, or 
  # has a status condition already) it will still lower the speed and vice-versa. If speed can't be lowered because of clear body 
  # or speed is already -6 it can still poison.
  #==
  def s_toxic_thread(launcher, target, skill, msg_push=true)
    #Checks if target's speed is already -6 or has a status already
    if target.spd >= (target.spd_basis / 4 + 1)
      __s_stat_us_step(launcher, target, skill, nil, 100)
      #Lowers the target's speed by 1
      _message_stack_push([:change_spd, target, -6])
    end
    #Checks if target has no status and doesn't have clear body
    if target.status == 0
      #Applies toxic status
      target.status = 8
    end
    #If target speed is -6 and has a status move fails
    if target.spd <= (target.spd_basis / 4 + 1) && target.status != 0
      #Gives fail message
      _message_stack_push(MSG_Fail)
      return false
    end
  end
end
