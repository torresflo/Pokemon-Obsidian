#encoding: utf-8
module GameData
  class Base
    attr_accessor :id
  end
end
# Header: psdk.pokemonworkshop.com/index.php/ScriptHeader
# Author: Nuri Yuri
# Date: 2014
# Update: 2014-mm-dd
# ScriptNorm: No
# Description: Données des Pokéball
module GameData
  class BallData < Base
    #===
    #>Attributs
    #===
    attr_accessor :name, #Nom de la ball
    :img, #Image de la ball fermée
    :catch_rate, #Taux de capture
    :special_catch, #Type de capture spécifique
    :color #Couleur à l'ouverture de la ball
    #===
    #>Constantes
    #===
    DefaultIMG = "ball_1"
    #===
    #>Méthodes
    #===
    def self.img(id)
      return DefaultIMG unless ball_data = Item::ball_data(id)
      return ball_data.img
    end
    def self.catch_rate(id)
      return 1 unless ball_data = Item::ball_data(id)
      return ball_data.catch_rate
    end
    def self.special_catch(id)
      return nil unless ball_data = Item::ball_data(id)
      return ball_data.special_catch
    end
  end
end
# Header: psdk.pokemonworkshop.com/index.php/ScriptHeader
# Author: Nuri Yuri
# Date: 2014
# Update: 2015-mm-dd
# ScriptNorm: No
# Description: Données des objets soignants
module GameData
  class ItemHeal < Base
    #===
    #>Attributs
    #===
    attr_accessor :hp, #HP soignés
    :hp_rate, #%de HP soignés
    :pp, #PP soignés
    :all_pp, #Si tous les PP d'une attaque sont soignés
    :states, #Status soignés
    :loyalty, #Modification de bonheur
    :level, #Modification de niveau
    :boost_stat, #Ajout de 4 EV sur une statistique
    :battle_boost, #Ajout d'un boost en combat sur une statistique
    :add_pp #PP+ 1: 1, 2: max, nil: rien
    #===
    #>Méthodes
    #===
    def self.hp(id)
      return 0 unless heal_data = Item::heal_data(id)
      return heal_data.hp
    end
    def self.hp_rate(id)
      return 0 unless heal_data = Item::heal_data(id)
      return heal_data.hp_rate
    end
    def self.pp(id)
      return nil unless heal_data = Item::heal_data(id)
      return heal_data.pp
    end
    def self.all_pp(id)
      return nil unless heal_data = Item::heal_data(id)
      return heal_data.all_pp
    end
    def self.states(id)
      return nil.to_a unless heal_data = Item::heal_data(id)
      return heal_data.states
    end
    def self.loyalty(id)
      return nil unless heal_data = Item::heal_data(id)
      return heal_data.loyalty
    end
    def self.level(id)
      return nil unless heal_data = Item::heal_data(id)
      return heal_data.level
    end
    def self.boost_stat(id)
      return nil unless heal_data = Item::heal_data(id)
      return heal_data.boost_stat
    end
    def self.battle_boost(id)
      return nil unless heal_data = Item::heal_data(id)
      return heal_data.battle_boost
    end
    def self.add_pp(id)
      return nil unless heal_data = Item::heal_data(id)
      return heal_data.add_pp
    end
  end
end
# Header: psdk.pokemonworkshop.com/index.php/ScriptHeader
# Author: Nuri Yuri
# Date: 2014
# Update: 2015-mm-dd
# ScriptNorm: No
# Description: Données particulières des objets
module GameData
  class ItemMisc < Base
    #===
    #>Attributs
    #===
    attr_accessor :event_id, #Evennement commun à appeler
    :repel_count, #Nombre de pas effectif de la repousse
#    :exp_share, #Si ça a l'effet du Multi-Exp
#    :luckyegg, #Si ça a l'effet de l'oeuf chance
#    :amuletcoin, #Si ça a l'effet de la piece rune
    :ct_id, #ID de la CT
    :cs_id, #ID de la CS
    :skill_learn, #Apprentissage d'une capacité (id)
    :stone, #Si c'est une pierre evolutive
    :berry, #Si c'est une baie (doit contenir le data de la baie qui n'est pas encore défini
    :flee, #Permet de fuire
    #>Partie pour le combat (OK)
    :need_user_id, #Nécessite un utilisateur particulier
    :check_atk_class, #Vérifie la catégorie du skill (1 2 3)
    :powering_skill_type1, #Premier type à amplifier
    :powering_skill_type2, #Deuxième type à amplifier
#    :choice_ph,  #Bandeau choix
#    :choice_sp,  #Lunet choix
    :need_ids_ph_2, #Multiplie par 2 si attaque physique et id pokémon inclut
    :need_ids_sp_2, #Multiplie par 2 si attaque spéciale et id pokémon inclut
    :need_ids_sp_1_5, #Multiplie par 1.5 si attaque spéciale et id pokémon inclut
