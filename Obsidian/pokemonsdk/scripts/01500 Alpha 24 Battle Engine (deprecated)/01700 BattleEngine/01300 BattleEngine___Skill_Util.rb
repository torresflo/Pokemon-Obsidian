#encoding: utf-8

#noyard
module BattleEngine
  module_function
  #===
  #>_rand_check(rate, dice)
  # Lancement de dés notifiés à l'IA
  #---
  # rate = false => valeur du random utilisée
  #===
  def _rand_check(rate, dice)
    if(@IA_flag)
      _mp([:rand_check, rate, dice])
      if(rate)
        if dice == 0
          return 1
        elsif dice == 1
          return 0
        else
          return dice - 1
        end
      else
        return true
      end
    else
      if(rate)
        return rand(dice) < rate
      else
        return rand(dice)
      end
    end
  end
  #===
  #>_status_chance
  # Chance d'infliger un statut
  #---
  #E : value : Fixnum : chances en %
  #    <BE_Model1>
  #===
  def _status_chance(value, launcher, target, skill)
    #>Roche Royale
    value = value + (100 - value) / 10 if @_State[:launcher_item] == 221
    #>Écran Poudre
    value*=0 if Abilities::enemy_has_ability_usable(launcher, 19)
    #>Sérénité / Aire d'eau
    value*=2 if Abilities::has_ability_usable(launcher, 32) or @_State[launcher.position < 0 ? :enn_rainbow : :act_rainbow] > 0
    #value *= @_State[:status_chance]
    return rand(100)<value unless _IA?
    _message_stack_push([:status_chance, value])
    return true
  end
  #===
  #>_chance
  # Chances d'infliger autre chose que du statut
  #---
  #E : value : Fixnum : chances en %
  #    <BE_Model1>
  #===
  def _chance(value, launcher, target, skill)
    #>Écran Poudre
    value*=0 if Abilities::enemy_has_ability_usable(launcher, 19)
    #>Sérénité
    value*=2 if Abilities::has_ability_usable(launcher, 32)
    return (rand(100)<value) unless _IA?
    _message_stack_push([:chance, value])
    return true
  end
  #===
  #>_status_attempt
  #  Tente d'affecter un status à la cible
  #  Ne pas faire les vérifications de type ici ! Les faire dans les méthodes
  #  correspondantes pour afficher les messages.
  #---
  #E : <BE_Model1>
  #S : bool : status affecté ou non
  #===
  def _status_attempt(launcher, target, skill)
    target = _magic_coat(launcher, target, skill)
    if(target.battle_effect.has_safe_guard_effect?) #>Rune Protect
      _mp([:msg, parse_text_with_pokemon(19,842, target)])
      return false
    end
    case skill.status_effect
    when 1 #>Poison
      _message_stack_push([:status_poison, target])
    when 2 #>Paralysie
      _message_stack_push([:status_paralyze, target])
    when 3 #>Brûlure
      _message_stack_push([:status_burn, target])
    when 4 #>Someil
      _message_stack_push([:status_sleep, target])
    when 5 #>Gel
      _message_stack_push([:status_frozen, target])
    when 6 #>Confusion
      _message_stack_push([:status_confuse, target])
    when 7 #>Peur
      _message_stack_push([:effect_afraid, target])
    when 8 #>Toxic
      _message_stack_push([:status_toxic, target])
    else
      return false
    end
    return true
  end
  #===
  #> _stat_change_attempt
  #  Tente le changement de stat d'un Pokémon
  #  /!\ Refaire l'interpreter !!!
  #  /!\ Vérifier les reflets et snatch
  #===
  def _stat_change_attempt(launcher, target, skill)
    did_something = false
    if(target.battle_effect.has_mist_effect? and get_enemies!(launcher).include?(target))
      _message_stack_push([:msg, parse_text_with_pokemon(19, 845, launcher)])
      return false
    end
    bs = skill.battle_stage_mod
    t_up = _snatch_check(target, skill)
    t_down = _magic_coat(launcher, target, skill)
    #>Attaque
    if((v=bs[0]) != 0)
      target = v < 0 ? t_down : t_up
      _message_stack_push([:change_atk, target, bs[0]])
      did_something = true
    end
    #>Defense
    if((v=bs[1]) != 0)
      target = v < 0 ? t_down : t_up
      _message_stack_push([:change_dfe, target, bs[1]])
      did_something = true
    end
    #>Vitesse
    if((v=bs[2]) != 0)
      target = v < 0 ? t_down : t_up
      _message_stack_push([:change_spd, target, bs[2]])
      did_something = true
    end
    #>Attaque spe
    if((v=bs[3]) != 0)
      target = v < 0 ? t_down : t_up
      _message_stack_push([:change_ats, target, bs[3]])
      did_something = true
    end
    #>Defense spe
    if((v=bs[4]) != 0)
      target = v < 0 ? t_down : t_up
      _message_stack_push([:change_dfs, target, bs[4]])
      did_something = true
    end
    #>Esquive
    if((v=bs[5]) != 0)
      target = v < 0 ? t_down : t_up
      _message_stack_push([:change_eva, target, bs[5]])
      did_something = true
    end
    #>Précision
    if((v=bs[6]) != 0)
      target = v < 0 ? t_down : t_up
      _message_stack_push([:change_acc, target, bs[6]])
      did_something = true
    end
    return did_something
  end
  #===
  #>_target_protected
  #  Vérifie si le skill est bloqué par abris ou détection
  #E : <BE_Model1>
  #S : bool : si bloqué
  #===
  def _target_protected(launcher, target, skill)
    if(skill.blocable?)
      if(target.battle_effect.has_protect_effect?)
        _message_stack_push([:msg, parse_text_with_pokemon(19, 523, target)])
        _mp([:change_atk, launcher, -2]) if(target.last_skill == 588 and skill.direct?) #>Si pb changer contact? par direct? (Bouclier Royal)
        _mp([:hp_down, launcher, launcher.max_hp/8]) if(target.last_skill == 596 and skill.direct?) #> Pico-Défense
        return true if(target.last_skill != 501 or skill.priority > 7) #> Prévention (A vérifier :d)
      end
    end
    #>Cible hors de portée / Annule Garde
    if(target.battle_effect.has_out_of_reach_effect? and @_State[:launcher_ability] != 34 and @_State[:target_ability] != 34)
      oor = target.battle_effect.get_out_of_reach
      if(!::GameData::Skill.can_hit_out_of_reach?(oor ,skill.db_symbol))
        _mp(MSG_Fail)
        return true
      end
    end
    return false
  end
  #===
  #>_skill_critical_push
  #  push l'information critical hit si l'attaque est critique
  #===
  def _skill_critical_push
    _message_stack_push([:critical_hit]) if @_State[:last_critical_hit] > 1
  end
  #===
  #>_skill_efficiency_push
  #  push le message d'efficacité de l'attaque
  #===
  def _skill_efficiency_push
    type_mod = @_State[:last_type_modifier]
    if type_mod > 1 #>Très efficace
      _message_stack_push([:efficient_msg])
    elsif type_mod < 1 #>Pas très efficace
      _message_stack_push([:unefficient_msg])
    end
  end
  #===
  #>__s_beg_step
  # Définition de la procédure de début d'une attaque
  #---
  #E : <BE_Model1>
  #S : bool : Si l'attaque peut continuer
  #===
  On_Launcher_Atk = [:user, :all_pokemon, :user_or_adjacent_ally, :all_ally, :none]#[:user, :one_ally, :all_ally, :field, :field_all, :none]
  def __s_beg_step(launcher, target, skill, msg_push = true)
    #>Ajout de machin utilise
    _message_stack_push([:use_skill_msg, launcher, target, skill]) if msg_push

    #>Vérification du cas où on attaquais l'allié mais qu'il est KO (donc on se la prend)
    if(launcher == target and !On_Launcher_Atk.include?(skill.target))
      unless(skill.id == 174 and !launcher.type_ghost?) #> Malédiction
        _mp(MSG_Fail)
        return false
      end
    end

    #>Vérification de la possibilité d'attaque (sonore + Anti Bruit)
    if(skill.sound_attack? and Abilities.has_ability_usable(target, 52))
      return false if skill.id != 215 #>Glas de soin passe au travers
    end

    #>Les attaques sur les alliés ne ratent pas (sauf cas de précision à vérifier)
    unless On_Launcher_Atk.include?(skill.target)
      #>Vérification du blocage (abris)
      return false if _target_protected(launcher, target, skill)
      #>Vérification de la précision
      return false unless _attack_hit?(launcher, target, skill)
    end
    return false if _skill_blocked?(launcher, skill)
    return true
  end
  #===
  #>__s_stat_us_step
  # Définition de la fonction de gestion des stats et statuts basique lors d'une attaque
  #---
  #E : <BE_Model1>
  #    prec1 : nil/Fixnum : chances d'infliger une stat
  #    prec2 : nil/Fixnum : chances d'infliger un statut
  #S : bool : Si ça a fait qqch
  #===
  def __s_stat_us_step(launcher, target, skill, prec1 = nil, prec2 = nil)
    did_something = false
    chance1 = prec1 ? prec1 : skill.effect_chance.to_i
    #>Chance d'affecter des stats
    if(chance1 > 0 and _chance(chance1, launcher, target, skill))
      did_something |= _stat_change_attempt(launcher, target, skill)
      unless prec1 or prec2 #>Si les deux sont à nil alors on inflige le statut en même temps !
        did_something |= _status_attempt(launcher, target, skill)
        return did_something
      end
    end
    chance2 = prec2 ? prec2 : skill.effect_chance.to_i
    #>Chance d'affeter du statut
    if(chance2 > 0 and skill.status_effect != 0 and 
      _status_chance(chance2, launcher, target, skill))
      did_something |= _status_attempt(launcher, target, skill)
    end
    return did_something
  end
  #===
  #>__s_hp_down_check
  # Factorisation de la perte de HP
  #---
  #E : hp : Fixnum
  #    crit : Si on affiche le critique
  #    eff : Si on affiche l'efficacité
  #S : Si la méthode doit s'arrêter
  #===
  def __s_hp_down_check(hp, target, crit = true, eff = true)
    if hp>0
      if(false and Abilities.has_ability_usable(target, 22)) #<<< Qu'est-ce que c'était ._. ?
        hp = target.max_hp / 4 if hp > target.max_hp / 4
        _mp([:ability_display, target])
        _message_stack_push([:hp_up, target, hp])
      else
        _mp([:efficiency_sound, @_State[:last_type_modifier]])
        _message_stack_push([:hp_down, target, hp])
      end
      _skill_critical_push if crit
      _skill_efficiency_push if eff
    elsif(eff and @_State[:last_type_modifier] == 0)
      _message_stack_push([:useless_msg, target])
      return true#>Pour empêcher de mettre l'effet, à vérifier
    end
    return false
  end
  #===
  #>_weight_test
  # Séquence de vérification du poids
  # Note : vérifier Heavy / Light Metal / Allègement quand poids < 100
  #===
  def _weight_test(pokemon, ability, item, poids, other = nil, other_ability = 0, other_item = 0)
