#encoding: utf-8

#noyard
# Description: Définition de la phase d'initialisation du combat
class Scene_Battle
  #===
  #>start_phase1
  #Phase de prébataille : Va lancer l'initilisation par évent du combat
  #===
  def start_phase1
    #>Mise à niveau du seed (Supprimer pour les relase !)
=begin
    if(self.class == Scene_Battle)
      v = Kernel.get_int("PokemonSDK","Seed")
      if v > 0
        pc "BattleSeed : #{v}"
        srand(v)
      end
    end
=end
    #<0
    $game_switches[Yuki::Sw::BT_Phase1]=true
    $game_switches[Yuki::Sw::BT_PhaseUpdate]=false
    BattleEngine::_State_reset
    # Passage à la phase 1
    @phase = 1
    # Vidage des actions des joueurs
#    $game_party.clear_actions #Est-ce utile ?
    # Mise en place des évents de combat
    setup_battle_event
    $game_switches[Yuki::Sw::BT_Phase1]=false
  end
  #===
  #>update_phase1
  #Mise à jour de la première phase : lance l'animation de début du combat
  #===
  def update_phase1
    return if judge
    # バトル BGM を演奏
    $game_system.bgm_play($game_system.battle_bgm)
    #L'équipe ennemie est normalement initialisée donc on clone le tableau d'ennemis
    @enemies=@enemy_party.actors.clone
    #Initialisation des effets des Pokémons
    (@actors+@enemies).each do |i|
      phase1_init_pokemon(i)
    end
    BattleEngine::set_actors(@actors)
    BattleEngine::set_enemies(@enemies)
    #Choix de l'intro
    if $game_temp.trainer_battle
      gr_start_train
    else
      gr_start_poke
    end
    launch_phase_event(1,true)
    #phase1_show_ability
    #La phase 2 sera lancée après la validation de l'interpreter phase1.update
    #@to_start=:start_phase2
    @to_start=:phase1_show_ability
  end
  #===
  #>Méthode de calibrage du Pokémon pour le combat
  #===
  def phase1_init_pokemon(pkmn)
    if pkmn
      pkmn.battle_effect=Pokemon_Effect.new
      pkmn.battle_effect.item_held = pkmn.item_holding
      pkmn.reset_stat_stage
      pkmn.form_calibrate
      pkmn.battle_turns=0
      pkmn.position=nil
      pkmn.skills_set.each do |j|
        j.used=false if(j)
      end
      pkmn.battle_item=pkmn.item_holding
    end
  end
  #===
  #> Méthode d'affichage des talents qui s'activent lors du lancé des Pokémon
  #===
  def phase1_show_ability
    pkmn = nil
    (battlers = BattleEngine.get_battlers).each do |pkmn|
      switch_turn_entry_hasard(pkmn)
    end
    battlers.each do |pkmn|
      BattleEngine::Abilities.on_launch_ability(pkmn)
    end
    phase4_message_display
    @to_start=:start_phase2
  end
end