#    :mental_powder,  #Poudre mental
#    :deepseascale, #Ecaille océan
#    :life_orb, #Orbe de vie x1.3
#    :metronome, #Augmentation de puissance si même skill xfois
#    :expert_bell, #Augmentation si attaque super efficace
#    :berry_type, #Reduction due à la baie
#    :berry_type_effective, #Réduction due à la baie en cas d'attaque super efficace du même type
    
    :acc, #>Multiplication de précision au lanceur (Nombre)
    :eva, #>Multiplication de l'esquive de la cible (Nombre)
    :none
    
    #berry : {
    # :type => type de la baie,
    # :power => puissance de l'attaque de la baie,
    
    #===
    #>Méthodes
    #===
    def self.event_id(id)
      return 0 unless misc_data = Item::misc_data(id)
      return misc_data.event_id
    end
    def self.repel_count(id)
      return 0 unless misc_data = Item::misc_data(id)
      return misc_data.repel_count
    end
    def self.ct_id(id)
      return nil unless misc_data = Item::misc_data(id)
      return misc_data.ct_id
    end
    def self.cs_id(id)
      return nil unless misc_data = Item::misc_data(id)
      return misc_data.cs_id
    end
    def self.skill_learn(id)
      return nil unless misc_data = Item::misc_data(id)
      return misc_data.skill_learn
    end
    def self.stone(id)
      return false unless misc_data = Item::misc_data(id)
      return misc_data.stone
    end
    def self.flee(id)
      return false unless misc_data = Item::misc_data(id)
      return misc_data.flee
    end
    def self.berry(id)
      return nil unless misc_data = Item::misc_data(id)
      return misc_data.berry
    end
    def self.need_user_id(id)
      return nil unless misc_data = Item::misc_data(id)
      return misc_data.need_user_id
    end
    def self.check_atk_class(id)
      return nil unless misc_data = Item::misc_data(id)
      return misc_data.check_atk_class
    end
    def self.powering_skill_type1(id)
      return nil unless misc_data = Item::misc_data(id)
      return misc_data.powering_skill_type1
    end
    def self.powering_skill_type2(id)
      return nil unless misc_data = Item::misc_data(id)
      return misc_data.powering_skill_type2
    end
    def self.need_ids_ph_2(id)
      return nil unless misc_data = Item::misc_data(id)
      return misc_data.need_ids_ph_2
    end
    def self.need_ids_sp_2(id)
      return nil unless misc_data = Item::misc_data(id)
      return misc_data.need_ids_sp_2
    end
    def self.need_ids_sp_1_5(id)
      return nil unless misc_data = Item::misc_data(id)
      return misc_data.need_ids_sp_1_5
    end
    def self.acc(id)
      return nil unless misc_data = Item::misc_data(id)
      return misc_data.acc
    end
    def self.eva(id)
      return nil unless misc_data = Item::misc_data(id)
      return misc_data.eva
    end
  end
