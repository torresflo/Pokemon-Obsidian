#encoding: utf-8

#noyard
# Description: Définition du coeur du combat : fonctionnement principal de la scène de combat
class Scene_Battle
  SWs_ID_Phase=[Yuki::Sw::BT_Phase1,Yuki::Sw::BT_Phase1,
  Yuki::Sw::BT_Phase2,Yuki::Sw::BT_Phase3,
  Yuki::Sw::BT_Phase4,Yuki::Sw::BT_Phase5]
  USE_ALPHA_25_UI = true
  SHOW_ALPHA_25_BLACK_BORDER = true
  #===
  #>Récupération des contantes utiles
  #===
  ::PFM::Text.define_const(self)
  attr_reader :phase
  attr_accessor :enemy_party, :money, :screenshot
  attr_reader :trainer_names, :message_window
  attr_accessor :fished
  attr_reader :actions
  attr_reader :phase4_step
  attr_reader :parallel_animations
  attr_reader :viewport
  #--------------------------------------------------------------------------
  # ● Lancement de la scène
  #--------------------------------------------------------------------------
  def main
    #> Prevent a bug from Scene_Map with common events
    $game_temp.common_event_id = 0
    # Load the animations if not loaded
    $data_animations ||= load_data('Data/Animations.rxdata')
    # Animation fix because of RMXP Garbage
    Sprite_Character.fix_rmxp_animations
#    RPG::Cache.load_data_14 #>Chargement des battle_back
#    RPG::Cache.load_data_15 #>Chargement des battlers
    # Initialisation des données de combat
    $game_temp.in_battle = true
    $game_temp.battle_turn = 0
    $game_temp.battle_event_flags.clear
    $game_temp.battle_abort = false
#    $game_temp.battle_main_phase = false
    $game_temp.battleback_name = $game_map.battleback_name
    $game_temp.forcing_battler = nil
    # Initialisation de l'interpreter
    $game_system.battle_interpreter.setup(nil, 0)
    # Préparation des troupes ennemies
    @troop_id = $game_temp.battle_troop_id
    @enemy_party=PFM::Pokemon_Party.new(true)
    @trainer_names=[]
    # Initialisation de l'affichage graphique du bas
    @message_window = Message.new(Viewport.create(:main, 2000), self)# Window_Message.new()#true)
    unless USE_ALPHA_25_UI
      @action_selector=Action_Selector.new
      @skill_selector=Skill_Selector.new
    end
    #Initialisation des variables d'état
    @action_index=0 
    @actor_actions=[]
    @enemy_actions=[]
    @actors=[]
    @enemies=[]
    @_SWITCH=[]
    @_EXP_GIVE=[]
    @_Evolve=[] #> Pokémon qui devront évoluer
    @_NoChoice = {} #>Switchs forcés
    @Actions_To_DO=[]
    @Actions_Counter=0
    @stuff_to_update = [] #>Variable des objets à mettre à jour pendant les messages
    @e_remaining_pk = nil #>Sprite des ball enemies
    @a_remaining_pk = nil #>Sprite des ball allié
    @parallel_animations = {}
    @to_start=nil #Variable de synchronisation entre start x et l'interpreter
    @money = 0
    @flee_attempt = 0
    @to_dispose = Array.new #> Sprites à effacer avant la transition
    $game_switches[Yuki::Sw::BT_Defeat] = 
    $game_switches[Yuki::Sw::BT_Victory] =
    $game_switches[Yuki::Sw::BT_Catch] = false
    setup_battle_event
    $game_system.battle_interpreter.update

    # Intialisation de la variable d'attente
    @wait_count = 0
    # Initialisation du background
    @viewport = Viewport.create(:main, 1000)
    @viewport.extend(Viewport::WithToneAndColors)
    @viewport.shader = Shader.create(:map_shader)
    if USE_ALPHA_25_UI
      rc = @viewport.rect
      @viewport_sub = Viewport.new(rc.x, rc.y + rc.height - 48, rc.width, 48)
      @viewport_sub.z = 60_000
      @player_choice_ui = BattleUI::PlayerChoice.new(@viewport_sub)
      @skill_choice_ui = BattleUI::SkillChoice.new(@viewport_sub)
    end
    gr_display_background()
    @mega_evolve_window = MegaEvolveWindow.new(@viewport)
    BattleEngine.reset_mega_evolutions
    # Creation des tableaux de sprite
    @actor_sprites = []
    @enemy_sprites=[]
    @actor_bars=[]
    @enemy_bars=[]
    @enemy_fought = []
    @actors_ground = nil
    @enemies_ground = nil
    @animator = nil
    @phase4_step = 0
    #>PSPADD
    PSP.make_sprite(@viewport)
    #<PSPADD
    # Lancement de la phase 1
    start_phase1
    # Boucle principale
    loop do
      Graphics.update
      # Mise à jour de la scène
      update
      # Arrêt de la scène si la nouvelle scène n'est plus l'objet courant
      if $scene != self
        break
      end
    end

    # Rafraîchissement de la MAP
    $game_map.refresh
