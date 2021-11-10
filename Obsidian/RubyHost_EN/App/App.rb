#encoding: utf-8
#===
#>Module de gestion interne de toute l'application
#---
# © 2014 - Nuri Yuri (塗 ゆり) Ecriture du script
#===
module App
  #>Définition des boutons
  Button=[-1,1011,1012,1013,1014,1015,1016,1017,1018,1019,1020, 1108, 1112, 1114, 1115]
  #>Définition des images
  Images=[-1,110]
  #>Définition des champs d'édition
  Edit=[-1,1031,1033,1034,1035,1036,1037,1038,1039,1040,1041,
  1084,1085,1086,1087,1088,1089,1090,1091,1092,1093,1094,1095,
  1096,1097,1098,1099,1101]
  #>Définition des combos
  Combo=[-1,1042,1043,1044,1045,1046,1047,1048,1049,1050,1051,1109,1110, 1113]
  #>Définition des radio button
  Radio=[-1,1052,1053,1054,1055,1056,1057,1058,1059,1060,1061]
  #>Définition des check box
  Check=[-1,1021,1022,1023,1024,1025,1026,1027,1028,1029,1030]
  #>Définition des spins
  Spin=[-1,1062,1063,1064,1065,1066,1067,1068,1069,1070,1071]
  #>Définition des listes
  List=[-1,1104,1105,1106,1107]
  #>Définition des dialogues
  Dialogs={:main=>130, #Dialog principal
  :pokemon=>131, #Edition des Pokémon
  :type=>132, #Edition des types
  :atk=>133, #Edition des attaques
  :text=>134, #Edition des textes
  :atk_pk=>135, #Edition des attaques du Pokémon
  :debug => 136, #Debug du jeu
  :objets => 137, #Objets
  :item_heal => 138, #Soins
  :item_ball => 139, #Balles
  :item_misc => 140, #Données autres
  :zone => 141, #Edition des Zones
  :ct_pk => 142, #Edition des ct, breedmoves, et objet porté
  :team_edit => 143, #Edition des équipes
  :group_edit => 144,
  :normalizer => 146,
  :maplinks => 147,
  :quest => 148,
  :reserved=>129}
  
  #===
  #>Variables du module
  #===
  @dir=nil
  @poke_window=nil
  @warn_when_closing=true
  @current_path=File.expand_path(".")
  @lang=0
  module_function
  #===
  #>Getter et setter du répertoire de base de données
  #===
  def set_dir(dir)
    if try_to_load(dir)
      @dir=dir
      Kernel.set_ini("#{@current_path}/Ruby Host.ini")
      Kernel.set_string("App","LastProject",dir)
      @project_dir = dir.split("/")
      @project_dir.pop
      @project_dir = @project_dir.join("\\")+"\\"
    end
  end
  def get_dir
    return @dir
  end
  def get_file_name(filename = nil)
    if(filename)
      return @project_dir+filename
    else
      return @project_dir
    end
  end
  #===
  #>Getter et setter de la fenêtre d'édition des Pokémon
  #===
  def get_pokewindow
    return @poke_window
  end
  def set_pokewindow(wnd)
    @poke_window=wnd
  end
  #===
  #>Indique si le système doit alerter l'utilisateur lorsqu'il ferme une fenêtre
  #===
  def warn?
    return @warn_when_closing
  end
  #===
  #>Récupérer l'id de la langue
  #===
  def lang_id
    return @lang
  end
  
  def sort_alpha
    return false #> Pour éviter les problèmes (temporaire v2 #flemme)
    return @sort_alpha
  end
  #===
  #>Chargement des données (possibilité d'echec)
  #==
  def try_to_load(dir)
    dir.force_encoding("UTF-8")
    $game_data_pokemon=load_data("#{dir}PSDK/PokemonData.rxdata")
    $game_data_item=load_data("#{dir}PSDK/ItemData.rxdata")
    $game_data_skill=load_data("#{dir}PSDK/SkillData.rxdata")
    arr=load_data("#{dir}PSDK/MapData.rxdata")
    $game_data_zone = arr[1]
    $game_data_map = arr[0]
    $game_data_natures = load_data("#{dir}PSDK/Natures.rxdata")
    $game_data_types = load_data("#{dir}PSDK/Types.rxdata")
    $game_data_abilities = load_data("#{dir}PSDK/Abilities.rxdata")
    $mapinfos = load_data("#{dir}MapInfos.rxdata")
    $game_data_maplinks = load_data("#{dir}PSDK/Maplinks.rxdata")
    $game_data_quest = load_data("#{dir}PSDK/Quests.rxdata")
    $game_data_trainer = load_data("#{dir}PSDK/Trainers.rxdata")
    #$game_data_teams=load_data("#{dir}PSDK/Teams.rxdata")
    GameData::Text.load_all(dir)
    check_id_set(dir)
    return true
  rescue Exception
    DialogInterface::MessageBox(0,"Classe : #{$!.class}\r\nMessage : #{$!.message}\r\n\r\n#{$!.backtrace.join("\r\n")}","Echec du chargement",DialogInterface::Constants::MB_ICONERROR)
    return false
  end
  #===
  #> Calibration des ids des objets
  #===
  def check_id_set(dir)
    unless $game_data_zone[0].id
      $game_data_zone.each_with_index do |el, id|
        el.id = id
      end
      $game_data_pokemon.each_with_index do |pkarr, id|
        next unless pkarr.class == Array
        pkarr.each_with_index do |el, form|
          next unless el
          el.id = id
          el.form = form
        end
      end
      $game_data_item.each_with_index do |el, id|
        next if id == 0
        el.id = id
        if el.heal_data
          el.heal_data.id = id
        end
        if el.ball_data
          el.ball_data.id = id
        end
        if el.misc_data
          el.misc_data.id = id
        end
      end
      $game_data_skill.each_with_index do |el, id|
        next if id == 0
        el.id = id
      end
      $game_data_types.each_with_index do |el, id|
        next if id == 0
        el.id = id
      end
      $game_data_quest.each_with_index do |el, id|
        el.id = id
      end
      save_data($game_data_pokemon, "#{dir}PSDK/PokemonData.rxdata")
      save_data($game_data_item, "#{dir}PSDK/ItemData.rxdata")
      save_data($game_data_skill, "#{dir}PSDK/SkillData.rxdata")
      save_data([$game_data_map, $game_data_zone],"#{dir}PSDK/MapData.rxdata")
      save_data($game_data_types, "#{dir}PSDK/Types.rxdata")
    end
  end
  #===
  #>Chargement du data
  #===
  def load_data(filename)
    f=File.new(filename,"rb")
    data=Marshal.load(f)
    f.close
    return data
  end
  #===
  #>Sauvegarde
  #===
  def save_data(var,filename)
    f=File.new(filename,"wb")
    Marshal.dump(var,f)
    f.close
  end
  #===
  #>Chargement de la configuration
  #===
  def load_self_conf
    Kernel.set_ini("#{@current_path}/Ruby Host.ini")
    @warn_when_closing=get_int("App","Warn")==1
    @lang=(get_int("App","LangID") % GameData::Text::Available_Langs.size)
    @sort_alpha=get_int("App","SortAlpha")==1
    str=Kernel.get_string("App","LastProject")
    if(str and str.size>0)
      set_dir(str)
      #@dir=str if try_to_load(str)
    end
  end
end

class DialogInterface::DialogObject
  CommonSplt="("
  def get_id_from_list(arr, pos)
    str = arr[pos.to_i]
    if str
      return str.split(CommonSplt)[-1].to_i
    else
      return 0
    end
  end
end