end
# Header: psdk.pokemonworkshop.com/index.php/ScriptHeader
# Author: Nuri Yuri
# Date: 2014
# Update: 2015-mm-dd
# ScriptNorm: No
# Description: Données des objets du jeu
module GameData
  class Item < Base
    #===
    #>Constantes
    #===
    NoIcon="return"
    #===
    #>Attributs
    #===
    attr_accessor :name, #Nom <- déprécié
    :descr, #Description <- déprécié
    :icon, #Icone dans le sac
    :price, #Prix en magasin
    :socket, #Id de la poche dans le sac
    :battle_usable, #Utilisable en combat
    :map_usable, #Utilisable en map
    :limited, #Utilisation limité
    :holdable, #Portable par un Pokémon
    :soldable, #Revendable
    :on_pokemon_usable, #Utilisable sur un Pokemon <- déprécié (script)
    :able_mode, #Doit vérifier la possibilité d'utilisation (Apte)
    :use_string, #Message affiché lors de l'utilisation <- déprécié
    :position, #Position dans le tri du sac
    :fling_power, #Puissance de dégommage
    :heal_data, #Données de soin
    :ball_data, #Données relative à la ball
    :misc_data #Données autres
    #===
    #>Méthodes statiques
    #===
    #===
    #>name : Obtenir le nom d'un objet par son id
    #===
    def self.name(id)
      if(id.between?(1, LastID))
        return Text.get(12,id)
      end
      return Text.get(12,0)
    end
    #===
    #>descr : Description d'un objet
    #===
    def self.descr(id)
      if(id.between?(1, LastID))
        return Text.get(13,id)
      end
      return Text.get(13,0)
    end
    #===
    #>icon : Icone dans le menu d'un objet
    #===
    def self.icon(id)
      if(id.between?(1, LastID))
        return $game_data_item[id].icon
      end
      return NoIcon
    end
    #===
    #>price : Prix d'un objet en magasin
    #===
    def self.price(id)
      if(id.between?(1, LastID))
        return $game_data_item[id].price
      end
      return 0
    end
    #===
    #>socket : Poche dans le sac
    #===
    def self.socket(id)
      if(id.between?(1, LastID))
        return $game_data_item[id].socket
      end
      return 0
    end
    #===
    #>battle_usable? : Utilisable en combat ?
    #===
    def self.battle_usable?(id)
      if(id.between?(1, LastID))
        return $game_data_item[id].battle_usable
      end
      return false
    end
    #===
    #>map_usable? : Utilisable en map ?
    #===
    def self.map_usable?(id)
      if(id.between?(1, LastID))
        return $game_data_item[id].map_usable
      end
      return false
    end
    #===
    #>limited_use? : Utilisation limitée ?
    #===
    def self.limited_use?(id)
      if(id.between?(1, LastID))
        return $game_data_item[id].limited
      end
      return true
    end
    #===
    #>holdable? : Portable par un Pokémon ?
    #===
    def self.holdable?(id)
      if(id.between?(1, LastID))
        return $game_data_item[id].holdable
      end
      return false
    end
    #===
    #>soldable? : Revendable
    #===
    def self.soldable?(id)
      if(id.between?(1, LastID))
        return $game_data_item[id].soldable
      end
      return false
    end
    #===
    #>on_pokemon_usable? : Utilisable sur un Pokémon
    #===
    def self.on_pokemon_usable?(id)
      if(id.between?(1, LastID))
        return $game_data_item[id].on_pokemon_usable
      end
      return false
    end
    #===
    #>check_able? : Vérifier l'aptitude à recevoir l'objet
    #===
    def self.check_able?(id)
      if(id.between?(1, LastID))
        return $game_data_item[id].able_mode
      end
      return false
    end
    #===
    #>use_string : string d'utilisation de l'objet
    #===
    def self.use_string(id)
      if(id.between?(1, LastID))
        return $game_data_item[id].use_string
      end
      return "L'objet #{id} n'est pas dans la base de données."
    end
    #===
    #>position : retourne la position ordonnée de l'objet dans le sac
    #===
    def self.position(id)
      if(id.between?(1, LastID) and $game_data_item[id].position)
        return $game_data_item[id].position
      end
      return 99999
    end
    #===
    #>heal_data : Retourne le data de soin si existant
    #===
    def self.heal_data(id)
      if(id.between?(1, LastID))
        return $game_data_item[id].heal_data
      end
      return nil
    end
    #===
    #>ball_data : Retourne le data de la Pokéball si c'en est une
    #===
    def self.ball_data(id)
      if(id.between?(1, LastID))
        return $game_data_item[id].ball_data
      end
      return nil
    end
    #===
    #>misc_data : Retourne le data autre si existant
    #===
    def self.misc_data(id)
      if(id.between?(1, LastID))
        return $game_data_item[id].misc_data
      end
      return nil
    end
  end
end
# Header: psdk.pokemonworkshop.com/index.php/ScriptHeader
# Author: Nuri Yuri
# Date: 2014
# Update: 2017-mm-dd
# ScriptNorm: No
# Description: Données relatives à la carte du Monde
module GameData
  class Map < Base
    attr_accessor :map_id, #ID de la map
    :map_name, #Nom de la map
    :panel_id, #ID du panneau
    :warp_x, #Téléportation x via Tunnel/Téléport ou Vol
    :warp_y, #Téléportation y via Tunnel/Téléport ou Vol
    :pos_x, #Position x de placement forcé du Héros dans la WorldMap
    :pos_y, #Position y de placement forcé du Héros dans la WorldMap
    :fly_allowed, #Indique si on peut voler ou faire tunnel
    :warp_dissalowed, #Indique si tout type de téléportation (vol/téléport/tunnel) sont autorisés
    :sub_map, #Maps pouvant être contenues dans l'objet en question
    :forced_weather, #Météo forcée
    :description, #Lignes de description
    :groups
    
    def initialize(map_id, panel_id=0, description=nil, warp_x=nil, warp_y=nil, sub_map=nil, pos_x=nil, pos_y=nil, fly_allowed=true, warp_dissalowed=false,forced_weather=nil)
      @map_id=map_id
      @map_name=nil
      @panel_id=panel_id
      @warp_x=warp_x
      @warp_y=warp_y
      @pos_x=pos_x
      @pos_y=pos_y
      @sub_map=sub_map
      @fly_allowed=fly_allowed
      @warp_dissalowed=warp_dissalowed
      @forced_weather=forced_weather
      @description=description
      @groups = []
    end
    
    def map_included?(map_id)
      if(@map_id.is_a?(Numeric))
        return @map_id == map_id
      end
      @map_id.include?(map_id)
    end
  end