#    if(@IA_flag)
#      _message_stack_push([:weight_test, pokemon, poids])
#      return false
#    end
    weight = pokemon.weight
    # Allègement
    if pokemon.battle_effect.has_autotomize_effect?
      weight -= 100
      weight /= -1000.0 if weight <= 0
    end

    if ability == 133 # Heavy Metal
      weight *= 2
    elsif ability == 134 # Light Metal
      weight *= 0.5
    end

    if item == 539 # Pierrallégée
      weight *= 0.5
    end

    if other
      weight2 = other.weight
      # Allègement
      if other.battle_effect.has_autotomize_effect?
        weight2 -= 100
        weight2 /= -1000.0 if weight2 <= 0
      end

      if other_item == 539 # Pierrallégée
        weight2 *= 0.5
      end

      if other_ability == 133 # Heavy Metal
        weight2 *= 2
      elsif other_ability == 134 # Light Metal
        weight2 *= 0.5
      end

      weight = (weight*100)/weight2
    end
    #>Vérifier les altérations !
    ret=0
    poids.each do |i|
      return ret if weight<=i
      ret+=1
    end
    return ret
  end
  #===
  #>_skill_blocked?
  # Indique si l'attaque est bloqué et affiche le message
  #===
  def _skill_blocked?(launcher, skill, msg = true)
    id = skill.id
    be = launcher.battle_effect
    #>Entrave
    if(be.has_disable_effect? and id == be.disable_skill_id)
      _mp([:msg, parse_text_with_pokemon(19, 595, launcher, MOVE[1] => skill.name)]) if msg
      return true
    elsif(skill.status? and be.has_taunt_effect?) #> Provoc
      _mp([:msg, parse_text_with_pokemon(19, 571, launcher, MOVE[1] => skill.name)]) if msg
      return true
    elsif(be.has_torment_effect? and skill.id == launcher.last_skill) #> Tourmente
      _mp([:msg, parse_text_with_pokemon(19, 580, launcher)]) if msg
      return true
    elsif(be.has_imprison_effect? and be.is_skill_imprisonned?(skill)) #> Possessif
      _mp([:msg, parse_text_with_pokemon(19, 589, launcher, MOVE[1] => skill.name)]) if msg
      return true
    elsif (skill.pp <= 0) #> Pas de PP
      _mp([:msg, parse_text_with_pokemon(18, 85, launcher, MOVE[1] => skill.name)]) if msg
      return true
    end
    return false
  end
  #===
  #>_random_target_selection
  # Choix d'une cible au hasard
  #===
  def _random_target_selection(launcher, target)
    enn = get_enemies!(launcher)
    target = enn[rand(enn.size)]
    until target and !target.dead?
      enn.delete(target)
      break if target == launcher
      target = enn.size > 0 ? enn[rand(enn.size)] : launcher
    end
    return target
  end
  #===
  #>_launch_skill
  # Lancer une autre attaque
  #===
  def _launch_skill(launcher, target, skill)
    #>Clonage pour utilisation
    launcher.skills_set[5] = skill.clone
    launcher.skills_set[5].pp += 1
    if @IA_flag
      target = [target] unless target.is_a?(Array)
      use_skill(launcher, target, skill)
    else
      #>Utilisation
      $scene.phase4_attack([0, 5, -target.position-1, launcher])
    end
    #>Restauration de l'état
    launcher.skills_set[5] = nil
    launcher.skills_set.compact!
  end
  #===
  #>_follow_me_check
  # Vérification Par Ici / Poudre Fureur
  #===
  def _follow_me_check(launcher, target, skill)
    if skill.target == :one_ennemy and skill.id != 228 #> Poursuite
      sym = launcher.position >= 0 ? :enn_follow_me : :act_follow_me
      if _target = @_State[sym]
        if _target.last_skill == 476 #> Poudre Fureur
          unless launcher.type_grass? or 
            (!launcher.battle_effect.has_no_ability_effect? and launcher.ability == 141) or
            BattleEngine::has_item(launcher, 650) #> Envellocape / Lunettes Filtre
            return _target
          end
        else
          return _target
        end
      end
    end
    return target
  end
end
