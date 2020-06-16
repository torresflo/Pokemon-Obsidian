#encoding: utf-8

#noyard
module BattleEngine
	module_function
  #===
  #>s_basic
  # Définition d'un skill basique
  #---
  #E : <BE_Model1>
  #===
  def s_basic(launcher, target, skill, msg_push = true)
    did_something = false
    return false unless __s_beg_step(launcher, target, skill, msg_push)

    #>Vérification de l'attaque
    if skill.power > 0
      hp=_damage_calculation(launcher, target, skill).to_i
      return false if __s_hp_down_check(hp, target)
      did_something = true
    end

    did_something |= __s_stat_us_step(launcher, target, skill)

    unless did_something
      _message_stack_push([:msg, parse_text(18, 74)])
      #Prévenir que ça n'a aucun effet
    end
    return did_something
  end
  #===
  #>s_ohko
  # Définition d'un skill qui met KO en un coup
  #---
  #E : <BE_Model1>
  #===
  def s_ohko(launcher, target, skill, msg_push = true)
    #>Ajout de machin utilise
    _message_stack_push([:use_skill_msg, launcher, target, skill])
    #>Sacrifices ?
    if(launcher == target)
      if (target.position < 0 ? $scene.enemy_party : $pokemon_party).pokemon_alive > $game_temp.vs_type
        _mp([:hp_down, target, target.hp])
      else
        _mp(MSG_Fail)
        return false
      end
      return true
    end
    #>Vérification de l'impossibilité d'attaquer (type)
    if(_type_modifier_calculation(target, skill) == 0)
      _message_stack_push([:useless_msg, target])
      return
    end
    #>Vérification de la précision
    unless(launcher.level >= target.level and 
      _rand_check(launcher.level - target.level + 30, 100))
      _message_stack_push([:msg, parse_text(18, 74)])
      return
    end
    return if _target_protected(launcher, target, skill)
    _message_stack_push([:OHKO, target])
  end
  #===
  #>s_stat
  # Définition d'un skill statistique : les statistiques, le statut aura 100%.
  #---
  #E : <BE_Model1>
  #===
  ImmuGrass = [147, 78, 77, 79, 178]
  def s_stat(launcher, target, skill, msg_push = true)
    did_something = false
    return unless __s_beg_step(launcher, target, skill, msg_push)

    #> Immunité aux graines et autres
    unless target.type_grass? and ImmuGrass.include?(skill.id)
      #>Vérification de l'attaque
      if skill.power > 0
        hp=_damage_calculation(launcher, target, skill).to_i
        return if __s_hp_down_check(hp, target)
        did_something = true
      end

      did_something |= __s_stat_us_step(launcher, target, skill, nil, 100)
    end

    unless did_something
      _message_stack_push([:msg, parse_text(18, 70)])
      #Prévenir que ça n'a aucun effet
    end
  end
  #===
  #>s_status
  # Le champ "Chance..." n'est valide que pour le statut, les statistiques auront 100%
  #---
  #E : <BE_Model1>
  #===
  def s_status(launcher, target, skill, msg_push = true)
    did_something = false
    return unless __s_beg_step(launcher, target, skill, msg_push)
    #> Immunité aux graines et autres
    unless target.type_grass? and ImmuGrass.include?(skill.id)
      #>Vérification de l'attaque
      if skill.power > 0
        hp=_damage_calculation(launcher, target, skill).to_i
        return if __s_hp_down_check(hp, target)
        did_something = true
      end

      did_something |= __s_stat_us_step(launcher, target, skill, 100)
    end
    unless did_something
      _message_stack_push([:msg, parse_text(18, 70)])
      #Prévenir que ça n'a aucun effet
    end

  end
  #===
  #>s_self_stat
  # Définition d'un skill statistique sur sois : les statistiques, le statut aura 100%.
  #---
  #E : <BE_Model1>
  #===
  def s_self_stat(launcher, target, skill, msg_push = true)
    did_something = false
    return unless __s_beg_step(launcher, target, skill, msg_push)

    #>Vérification de l'attaque
    if skill.power > 0
      hp=_damage_calculation(launcher, target, skill).to_i
      return if __s_hp_down_check(hp, target)
      did_something = true
    end

    did_something |= __s_stat_us_step(launcher, launcher, skill, nil, 100)

    unless did_something
      _message_stack_push([:msg, parse_text(18, 70)])
      #Prévenir que ça n'a aucun effet
    end
  end
  #===
  #>s_self_statut
  # Le champ "Chance..." n'est valide que pour le statut, les statistiques auront 100%
  #---
  #E : <BE_Model1>
  #===
  def s_self_statut(launcher, target, skill, msg_push = true)
    did_something = false
    return unless __s_beg_step(launcher, target, skill, msg_push)

    #>Vérification de l'attaque
    if skill.power > 0
      hp=_damage_calculation(launcher, target, skill).to_i
      return if __s_hp_down_check(hp, target)
      did_something = true
    end

    did_something |= __s_stat_us_step(launcher, launcher, skill, 100, nil)

    unless did_something
      _message_stack_push([:msg, parse_text(18, 70)])
      #Prévenir que ça n'a aucun effet
    end
  end
  #===
  #>s_multi_hit
  # Définition d'un skill faisant jusqu'à 5 coup
  #---
  #E : <BE_Model1>
  #===
  Multi_Hit_Chances = [2, 2, 2, 3, 3, 5, 4, 3]
  def s_multi_hit(launcher, target, skill, msg_push = true)
    did_something = false
    hit2 = false
    criti = {:ch => false}
    return unless __s_beg_step(launcher, target, skill, msg_push)

    #>Vérification de l'attaque
    if skill.power > 0
      #>Calcul du nombre de coup (Riposte / aléatoire)
      if(false or target.prepared_skill == 68) #>Ajouter patience
        nb_hit = 1
      elsif(skill.symbol == :s_2hits)
        nb_hit = 2
        hit2 = true if skill.id == 24 #>Seulement double pied reporte le critique (à vérifier)
      elsif(skill.id == 167) #>Triple pied qui en fera 3
        nb_hit = 3
      elsif(Abilities::has_ability_usable(launcher, 47)) #> Multi-Coups
        nb_hit = 5
      else
        nb_hit = Multi_Hit_Chances[rand(Multi_Hit_Chances.size)]
      end
      hits = 0
      target_hp = target.hp
      nb_hit.times do
        hp = _damage_calculation(launcher, target, skill, criti).to_i
        if hp > 0
          target_hp -= hp
          #>Vérifier certains paramètres
          _mp([:skill_animation, launcher, target, skill]) if hits > 0
          _message_stack_push([:hp_down, target, hp])
          _skill_critical_push unless criti[:ch]
          #>Forcer le coup critique pour double pied
          ## criti[:ch] = true if hit2 and @_State[:last_critical_hit] > 1 # Cependant pendant la 1G, c'est pas la 1G :v
          did_something = true
          hits += 1
          break if target_hp <= 0 #>Condition d'arrêt
        elsif(@_State[:last_type_modifier] == 0)
          _message_stack_push([:useless_msg, target])
          return #>Pour empêcher de mettre l'effet, à vérifier
        else #>Si le coup a raté on arrête d'en faire
          break
        end
      end
      _message_stack_push([:msg, parse_text(18, 33, {NUMB[1] => hits.to_s})])
      _skill_efficiency_push
    end

    did_something |= __s_stat_us_step(launcher, target, skill)

    unless did_something
      _message_stack_push([:msg, parse_text(18, 74)])
      #Prévenir que ça n'a aucun effet
    end
  end
  #===
  #>s_2hits
  # Définition d'un skill faisant deux coup
  #===
  def s_2hits(launcher, target, skill, msg_push = true)
    s_multi_hit(launcher, target, skill)
  end
  #===
  #>s_2turns
  # Définition d'un skill qui attaque en deux tours (load => hit)
  #---
  #E : <BE_Model1>
  #===
  def s_2turns(launcher, target, skill, msg_push = true)
    #>Si il n'a pas fait le tour d'attente / Herbe Pouvoir
    unless(launcher.battle_effect.has_forced_attack? or (skill.id == 76 and $env.sunny?) or _has_item(launcher, 271))
      _message_stack_push([:change_dfe, launcher, 1]) if skill.id == 130
      oor = GameData::Skill.get_out_of_reach_type(skill.db_symbol)
      _message_stack_push([:apply_out_of_reach, launcher, oor]) if(oor)
      id_txt = GameData::Skill.get_2turns_announce(skill.db_symbol)
      _message_stack_push([:msg, parse_text_with_pokemon(19, id_txt, launcher)]) if id_txt
      _message_stack_push([:force_attack, launcher, target, skill, 2])
      return
    end
    #> Herbe Pouvoir
    if(_has_item(launcher, 271))
      _mp([:set_item, launcher, 0, true])
    end
    #> Lance-Soleil -> Tempête de sable / Tempête de neige / Pluie
    skill.power2 = skill.power / 2 if(skill.id == 76 and ($env.sandstorm? or $env.hail? or $env.rain?))
    _message_stack_push([:apply_out_of_reach, launcher, 0])
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end
  #===
  #>s_reload
  # Définition d'une attaque qui doit se recharger
  #---
  #E : <BE_Model1>
  #===
  def s_reload(launcher, target, skill, msg_push = true)
    if(launcher.battle_effect.must_reload)
      _message_stack_push([:msg, parse_text_with_pokemon(19, 851, launcher)])
    else
      s_basic(launcher, target, skill)
      _message_stack_push([:set_reload_state, launcher])
    end
  end
  #===
  #>s_fixed_damage
  # Définition d'un skill qui inflige une valeur fixe de dégas
  #---
  #E : <BE_Model1>
  #===
  def s_fixed_damage(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)

    @_State[:last_type_modifier] = 1
    #id = 82 => draco-rage
    _message_stack_push([:hp_down, target, skill.id == 82 ? 40 : 20])

    __s_stat_us_step(launcher, target, skill)
  end
  #===
  #>s_struggle
  # Définition de l'attaque lutte
  #===
  def s_struggle(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    skill.type2 = 0
    hp=_damage_calculation(launcher, target, skill).to_i
    skill.type2 = nil
    hp=1 if hp == 0
    _message_stack_push([:hp_down, target, hp])
    _skill_critical_push
    _message_stack_push([:msg, parse_text_with_pokemon(19, 378, launcher)])
    _message_stack_push([:hp_down, launcher, (launcher.max_hp+3)/4])

  end
  #===
  #>s_electro_ball
  # Définition de l'attaque Boule Elek
  #===
  def s_electro_ball(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    rate = 100 * target.spd / launcher.spd
    rate /= 2 if target.paralyzed?
    rate *= 2 if launcher.paralyzed?
    if(rate <= 25)
      skill.power2 = 150
    elsif(rate <= 33)
      skill.power2 = 120
    elsif(rate <= 50)
      skill.power2 = 80
    else
      skill.power2 = 60
    end
    hp=_damage_calculation(launcher, target, skill).to_i
    skill.power2 = nil
    __s_hp_down_check(hp, target)

  end
  #===
  #>s_stomp
  # Définition de l'attaque Ecrasement
  #---
  #E : <BE_Model1>
  #===
  def s_stomp(launcher, target, skill, msg_push = true)
    skill.power2 = skill.power * 2 if target.battle_effect.has_minimize_effect? #>Lilliput
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end
  #===
  #>s_jump_kick
  # Définition de l'attaque Pied Sauté
  #---
  #E : <BE_Model1>
  #===
  def s_jump_kick(launcher, target, skill, msg_push = true)
    if(Abilities.has_ability_usable(launcher, 54)) #>Téméraire
      skill.power2 = skill.power * 120 / 100
    end
    failed = !s_basic(launcher, target, skill)
    skill.power2 = nil
    if(failed)
      _message_stack_push([:msg, parse_text_with_pokemon(19, 908, launcher)])
      _message_stack_push([:hp_down, launcher, launcher.max_hp / 2])
    end
  end
  #===
  #>s_low_kick
  # Définition de l'attaque balayage
  #===
  LK_W = [10, 25, 50, 100, 200]
  LK_POW = [20, 40, 60, 80, 100, 120]
  def s_low_kick(launcher, target, skill, msg_push = true)
    skill.power2 = LK_POW[_weight_test(target, @_State[:target_ability], @_State[:target_item], LK_W)]
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end
  #===
  #>s_heavy_slam
  # Définition de l'attaque Tacle Lourd / Feu
  #===
  HS_W = [20, 25, 33, 50]
  HS_POW = [120, 100, 80, 60, 40]
  def s_heavy_slam(launcher, target, skill, msg_push = true)
    skill.power2 = HS_POW[_weight_test(target, @_State[:target_ability], @_State[:target_item], HS_W, launcher, @_State[:launcher_ability], @_State[:launcher_item])]
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end
  #===
  #>s_counter
  # Définition de l'attaque riposte / voile miroir et fulmifer
  #===
  def s_counter(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    damages = launcher.battle_effect.get_taken_damages_from(target)
    if(damages > 0 && skill.id == 68) #> Dommages et de type physique
      _message_stack_push([:hp_down, target, 2*damages])
    elsif(damages < 0 && skill.id == 243)
      _message_stack_push([:hp_down, target, -2*damages])
    elsif(damages != 0 && skill.id == 368)
      _message_stack_push([:hp_down, target, damages.abs*3/2])
    else
      _message_stack_push(MSG_Fail)
    end
  end
  #===
  #>s_hp_eq_level
  # Définition des attaques frappe atlas et ombre nocturne
  #===
  def s_hp_eq_level(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    type_mod = _type_modifier_calculation(target, skill)
    if(type_mod != 0)
      _message_stack_push([:hp_down, target, launcher.level])
    else
      _message_stack_push(MSG_Fail)
    end
  end
  #===
  #>s_recoil
  # Définition d'une attaque à recul
  #===
  Recoil_3 = [394, 38, 344, 452, 413]
  def s_recoil(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)

    #>Vérification de l'attaque
    if skill.power > 0
      if(Abilities.has_ability_usable(launcher, 54)) #>Téméraire
        skill.power2 = skill.power * 120 / 100
      end
      hp = _damage_calculation(launcher, target, skill).to_i
      hp = target.max_hp if hp > target.max_hp
      skill.power2 = nil
      return false if __s_hp_down_check(hp, target)
      #>Recul
      #>Tête de Roc / Garde Magik
      unless(Abilities.has_abilities(launcher, 38, 17))
        n = Recoil_3.include?(skill.id) ? 3 : 4
        n = 2 if skill.id == 457 || skill.id == 617 #>Fracass'Tête / Lumière du Néant
        _message_stack_push([:hp_down, launcher, hp / n])
        _message_stack_push([:msg, parse_text_with_pokemon(19, 378, launcher)])
      end
      did_something = true
    end

    did_something |= __s_stat_us_step(launcher, target, skill)

    unless did_something
      _message_stack_push(MSG_Fail)
      #Prévenir que ça n'a aucun effet
    end
    return did_something
  end
  #===
  #>s_a_fang
  # Définition des attaques crocs éclaire/givre/feu
  #===
  def s_a_fang(launcher, target, skill, msg_push = true)
    return unless s_basic(launcher, target, skill)
    if _attacking_first?(launcher) and _chance(10, launcher, target, skill)
      _message_stack_push([:effect_afraid, target])
    end
  end
  #===
  #>s_eruption
  # Définition de giclé d'eau et éruption
  #===
  def s_eruption(launcher, target, skill, msg_push = true)
    skill.power2 = 150 * launcher.hp / launcher.max_hp
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end
  #===
  #>s_flail
  # Définition de Fléau
  #===
  Flail_Pow = [20, 40, 80, 100, 150, 200]
  Flail_HP  = [70, 35, 20, 10, 4, 0]
  def s_flail(launcher, target, skill, msg_push = true)
    hp_rate = 100 * launcher.hp / launcher.max_hp
    i = 0
    while Flail_HP[i] > hp_rate
      i += 1
    end
    skill.power2 = Flail_Pow[i].to_i
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end
  #===
  #>s_wring_out
  # Essorage et Presse
  #===
  def s_wring_out(launcher, target, skill, msg_push = true)
    skill.power2 = (skill.id == 462 ? 120 : 110) * target.hp / target.max_hp
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end
  #===
  #>s_return
  # Retour et Frustration
  #===
  def s_return(launcher, target, skill, msg_push = true)
    skill.power2 = (skill.id == 218 ? 255 - launcher.loyalty : launcher.loyalty) * 10 / 25
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end
  #===
  #>s_fling
  # Dégomage
  #===
  def s_fling(launcher, target, skill, msg_push = true)
    if(@_State[:launcher_item] > 0)
      skill.power2 = GameData::Item[@_State[:launcher_item]].fling_power
      if(s_basic(launcher, target, skill))
        case @_State[:launcher_item]
        when 273 #>Orbe Flame
          _message_stack_push([:status_burn, target, true])
        when 272 #>Orbe Toxik
          _message_stack_push([:status_toxic, target, true])
        when 236 #>Balle Lumière
          _message_stack_push([:status_paralyze, target, true])
        when 219 #>Herbe Mental
          #>Message 19, 941
          _message_stack_push([:attract_effect, launcher, target, 0])
          _mp([:set_item, target, 0, true])
        when 214 #>Herbe Blanche
          #>Message 19, 195 (ou 228 ?)
          _message_stack_push([:stat_reset_neg, target])
        when 245 #> Pic venin
          _message_stack_push([:status_poison, target, true])
        when 327, 221 #>Croc rasoir et Roche royale
          _message_stack_push([:effect_afraid, target])
        end
      end
      skill.power2 = nil
    elsif(__s_beg_step(launcher, target, skill, msg_push))
      _message_stack_push(MSG_Fail)
    end
  end
  #===
  #>s_payback
  # Représailles
  #===
  def s_payback(launcher, target, skill, msg_push = true)
   skill.power2 = skill.power * 2 if(launcher.battle_effect.get_taken_damages_from(target) != 0)
   s_basic(launcher, target, skill)
   skill.power2 = nil
  end
  #===
  #>s_assurance
  # Assurance / Vendetta
  #===
  def s_assurance(launcher, target, skill, msg_push = true)
    skill.power2 = skill.power * 2 if(launcher.battle_effect.took_damage)
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end
  #===
  #>s_tri_attack
  # Triplattaque
  #===
  def s_tri_attack(launcher, target, skill, msg_push = true)
    if(s_basic(launcher, target, skill))
      if(_status_chance(20, launcher, target, skill))
        target = _magic_coat(launcher, target, skill)
        v = rand(3)
        case v
        when 0
          _message_stack_push([:status_burn, target])
        when 1
          _message_stack_push([:status_paralyze, target])
        when 2
          _message_stack_push([:status_frozen, target])
        end
      end
    end
  end
  #===
  #>s_super_fang
  # Croc Fatal
  #===
  def s_super_fang(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    _message_stack_push([:hp_down, target, (target.hp+1)/2])
  end
  #===
  #>s_destiny_bond
  # Prélèvem. Destin
  #===
  def s_destiny_bond(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    _message_stack_push([:msg, parse_text_with_pokemon(19, 626, launcher)])
  end
  #===
  #>s_false_swipe
  # Faux-Chage / Retenue
  #===
  def s_false_swipe(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    hp=_damage_calculation(launcher, target, skill).to_i
    if(hp >= target.hp)
      hp = target.hp - 1
    end
    __s_hp_down_check(hp, target)
  end
  #===
  #>s_fell_stinger
  # Dard Mortel
  #===
  def s_fell_stinger(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    hp=_damage_calculation(launcher, target, skill).to_i
    __s_hp_down_check(hp, target)
    if(hp >= target.hp)
      _message_stack_push([:change_atk, launcher, 2])
    end
  end
  #===
  #>s_stored_power
  # Force ajouté
  #===
  def s_stored_power(launcher, target, skill, msg_push = true)
    target = _magic_coat(launcher, target, skill)
    if(skill.id == 386) #>Punition 
      bs = target.battle_stage
      pow = 60
      5.times do |i|
        pow += (20*bs[i]) if bs[i] > 0
      end
      pow = 200 if pow > 200
    else
      bs = launcher.battle_stage
      pow = 20
      bs.each do |i|
        pow += (20*i) if i > 0
      end
    end
    skill.power2 = pow
    s_basic(launcher,target, skill)
    skill.power2 = nil
  end
  #===
  #>s_gyro_ball
  # Gyroball
  #===
  def s_gyro_ball(launcher, target, skill, msg_push = true)
    skill.power2 = 25 * target.spd / launcher.spd
    skill.power2 /= 2 if target.paralyzed?
    skill.power2 *= 2 if launcher.paralyzed?
    skill.power2 = 150 if skill.power2 > 150
    s_basic(launcher,target, skill)
    skill.power2 = nil
  end
  #===
  #>s_acrobatics
  # Acrobatie
  #===
  def s_acrobatics(launcher, target, skill, msg_push = true)
    skill.power2 = 2*skill.power if launcher.battle_item == 0 or !_has_item(launcher, launcher.battle_item)
    s_basic(launcher,target, skill)
    skill.power2 = nil
  end
  #===
  #>s_natural_gift
  # Don Naturel
  #===
  def s_natural_gift(launcher, target, skill, msg_push = true)
    li = launcher.battle_item
    if(li > 0)
      data = ::GameData::Item[li].misc_data
      if(data and data.berry)
        skill.power2 = data.berry[:power]
        skill.type2 = data.berry[:type]
        s_basic(launcher, target, skill)
        _mp([:set_item, launcher, 0, true])
        skill.power2 = nil
        skill.type2 = nil
        return
      end
    end
    if(__s_beg_step(launcher, target, skill, msg_push))
      _mp(MSG_Fail)
    end
  end
  #===
  #>s_hidden_power
  # Puissance Cachée
  #===
  HP_Types = [7, 10, 8, 9, 13, 12, 14, 16, 2, 3, 5, 4, 11, 6, 15, 17]
  def s_hidden_power(launcher, target, skill, msg_push = true)
    type_index = (launcher.iv_hp & 1) | ((launcher.iv_atk & 1) << 1) | 
    ((launcher.iv_dfe & 1) << 2) | ((launcher.iv_spd & 1) << 3) | 
    ((launcher.iv_ats & 1) << 4) | ((launcher.iv_dfs & 1) << 5)
    skill.type2 = HP_Types[type_index * 15 / 63]
    s_basic(launcher, target, skill)
    skill.type2 = nil
  end
  #===
  #>s_magnitude
  # Ampleur
  #===
  R_Magnitude = [5, 15, 35, 65, 85, 95, 100]
  P_Magnitude = [10, 30, 50, 70, 90, 110, 150]
  def s_magnitude(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    if msg_push
      i = skill.power2
      skill.power2 = P_Magnitude[i]
      _mp([:msg, parse_text(18, 108+i)])
      msg_push = false
    end
    
    #>Infliger les dégas
    hp=_damage_calculation(launcher, target, skill).to_i
    __s_hp_down_check(hp, target)
  end
  #===
  #>s_psywave
  # Vague Psy
  #===
  def s_psywave(launcher, target, skill, msg_push = true)
    skill.power2 = launcher.level * (rand(10) + 5) / 10
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end
  #===
  #>s_final_gambit
  # Tout ou Rien
  #===
  def s_final_gambit(launcher, target, skill, msg_push = true)
    return unless __s_beg_step(launcher, target, skill, msg_push)
    __s_hp_down_check(launcher.hp, target)
    _mp([:hp_down, launcher, launcher.hp])
  end
  #===
  #>s_outrage
  # Colère / Danse-Fleur
  #===
  def s_outrage(launcher, target, skill, msg_push = true)
    #> Danse-Fleur : Enemy aléatoire
    if(skill.id == 80)
      target = _random_target_selection(launcher, target)
    end
    result = s_basic(launcher, target, skill)
    counter = launcher.battle_effect.get_forced_attack_counter
    #> Colère inactive
    if(counter == 0)
      return unless result
      _mp([:apply_effect, launcher, :apply_forced_attack, skill.id, rand(2)+2, target]) unless @_State[:ext_info]
      @_State[:ext_info] = true
    elsif(counter == 1 or !result)
      unless @_State[:ext_info]
        _mp([:apply_effect, launcher, :apply_forced_attack, 0, 0, target])
        _mp([:status_confuse, launcher, true, 360])
      end
      @_State[:ext_info] = true
    end
  end
  #===
  #>s_rollout
  # Roulade
  #===
  def s_rollout(launcher, target, skill, msg_push = true)
    be = launcher.battle_effect
    #> Boul'Armure
    if(launcher.last_skill == 111)
      skill.power2 = skill.power * 2
    elsif(be.rollout_power > 0)
      skill.power2 = be.rollout_power
    end
    result = s_basic(launcher, target, skill)
    #> Roulade inactive
    if(be.get_forced_attack_counter == 0)
      if result
        _mp([:apply_effect, launcher, :apply_forced_attack, skill.id, 5, target])
        _mp([:apply_effect, launcher, :rollout_power=, 2 * skill.power])
      else
        _mp([:apply_effect, launcher, :rollout_power=, 0])
      end
    elsif(be.get_forced_attack_counter == 1 or !result)
      _mp([:apply_effect, launcher, :apply_forced_attack, 0, 0, target])
      _mp([:apply_effect, launcher, :rollout_power=, 0])
    else
      _mp([:apply_effect, launcher, :rollout_power=, 2 * skill.power])
    end
    skill.power2 = nil
  end
  #===
  #>s_fury_cutter
  # Taillade
  #===
  def s_fury_cutter(launcher, target, skill, msg_push = true)
    be = launcher.battle_effect
    if(be.fury_cutter_power > 0)
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
  #===
  #>s_bide
  # Patience
  #===
  def s_bide(launcher, target, skill, msg_push = true)
    counter = launcher.battle_effect.get_forced_attack_counter
    
    #> Patience inactive
    if(counter == 0)
      _message_stack_push([:use_skill_msg, launcher, target, skill])
      _mp([:msg, parse_text_with_pokemon(19, 745, launcher)])
      _mp([:apply_effect, launcher, :apply_bide])
      _mp([:apply_effect, launcher, :apply_forced_attack, skill.id, rand(2)+3, target])
    elsif(counter == 1)
      _mp([:apply_effect, launcher, :apply_forced_attack, 0, 0, target])
      _mp([:msg, parse_text_with_pokemon(19, 748, launcher)])
      return false unless __s_beg_step(launcher, target, skill, false)
      hp = launcher.battle_effect.get_bide_power * 2
      if(hp > 0)
        _mp([:hp_down, target, hp])
      else
        _mp(MSG_Fail)
      end
      @_State[:ext_info] = true
    end
  end
  #===
  #> s_brine
  # Saumure
  #===
  def s_brine(launcher, target, skill, msg_push = true)
    return false unless __s_beg_step(launcher, target, skill, msg_push)
    skill.power2 = skill.power * 2 if target.hp <= (target.max_hp / 2)
    s_basic(launcher, target, skill)
    skill.power2 = nil
  end
end