end
# Header: psdk.pokemonworkshop.com/index.php/ScriptHeader
# Author: Nuri Yuri
# Date: 2014
# Update: 2015-mm-dd
# ScriptNorm: No
# Description: Données des Pokémon (statiques)
module GameData
  class Pokemon < Base
    attr_accessor :height, #Taille du Pokémon (m)
    :weight, #Poid du Pokémon (kg)
    :id_bis, #ID dans le dex régional
    :type1, #Premier type
    :type2, #Deuxième type
    #====Statistiques de base====#
    :base_hp, #HP
    :base_atk, #Attaque
    :base_dfe, #Défense
    :base_spd, #Vitesse
    :base_ats, #Attaque spéciale
    :base_dfs, #Défense spéciale
    #====EVs donnés en combat====#
    :ev_hp,
    :ev_atk,
    :ev_dfe,
    :ev_spd,
    :ev_ats,
    :ev_dfs,
    #>Autres données
    :move_set, #Skills apprenable [lvl,id,lvl,id...]
    :tech_set, #CTs apprennable
    :evolution_level, #Niveau d'évolution (nombre ou nil)
    :evolution_id, #ID du pokémon d'évolution
    :special_evolution, #évolution spéciale
    :exp_type, #Type de la courbe d'expérience
    :base_exp, #Expérience de base entrant en jeu dans le calcul de l'exp
    :base_loyalty, #Bonheur de base
    :rareness, #rareté du Pokémon
    :female_rate, #Taux de femelles, -1=assexué
    :abilities, #Capacités spéciales
    :breed_groupes, #Groupe de compatibilité (élevage)
    :breed_moves, #Capacités apprises en élevage
    :master_moves, #Capacités apprises par maitres des cap'
    :hatch_step, #Nombre de pas avant éclosion
    :items, #Objets portés naturellement  #[id, %, id, %]
    :baby, #ID de l'enfant
    :form
    def self.name(id)
      return GameData::Text.get(0,id)
    end
    def self.descr(id)
      return GameData::Text.get(2,id)
    end
    def self.species(id)
      return GameData::Text.get(1,id)
    end
    #===
    #>Récupération du data d'un Pokémon
    #===
    def self.get_data(id, form)
      return $game_data_pokemon[0][0] unless data = $game_data_pokemon[id]
      return data[0] unless data = data[form]
      return data
    end
    #===
    #> height :
    #===
    def self.height(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).height
      end
      return $game_data_pokemon[0][0].height
    end
    #===
    #> weight :
    #===
    def self.weight(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).weight
      end
      return $game_data_pokemon[0][0].weight
    end
    #===
    #> id_bis :
    #===
    def self.id_bis(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).id_bis
      end
      return $game_data_pokemon[0][0].id_bis
    end
    #===
    #> type1 :
    #===
    def self.type1(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).type1
      end
      return $game_data_pokemon[0][0].type1
    end
    #===
    #> type2 :
    #===
    def self.type2(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).type2
      end
      return $game_data_pokemon[0][0].type2
    end
    #===
    #> base_hp :
    #===
    def self.base_hp(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).base_hp
      end
      return $game_data_pokemon[0][0].base_hp
    end
    #===
    #> base_atk :
    #===
    def self.base_atk(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).base_atk
      end
      return $game_data_pokemon[0][0].base_atk
    end
    #===
    #> base_dfe :
    #===
    def self.base_dfe(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).base_dfe
      end
      return $game_data_pokemon[0][0].base_dfe
    end
    #===
    #> base_spd :
    #===
    def self.base_spd(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).base_spd
      end
      return $game_data_pokemon[0][0].base_spd
    end
    #===
    #> base_ats :
    #===
    def self.base_ats(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).base_ats
      end
      return $game_data_pokemon[0][0].base_ats
    end
    #===
    #> base_dfs :
    #===
    def self.base_dfs(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).base_dfs
      end
      return $game_data_pokemon[0][0].base_dfs
    end
    #===
    #> ev_hp :
    #===
    def self.ev_hp(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).ev_hp
      end
      return $game_data_pokemon[0][0].ev_hp
    end
    #===
    #> ev_atk :
    #===
    def self.ev_atk(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).ev_atk
      end
      return $game_data_pokemon[0][0].ev_atk
    end
    #===
    #> ev_dfe :
    #===
    def self.ev_dfe(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).ev_dfe
      end
      return $game_data_pokemon[0][0].ev_dfe
    end
    #===
    #> ev_spd :
    #===
    def self.ev_spd(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).ev_spd
      end
      return $game_data_pokemon[0][0].ev_spd
    end
    #===
    #> ev_ats :
    #===
    def self.ev_ats(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).ev_ats
      end
      return $game_data_pokemon[0][0].ev_ats
    end
    #===
    #> ev_dfs :
    #===
    def self.ev_dfs(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).ev_dfs
      end
      return $game_data_pokemon[0][0].ev_dfs
    end
    #===
    #> move_set :
    #===
    def self.move_set(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).move_set
      end
      return $game_data_pokemon[0][0].move_set
    end
    #===
    #> tech_set :
    #===
    def self.tech_set(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).tech_set
      end
      return $game_data_pokemon[0][0].tech_set
    end
    #===
    #> evolution_level :
    #===
    def self.evolution_level(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).evolution_level
      end
      return $game_data_pokemon[0][0].evolution_level
    end
    #===
    #> evolution_id :
    #===
    def self.evolution_id(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).evolution_id
      end
      return $game_data_pokemon[0][0].evolution_id
    end
    #===
    #> special_evolution :
    #===
    def self.special_evolution(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).special_evolution
      end
      return $game_data_pokemon[0][0].special_evolution
    end
    #===
    #> exp_type :
    #===
    def self.exp_type(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).exp_type
      end
      return $game_data_pokemon[0][0].exp_type
    end
    #===
    #> base_exp :
    #===
    def self.base_exp(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).base_exp
      end
      return $game_data_pokemon[0][0].base_exp
    end
    #===
    #> base_loyalty :
    #===
    def self.base_loyalty(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).base_loyalty
      end
      return $game_data_pokemon[0][0].base_loyalty
    end
    #===
    #> rareness :
    #===
    def self.rareness(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).rareness
      end
      return $game_data_pokemon[0][0].rareness
    end
    #===
    #> female_rate :
    #===
    def self.female_rate(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).female_rate
      end
      return $game_data_pokemon[0][0].female_rate
    end
    #===
    #> abilities :
    #===
    def self.abilities(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).abilities
      end
      return $game_data_pokemon[0][0].abilities
    end
    #===
    #> breed_groupes :
    #===
    def self.breed_groupes(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).breed_groupes
      end
      return $game_data_pokemon[0][0].breed_groupes
    end
    #===
    #> breed_moves :
    #===
    def self.breed_moves(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).breed_moves
      end
      return $game_data_pokemon[0][0].breed_moves
    end
    #===
    #> master_moves :
    #===
    def self.master_moves(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).master_moves
      end
      return $game_data_pokemon[0][0].master_moves
    end
    #===
    #> hatch_step :
    #===
    def self.hatch_step(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).hatch_step
      end
      return $game_data_pokemon[0][0].hatch_step
    end
    #===
    #> items :
    #===
    def self.items(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).items
      end
      return $game_data_pokemon[0][0].items
    end
    #===
    #> baby :
    #===
    def self.baby(id, form = 0)
      if id.between?(1, LastID)
        data = $game_data_pokemon[id]
        return(data[form] ? data[form] : data[0]).baby
      end
      return $game_data_pokemon[0][0].baby
    end
    
  end
