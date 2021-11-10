#encoding: utf-8

#noyard
class Pokemon_Effect

  #===
  #> Gestion du switch des Pokémon
  #===
  def switch_with(pokemon)
    @__pokemon_switched_with = pokemon
  end
  def switched_with
    @__pokemon_switched_with
  end

  #===
  #> Gestion de l'attaque Anti-Air
  #===
  def apply_smack_down
    @smack_down = true
  end

  #>Vérification de la présence de l'effet Anti-Air
  def has_smack_down_effect?
    return @smack_down
  end
  #===
  #>Coup de main / Helping Hand
  #===
  def apply_helping_hand
    @helping_hand=true
  end

  def has_helping_hand_effect?
    return @helping_hand
  end
  #===
  #>Chargeur / Charge
  #===
  def apply_charge
    @charge=true
  end

  def has_charge_effect?
    return @charge
  end

  #===
  #>Depuis quand le Pokémon est sur le terrain
  #===
  def get_launched_turn
    @_pokemon_launched_turn
  end

  #===
  #>Depuis combien de tours le Pokémon est sur le terrain
  #===
  def nb_of_turn_here
    return $game_temp.battle_turn - @_pokemon_launched_turn
  end

  #===
  #>Appliquer l'effet de Ténacité
  #===
  def apply_endure
    @protect_counter = (@protect_scounter==0 ? 1 : @protect_counter+1)
    @protect_scounter = 2
    @endure = true
  end

  def has_endure_effect?
    return @endure
  end

  #===
  #>Appliquer l'effet Abri/Détection/etc...
  #===
  def apply_protect
    @protect_counter = (@protect_scounter==0 ? 1 : @protect_counter+1)
    @protect_scounter = 2
    @has_protect = true unless @protect_ruse
    @protect_ruse = false
  end

  #===
  #>Vérification de la présence l'effet Abri/Détection
  #===
  def has_protect_effect?
    return @has_protect
  end

  Protect_Prec = [1000, 500, 250, 125] 
  #>Récupération de la précision modifié de Abri/Détection
  def get_protect_accuracy
    v = Protect_Prec[@protect_counter]
    return 0 unless v
    return v
  end

  #===
  #>Blockage de l'effet Abri/Détection
  #===
  def set_protect_ruse
    @protect_ruse=true
  end

  #===
  #>Vérifie si le Pokémon est Amoureux
  #===
  def has_attract_effect?
    return (@attract_counter!=0)
  end

  #>Récupère le Pokémon Aimé
  def attracted_to
    return @attract_target
  end

  #Appliquer l'amour à un Pokémon
  def apply_attract(target,counter)
    @attract_counter=counter
    @attract_target=target
  end

  #===
  #>Appliquer le rechargement
  # Le rechargement permet à Ultra Lazer et d'autres attaques
  #===
  def set_reload_state(bool)
    @reload_state=bool
  end

  #>Vérifier la nécessite de recharger
  def must_reload
    return @reload_state
  end

  #====
  #>Attaques forcées
  #>Vérifie si le Pokémon doit faire une attaque
  #===
  def has_forced_attack?
    return @forced_attack_count!=0
  end

  #>Appliquer l'effet forçant à faire une attaque
  def apply_forced_attack(atk_id,nb_turn,target)
    @forced_attack_id=atk_id
    @forced_attack_count=nb_turn.to_i
    @forced_target=target
    @forced_position=target.position
    @thrash_incomplete = false
  end

  #>Récupérer l'attaque ou la position de l'attaque dans le skills_set
  def get_forced_attack(pkm=nil)
    return @forced_attack_id unless pkm
    ss=pkm.skills_set
    ss.each_index do |i|
      return i if(ss[i].id==@forced_attack_id)
    end
    return 0
  end

  #>Récupérer la cible de l'attaque forcée
  def get_forced_target
    return @forced_target
  end

  #>Récupérer la position de la cible de l'attaque forcée
  def get_forced_position
    return @forced_position
  end

  #>Récupération du compteur de tours de l'attaque forcée
  def get_forced_attack_counter
    return @forced_attack_count
  end

  #>Incrément du compteur pour patience
  def inc_forced_attack_counter
    @forced_attack_count+=1
  end

  #===
  #>Effets hors de portée
  #>Vérification de la non présence du Pokémon sur le terrain 
  #===
  def has_out_of_reach_effect?
    return @c_out_of_reach>0
  end

  #>Appliquer la non présence du Pokémon sur le terrain (avec le type)
  def apply_out_of_reach(v)
    @out_of_reach=v
    @c_out_of_reach=(v==0 ? 0 : 2)
  end

  #>Récupération du compteur de non présence du Pokémon
  def get_out_of_reach_counter
    return @c_out_of_reach
  end

  #>Récupération du type de non présence du Pokémon
  def get_out_of_reach
    return @out_of_reach
  end

  #===
  #>Effet relatif à Nuée de poudre (Powder)
  #===
  def apply_powder
    @powder_active = true
  end

  def has_powder_effect?
    return @powder_active
  end
  #===
  #>Appliquer l'effet de Requiem
  #===
  def apply_perish_song(nb_turn = 3)
    @perish_song_counter=nb_turn
  end

  #>Vérification de la présence de l'effet requiem
  def has_perish_song_effect?
    return @perish_song_counter>0
  end

  #>Récupération du compteur de Requiem
  def get_perish_song_counter
    return @perish_song_counter
  end

  #>Décrément du compteur de Requiem
  def dec_perish_song_counter
    @perish_song_counter-=1 if @perish_song_counter>0
  end

  #===
  #>Appliquer l'effet d'Etreinte
  #===
  def apply_bind(nb_turn, skill_name, launcher)
    @bind = nb_turn
    @bind_skill_name = skill_name
    @bind_launcher = launcher
  end

  #>Vérifier l'effet d'Etreinte
  def has_bind_effect?
    return (@bind > 0 and @bind_launcher.hp > 0)
  end

  #>Récupérer la cause de l'attaque
  def get_bind_skill_name
    return @bind_skill_name
  end

  #>Récupérer la puissance d'étreinte
  def get_bind_power(target)
    #>Bande Étreinte
    mult = BattleEngine::_has_item(@bind_launcher, 544) ? 8 : 16
    return (target.max_hp<mult ? 1 : target.max_hp/mult)
  end

  def transmit_bind(be)
    be.apply_bind(@bind, @bind_skill_name, @bind_launcher)
  end
  #===
  #>Gestion des dommages pris par des attaques de type riposte
  #===
  def take_damages(hp, atk_kind, launcher)
    #>Gestion de patience
    if(has_bide_effect? and launcher == @forced_target)
      @bide += hp
    end
    hp *= -1 if atk_kind == 2
    @damage_taken.push(hp)
    @damage_from.push(launcher)
    @last_damager = launcher
  end

  def get_taken_damages_from(launcher)
    index = @damage_from.rindex(launcher)
    if(index)
      return @damage_taken[index]
    end
    return 0
  end

  def took_damage
    return @damage_taken.size > 0
  end

  def last_damager
    return @last_damager
  end

  
  #===
  #>Gestion de Vampigraine
  #===
  def apply_leech_seed(receiver)
    @leech_seed=receiver
  end

  #>Vérification de la présence de l'effet Vampigraine
  def has_leech_seed_effect?
    return @leech_seed!=false
  end

  #>Récupération du Pokémon récupérant les bonus de Vampigraine
  def get_leech_seed_receiver
    return @leech_seed
  end

  #===
  #> Gestion de Préscience et Carnareket
  #===
  #>Vérification de la présence d'un Skill du type Préscience / Carnareket
  def has_future_skill?
    return @future_skill>0
  end

  #>Vérification de la liaison à un skill du genre Préscience / Carnareket
  def is_locked_by_future_skill?
    return @future_skill_t>0
  end

  #>Appliquer un Skill du genre Préscience / Carnareket
  def set_future_skill(damage,n_turn,skill_id)
    @future_damage=damage
    @future_skill_t=n_turn+1
    @future_skill_id=skill_id
  end

  #>Récupération du compteur d'avant action de Futur Skill
  def get_future_skill_counter
    return @future_skill_t
  end

  #>Récupération de l'ID du skill frappant
  def get_future_skill_id
    return @future_skill_id
  end

  #>Mis en attente du Pokémon avant de relancer un Skill du genre Préscience / Carnareket
  def set_future_wait(n_turn)
    @future_skill=n_turn
  end

  #>Récupération des HP infligés par le Skill Préscience / Carnareket
  def get_future_damage
    return @future_damage
  end

  #===
  #> Vérification de la présence de l'effet Picot
  #===
  def has_spikes_effect?
    return @spikes>0
  end

  #>Récupération des dommages infligés par les Picots
  def get_spikes_dammages(pokemon)
    # If Flying type / Levitate / Iron Ball / Gravity
    if (pokemon.type_fly? || BattleEngine::Abilities.has_ability_usable(pokemon, 26)) && !BattleEngine::_has_item(pokemon, 278) && !BattleEngine.state[:gravity] > 0
      return 0
    end
    case @spikes
    when 0
      return 0
    when 1
      return pokemon.max_hp/8
    when 2
      return pokemon.max_hp*3/16
    else
      return pokemon.max_hp/4
    end
  end

  #>Récupération des HP perdus à cause de Piege de rock A conserver !!!!
  def get_stealth_rock_dammages(pokemon)
    mod = GameData::Type[pokemon.type1].hit_by(13) *
          GameData::Type[pokemon.type2].hit_by(13) *
          GameData::Type[pokemon.type3].hit_by(13)
    return (pokemon.max_hp * mod / 8).floor
  end
  #> application de la toile gluante
  def sticky_web
    @priority -= 1
  end

  #===
  #>Appliquer l'effet brûme
  #===
  def apply_mist(nb_turn = 5)
    @mist = nb_turn
  end

  def has_mist_effect?
    return @mist > 0
  end

  def get_mist_counter
    return @mist
  end

  #===
  #>Vérifie la présence de l'effet Saisie
  #===
  def has_snatch_effect?
    return (@snatch_target!=nil)
  end

  #>Applique l'effet Saisie
  def apply_snatch(snatch_target)
    @snatch_target=snatch_target
  end

  #>Retourne la cible qui Saisie ra les effets
  def get_snatch_target
    return @snatch_target
  end

  #===
  #>Appliquer l'effet reflet magik
  #===
  def apply_magic_coat
    @magic_coat=true
  end

  #>Vérification de la présence de l'effet Reflet Magik
  def has_magic_coat_effect?
    return @magic_coat
  end

  
  #>Vérifier la présence de l'effet Cauchemar
  def has_nightmare_effect?
    return @nightmare!=false
  end

  #>Appliquer l'effet Cauchemard
  def apply_nightmare(ena = true)
    @nightmare = ena
  end

  #===
  #>Vérifie la présence de l'effet "Peur" empêchant au Pokémon d'attaquer
  #===
  def has_afraid_effect?
    return @afraid_counter>0
  end

  #>Applique la peur
  def apply_afraid
    @afraid_counter=1
  end


  #>Appliquer l'effet bloquant les capacités spéciales
  def apply_no_ability
    @no_ability=true
  end

  #>Vérificiation de l'incapacité d'utiliser une capacité spéciale
  def has_no_ability_effect?
    return @no_ability
  end
  #===
  #>Effet de boost (Empêcher les changements de stat)
  #===
  def has_no_stat_change_effect?
    @no_stat_change
  end

  def apply_no_stat_change
    @no_stat_change = true
  end

  #===
  #>Rune Protect
  #===
  def has_safe_guard_effect?
    @safe_guard
  end

  def apply_safe_guard(v = true)
    @safe_guard = v
  end

  #===
  #>Anti-Soin
  #===
  def has_heal_block_effect?
    @heal_block > 0
  end

  def apply_heal_block(nb_turn = 5)
    @heal_block = nb_turn
  end

  #===
  #>Vol magnétique
  #===
  def has_magnet_rise_effect?
    @magnet_rise > 0
  end

  def apply_magnet_rise(nb_turn = 5)
    @magnet_rise = nb_turn
  end

  #===
  #> Levikinesis
  #===
  def has_telekinesis_effect?
    @telekinesis > 0
  end

  def apply_telekinesis(nb_turn = 3)
    @telekinesis = nb_turn
  end
  #===
  #> Clairevoyance / Flair
  #===
  def has_foresight_effect?
    @foresight
  end

  def apply_foresight
    @foresight = true
  end
  #===
  #> Entrave
  #===
  def has_disable_effect?
    return @disable_counter > 0
  end

  def apply_disable(id_skill)
    @disable_counter = id_skill ? 2 + rand(6) : 0
    @disable = id_skill
  end

  def disable_skill_id
    @disable
  end
  #===
  #> Effet de copie (pour suppr en cas de switch/mort)
  #===
  def get_mimic
    @mimic
  end

  def apply_mimic(pokemon, skill)
    @mimic[pokemon] = skill
  end
  #===
  #> Encore
  #===
  def has_encore_effect?
    return @encore_counter > 0
  end

  def apply_encore(skill)
    @encore_counter = skill ? 3 : 0
    @encore = skill
  end

  # @return [PFM::Skill, nil]
  def encore_skill
    @encore
  end

  #===
  #>Appliquer l'effet empêchant de fuir
  #===
  def apply_cant_flee(launcher)
    @cant_flee_launcher = launcher
  end

  def has_cant_flee_effect?
    return @cant_flee_launcher != nil
  end

  def get_cant_flee_launcher
    return @cant_flee_launcher
  end

  def transmit_cant_flee(be)
    be.apply_cant_flee(@cant_flee_launcher)
  end
  #===
  #>Appliquer l'effet d'embargo 
  #===
  def apply_embargo(nb_turn = 5)
    @embargo_counter = nb_turn
  end

  def has_embargo_effect?
    @embargo_counter > 0
  end

  #===
  #>Appliquer l'effet d'Allègement
  #===
  def apply_autotomize(reset = false)
    @autotomize = !reset
  end

  def has_autotomize_effect?
    return @autotomize
  end

  #===
  #>Appliquer l'effet de Provoc
  #===
  def apply_taunt(nb_turn)
    @taunt_counter=nb_turn
  end

  #>Vérifie la présence de l'effet Taunt
  def has_taunt_effect?
    return @taunt_counter>0
  end

  #===
  #>Appliquer clonnage
  #===
  def apply_substitute(hp)
    @substitute_hp = hp
  end

  def has_substitute_effect?
    return @substitute_hp > 0
  end

  def substitute_hp=(v)
    @substitute_hp = v
    if @substitute_hp < 0
      @substitute_hp = 0
    end
  end

  def substitute_hp
    return @substitute_hp
  end

  def transmit_substitute(be)
    be.apply_substitute(@substitute_hp)
  end
  #===
  #>Effet de frénésie
  #===
  def apply_rage
    @rage = true
  end

  def has_rage_effect?
    return @rage
  end

  #===
  #>Effet de patience
  #===
  def has_bide_effect?
    return @bide > 0
  end

  def get_bide_power
    power = @bide - 1
    @bide = 0
    return power
  end

  def apply_bide
    @bide = 1
  end

  #===
  #>Effet de Lire-Esprit
  #===
  def apply_mind_reader(target)
    @mind_reader = target
  end

  def has_mind_reader_effect?
    return @mind_reader != nil
  end

  def get_mind_reader_target
    return @mind_reader
  end

  #===
  #>Tourmente
  #===
  def apply_torment
    @torment = true
  end

  def has_torment_effect?
    return @torment
  end

  #===
  #>Voeu
  #===
  def apply_wish(wisher, nb_turn = 2)
    @wish = nb_turn
    @wisher = wisher
  end

  def has_wish_effect?
    return @wish == 1
  end

  def get_wisher
    return @wisher
  end

  #===
  #>Racines
  #===
  def apply_ingrain(v = true)
    @ingrain = v
  end

  def has_ingrain_effect?
    return @ingrain
  end

  #===
  #>Anneau Hydro
  #===
  def apply_aqua_ring(v = true)
    @aqua_ring = v
  end

  def has_aqua_ring_effect?
    return @aqua_ring
  end
  #===
  #>Baillement
  #===
  def apply_yawn(nb_turn = 2)
    @yawn = nb_turn
  end

  def has_yawn_effect?
    return @yawn >= 1
  end

  def fell_asleep_from_yawning?
    return @yawn == 1
  end

  #>Appliquer l'effet Rancune
  def apply_grudge(v = true)
    @grudge = v
  end

  def has_grudge_effect?()
    return @grudge
  end

  #===
  #>Mitra-poing
  #===
  def apply_focus_punch
    @focus_punch = $game_temp.battle_turn
  end

  def has_focus_punch_effect?
    return @focus_punch == $game_temp.battle_turn
  end

  #===
  #>Œil Miracle
  #===
  def apply_miracle_eye(v = true)
    @miracle_eye = v
  end

  def has_miracle_eye_effect?()
    return @miracle_eye
  end

  #===
  #>Possessif
  #===
  def has_imprison_effect?
    return @imprison != nil
  end

  def apply_imprison_effect(launcher, common)
    @imprison = common
    @imprison_launcher = launcher
  end

  def get_imprison_launcher
    return @imprison_launcher
  end

  def is_skill_imprisonned?(skill)
    @imprison.each do |i|
      return true if skill.id == i&.id
    end
    return false
  end
end
