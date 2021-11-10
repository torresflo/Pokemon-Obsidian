#encoding: utf-8

#noyard
# Description: Définition des fonctions utiles au lancement du combat et à l'interface Event <-> Combat
class Scene_Battle
  DefaultNames = ["Dresseur","Dresseuse"]
  DefaultVictoryPhrase = "Ahahah ! Je suis victorieux !"
  DefaultDefeatPhrase = "Bien joué."
  #===
  #>init_trainer_battle
  # Méthode d'initialisation d'un combat de dresseur
  #===
  def init_trainer_battle(actor_cnt = 1)
    #> Récupération des données du dresseur
    id = $game_variables[::Yuki::Var::Trainer_Battle_ID]
    id = 0 unless GameData::Trainer.id_valid?(id)
    @trainer_class = id
    data = GameData::Trainer.get(id)
    #> Initialisation des variables du combat
    $game_temp.vs_actors = actor_cnt
    $game_temp.vs_enemies = 1
    $game_temp.vs_type = data.vs_type
    $game_temp.enemy_battler = [data.battler]
    $game_temp.trainer_battle = true
    @actors = $actors.clone
    __sort_actors
    @victory_phrase = text_get(47, id)
    @defeat_phrase = text_get(48, id)
    @trainer_names = data.internal_names
    @troop_id = data.special_group if data.special_group and data.special_group > 5
    #> Configuration des Pokémon du dresseur
    enemy_party = @enemy_party.actors
    enemy_party.clear
    data.team.each do |hash|
      next unless hash.class == Hash
      enemy_party << (pokemon = PFM::Pokemon.generate_from_hash(hash))
      # Remove moves that are 0
      if $game_switches[Yuki::Sw::BT_NO_MOVE_WHEN_DEFAULT] && !hash[:moves].all?(&:zero?)
        hash[:moves].each_with_index do |m, index|
          pokemon.skills_set[index] = nil if m == 0
          pokemon.skills_set.compact!
        end
      end
      next
    end
    raise "Aucun Pokémon n'a été trouvé dans ce combat de dresseur..." if enemy_party.size == 0
  end
  #===
  #>setup_battle
  #Méthode initialisant le combat
  #type : 1 = 1v1 2=2v2
  #actor_cnt : défini le nombre d'actor pour l'affichage au début
  #enemy_cnt : défini le nombre d'enemy pour l'affichage au début
  #battlers défini les battlers de dresseurs, si cette argument contient quelque chose
  # ça sera un combat de dresseur, sinon un combat de Pokémon sauvage.
  #===
  def setup_battle(type,actor_cnt,enemy_cnt,*battlers)
    $game_temp.vs_actors=actor_cnt
    $game_temp.vs_enemies=enemy_cnt
    $game_temp.vs_type=type
    $game_temp.enemy_battler=battlers
    $game_temp.trainer_battle=(battlers.size>0)
    @actors=$actors.clone
    __sort_actors
    @victory_phrase = DefaultVictoryPhrase unless @victory_phrase
    @defeat_phrase = DefaultDefeatPhrase unless @defeat_phrase
    @trainer_names = DefaultNames unless @trainer_names
    @trainer_class = 0 unless @trainer_class
  end
  #===
  #>configure_ids
  #Méthode permettant de redéfinir de manière barbare les ids des Pokémons du groupe
  #si un argument est nil ou false, l'id n'est pas redéfini
  #===
  def configure_ids(*args)
    args.size.times do |i|
      pkmn=$data_troops[@troop_id].members[i]
      next unless pkmn
      id=args[i]
      next unless id
      pkmn.enemy_id=id
    end
  end
  #===
  #>configure_pokemons
  #Méthode permettant de configurer les pokémons selon des paramètres spécifiques
  #Si l'argument n est un Hash c'est une définition complète, sinon c'est le niveau.
  #===
  def configure_pokemons(*args)
    #>Préparation talent
    @select_pokemon_chances = Array.new(args.size, 1)
    ability = $actors[0].ability
    #>Préparation Pokémon
    enemy_party = @enemy_party.actors
    repel_active = $pokemon_party.repel_count > 0
    args.size.times do |i|
      pkmn_id=$data_troops[@troop_id].members[i]
      next unless pkmn_id
      pkmn_id=pkmn_id.enemy_id
      if(args[i].is_a?(Integer))
        enemy_party[i]=PFM::Pokemon.new(pkmn_id,args[i])
      else
        arg=args[i]
        arg[:id] = pkmn_id unless arg[:id]
        arg = enemy_party[i] = PFM::Pokemon.generate_from_hash(arg)
      end
      enemy_party[i].trainer_name=@trainer_names[$game_temp.vs_type==1 ? 0 : i % $game_temp.vs_type]
      #> Action des talents
      case ability
      when 11, 7#> Intimidation / Regard vif
        @select_pokemon_chances[i] = 0.5 if (enemy_party[i].level+5) < $actors[0].level
      when 16 #> Joli Sourire
        @select_pokemon_chances[i] = 1.5 if ($actors[0].gender * enemy_party[i].gender) == 2
      when 92 #> Magnépiège
        @select_pokemon_chances[i] = 1.5 if enemy_party[i].type_steel?
      when 5 #> Œil Composé
        @select_pokemon_chances[i] = 1.5 if enemy_party[i].item_holding != 0
      when 12 #> Statik
        @select_pokemon_chances[i] = 1.5 if enemy_party[i].type_electric?
      when 33 #> Synchro
        @select_pokemon_chances[i] = 1.5 if enemy_party[i].nature_id == $actors[0].nature_id
      end
      if enemy_party[i].level < $actors[0].level
        @select_pokemon_chances[i] *= 0.33 if $actors[0].item_db_symbol == :cleanse_tag
        @select_pokemon_chances[i] = 0 if repel_active
      end
    end
  end
  #===
  #>select_pokemon
  #Méthode permettant de choisir aléatoirement les Pokémons sauvage
  #L'écart var définir la plage de niveau des Pokémons, le milieu est leur niveau défini
  #===
  MaxEcart = [74, 30, 72] #> Agitation / Esprit Vital / Pression
  def select_pokemon(ecart,*rareness)
    return if $game_temp.trainer_battle
    max_rand = 0
    i = nil
    rareness.each_index do |i|
      @select_pokemon_chances[i] ||= 1
      max_rand += rareness[i]*@select_pokemon_chances[i]
    end
    selected=[]
    $game_temp.vs_type.times do |i|
      nb = Random::WILD_BATTLE.rand(max_rand.to_i) #rand(max_rand.to_i)
      puts "Generated number : #{nb} / #{max_rand.to_i}"
      count=0
      rareness.each_index do |j|
        count+=(rareness[j]*@select_pokemon_chances[j])
        if nb<count
          selected.push(@enemy_party.actors[j].clone)
          break
        end
      end
      selected.push(@enemy_party.actors[rand(@enemy_party.actors.size)].clone) if selected.size <= i
    end
    @enemy_party.actors.clear
    $game_temp.vs_type.times do |i|
      @enemy_party.actors.push(selected[i])
      if MaxEcart.include?($actors[0].ability) and rand(100) < 50
        lvl=selected[i].level-ecart/2+ecart-1
      else
        lvl=selected[i].level-ecart/2+rand(ecart)
      end
      lvl = 1 if lvl < 1
      selected[i].level=lvl
      selected[i].captured_level = lvl
      selected[i].exp=selected[i].exp_list[lvl]
      selected[i].hp=selected[i].max_hp
    end
  end
  #===
  #>set_trainer_names
  #Méthode définissant le nom des dresseurs adverses
  #===
  def set_trainer_names(*args)
    @trainer_names=args
  end
  #===
  #>set_trainer_phrases
  # Ajouter les phrase dites par le dresseur en fonction de son résultat
  #===
  def set_trainer_phrases(victory_phrase, defeat_phrase)
    @victory_phrase = victory_phrase
    @defeat_phrase = defeat_phrase
  end
  #===
  #>set_trainer_class
  # Définition de la classe du dresseur
  #===
  def set_trainer_class(class_id)
    @trainer_class = class_id if GameData::Trainer.id_valid?(class_id)
  end
  #===
  #>display_message
  #Méthode permettant d'afficher un message et par la même occation
  #de proposer un choix.
  #===
  def display_message(str,let=true,start=1,*choices)