end
# Header: psdk.pokemonworkshop.com/index.php/ScriptHeader
# Author: Nuri Yuri
# Date: 2014
# Update: 2015-mm-dd
# ScriptNorm: No
# Description: Structure de données des Attaques
module GameData
  class Skill < Base
    attr_accessor :map_use, #ID de l'évent commun à utiliser si utilisable en map
    :be_method, #Symbol de la méthode à appeler dans la BattleEngine pour attaquer
    :type, #Type de l'attaque
    :power, #Puissance de base de l'attaque
    :accuracy, #Précision de l'attaque
    :pp_max, #Points de pouvoir par défaut de l'attaque
    :target, #Cible que l'attaque peut prendre
    :atk_class, #Définie si elle est physique, spéciale ou statu
    :direct, #Indique si l'attaque est directe
    #:contact, #Indique si il y a contact avec l'ennemi != direct /Déprécié
    :critical_rate, #Indique le taux de coup critique
    :priority, #Indique la priorité par rapport aux autres attaques
    :blocable, #Indique si l'attaque est affecté par Abri/Détection
    :snatchable, #Indique si l'attaque est saisisable
    :gravity, #Indique si l'attaque est affecté par Gravité
    :magic_coat_affected, #Indique si l'attaque est affecté par reflet magik
    :mirror_move, #Indique si l'attaque est affecté par Mimique
    :unfreeze, #Indique si l'attaque dégèle
    :sound_attack, #Indique si l'attaque est du type sonore
    :king_rock_utility, #Indique si l'attaque est compatible avec Roche Royale
    :effect_chance, #Chance que l'effet se produise
    :battle_stage_mod, #Tableau des modifications du battle stage
    :status, #Statut infligeables (pour fonctionnement auto)
    
    :recoil_intencity, #Intencité du recul
    :punching, #Attaque du type coup de poing
    :self_destruct, #Attaque explosion ou destruction
    
    :none
    
    def self.name(id)
      if(id > 0 and id < $game_data_skill.size)
        return Text.get(6,id)
      end
      return "???"
    end
    
    SleepingAttack = [173, 214]
    def self.is_sleeping_attack?(id)
      SleepingAttack.include?(id)
    end
    
    #===
    #>Hors de portée
    # 1: tunel 2: vol 3:plongée 4:rebond 5:hantise 6:chute libre
    # [id_atk] = type
    #===
    OutOfReach = { 91 => 1, 19 => 2, 291 => 3, 340 => 4, 566 => 5, 467 => 5, 507 => 6}
    def self.get_out_of_reach_type(id)
      return OutOfReach[id]
    end
    #===
    #>Attaques touchant et étant doublés en OutOfReach
    #===
    OutOfReach_hit = [[], [89,92], [16, 239, 327, 92, 479], [57], [16, 327, 239, 479], [], [479]]
    def self.can_hit_out_of_reach?(oor, id)
      return OutOfReach_hit[oor].include?(id)
    end
    #===
    #>Phrase annoncée lors du chargement
    #===
    Announce_2turns = { 91 => 538, 19 => 529, 291 => 535, 340 => 544, 566 => 541, 467 => 541, 
    76 => 553, 130 => 556, 13 => 547, 553 => 866, 554 => 869, 601 => 1213, 143 => 550, 264 => 1213}
    def self.get_2turns_announce(id)
      return Announce_2turns[id]
    end
    #===
    #> map_use :
    #===
    def self.map_use(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].map_use
      end
      return $game_data_skill[0].map_use
    end
    #===
    #> be_method :
    #===
    def self.be_method(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].be_method
      end
      return $game_data_skill[0].be_method
    end
    #===
    #> type :
    #===
    def self.type(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].type
      end
      return $game_data_skill[0].type
    end
    #===
    #> power :
    #===
    def self.power(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].power
      end
      return $game_data_skill[0].power
    end
    #===
    #> accuracy :
    #===
    def self.accuracy(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].accuracy
      end
      return $game_data_skill[0].accuracy
    end
    #===
    #> pp_max :
    #===
    def self.pp_max(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].pp_max
      end
      return $game_data_skill[0].pp_max
    end
    #===
    #> target :
    #===
    def self.target(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].target
      end
      return $game_data_skill[0].target
    end
    #===
    #> atk_class :
    #===
    def self.atk_class(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].atk_class
      end
      return $game_data_skill[0].atk_class
    end
    #===
    #> direct :
    #===
    def self.direct(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].direct
      end
      return $game_data_skill[0].direct
    end
    #===
    #> critical_rate :
    #===
    def self.critical_rate(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].critical_rate
      end
      return $game_data_skill[0].critical_rate
    end
    #===
    #> priority :
    #===
    def self.priority(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].priority
      end
      return $game_data_skill[0].priority
    end
    #===
    #> blocable :
    #===
    def self.blocable(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].blocable
      end
      return $game_data_skill[0].blocable
    end
    #===
    #> snatchable :
    #===
    def self.snatchable(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].snatchable
      end
      return $game_data_skill[0].snatchable
    end
    #===
    #> gravity :
    #===
    def self.gravity(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].gravity
      end
      return $game_data_skill[0].gravity
    end
    #===
    #> magic_coat_affected :
    #===
    def self.magic_coat_affected(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].magic_coat_affected
      end
      return $game_data_skill[0].magic_coat_affected
    end
    #===
    #> mirror_move :
    #===
    def self.mirror_move(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].mirror_move
      end
      return $game_data_skill[0].mirror_move
    end
    #===
    #> unfreeze :
    #===
    def self.unfreeze(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].unfreeze
      end
      return $game_data_skill[0].unfreeze
    end
    #===
    #> sound_attack :
    #===
    def self.sound_attack(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].sound_attack
      end
      return $game_data_skill[0].sound_attack
    end
    #===
    #> king_rock_utility :
    #===
    def self.king_rock_utility(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].king_rock_utility
      end
      return $game_data_skill[0].king_rock_utility
    end
    #===
    #> effect_chance :
    #===
    def self.effect_chance(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].effect_chance
      end
      return $game_data_skill[0].effect_chance
    end
    #===
    #> battle_stage_mod :
    #===
    def self.battle_stage_mod(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].battle_stage_mod
      end
      return $game_data_skill[0].battle_stage_mod
    end
    #===
    #> status :
    #===
    def self.status(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].status
      end
      return $game_data_skill[0].status
    end
    #===
    #> recoil_intencity :
    #===
    def self.recoil_intencity(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].recoil_intencity
      end
      return $game_data_skill[0].recoil_intencity
    end
    #===
    #> punching :
    #===
    def self.punching(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].punching
      end
      return $game_data_skill[0].punching
    end
    #===
    #> self_destruct :
    #===
    def self.self_destruct(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].self_destruct
      end
      return $game_data_skill[0].self_destruct
    end
  end
