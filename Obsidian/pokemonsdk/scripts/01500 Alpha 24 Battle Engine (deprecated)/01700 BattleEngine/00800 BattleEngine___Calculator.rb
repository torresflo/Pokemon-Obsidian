#encoding: utf-8

#noyard
module BattleEngine
	module_function
  #===
  #>_damage_calculation
  # Calcul des dégas infligés par l'attaque
  #---
  #E : <BE_Model1>
  #    params : Hash/nil
  #---
  #Ref : http://www.smogon.com/dp/articles/damage_formula#attack
  #===
  def _damage_calculation(launcher, target, skill, params = nil)
    #===
    #>Level
    #---
    # Tout reste en entier et on utilise les parenthèses pour avoir la formule correcte
    #===
    level = ((launcher.level * 2) / 5) + 2
    #>Base power
    base_power = _base_power_calculation(launcher, target, skill)
    #>[Sp] Atk
    sp_atk = _sp_atk_calculation(launcher, target, skill)
    #>[Sp] Def
    sp_def = _sp_def_calculation(launcher, target, skill)
    #>First modifier
    mod1 = _mod1_calculation(launcher, target, skill)
    #>CH (critical hit)
    ch = _critical_calculation(launcher, target, skill, (params && params[:ch]))
    #>Second modifier
    mod2 = _mod2_calculation(launcher, target, skill)
    #>R
    r = 100 - (@IA_flag ? 0 : rand(16)) #0..15
    #> Normalise
    if(Abilities.has_ability_usable(launcher, 93))
      skill = skill.clone
      skill.type2 = 1
    end
    #>STAB
    stab = _stab_calculation(launcher, target, skill)
    type_mod = _type_modifier_calculation(target, skill)
    if(type_mod == 0)
      #>Est au sol
      if skill.type_ground? && _is_grounded(target)
        type_mod = 1
      #>Fair / Clairevoyance
      elsif(target.type_ghost? && target.battle_effect.has_foresight_effect?)
        type_mod = 1
      #> Querelleur
      elsif(target.type_ghost? && @_State[:launcher_ability] == 59)
        type_mod = 1
      elsif(target.battle_effect.has_miracle_eye_effect? && target.type_dark? && skill.type_psy?)
        type_mod = 1
      end
    elsif(skill.type_ground? && !_is_grounded(target))
      type_mod = 0
      if _has_item(target, 541) #> Ballon
        _msgp(19, 408, target)
      elsif @_State[:target_ability] == 48 #> Lévitation
        _mp([:ability_display, target])
      end
    #> Garde Mystik
    elsif(type_mod < 2 && Abilities.has_ability_usable(target, 91))
      type_mod = 0
      _mp([:ability_display, target])
    elsif skill.type_grass? && Abilities.has_ability_usable(target, 156) #> Herbivore
      type_mod = 0
      _mp([:ability_display, target])
      _mp([:change_atk, target, 1])
    end
    @_State[:last_type_modifier] = type_mod
    #>Third modifier
    mod3 = _mod3_calculation(launcher, target, skill, type_mod)
    #>Résultat
    damages = ((((((level * base_power * sp_atk / 50) / sp_def) * mod1) + 2) * ch * mod2 * r / 100) * stab * type_mod * mod3)
    #>Partie debug
    if !@IA_flag
    cc 0x06
    pc "==== Damage calculation ===="
    pc "L:#{launcher}, T:#{target}, S:#{skill}"
    pc "Base Power : #{base_power} ___ Critical Hit : #{ch}"
    pc "SP_ATK : #{sp_atk} ___ SP_DEF #{sp_def}"
    pc "STAB : #{stab} ___ TypeMod : #{type_mod}"
    pc "RandValue : #{r}"
    pc "Mods [#{mod1}, #{mod2}, #{mod3}]"
    pc "Level : #{level}"
    pc "==== Damage END : #{damages} ===="
    cc 0x07
    end
    damages = (base_power > 0 && damages > 0 && damages < 1) ? 1 : damages.to_i
    return damages
  end
  #===
  #>_type_modifier_calculation
  # Calcule le mutilicateur relatif au type
  #E : target : PFM::Pokemon
  #    skill : PFM::Skill
  #===
  def _type_modifier_calculation(target, skill)
    return 2 if skill.id == 573 && target.type_water? # Lyophilisation
    type = skill.type
    type1 = GameData::Type[target.type1].hit_by(type)
    type2 = GameData::Type[target.type2].hit_by(type)
    type3 = GameData::Type[target.type3].hit_by(type)
    return type1 * type2 * type3
  end

  #===
  #>_base_power_calculation
  # Calcule la puissance de base en considérant les modifications
  #---
  #E : <BE_Model1>
  #V : be : Pokemon_Effect  Données des effets appliqué au Pokémon
  #    hh : Numeric : variable du modificateur de coup de main
  #    bp : Numeric : variable du pouvoir de base (avec modifications)
  #    it : Numeric : variable des modifs de l'objet porté
  #    chg : Numeric : variable des modifs de chargeur
  #    ms : Numeric : variable des modifications de Lance Boue
  #    ws : Numeric : variable des modifications de Tourniquet
  #    ua : Numeric : variable des modifications dues au talent du lanceur
  #    fa : Numeric : variable des modifications dues au talent de la cible
  #===
  def _base_power_calculation(launcher, target, skill)
    be = launcher.battle_effect
    bet = target.battle_effect
    #>Variable dédiée à Helping Hand
    hh = be.has_helping_hand_effect? ? 1.5 : 1
    #>Variable dédiée au pouvoir de base de l'attaque
    # /!\ Faire attention à ce que les pouvoirs de base dynamiques soient bien pris en compte !
    bp = skill.power
    #>Variable dédiée à la modification des items
    it = _base_power_item_calculation(launcher, skill)
    #>Modifieur de chargeur
    chg = (be.has_charge_effect? && skill.type_electric?) ? 2 : 1
    #>Modification par lance boue
    ms = (@_State[:mud_sport] > 0 && skill.type_electric?) ? 0.33 : 1
    #>Modification par Tourniquet
    ws = (@_State[:water_sport] > 0 && skill.type_fire?) ? 0.5 : 1 #> Pas réduit de 67% ?
    #>Modification talent lanceur
    ua = _base_power_user_ability_calculation(launcher, target, skill)
    #>Modification talent cible
    fa = _base_power_foe_ability_calculation(launcher, target, skill)
    #>Si la cible est hors de portée les attaques qui touchent mettent aussi x2
    if(target.battle_effect.has_out_of_reach_effect?)
      oor = target.battle_effect.get_out_of_reach
      chg *= 2 if(::GameData::Skill.can_hit_out_of_reach?(oor, skill.db_symbol))
    end
    return (fa * ua * ws * ms * chg * it * bp * hh)
  end
  #===
  #>_base_power_item_calculation
  # Calcule le modificateur de puissance dû aux onbjets
  #---
  #E : launcher : PFM::Pokemon
  #    skill : PFM::Skill
  #V : item : GameData::Item : Objet porté
  #    imisc : GameData::ItemMisc : Data particulier de l'objet porté
  #S : n : Numeric : Multiplicateur
  #===
  def _base_power_item_calculation(launcher, skill)
    item = GameData::Item[@_State[:launcher_item]]
    return 1 unless item
    imisc = item.misc_data
    return 1 unless imisc
    return 1 if imisc.need_user_id && imisc.need_user_id != launcher.id
    n = 1
    n *= 1.1 if imisc.check_atk_class == skill.atk_class
    n *= 1.2 if imisc.powering_skill_type1 == skill.type
    n *= 1.2 if imisc.powering_skill_type2 == skill.type
    return n
  end
  #===
  #>_base_power_user_ability_calculation
  # Calcule le modificateur dû au talent du lanceur
  #---
  #E : <BE_Model1>
  #V : ability : Fixnum  capcité de l'utilisateur
  #S : n : Numeric : Multiplicateur
  #===
  BlastSkills = [352, 399, 396, 406, 618]
  def _base_power_user_ability_calculation(launcher, target, skill)
    ability = @_State[:launcher_ability]
    case ability
    when 15  #> Rivalité
      gender_coef = launcher.gender * target.gender
      if(gender_coef == 2) #> Sexe opposé
        return 0.75
      elsif(gender_coef != 0) #> Aucun des deux n'est assexué (cummulé avec la condition précédente => même sexe)
        return 1.25
      end
    when 54 #> Téméraire
      return 1.2 if skill.recoil? #> Skill ayant du recul
    when 55 #> Poing de fer
      return 1.2 if skill.punching? #> Skill de type coup de poing - La donnée n'est peut être pas renseignée !
    when 1 #> Brasier
      return 1.5 if skill.type_fire? && launcher.hp < (launcher.max_hp / 3)
    when 0 #> Engrais
      return 1.5 if skill.type_grass? && launcher.hp < (launcher.max_hp / 3)
    when 2 #> Torrent
      return 1.5 if skill.type_water? && launcher.hp < (launcher.max_hp / 3)
    when 6 #> Essaim
      return 1.5 if skill.type_insect? && launcher.hp < (launcher.max_hp / 3)
    when 26 #> Technicien
      return 1.5 if skill.base_power <= 60
    when 177 #> Méga Blaster
      return 1.5 if(BlastSkills.include?(skill.id))
    end
    return 1
  end
  #===
  #>_base_power_foe_ability_calculation
  # Calcule le modificateur dû au talent de la cible
  #---
  #E : <BE_Model1>
  #V : ability : Fixnum  capcité de la cible
  #    type : Fixnum : type de l'attaque
  #S : n : Numeric : Multiplicateur
  #===
  def _base_power_foe_ability_calculation(launcher, target, skill)
    ability = @_State[:target_ability]
    case ability
    when 42 #> Isograisse
      return 0.5 if skill.type_ice? || skill.type_fire?
    when 117 #> Ignifugé
      return 0.5 if skill.type_fire?
    when 22 #> Peau sèche
      return 1.25 if skill.type_fire?
    end
    return 1
  end
  #===
  #>_sp_atk_calculation
  # Calcul du multiplieur d'attaque
  #---
  #E : <BE_Model1>
  #===
  def _sp_atk_calculation(launcher, target, skill)
    id = skill.id
    if skill.physical?
      if(id == 251 && !::GameData::Flag_4G) #> Baston
        stat = launcher.base_atk
      elsif(id == 492) #>Tricherie
        stat = target.atk
      else
        #> Lame Sainte / Inconscient
        stat = ((id == 533 || @_State[:target_ability] == 110) ? launcher.atk_basis : launcher.atk)
      end
      #>Protection
      sym = launcher.position < 0 ? :enn_reflect : :act_reflect
      stat /= 2 if @_State[sym] > 0
      #sm = launcher.atk_modifier
      am = _sp_atk_ph_ability_calculation(launcher, target, skill)
      im = _sp_atk_ph_item_calculation(launcher, target, skill)
    else
      #> Lame Sainte / Inconscient
      stat = ((id == 533 || @_State[:target_ability] == 110) ? 
        launcher.ats_basis : 
        launcher.ats)
      #>Mur Lumière
      sym = launcher.position < 0 ? :enn_light_screen : :act_light_screen
      stat /= 2 if @_State[sym] > 0
      #sm = launcher.ats_modifier
      am = _sp_atk_sp_ability_calculation(launcher, target, skill)
      im = _sp_atk_sp_item_calculation(launcher, target, skill)
    end
    return (im * am * stat) #sm * 
  end
  #===
  #>_sp_atk_ph_ability_calculation
  # Calcule le multiplicateur due aux capacités spéciales sur attaque physique
  #---
  #E : <BE_Model1>
  #===
  def _sp_atk_ph_ability_calculation(launcher, target, skill)
    n = 1
    ability = @_State[:launcher_ability]
    case ability
    when 95, 75 #> Force Pure, Coloforce
      n *= 2
    when 112 #> Don floral (2v2 !)
      n *= 1.5 if $env.sunny?
    when 10 #> Cran
      n *= 1.5 if launcher.paralyzed? || launcher.poisoned? || launcher.burn? || launcher.asleep?
    when 74 #> Agitation
      n *= 1.5
    when 120 #> Début calme
      n *= 0.5 if launcher.battle_effect.nb_of_turn_here < 5
    when 158 #> Force Sable
      n *= 1.3 if (skill.type_steel? || skill.type_rock? || skill.type_ground?) && $env.sandstorm?
    end
    #> Flower Gift (Don floral) 2v2 effect
    sun_allies = get_ally(launcher)
    check_flower_gift = false
    sun_allies.each { |i| check_flower_gift = true if Abilities.has_ability_usable(i, 112) }
    n *= 1.5 if $env.sunny? && $game_temp.vs_type != 1 && check_flower_gift
    return n
  end
  #===
  #>_sp_atk_sp_ability_calculation
  # Calcule le multiplicateur due aux capacités spéciales sur attaque spéciale
  #---
  #E : <BE_Model1>
  #===
  def _sp_atk_sp_ability_calculation(launcher, target, skill)
    ability = @_State[:launcher_ability]
    case ability
    when 74 #> Agitation
      return 1.5
    when 76 #> Force soleil
      return 1.5 if $env.sunny?
    when 96, 97 #> Plus, Minus
      other_ability = ability == 96 ? 97 : 96
      get_ally(launcher).each do |pkmn|
        return 1.5 if pkmn.ability == other_ability && !pkmn.battle_effect.has_no_ability_effect?
      end
    when 158 #> Force Sable
      return 1.3 if (skill.type_steel? || skill.type_rock? || skill.type_ground?) && $env.sandstorm?
    end
    return 1
  end
  #===
  #>_sp_atk_ph_item_calculation
  # Calcule le modificateur de stat physique dû aux onbjets
  #---
  #E : <BE_Model1>
  #V : item : GameData::Item : Objet porté
  #    imisc : GameData::ItemMisc : Data particulier de l'objet porté
  #S : n : Numeric : Multiplicateur
  #===
  def _sp_atk_ph_item_calculation(launcher, target, skill)
    item = GameData::Item[@_State[:launcher_item]]
    n = 1
    return n unless item
    n *= 1.5 if item == 220 #> Bandeau Choix
    imisc = item.misc_data
    return n unless imisc
    n *= 2 if imisc.need_ids_ph_2 && imisc.need_ids_ph_2.include?(launcher.id)
    return n
  end
  #===
  #>_sp_atk_ph_item_calculation
  # Calcule le modificateur de stat spéciale dû aux objets
  #---
  #E : <BE_Model1>
  #V : item : GameData::Item : Objet porté
  #    imisc : GameData::ItemMisc : Data particulier de l'objet porté
  #S : n : Numeric : Multiplicateur
  #===
  def _sp_atk_sp_item_calculation(launcher, target, skill)
    item = GameData::Item[@_State[:launcher_item]]
    n = 1
    return n unless item
    n *= 1.5 if item == 297 #> Lunettes Choix 
    imisc = item.misc_data
    return n unless imisc
    n *= 2 if imisc.need_ids_sp_2 && imisc.need_ids_sp_2.include?(launcher.id)
    n *= 1.5 if imisc.need_ids_sp_1_5 && imisc.need_ids_sp_1_5.include?(launcher.id)
    return n
  end
  #===
  #>_sp_def_calculation
  # Calcul du multiplieur de défense
  #---
  #E : <BE_Model1>
  #S : n : Numeric : Multiplicateur
  #>Attrition est géré ici
  #===
  Dfe_instead_of_dfs = [473, 540, 548]
  def _sp_def_calculation(launcher, target, skill)
    id = skill.id
    _state = @_State[:wonder_room] > 0
    dfe = _state ? :dfs : :dfe
    dfe_basis = _state ? :dfs_basis : :dfe_basis
    dfe = dfe_basis if @_State[:launcher_ability] == 110 #> Inconscient
    if skill.physical?
      #> Attrition / Lame Sainte
      stat = (id == 498 || id == 533) ? target.send(dfe_basis) : target.send(dfe)
      #sm = launcher.dfe_modifier
      mod = _sp_def_mod_ph_calculation(launcher, target, skill)
    else
      if Dfe_instead_of_dfs.include?(id) #>Choc Psy / Lame Ointe / Frappe Psy
        stat = target.send(dfe)
      else
        dfs = _state ? :dfe : :dfs
        dfs_basis = _state ? :dfe_basis : :dfs_basis
        dfs = dfs_basis if @_State[:launcher_ability] == 110 #> Inconscient
        #> Attrition / Lame Sainte
        stat = (id == 498 || id == 533) ? target.send(dfs_basis) : target.send(dfs)
      end
      #sm = launcher.dfs_modifier
      mod = _sp_def_mod_sp_calculation(launcher, target, skill)
    end
    #sx = skill.self_destruct? ? 0.5 : 1
    return (mod * stat) #sx * sm * 
  end
  #===
  #>_sp_def_mod_ph_calculation
  # Calcul du mod de def physique
  #---
  #E : <BE_Model1>
  #V : item : GameData::Item : Objet porté
  #    imisc : GameData::ItemMisc : Data particulier de l'objet porté
  #S : n : Numeric : Multiplicateur
  #===
  def _sp_def_mod_ph_calculation(launcher, target, skill)
    n = 1
    #>Partie capacité
    ability = @_State[:target_ability]
    case ability
    #> Écaille Spéciale
    when 103
      n *= 1.5 if target.paralyzed? || target.poisoned? || target.burn? || target.asleep?
    end
    #>Poudre Mental
    n *= 1.5 if @_State[:target_item] == 257 && target.id == 132
    return n
  end
  #===
  #>_sp_def_mod_sp_calculation
  # Calcul du mod de def spéciale
  #---
  #E : <BE_Model1>
  #V : item : GameData::Item : Objet porté
  #    imisc : GameData::ItemMisc : Data particulier de l'objet porté
  #S : n : Numeric : Multiplicateur
  #===
  def _sp_def_mod_sp_calculation(launcher, target, skill)
    n = 1
    #>Partie environnement
    n *= 1.5 if $env.sandstorm? && target.type_rock?
    #>Partie capacité
    ability = @_State[:target_ability]
    case ability
    when 112 #> Don floral (2v2 !)
      n *= 1.5 if $env.sunny?
    end
    #> Flower Gift (Don floral) 2v2 effect
    sun_allies = get_ally(launcher)
    check_flower_gift = false
    sun_allies.each { |i| check_flower_gift = true if Abilities.has_ability_usable(i, 112) }
    n *= 1.5 if $env.sunny? && $game_temp.vs_type != 1 && check_flower_gift
    #>Partie item
    #>Poudre Mental
    n *= 1.5 if @_State[:target_item] == 257 && target.id == 132
    #> Écaille Océan
    n *= 2 if @_State[:target_item] == 227 && target.id == 366
    item = GameData::Item[@_State[:target_item]]
    return n unless item
    imisc = item.misc_data
    return n unless imisc
    n *= 1.5 if imisc.need_ids_sp_1_5 && imisc.need_ids_sp_1_5.include?(target.id)
    return n
  end
  #===
  #>_mod1_calculation
  # Calcul du modificateur 1
  #---
  #E : <BE_Model1>
  #S : n : Numeric : Multiplicateur
  #===
  def _mod1_calculation(launcher, target, skill)
    n = 1
    ability = @_State[:launcher_ability]
    #>BRN / Cran
    if(ability != 10 && launcher.burn? && skill.physical?)
      n *= 0.5
    end
    #>RL
    if(skill.physical? && @_State[target.position < 0 ? :enn_reflect : :act_reflect] > 0)
      n *= ($game_temp.vs_type == 2 ? 0.666 : 0.5)
    elsif(skill.special? && @_State[target.position < 0 ? :enn_light_screen : :act_light_screen] > 0)
      n *= ($game_temp.vs_type == 2 ? 0.666 : 0.5)
    end
    #>TVT
    if($game_temp.vs_type==2)
      if(skill.target == :all_enemy || skill.target == :everybody)
        n *= 0.75 #>Il faut vérifier si les cibles sont vivante / Présentes !!!
      end
    end
    #>SR
    if($env.sunny?)
      n *= 1.5 if skill.type_fire?
      n *= 0.5 if skill.type_water?
    elsif($env.rain?)
      n *= 0.5 if skill.type_fire?
      n *= 1.5 if skill.type_water?
    end
    #>FF / Torche
    if ability == 18
      last_damaging = launcher.battle_effect.last_damaging_skill
      if(((last_damaging && last_damaging.type_fire?) || launcher.burn?) && skill.type_fire?)
        n *= 1.5
      end
    end
    return n
  end
  #===
  #>_critical_calculation
  # Calcul du mutiplicateur de coup critique
  #---
  #E : <BE_Model1>
  #S : n : Numeric : Multiplicateur
  #===
  Critical_Rates = [0, 6_25, 12_50, 25_00, 33_33, 50_00, 100_00, 100_00, 100_00, 100_00, 100_00, 100_00, 100_00, 100_00]
  Always_Crit_Atks = [480, 524]
  def _critical_calculation(launcher, target, skill, forced = false)
    #> Armurbaston / Coque Armure
    if(Abilities.has_abilities(target, 71, 46))
      return 1
    end
    return 1 if skill.id == 251 && ::GameData::Flag_4G #> Baston
    #> Yama Arashi, Souffle Glacé
    critical_rate = Always_Crit_Atks.include?(skill.id) ? 6 : skill.critical_rate
    critical_rate += launcher.critical_modifier
    critical_rate += 2 if launcher.battle_effect.has_focus_energy_effect?
    critical_rate += 1 if @_State[:launcher_ability] == 78 #> Chanceux
    critical_rate += 1 if launcher.id == 83 && @_State[:launcher_item] == 259 #> Bâton
    critical_rate += 1 if @_State[:launcher_item] == 326 #> Griffe Rasoir
    critical_rate += 1 if launcher.id == 113 && @_State[:launcher_item] == 256 #> Poing Chance
    critical_rate += 1 if @_State[:launcher_item] == 232 #> Lentilscope 
    n = ((rand(100_00) < Critical_Rates[critical_rate] || forced) ? 1.5 : 1)
    n *= 1.5 if(n>1 && @_State[:launcher_ability] == 61) #> Sniper
    #>Vérifier les autres cas dans le coup critique
    @_State[:last_critical_hit] = n
    return n
  end
  #===
  #>_mod2_calculation
  # Calcul du second modifier
  #---
  #E : <BE_Model1>
  #V : item : GameData::Item : Objet porté
  #    imisc : GameData::ItemMisc : Data particulier de l'objet porté
  #S : n : Numeric : Multiplicateur
  #===
  def _mod2_calculation(launcher, target, skill)
    n = 1
    #> Orbe Vie
    n *= 1.3 if @_State[:launcher_item] == 270
    #> Métronome
    if(@_State[:launcher_item] == 277)
      times = launcher.skill_use_times
      times = 10 if times > 10
      n *= (0.9 + 0.1 * times)
    end
    n *= 1.5 if(skill.id == 382) #Moi d'abord / Me First
    return n
  end
  #===
  #>_mod2_calculation
  # Calcul le STAB
  #---
  #E : <BE_Model1>
  #S : n : Numeric : Multiplicateur
  #===
  def _stab_calculation(launcher, target, skill)
    type = skill.type
    return 1 if type == 0
    if(type == launcher.type1 || type == launcher.type2 || type == launcher.type3)
      ability = @_State[:launcher_ability]
      if(ability == 67) #> Adaptabilité
        n = 2
      else
        n = 1.5
      end
    else
      n = 1
    end
    return n
  end
  #===
  #>_mod3_calculation
  # Calcul du troisième modifier
  #---
  #E : <BE_Model1>
  #    type_mod : Numeric modifier du type
  #V : item : GameData::Item : Objet porté
  #    imisc : GameData::ItemMisc : Data particulier de l'objet porté
  #S : n : Numeric : Multiplicateur
  #===
  def _mod3_calculation(launcher, target, skill, type_mod)
    n = 1
    ability = @_State[:target_ability]
    #SRF
    n *= 0.75 if type_mod >= 2 && (ability == 100 || ability == 64)#> Solide Roc / Filtre
    #>Partie item (EB)
    n *= 1.2 if type_mod >= 2 && @_State[:launcher_item] == 268 #> Ceinture pro
    #TL
    n *= 2 if type_mod <= 0.5 && @_State[:launcher_ability] == 23 #> Lentiteintée
    #TRB
    item = GameData::Item[@_State[:target_item]] #> Cible / lanceur ?
    return n unless item
    imisc = item.misc_data
    if imisc && berry = imisc.berry
      #> Réduction super efficace
      if((@_State[:target_item] >= 184 && @_State[:target_item] <= 200) ||
        @_State[:target_item] == 686)
        n *= 0.5 if type_mod >= 2 && berry[:type] == skill.type
      end
    end
    return n
  end
end