#    str = @message_window.contents.multiline_calibrate(str)
    $game_temp.message_text=str.clone
    b=true
    $game_temp.message_proc=Proc.new{b=false}
    c=nil
    if(choices.size>0)
      $game_temp.choice_max=choices.size
      $game_temp.choice_cancel_type=choices.size
      $game_temp.choice_proc=Proc.new{|i|c=i}
      $game_temp.choice_start=start
      $game_temp.choices=choices
    end
    @message_window.wait_input=let
    while b
      Graphics.update
      update_animated_sprites
      @message_window.update
    end
    @message_window.update #unless let
    Graphics.update
    update_animated_sprites
    return c
  end
  #===
  #>launch_phase_event
  #Méthode permettant d'activer l'évennement de combat en rapport avec la phase
  #courrante (id_phase)
  #L'argument is_updating indique si la phase est dans la mise à jour ou son lancement
  #===
  def launch_phase_event(id_phase,is_updating=false)
    return if $game_system.battle_interpreter.running?
    if id_phase<6
      id_phase=SWs_ID_Phase[id_phase]
    end
    $game_switches[id_phase]=true
    $game_switches[Yuki::Sw::BT_PhaseUpdate]=is_updating
    @message_window.wait_input = true
    setup_battle_event
    $game_switches[id_phase]=false
  end
  #===
  #>add_money : distribue l'argent
  #===
  def add_money(n=nil)
    unless n
      n=0
      @enemy_party.actors.each do |i|
        n+=i.level if i
      end
      n*=25
    end
    n+=@money
    $game_temp.vs_type.times do |i|
      pkmn=@actors[i]
      #>Piece rune / Encens veine
      if(pkmn && (pkmn.item_hold == 223 || pkmn.item_hold == 319))
        n *= 2
        break
      end
    end
    #> Happy Hour (Etrennes) effect
    n *= 2 if BattleEngine.state[:happy_hour]
    $pokemon_party.add_money(n)
    return n
  end
  #===
  #>get_poke_info : récupère les informations d'un Pokémon
  # position: Position du Pokémon 0:Actor_1 (-1):Enemy_1
  # id_var:Variable de jeu qui recevera l'info
  # sym_1:Info voulue
  # sym_2:Si il y a besoins d'autres info (0 par défauts)
  #===
  def get_poke_info(position,id_var,sym_1,sym_2=0,*args)
    pkm=(position<0 ? @enemies[-position-1] : @actors[position])
    info=0
    return unless pkm
    case sym_1
    when :hp #>Retourne les HP d'un pokémon
      info=pkm.hp
    when :max_hp #>Retourne les HP Max d'un Pokémon
      info=pkm.max_hp
    when :name #>Retourne le nom d'un Pokémon
      info=pkm.name
    when :given_name #>Retourne le nom donné d'un Pokémon
      info=pkm.given_name
    when :atk_name #>Retourne le nom d'une attaque
      info=pkm.skills_set[sym_2].name if(pkm.skills_set[sym_2])
    when :atk_pp #>Retourne les PP d'une attaque
      info=pkm.skills_set[sym_2].pp if(pkm.skills_set[sym_2])
    when :atk_ppmax #>Retourne les PP max d'une attaque
      info=pkm.skills_set[sym_2].ppmax if(pkm.skills_set[sym_2])
    when :atk_power #>Retourne la puissance d'une attaque
      info=pkm.skills_set[sym_2].power if(pkm.skills_set[sym_2])
    when :atk_name #>Retourne le nom d'une attaque
      info=pkm.skills_set[sym_2].name if(pkm.skills_set[sym_2])
    when :battle_stage #>Retourne l'état du battle_stage d'un Pokémon
      info=pkm.battle_stage[sym_2]
    when :send #>Appel d'une méthode (Expert !)
      info=pkm.send(sym_2,*args)
    end
    $game_variables[id_var]=info
  end
  #===
  #>Sort actors : Trier les actors en fonction de leur état
  #===
  def __sort_actors
    actors = @actors.clone
    pkmn = nil
    actors.delete_if { |pkmn| !pkmn.dead? }
    @actors.delete_if { |pkmn| pkmn.dead? }
    @actors+=actors
  end
end