end
# Header: psdk.pokemonworkshop.com/index.php/ScriptHeader
# Author: Nuri Yuri
# Date: 2014
# Update: 2014-mm-dd
# ScriptNorm: No
# Description: Structure des données des types des Pokémon
module GameData
  DefaultName = "???"
  class Type < Base
    attr_accessor :text_id, :on_hit_tbl
    def initialize(text_id,on_hit_tbl)
      #>Id du text à récuperer
      @text_id=text_id
      #>Table des multiplicateur quand il se fait touché par un type
      @on_hit_tbl=on_hit_tbl
    end
    
    def name
      return GameData::Text.get(3,@text_id) if @text_id>=0
      return DefaultName
    end
    
    def hit_by(type_id)
      return @on_hit_tbl[type_id]
    end
    
  end
end
module GameData
  class Quest < Base
    attr_accessor :items, #Liste des ids d'objet à trouver
    :item_amount, #Liste des nombre d'objet à trouver
    :speak_to, #Liste des nom de PNJ à qui parler
    :see_pokemon, #Liste des Pokémon à voir
    :beat_pokemon, #Liste des Pokémon à battre
    :beat_pokemon_amount, #Liste des nombre de Pokémon à battre
    :catch_pokemon, #Liste des Pokémon à capturer id ou hash
    :catch_pokemon_amount, #Liste des nombre de Pokémon à capturer
    :beat_npc, #Liste des noms des PNJ à battre
    :beat_npc_amount, #Nombre de fois à battre le NPC
    :get_egg_amount, #Nombre d'oeufs à obtenir
    :hatch_egg_amount, #Nombre d'oeufs à faire éclore
    :earnings, #Différentes choses en récompense
    :primary #Indique si la quête est principale
  end
