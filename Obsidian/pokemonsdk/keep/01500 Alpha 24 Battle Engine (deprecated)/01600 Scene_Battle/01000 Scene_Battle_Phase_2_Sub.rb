#encoding: utf-8

#noyard
# Description: Définition de la phase de choix de l'action à réaliser
class Scene_Battle
  #===
  #> Lorsqu'on appuie sur A ou la souris dans la phase 2
  #===
  def on_phase2_validation
    @action_selector&.visible = false
    case @action_index
    when 0  #Attaquer
      $game_system.se_play($data_system.decision_se)
      @player_choice_ui&.visible = false
      launch_phase_event(3,false)
      @to_start = :start_phase3
    when 2  # Sac
      phase2_display_bag
    when 1 # Pokémon
      phase2_display_team
    when 3 # Fuite
      phase2_flee
    end
  end

  #===
  #> Affichage de l'interface du sac
  #===
  def phase2_display_bag
    $game_system.se_play($data_system.decision_se)
    Graphics.freeze
    @message_window.visible = false
    @player_choice_ui&.visible = false
    #> Appel interne de l'interface
    scene = GamePlay::Battle_Bag.new(@actors)
    scene.main
    return_data = scene.return_data
    #> Retour sur la scène de combat
    if return_data == -1
      @action_selector&.visible = true
      @player_choice_ui&.visible = true
    end
    @message_window.visible = true
    Graphics.transition
    @player_choice_ui&.reset
    #> Action s'il y a bien eu utilisation d'un objet
    if return_data != -1
      @actor_actions.push([1,return_data])
      $bag.remove_item(return_data[0],1)
      update_phase2_next_act
    end
  end

  #===
  #> Affichage de l'interface de l'équipe
  #===
  def phase2_display_team
    #> Si le Pokémon est bloqué on l'empêche de se faire switch
    unless BattleEngine::_can_switch(@actors[@actor_actions.size])
      $game_system.se_play($data_system.buzzer_se)
      @player_choice_ui&.visible = true
      return @action_selector&.visible = true
    end
    $game_system.se_play($data_system.decision_se)
    Graphics.freeze
    @player_choice_ui&.visible = false
    @message_window.visible = false
    #> Appel interne de l'interface
    scene = GamePlay::Party_Menu.new(@actors, :battle)
    scene.main
    return_data = scene.return_data
    if(@actor_actions[-1] and @actor_actions[-1][0]==2 and @actor_actions[-1][1]==return_data)
      return_data = -1
    end
    #> Retour à la scène de combat
    if return_data == -1
      @action_selector&.visible = true
      @player_choice_ui&.visible = true
    end
    @message_window.visible = true
    @player_choice_ui&.reset
    Graphics.transition
    #> Action s'il y a bien eu switch de Pokémon
    if return_data != -1
      @actor_actions.push([2,return_data,@actor_actions.size])
      update_phase2_next_act
    end
  end

  #===
  #> Action de fuite
  #===
  def phase2_flee
    $game_system.se_play($data_system.decision_se)
    #> Vérification de l'empêchement de fuite (blocage ou combat de dresseur)
    t = $game_temp.trainer_battle 
    if t or $game_switches[Yuki::Sw::BT_NoEscape]
      @player_choice_ui&.visible = false
      display_message(text_get(18,(t ? 79 : 77))) #"Vous ne pouvez pas fuire lors d'un combat de dresseur.")
      @action_selector&.visible = true
      start_phase2(@actor_actions.size)
      return
    end
    # Mise à jour de la phase de fuite
    update_phase2_escape
  end

  #===
  #> Calcul du facteur de fuite
  #===
  def phase2_flee_factor
    a = @actors[@actor_actions.size].spd_basis
    b = @enemies[0].spd_basis
    b = 1 if b <= 0
    c = @flee_attempt
    @flee_attempt += 1
    f = ( ( a * 128 ) / b + 30 * c) #% 256 #< Le modulo rend la fuite merdique :/
    pc "Flee factor : #{f}"
    return f
  end
end
