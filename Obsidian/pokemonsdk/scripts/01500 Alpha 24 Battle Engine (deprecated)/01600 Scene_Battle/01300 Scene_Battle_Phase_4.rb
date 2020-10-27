#encoding: utf-8

#noyard
# Description: Définition de la phase d'action du combat
class Scene_Battle
  #===
  #>start_phase4
  #Lancement de la phase 4, initialisation de plusieurs choses
  #===
  def start_phase4
    @a_remaining_pk.visible = false
    @e_remaining_pk.visible = false if $game_temp.trainer_battle
    @exp_distributed = false
    @phase = 4
    # Incrémentation du nombre de tours
    $game_temp.battle_turn += 1
    # Mise à jour des pages d'évent
    for index in 0...$data_troops[@troop_id].pages.size
      # イベントページを取得
      page = $data_troops[@troop_id].pages[index]
      # このページのスパンが [ターン] の場合
      if page.span == 1
        # 実行済みフラグをクリア
        $game_temp.battle_event_flags[index] = false
      end
    end
#    $game_temp.battle_main_phase = true #nécessaire ?
    @enemy_actions.clear #Vidage des actions de l'ennemi
    #Test IA
    @enemy_actions+=PFM::IA.start
    #>Sécurité
    BattleEngine::set_actors(@actors)
    BattleEngine::set_enemies(@enemies)
    # Tri de l'odre d'execution des actions
    @actions = BattleEngine::_make_action_order(@actor_actions, @enemy_actions, @actors, @enemies)
    launch_phase_event(4,true)
    phase4_mega_evolve
    unless $game_switches[::Yuki::Sw::BT_HardExp]
      $game_temp.vs_type.times do |i|
        if(@actors[i] and !@actors[i].dead?)
          @actors[i].battle_turns += 1
        end
      end
    end
  end
  # Manage all mega evolution
  def phase4_mega_evolve
    BattleEngine.each_prepared_mega_evolve do |pokemon, bag|
      tool_name = BattleEngine.mega_tool_name(bag)
      BattleEngine._msgp(19, 1165, pokemon, 
        PKNICK[0] => pokemon.given_name, ITEM2[2] => pokemon.item_name,
        TRNAME[1] => pokemon.trainer_name, ITEM2[3] => tool_name
      )
      # Animation
      pokemon.mega_evolve
      BattleEngine._mp([:switch_form, pokemon])
      BattleEngine._mp([:refresh_bar, pokemon])
      BattleEngine._msgp(19, 1168, pokemon, PKNICK[0] => pokemon.given_name, PKNAME[1] => pokemon.name)
    end
    phase4_message_display
  end
  #===
  #>update_phase4
  #Mise à jour de la phase 4 : affichage des actions
  #===
  def update_phase4
    #Si la phase arrive à son terme
    if @phase4_step>=@actions.size
      end_turn_actions

      #"Netoyage" des effets
      clean_effect($actors)
      clean_effect(@enemy_party.actors)
      phase4_message_display
      @a_remaining_pk.visible = true
      @e_remaining_pk.visible = true if $game_temp.trainer_battle
      @a_remaining_pk.redraw
      @e_remaining_pk.redraw if $game_temp.trainer_battle
      _phase4_switch_check
      return if $game_temp.in_battle == false
      setup_battle_event unless judge  #>23/07/2014 (unless judge)
      return if interpreter_running_check or judge
      start_phase2
      return
    #Si on est au début de tours executer les actions qui se déroulent au début :d
    elsif @phase4_step==0
      begin_turn_actions
    end
    return if judge
    #Afficher le bonne action
    case @actions[@phase4_step][0]
    when 0 #Attaquer
      phase4_attack(@actions[@phase4_step])
    when 1 #Utiliser objet
      phase4_use_item(@actions[@phase4_step])
    when 2 #Changer de Pokémon
      phase4_switch_pokemon(@actions[@phase4_step])
    when 3
      if ::BattleEngine._can_switch(@actions[@phase4_step][1])
        ::BattleEngine._msgp(19, 767, @actions[@phase4_step][1])
        phase4_message_display
        $game_system.se_play($data_system.escape_se)
        battle_end(1)
        return
      else
        ::BattleEngine._msgp(19, 878, @actions[@phase4_step][1])
      end
    end
    _phase4_switch_check
    return unless $game_temp.in_battle
    #Incrémentation de l'étape de phase 4
    @phase4_step+=1
  end
  #===
  #>Utilisation d'un objet
  # Tableau de l'objet : 
  # [1, [item_id, extend_data, pokemon_position or false]
  #===
  def phase4_use_item(action, readd = false)
    data = action[1]
    item_id = data[0]
    extend_data = data[1]
    position = data[2]
    if(readd) #>Réajout
      $bag.add_item(item_id,1) if(!position or position >= 0) and not extend_data[:ball_data] # Patch sur cette ligne pour éviter un glitch de ball récupérée en double en cas de ball déviée suivi d'une fuite.
      return
    end
    unless extend_data[:ball_data]
      #> Récupération du nom (à améliorer)
      tname = position < 0 ? @trainer_names[-position-1] : $trainer.name
      ::BattleEngine._msgp(18, 34, nil, ::PFM::Text::ITEM2[1] => GameData::Item[item_id].name, TRNAME[0] => tname)
    end
    if(position)
      pkmn = position < 0 ? @enemies[-position - 1] : @actors[position]
      if(extend_data[:skill_selected])
        extend_data[:action_to_push].call(pkmn, pkmn.skills_set[extend_data[:skill_selected]])
      else
        extend_data[:action_to_push].call(pkmn)
      end
      phase4_message_display
    elsif(extend_data[:action_to_push])
      extend_data[:action_to_push].call
      phase4_message_display
    elsif(extend_data[:ball_data])
      # Nuzlocke poke limit
      if $pokemon_party.nuzlocke.enabled? && $pokemon_party.nuzlocke.catching_locked_here?
        unless $scene.enemy_party.actors[0].shiny
          display_message(ext_text(8999, 20)) # You can't catch anymore pokemon here
          @player_choice_ui&.visible = true
          @action_selector&.visible = true
          $bag.add_item(item_id, 1)
          @phase4_step += 1
          return
        end
      end
      $scene.message_window.blocking = false # Auto scrolling ball throw message
      # In 4G, it was "[Player] throw a [Ball]!". Among the existing strings, the (18, 34) is the one that comes closest
      # to it.
      msg = parse_text(18, 34, TRNAME[0] => $trainer.name, ITEM2[1] => GameData::Item[item_id].name)
      display_message(msg) # It will give "[Player] use [Ball]!" in place.
      $scene.message_window.blocking = true if $game_temp.trainer_battle == false
      phase4_try_to_catch_pokemon(extend_data[:ball_data], item_id)
    end
  end
  #===
  #>Changer de pokemon
  #===
  def phase4_switch_pokemon(action)
    current_pokemon=action[2]
    #>On récupère les informations nécessaires
    if(action[1]<0)
      actors = @enemies
      enemies = @actors
      return if !actors[current_pokemon]
      new_pokemon = -action[1]-1
      hash1 = {TRNAME[0] => @trainer_names[current_pokemon].to_s, 
      PKNICK[1] => actors[current_pokemon].given_name}
      msg1 = 32
      hash2 =  {TRNAME[0] => @trainer_names[current_pokemon].to_s, 
      PKNICK[1] => actors[new_pokemon].given_name}
      msg2 = 18
      @enemy_fought << actors[new_pokemon] unless @enemy_fought.include?(actors[new_pokemon])
    else
      actors = @actors
      enemies = @enemies
      return if !actors[current_pokemon]
      new_pokemon = action[1]
      hash1 = {PKNICK[0] => actors[current_pokemon].given_name}
      msg1 = 26 + actors[current_pokemon].hp % 5
      hash2 =  {PKNICK[0] => actors[new_pokemon].given_name}
      msg2 = 22 + actors[new_pokemon].hp % 2
    end
    #>Empêcher le switch par mort pendant le déroulement
    return if @phase4_step<@actions.size and actors[current_pokemon].dead?
    cc 0x20
    pc "Switch #{current_pokemon} #{new_pokemon}\n#{actors.join("|")}"
    cc 0x07
    #>Switch des Pokémon dans leur tableau d'équipe
    actors[new_pokemon], actors[current_pokemon] =
    (last_pokemon=actors[current_pokemon]), (next_pokemon=actors[new_pokemon])
    #>Recalibrage des données du pokémon envoyé
    next_pokemon.reset_stat_stage
    next_pokemon.form_calibrate
    next_pokemon.battle_effect.reset
    $pokedex.mark_seen(next_pokemon.id,next_pokemon.form)
    #>Affichage des messages
    if(last_pokemon.hp>0)
      last_pokemon
      action
      display_message(parse_text(18, msg1, hash1)) unless @_NoChoice[last_pokemon]
      gr_callback_pokemon(last_pokemon)
    end
    next_pokemon.position = last_pokemon.position
    #>Variation du message
    if(@_NoChoice[last_pokemon])
      display_message(parse_text_with_pokemon(19, 848, next_pokemon))
    else
      display_message(parse_text(18, msg2, hash2))
    end
    last_pokemon.position=nil
    last_pokemon.battle_effect.switch_with(next_pokemon)
    gr_launch_pokemon(next_pokemon)
    switch_turn_actions(actors,enemies,new_pokemon,current_pokemon)
  end
  #===
  #>Gestion de l'attaque
  #===
  def phase4_attack(action)
    i = nil
    tmp_target = nil
    #AFAIRE !
    #Faire la vérification pour action[2]>=2 (choix du pokémon d'à coté) et <=-3

    return unless action[3].position
    #<Selection de la cible
    #> Cas de l'attaque forcé
    if action[2].is_a?(Integer)
      if(action[2] < 0)
        target = [@actors[-action[2]-1]]
      else
        target = [@enemies[action[2]]]
      end
    #> Liste des cibles
    else
      target = action[2]

      #> Correction des cibles
      if target
        target.each_index do |i|
          tmp_target = target[i]
          target[i] = tmp_target.battle_effect.switched_with if tmp_target.position == nil
        end
      end
    end
    
    #<Mise à jour de l'état du BattleEngine
    BattleEngine::_State_sub_update
    #<Récupération de l'attaquant
    @_launcher = (action[3].position<0 ? @enemies[-action[3].position-1] : @actors[action[3].position])
    #> Retour en cas de mort du lanceur
    return if @_launcher.dead?
    #< Reset du flee attempt 
    @flee_attempt = 0 if @_launcher.position >= 0
    #<Récupération du skill
    if(action[1])
      @_skill = action[3].ss(action[1])
      if(@_launcher.battle_effect.has_taunt_effect? and @_skill.status?)
        display_message(parse_text_with_pokemon(19, 571, action[3], 
        BattleEngine::MOVE[1] => @_skill.name))
        return
      end
      #<< Utilité de la ligne suivante ?
      #target = action[3] if @_skill.target == :user or @_skill.target == :none
    else
      @_skill = PFM::Skill.new(BattleEngine::ID_Struggle)
    end

    #> On vérifie les cibles et on rechoisit en cas de problème
    return if target.size == 0
    alive_target = 0
    target.each do |i|
      alive_target += 1 unless i.dead?
    end
    if alive_target == 0
      target = util_targetselection_automatic(@_launcher, @_skill)
    end
    
    #> Recheck de la cible
    #<petite partie concernant le tour de repos
    if @_launcher.battle_effect.must_reload
      display_message(parse_text_with_pokemon(19, 851, @_launcher))
      @_launcher.battle_effect.set_reload_state(false)
      return
    else #> Si le lanceur ne doit pas se reposer
      if($game_switches[::Yuki::Sw::BT_HardExp])
        #Incrément du nombre de tours
        @_launcher.battle_turns+=1
      end
      #> Vérification des status et de la possibilité d'attaquer
      can_attack = BattleEngine.battler_can_attack?(@_launcher,@_skill)
      ::PFM::Text.reset_variables
      phase4_message_display
      unless can_attack
        if(@_skill.id == 37) #>Mania
          @_launcher.battle_effect.thrash_incomplete = true
        elsif(@_skill.id == 117)
          if(@_launcher.asleep?)
            @_launcher.battle_effect.get_bide_power
            @_launcher.battle_effect.apply_forced_attack(0, 0, target[0])
          else
            @_launcher.battle_effect.inc_forced_attack_counter
          end
        end
        return
      end
    end
    #> Mise à jour du nombre d'utilisation de l'attaque
    if(@_skill.id == @_launcher.last_skill)
      @_launcher.skill_use_times += 1
    else
      @_launcher.skill_use_times = 0
    end
    mind_reader = @_launcher.battle_effect.has_mind_reader_effect?
    #> Variable indiquant l'affichage ou non de l'attaque
    display_atk = true

    #> Application de l'attaque sur toute les cibles
    BattleEngine::use_skill(@_launcher, target, @_skill)

    @_launcher.last_skill = @_skill.id

    #Interpretation du BattleEngine
    phase4_message_display

    #Lire-Esprit
    @_launcher.battle_effect.apply_mind_reader(nil) if mind_reader
    @_launcher=nil if @actions[@phase4_step] == action #> Métronome & co

    #Refresh forcé des barres
    @actor_bars.each { |i| i.refresh }
    @enemy_bars.each { |i| i.refresh }
    @_skill.used = true #> On indique que l'attaque a été utilisée
  end
end