#    Yuki::VisualDebug.clear #£VisualDebug
    # Préparation de la transition Combat <=> MAP
    Graphics.freeze
    # Effacer les fenêtres
    @message_window.dispose(with_viewport: true)
    @action_selector&.dispose
    @skill_selector&.dispose
    #effacement de tous les sprites générés par l'affichage graphique
    gr_dispose
    #>PSPADD
    PSP.dispose_sprite
    #<PSPADD
    @viewport.dispose
    @viewport_sub&.dispose
    #>Réajout des objets non utilisés.
    while @phase4_step < @actions.size
      phase4_use_item(@actions[@phase4_step], true) if @actions[@phase4_step][0] == 1
      @phase4_step += 1
    end
    #>Marquage des Pokémon
    @enemy_fought.each do |pkmn|
      $pokedex.pokemon_fought_inc(pkmn.id)
      $pokedex.mark_seen(pkmn.id,pkmn.form)
      $quests.see_pokemon(pkmn.id)
    end
    ::Scheduler.start(:on_scene_switch, ::Scene_Battle)
=begin
    ::RPG::Cache.load_icon(true)
    ::RPG::Cache.load_battleback(true)
    ::RPG::Cache.load_battler(true)
=end
    #RPG::Cache.icon_flush #>Vidage du cache des icones
    #RPG::Cache.battleback_flush #>Vidage du cache BattleBack
    #RPG::Cache.battler_flush #>Vidage du cache des battlers
    # Si on retourne à l'écran Titre
    if $scene.is_a?(Scene_Title)
      Graphics.transition
      Graphics.freeze
    else
      $game_system.bgm_stop
      #$game_system.bgm_play($game_temp.map_bgm) unless $scene.is_a?(Yuki::SoftReset)
			$game_map.autoplay unless $scene.is_a?(Yuki::SoftReset)
    end
  end
  #--------------------------------------------------------------------------
  # ● Décision de la victoire ou la défaite
  #--------------------------------------------------------------------------
  def judge
    return true if @phase==5
    # Si l'équipe est Hors Combat ou vide
    if !$pokemon_party.alive? or $actors.size == 0
      # Si l'on peut perdre
      if $game_temp.battle_can_lose or true
        # Fin du combat
        start_phase5
        #battle_end(2)
        return true
      end
      # Règlage du Game Over
      $game_temp.gameover = true
      return true
    end
    # Retourne false si il y a au moins un ennemie
    return false if @enemy_party.alive?
    # Démarrage de la phase de victoire
    start_phase5
    return true
  end
  #--------------------------------------------------------------------------
  # ● Fin du combat
  #     result : résultat (0:Victoire 1:Défaite 2:Fuite)
  #--------------------------------------------------------------------------
  def battle_end(result)
    # Modification du flag de combat
    $game_temp.in_battle = false
    # Vidage des actions
#    $game_party.clear_actions
    # Annuler les status de combat