end

module GameData
  module Text
    Available_Langs=["kana","en","fr","it","de","es","ko"]
    Translations = ["ja_JP", "en_US", "fr_FR", "it_IT", "de_DE", "es_ES", "ko_KR"]
    Names = [
      "PokemonNames.json",
      "PokemonSpecies.json",
      "PokemonDescriptions.json",
      "TypeNames.json",
      "AbilityNames.json",
      "AbilityDescriptions.json",
      "MoveNames.json",
      "MoveDescriptions.json",
      "NatureNames.json",
      "RegionNames.json",
      "LocationNames.json",
      "ShopTexts.json",
      "ItemNames.json",
      "ItemDescriptions.json",
      "MenuTexts.json",
      "SocketNames.json",
      "BoxNames.json",
      "CommonEventTexts.json",
      "BattleStrings.json",
      "BattleStrings2.json",
      "BattleMenuStrings.json",
      "MoveUsageTexts.json",
      "BagTexts.json",
      "PartyTexts.json",
      "MoveTutorTexts.json",
      "LoadGameTexts.json",
      "SaveGameTexts.json",
      "SumaryTexts.json",
      "SumaryInfoTexts.json",
      "TrainerClassNames.json",
      "PokemonCatchTexts.json",
      "EvolveTexts.json",
      "BattleUIStrings.json",
      "BoxManagementTexts.json",
      "TrainerCardTexts.json",
      "PokemonCenterTexts.json",
      "DaycareTexts.json",
      "HMTexts.json",
      "BerryTexts.json",
      "MapEventTexts.json",
      "BerryNames.json",
      "ThingGotTexts.json",
      "OptionTexts.json",
      "NamingTexts.json",
      "RibbonsNames.json",
      "QuestNames.json",
      "QuestDescriptions.json",
      "VictoryPhrases.json",
      "DefeatPhrases.json"
    ]
    Default_Lang_ID=0
    @langs=Array.new(Available_Langs.size)
    Object.const_set(:TextDataError,Class.new(RuntimeError))
    module_function
    def load
      load_all
    end
    
    def load_all(dir=nil)
      app_dir=(dir ? dir : App.get_dir)
      Available_Langs.each_index do |i|
        file_name="#{app_dir}Text/#{Available_Langs[i]}.dat"
        f=File.new(file_name,"r")
        @langs[i]=Marshal.load(Zlib::Inflate.inflate(Marshal.load(f)))
        f.close
      end
      
      return
      require "json/ext/parser"
      Names.each_with_index do |name, index|
        arr = Array.new
        (langs = @langs)[0][index].size.times do |text_id|
          hash = {id: text_id}
          Translations.each_with_index do |tr, lang_id|
            hash[tr] = langs[lang_id][index][text_id]
          end
        end
        File.binwrite(JSON.parse(arr))
      end
    end
    
    
    
    def get(file_id, text_id)
      return _get(App.lang_id, file_id, text_id)
    end
    
    def _get(lang_id, file_id, text_id)
      if(lang=@langs[lang_id])
        if(file=lang[file_id])
          if(text=file[text_id])
            return text
          else
            #raise TextDataError,"Unable to find text #{text_id} in file #{file_id} from lang #{Available_Langs[lang_id]}."
          end
        else
          # raise TextDataError,"File #{file_id} doesn't exist in lang #{Available_Langs[lang_id]}."
        end
      else
        # raise TextDataError,"Lang #{lang_id} does not exist."
      end
      return "No Text"
    end
    
    def save_all
      app_dir=App.get_dir
      Available_Langs.each_index do |i|
        file_name="#{app_dir}/Text/#{Available_Langs[i]}.dat"
        f=File.new(file_name,"wb")
        data=Marshal.dump(Zlib::Deflate.deflate(Marshal.dump(@langs[i])))
        f.write(data)
        f.close
      end
    end
    
    def get_text_file(lang_id,file_id)
      if(lang=@langs[lang_id])
        if(file=lang[file_id])
          return file
        else
          raise TextDataError,"File #{file_id} doesn't exist in lang #{Available_Langs[lang_id]}."
        end
      else
        raise TextDataError,"Lang #{lang_id} does not exist."
      end
    end
  end
