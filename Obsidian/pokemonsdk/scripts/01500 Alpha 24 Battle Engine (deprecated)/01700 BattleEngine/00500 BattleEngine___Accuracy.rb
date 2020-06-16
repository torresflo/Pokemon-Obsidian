#encoding: utf-8

#noyard
module BattleEngine
  module_function
  #>Tableau des valeurs de précision
  ACC_Table=[0.333, 0.375, 0.428, 0.500, 0.600, 0.750, 1, 1.333, 1.666, 2.000, 2.333, 2.666, 3.000]
  NeverFailMini = [23, 537, 560, 34, 407, 566]
  #===
  #> _attack_hit?
  #  Vérifie si l'attaque a des chances de toucher (Lame Sainte est vérifié avec id == 533
  #  Lilliput est vérifié ici
  #---
  #E : <BE_Model1>
  #S : L'attaque a touché
  #===
  def _attack_hit?(launcher, target, skill)
    move_accuracy = skill.accuracy
    id = skill.id
    be = launcher.battle_effect
    return true if move_accuracy == 0
    return true if be.has_mind_reader_effect? and target == be.get_mind_reader_target
    return true if be.has_lock_on_effect? and be.get_lock_on_target == target
    return true if @_State[:launcher_ability] == 34 or @_State[:target_ability] == 34 #> Annule Garde
    #>Fatal-Foudres et Vent Violents
    if(id == 87 or id == 542)
      move_accuracy /= 2 if($env.sunny?)
      move_accuracy = 100 if($env.rain?)
    elsif(id == 59)
      move_accuracy = 100 if($env.hail?)
    end

    #> Attaques qui ne ratent jamais contre un clone
    return true if target.battle_effect.has_minimize_effect? and NeverFailMini.include?(id)

    #====
    #>Coté attaquant (Acc)
    #===
    #>Stage du lanceur
    l_acc_stage = launcher.acc_stage
    #>Si il fait brûme et que Air-Lock n'est pas actif
    l_acc_stage -= 1 if l_acc_stage > -6 and $env.fog? and !@_State[:air_lock]
    #>Modificateur de précision
    acc_mod = id == 533 ? ACC_Table[6] : ACC_Table[l_acc_stage+6]
    #>Talents
    acc_mod_ability = 1
    ability = @_State[:launcher_ability]
    case ability
    when 5 #> Oeil composé
      acc_mod_ability *= 1.3
    when 74 #> Agitation
      acc_mod_ability *= 0.8 if skill.physical?
    end
    #> Baie Micle
    if(@_State[:launcher_item] == 209)
      acc_mod_ability *= 1.2
      _mp([:berry_use, launcher, true])
    end
    #>Modificateur des objets
    acc_mod_item = _attack_hit_launcher_item?(launcher, target, skill)

    #===
    #>Coté cible (Eva)
    #===
    #>Stage de la cible
    t_acc_stage=target.eva_stage
    #>Vérifier annule garde (launcher) et écrasement pour t_acc_stage
    eva_mod = (id != 498 and id != 533) ? ACC_Table[t_acc_stage+6] : ACC_Table[6]
    #>Talents
    eva_mod_ability = 1
    ability = @_State[:target_ability]
    case ability
    when 13 #> Voile sable
      eva_mod_ability *= 1.2 if $env.sandstorm?
    when 83 #> Rideau neige
      eva_mod_ability *= 1.2 if $env.hail?
    when 8 #> Pieds Confus
      eva_mod_ability *= 1.2 if target.confused?
    end
    #>Modificateur des items
    eva_mod_item = _attack_hit_target_item?(launcher, target, skill)

    #>Modificateur de gravité
    gravity_mod = 1 #>Connait pas encore la formule pour...

    #> Inconscient
    acc_mod = 1 if @_State[:target_ability] == 110
    eva_mod = 1 if @_State[:launcher_ability] == 110

    accuracy = (move_accuracy * acc_mod * acc_mod_ability * acc_mod_item / 
    eva_mod / eva_mod_ability / eva_mod_item * gravity_mod).to_i

    #> Debug
    if !@IA_flag
    cc 0x03
    pc "==== Accuracy Calculation ===="
    pc "L:#{launcher}, T:#{target}, S:#{skill}"
    pc "Move Acc : #{move_accuracy} ___ AccMod : #{acc_mod} ___ EvaMod : #{eva_mod}"
    pc "AccAbilityMod : #{acc_mod_ability} ___ EvaAbilityMod : #{eva_mod_ability}"
    pc "AccItem: #{acc_mod_item} ___ EvaItem : #{eva_mod_item}"
    pc "==== Accuracy End : #{accuracy} ===="
    cc 0x07
    end
    #>L'attaque réussit
    return true if(rand(100) < accuracy)
    if(l_acc_stage >= t_acc_stage)
      _message_stack_push([:launcher_fail_msg, launcher, target])
    else
      _message_stack_push([:target_evasion_msg, launcher, target])
    end
    return false
  end

  #===
  #>_attack_hit_launcher_item?
  #  Calcul du modificateur de précision provoqué par l'item
  #---
  #E : <BE_Model1>
  #S : n : Numeric
  #===
  def _attack_hit_launcher_item?(launcher, target, skill)
    item = GameData::Item[@_State[:launcher_item]]
    return 1 unless item
    imisc = item.misc_data
    return 1 unless imisc
    return 1 if imisc.need_user_id and imisc.need_user_id != launcher.id
    n = 1
    n *= imisc.acc if imisc.acc
    return n
  end

  #===
  #>_attack_hit_target_item?
  #  Calcul du modificateur de précision provoqué par l'item
  #---
  #E : <BE_Model1>
  #S : n : Numeric
  #===
  def _attack_hit_target_item?(launcher, target, skill)
    item = GameData::Item[@_State[:target_item]]
    return 1 unless item
    imisc = item.misc_data
    return 1 unless imisc
    return 1 if imisc.need_user_id and imisc.need_user_id != target.id
    n = 1
    n *= imisc.eva if imisc.eva
    return n
  end
end