#    for actor in $game_party.actors
#      actor.remove_states_battle
#    end
    # Effacement des ennemis
    #>Retrait de l'état de méga évolution
    @actors.each do |pkmn|
      next unless pkmn

      pkmn.unmega_evolve
      pkmn.reset_stat_stage
      pkmn.form_calibrate
      #>Vérifications de cheniti
      pkmn.form = pkmn.form_generation(-1) if pkmn.id == 412 || pkmn.id == 413
    end
    $game_troop.enemies.clear
    # Appel de la procedure de fin de combat (pour la branche d'évent)
    if $game_temp.battle_proc != nil
      $game_temp.battle_proc.call(result)
      $game_temp.battle_proc = nil
    end
    BattleEngine.get_actors.clear
    BattleEngine.get_enemies.clear
    if $pokemon_party.nuzlocke.enabled?
      $pokemon_party.nuzlocke.clear_dead_pokemon
      $pokemon_party.nuzlocke.lock_catch_in_current_zone($scene.enemy_party.actors[0].id)
    end
    # Retour à la carte
    $scene = Scene_Map.new
  end
  #--------------------------------------------------------------------------
  # ● Mise en place des évents de combats
  #--------------------------------------------------------------------------
  def setup_battle_event
    # Retour si l'interpreter de combat est en route
    if $game_system.battle_interpreter.running?
      return
    end
    # Vérification de toute les pages de combat
    for index in 0...$data_troops[@troop_id].pages.size
      # Récupération de la page
      page = $data_troops[@troop_id].pages[index]
      # Récupération des conditions dans c
      c = page.condition
      # Vérification des conditions, aller à la page suivante si aucune des conditions n'est respectée
      unless c.turn_valid or c.enemy_valid or
             c.actor_valid or c.switch_valid
        next
      end
      # Saut si un évent a déjà été executé (span=0 féquence=0-Combat)
      if $game_temp.battle_event_flags[index]
        next
      end
      # Vérification de la validité du tour
      if c.turn_valid
        n = $game_temp.battle_turn
        a = c.turn_a
        b = c.turn_b
        if (b == 0 and n != a) or
           (b > 0 and (n < 1 or n < a or n % b != a % b))
          next
        end
      end
      # Vérification de l'ennemy
      if c.enemy_valid
        enemy = PFM::BattleInterface.get_enemy(c.enemy_index)#$game_troop.enemies[c.enemy_index]
        if enemy == nil or enemy.hp_rate > c.enemy_hp #enemy.hp * 100.0 / enemy.maxhp > c.enemy_hp
          next
        end
      end
      # Celle de l'actor
      if c.actor_valid
        actor = PFM::BattleInterface.get_actor(c.actor_id)#$game_actors[c.actor_id]
        if actor == nil or actor.hp_rate > c.actor_hp#actor.hp * 100.0 / actor.maxhp > c.actor_hp
          next
        end
      end
      # Celle des switchs
      if c.switch_valid
        if $game_switches[c.switch_id] == false
          next
        end
      end
      # Mise en place de l'évent dans l'interpreter du combat
      $game_system.battle_interpreter.setup(page.list, 0)
      # Vérification de la fréquence de l'évent
      if page.span <= 1
        # Mise à jour du flag d'execution
        $game_temp.battle_event_flags[index] = true
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # ● Mise à jour globale
  #--------------------------------------------------------------------------
  def update
    #> Mise à jour de l'interpreter
    interpreter_running_check
    # Mises à jour de Game System / Screen (Compteur)
    $game_system.update
    $game_screen.update
    # Mise à jour des objets animés
    update_animated_sprites
    # Si le compteur a atteint 0
    if $game_system.timer_working and $game_system.timer == 0
      # Arrêt du combat
      $game_temp.battle_abort = true
    end
    # Mise à jour des fenêtres
    @message_window.update
    # Si la transition est active
    if $game_temp.transition_processing
      # Mise à jour du flag de transition
      $game_temp.transition_processing = false
      # Execution de la transition
      unless $game_temp.transition_name.empty? #if $game_temp.transition_name == ""
        Graphics.transition(20)
      else
        Graphics.transition(60, RPG::Cache.transition($game_temp.transition_name))
      end
    end
    # Si la fenêtre de message est active
    if $game_temp.message_window_showing
      return
    end
    # Si le Game Over est déclaré
    if $game_temp.gameover
      $scene = nil#Scene_Gameover.new
      return
    end
    # Si le saut à l'écran titre l'est
    if $game_temp.to_title
      $scene = Scene_Title.new
      return
    end
    # Si le combat est arrêté
    if $game_temp.battle_abort
      battle_end(1)
      return
    end
    # Si le compteur d'attente est actif
    if @wait_count > 0
      # Décrémentation
      @wait_count -= 1
      return
    end
    # アクションを強制されているバトラーが存在せず、 J'ai absolument rien compris ._.
    # かつバトルイベントが実行中の場合
    if $game_temp.forcing_battler == nil and
       $game_system.battle_interpreter.running?
      return
    end
    #lancement d'une phase quand l'interpreter a fini son job
    if @to_start
      meth=@to_start
      @to_start=nil
      self.send(meth)
      return
    end
    # Mises à jour des phases
    case @phase
    when 1  # Phase de pré-bataille
      update_phase1
    when 2  # Phase de choix
      update_phase2
    when 3  # Phase de commande
      update_phase3
    when 4  # Phase de déroulement des actions
      update_phase4
    when 5  # Phase de fin du combat
      update_phase5
    end
  end
  #===
  #>interpreter_running_check
  #Vérification du fonctionnement de l'interpreter
  #===
  def interpreter_running_check
    # Si l'interpreter de combat s'execute
    if $game_system.battle_interpreter.running?
      # Mise à jour de l'interpreter
      $game_system.battle_interpreter.update
      # アクションを強制されているバトラーが存在しない場合 ???
      if $game_temp.forcing_battler == nil
        # Si l'interpreter ne tourne plus
        unless $game_system.battle_interpreter.running?
          # Vérification de la continuité du combat et reset des évents
          unless judge
            setup_battle_event
          end
        end
        # Si on est pas en phase de victoire
        if @phase != 5
          # Mise à jour de la fenêtre de statu
          #@status_window.refresh
        end
      end
      return true
    end
    return false
  end
  #===
  #>Mise à jour des battlers etc...
  #===
  def update_animated_sprites
    return unless @viewport
    @viewport.update
    @viewport.need_to_sort = true
    @viewport.sort_z
    @stuff_to_update.each do |i|
      i.update
    end
    @actor_sprites.each do |i| 
      i.update if i
    end
    @enemy_sprites.each do |i|
      i.update if i
    end
    @parallel_animations.each_value(&:update)
  end
end