end
module RPG
  class MapInfo
    def initialize
      @name = ""
      @parent_id = 0
      @order = 0
      @expanded = false
      @scroll_x = 0
      @scroll_y = 0
    end
    attr_accessor :name
    attr_accessor :parent_id
    attr_accessor :order
    attr_accessor :expanded
    attr_accessor :scroll_x
    attr_accessor :scroll_y
  end
end
# Header: psdk.pokemonworkshop.com/index.php/ScriptHeader
# Author: Nuri Yuri
# Date: 2015
# Update: 2017-07-31
# ScriptNorm: No
# Description: Gestion des classes de dresseurs
module GameData
  class Trainer < Base
    attr_accessor :base_money,
    :internal_names,
    :vs_type,
    :team,
    :battler,
    :special_group
    def initialize
      @base_money = 30
      @internal_names = ["Jean"]
      @vs_type = 1
      @team = []
      @battler = "001"
      @special_group = 0
    end
    
    def self.name(id)
      if $game_data_trainer.size > id and id > 0
        return GameData::Text.get(29, id)
      end
      return GameData::Text.get(29, 0)
    end
  end
end
#==> Datas RMXP
class RGSSO < Object
end
class Table < RGSSO
attr_accessor :dim, :x, :y, :z, :data
def initialize(bytes)
  @dim, @x, @y, @z, items, *@data = bytes.unpack('L5 S*')
  raise "Size mismatch loading Table from data" unless @x * @y * @z == items
  while(items > @data.length)
    @data << 0
  end
=begin
  raise "Size mismatch loading Table from data" unless items == @data.length
  raise "Size mismatch loading Table from data" unless @x * @y * @z == items
=end
end
def !=(v)
  return true if v.class != Table
  return true if @dim != v.dim
  return true if @x != v.x
  return true if @y != v.y
  return true if @z != v.z
  return true if @data != v.data
  return false
end
alias neq !=
def self._load(bytes)
Table.new(bytes)
end
def _dump(*ignored)
  return [@dim, @x, @y, @z, @x * @y * @z, *@data].pack('L5 S*')
end
def instance_variables
[]
end
end
class Rect < RGSSO
attr_accessor :x, :y, :width, :height
def initialize(bytes)
  @x, @y, @width, @height = *bytes.unpack('i4')
end
def !=(v)
  return true if v.class != Rect
  return true if @x != v.x
  return true if @y != v.y
  return true if @width != v.width
  return true if @height != v.height
  return false
end
alias neq !=
def self._load(bytes)
  Rect.new(bytes)
end
def _dump(*ignored)
  return [@x, @y, @width, @height].pack('i4')
end
def instance_variables
[]
end
end
class Tone < RGSSO
attr_accessor :r, :g, :b, :a
def initialize(bytes)
  @r, @g, @b, @a = *bytes.unpack('D4')
end
def !=(v)
  return true if v.class != Tone
  return true if @r != v.r
  return true if @g != v.g
  return true if @b != v.b
  return true if @a != v.a
  return false
end
alias neq !=
def self._load(bytes)
  Tone.new(bytes)
end
def _dump(*ignored)
  return [@r, @g, @b, @a].pack('D4')
end
def instance_variables
[]
end
end
class Color < RGSSO
attr_accessor :r, :g, :b, :a
def initialize(bytes)
  @r, @g, @b, @a = *bytes.unpack('D4')
end
def !=(v)
  return true if v.class != Tone
  return true if @r != v.r
  return true if @g != v.g
  return true if @b != v.b
  return true if @a != v.a
  return false
end
alias neq !=
def self._load(bytes)
  Tone.new(bytes)
end
def _dump(*ignored)
  return [@r, @g, @b, @a].pack('D4')
end
end