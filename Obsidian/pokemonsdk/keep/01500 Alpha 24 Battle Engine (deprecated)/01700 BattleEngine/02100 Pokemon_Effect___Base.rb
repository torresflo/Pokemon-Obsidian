#encoding: utf-8

#noyard
class Pokemon_Effect
  attr_accessor :atk, :ats, :spd, :dfs, :dfe, :item_held, :thrash_incomplete, 
  :rollout_power, :fury_cutter_power, :stockpile, :last_damaging_skill, 
  :last_attacking, :priority
  def initialize()
    @helping_hand = false #>Coup de main
    @charge = false #>Chargeur
    @_pokemon_launched_turn=($game_temp ? $game_temp.battle_turn : 0)
    #>Abris / Détection
    @has_protect=false
    @protect_counter=0
    @protect_scounter=0
    @attract_counter=0
    @attract_target=nil
    @reload_state=false
    @forced_target=nil
    @forced_attack_id=0
    @forced_attack_count=0
    @forced_position=0
    @powder_active = false
    @perish_song_counter = 0
    @bind = 0
    @bind_skill_name = nil
    @bind_launcher = nil
    @damage_taken = Array.new
    @damage_from = Array.new
    @leech_seed=false
    @future_skill=0
    @future_skill_t=0
    @spikes=0
    @toxic_spikes=0
    @stealth_rock=0
    @minimize=false
    @mist = 0
    @snatch_target = nil #Effet de la saisie
    @magic_coat=false
    @nightmare=false
    @afraid_counter=0
    @no_ability=false
    @atk = @ats = @spd = @dfe = @dfs = nil
    @no_stat_change = false
    @safe_guard = false
    @heal_block = 0
    @magnet_rise = 0
    @foresight = false
    @disable = 0
    @disable_counter = 0
    @mimic = {}
    @encore = nil
    @encore_counter = 0
    @cant_flee_launcher = nil
    @embargo_counter = 0
    @autotomize = false
    @taunt_counter=0
    @substitute_hp = 0
    @rage = false
    @thrash_incomplete = false
    @endure = false
    @rollout_power = 0
    @fury_cutter_power = 0
    @stockpile = 0
    @focus_punch = nil
    @last_damaging_skill = nil
    @bide = 0
    @mind_reader = nil
    @last_damager = nil
    @last_attacking = nil
    @torment = false
    @wish = 0
    @ingrain = false
    @yawn = 0
    @aqua_ring = false
    @grudge = false
    @out_of_reach = 0
    @c_out_of_reach = 0
    @miracle_eye = false
    @imprison=nil
    @imprison_launcher=nil
    @telekinesis = 0

    @no_critic_count=0
    @nsm_counter=0
    @cuo_counter=0
    @cat_counter=0
    @cat_skillid=0
    @culastskill_counter=0
    @lock_counter=0
    @taken_dammage=0
    @atk_kind=0
    @wrap_counter=0
    @wrap_id=0
    @has_no_aoe=false
    @has_endure=false
    @waiting_effect=nil
    @waiting_effect_counter=0
    @boost_type_counter_on=Array.new(18,0)
    @boost_type_on=Array.new(18,1)
    @boost_type_counter_to=Array.new(18,0)
    @boost_type_to=Array.new(18,1)
    @stat_raise=Hash.new
    @stat_switch=nil
    @type_switch=nil
    @type_switch_counter=0
    @storages=0
    @mind_reader=false
    @no_pp_loose=0
    @wish=false
    @priority = 0
  end

  def reset
    initialize()
  end

  def update_counter(pokemon)
    be = ::BattleEngine
    @helping_hand = false
    @charge = false
    @protect_scounter-=1 if @protect_scounter>0
    #>Attaque forcée
    @forced_attack_count-=1 if @forced_attack_count>0
    @powder_active = false
    #> Etreinte & co
    @bind -= 1 if @bind > 0
    @damage_taken.clear
    @damage_from.clear
    #> Carnareket / Prescience
    @future_skill-=1 if @future_skill>0
    @future_skill_t-=1 if @future_skill_t>0
    #> Brûme
    @mist -= 1 if @mist > 0
    @snatch_target=nil
    @magic_coat=false
    @afraid_counter=0
    @rage = false
    @endure = false
    @c_out_of_reach -= 1 if @c_out_of_reach > 0
    #> Anti-Soin
    @heal_block -= 1 if @heal_block > 0
    #> Vol magnetique
    if @magnet_rise > 0
      @magnet_rise -= 1
      if(@magnet_rise == 0)
        be._msgp(19, 661, pokemon)
      end
    end
    #> Levikinesi
    if @telekinesis > 0
      @telekinesis -= 1
      if(@telekinesis == 0)
        be._msgp(19, 1149, pokemon)
      end
    end
    #> Entrave
    if @disable_counter > 0
      @disable_counter -= 1
      if(@disable_counter == 0)
        be._msgp(19, 598, pokemon)
      end
    end
    #> Encore
    if @encore_counter > 0
      @encore_counter -= 1
      if(@encore_counter == 0)
        be._msgp(19, 562, pokemon)
      end
    end
    #> Embargo
    if @embargo_counter > 0
      @embargo_counter -= 1
      if(@embargo_counter == 0)
        be._msgp(19, 730, pokemon)
      end
    end
    #> Provoc
    if @taunt_counter>0
      @taunt_counter-=1
      if(@taunt_counter == 0)
        be._msgp(19, 574, pokemon)
      end
    end
    #> Amour
    if @attract_counter>0
      @attract_counter-=1
      if(@attract_counter == 0)
        be._msgp(19, 339, pokemon)
      end
    end

    @mind_reader=false
    @has_protect=false
    @has_no_aoe=false
    @has_endure=false
    @wish==1 || @wish==false ? @wish=false : @wish-=1
    @no_pp_loose-=1 if @no_pp_loose>0
    @no_critic_count-=1 if @no_critic_count>0
    @nsm_counter-=1 if @nsm_counter>0
    @cuo_counter-=1 if @cuo_counter>0
    @cat_counter-=1 if @cat_counter>0
    @culastskill_counter-=1 if @culastskill_counter>0
    @lock_counter-=1 if @lock_counter>0
    #@bad_dream=false if @bad_dream and !@bad_dream.asleep?
    @taken_dammage=0
    if @wrap_counter>0
      @wrap_counter-=1
      @wrap_id=@wrap_id.abs
    end
    @waiting_effect_counter-=1 if @waiting_effect_counter>0
    if @type_switch_counter>0
      @type_switch_counter-=1
      if @type_switch_counter==0
        @type_switch=nil
      end
    end
    #Partie sensible
    @boost_type_counter_to.size.times do |i|
      if(@boost_type_counter_to[i]>0)
        @boost_type_counter_to[i]-=1
        if(@boost_type_counter_to[i]==0)
          @boost_type_to[i]=1
        end
      end
    end

    @boost_type_counter_on.size.times do |i|
      if(@boost_type_counter_on[i]>0)
        @boost_type_counter_on[i]-=1
        if(@boost_type_counter_on[i]==0)
          @boost_type_on[i]=1
        end
      end
    end

    @stat_raise.each_key do |i|
      data=@stat_raise[i]
      next unless data
      data[1]-=1 if data[1].is_a?(Integer) && data[1]>0
      if data[1]==0
        @stat_raise[i]=nil
      end
    end

  end

  

  


  #>Suppression des critiques
  def has_no_critic_effect?()
    return @no_critic_count!=0
  end

  #>Appliquer l'effet qui supprime les coup critiques
  def apply_no_critic(nb_turn)
    @no_critic_count=nb_turn.to_i
  end

  
  #>Vérifie la présence de l'effet empêchant la modification de status/stat
  def has_no_status_modification_effect?()
    return @nsm_counter>0
  end

  #>Appliquer l'effet empêchant la modification de status/stat
  def apply_no_statu_modification()
    @nsm_counfter=6
  end

  #>Vérification de la présence de l'effet empêchant d'utiliser les objets
  def has_cant_use_item_effect?()
    return (@sabotage or @cuo_counter>0)
  end

  #>Appliquer l'effet sabottage
  def apply_sabotage()
    @sabotage=true
  end

  #>Appliquer l'effet empêchant d'utiliser un objet
  def apply_cant_use_item(nb_turn)
    @cuo_counter=nb_turn
  end

  #>Appliquer l'effet empêchant d'utiliser une attaque
  def apply_cant_attack(nb_turn,id)
    @cat_counter=nb_turn
    @cat_skillid=id
  end

  #>Vérification de la présence de l'effet empêchant d'utiliser une attaque
  def has_cant_attack_effect?()
    return @cat_counter>0
  end

  #>Récupération de l'Id de l'attaque inutilisable
  def get_cant_attack_id()
    return @cat_skillid
  end

  #>Appliquer l'effet empêchant d'utiliser deux fois de suite la même attaque
  def apply_cant_use_last_skill(nb_turn)
    @culastskill_counter=nb_turn
  end

  #>Vérifier la présence de de l'effet empêchant d'utiliser deux fois de suite la même attaque
  def has_cant_use_last_skill_effect?()
    return @culastskill_counter>0
  end

  #>Appliquer l'effet de verrouillage
  def apply_lock()
    @lock_counter=2
  end

  #>Vérification de la présence de l'effet verrouillage
  def has_lock_effect?()
    return @lock_counter>0
  end

  #>Préparation de la riposte
  def update_taken_damage(hp,skill,launcher)
    @taken_dammage+=hp
    @dmg_launcher=launcher
    @atk_kind=skill.atk_class
  end

  #>Récupérer les hp perdus en fonction du type d'attaque (Riposte/Voil Miroir)
  def get_taken_dammage(kind)
    return @atk_kind==kind ? @taken_dammage : 0
  end

  #>Récupérer les hp perdus quelque soit le type d'attaque
  def get_taken_dammage!()
    return @taken_dammage
  end

  #>Récupérer le Pokémon ayant fait les degas
  def get_dammager()
    return @dmg_launcher
  end

  #>Appliquer l'effet ligotage
  def apply_warp(nb_turn,skill_id)
    @wrap_counter=nb_turn
    @wrap_id=-skill_id
  end

  #>Vérification de la présence de l'effet Ligotage
  def has_warp_effect?()
    return (@wrap_counter>0 and @wrap_id>0)
  end

  #>Récupérer le nom de l'attaque utilisé pour Ligotage
  def get_warp_skill_name()
    return $data_skills[@wrap_id.abs].name
  end

  #>Appliquer le blocage des attaques de zone
  def apply_no_aoe()
    @protect_counter=(@protect_scounter==0 ? 1 : @protect_counter+1)
    @protect_scounter=2
    @has_no_aoe=true
  end

  #>Vérification de la présence de l'effet bloquant les effets de zone
  def has_no_aoe_effect?()
    return @has_no_aoe
  end

  
  #>Appliquer l'effet de Tenacité
  def apply_endure()
    @protect_counter=(@protect_scounter==0 ? 1 : @protect_counter+1)
    @protect_scounter=2
    @has_endure=true
  end

  #>Vérification de la présence de l'effet Tenacité
  def has_endure_effect?()
    return @has_endure
  end

  
  #>Appliquer l'effet de Voeux
  def apply_wish()
    @wish=true
  end

  #>Vérification de la présence de l'effet Voeux
  def has_wish_effect?
    return @wish
  end

  #>Appliquer un effet qui se déclenchera plus tard
  def apply_waiting_effect(effect,nb_turn)
    @waiting_effect_counter=nb_turn
    @waiting_effect=effect
  end

  #>Vérification de la présence d'un effet déclenchable plus tard
  def has_waiting_effect?()
    return (@waiting_effect_counter==0 && @waiting_effect)
  end

  #>Récupération de l'effet déclenchable plus tard
  def get_waiting_effect()
    tmp=@waiting_effect
    @waiting_effect=nil
    return tmp
  end

  #>Appliquer un effet de boost
  def apply_boost_type(hash)
    amp=hash[:amplified_type]
    cdn=hash[:end_condition]
    if(amp)
      @boost_type_on[amp[0]]=amp[1]
      if(cdn)
        @boost_type_counter_on[amp[0]]=cdn
      else
        @boost_type_counter_on[amp[0]]=1/0.0
      end
    end
    amp=hash[:_amplified_type]
    if(amp)
      @boost_type_to[amp[0]]=amp[1]
      if(cdn)
        @boost_type_counter_to[amp[0]]=cdn
      else
        @boost_type_counter_to[amp[0]]=1/0.0
      end
    end

  end

  #>Récupération des boost de type pour les attaques envoyés
  def get_boost_type_on()
    return @boost_type_on
  end

  #>Récupération des boost de type appliqués pour les attaques reçues
  def get_boost_type_to()
    return @boost_type_to
  end

  #>Appliquer un effet d'amplification de statistiques (HP => perte/gain à chaque tours)
  def apply_stat_raise(array,nb_turn)
    @stat_raise[array[0]]=[array[1],nb_turn]
  end

  #>Récupération des statistiques amplifiés
  def get_stat_raise()
    return @stat_raise
  end

  #>Appliquer une effet d'échange de stats
  def apply_stat_switch(array)
    @stat_switch=array
  end

  #>Récupérer les stats échangés
  def get_stat_switch()
    return @stat_switch
  end

  #>Appliquer un effet de switch de type
  def apply_type_switch(array,nb_turn)
    @type_switch=array
    @type_switch_counter=nb_turn.to_i
  end

  #>Récupérer le switch de type
  def get_type_switch()
    return @type_switch
  end

  #>Augmentation de l'effet de l'attaque Stockage
  def add_storages()
    @storages+=1
  end

  #>Récupération du nombre de stockage réalisés
  def get_storages()
    return @storages
  end

  #>Remise à zéro du Stockage
  def reset_storages()
    @storages=0
  end

  
  #>Appliquer l'effet de Lire Esprit
  def apply_mind_reader()
    @mind_reader=true
  end

  #>Vérifier la présence de l'effet de Lire Esprit
  def has_mind_reader_effect?()
    return @mind_reader
  end

  #>Appliquer l'effet de non perte de PP
  def apply_no_pp_loose(nb_turn)
    @no_pp_loose=nb_turn
  end

  #>Vérification de la présence de l'effet de non perte de PP
  def has_no_pp_loose_effect?
    return @no_pp_loose>0
  end


  @self=self.new
  def self.default_be
    return @self
  end
end
