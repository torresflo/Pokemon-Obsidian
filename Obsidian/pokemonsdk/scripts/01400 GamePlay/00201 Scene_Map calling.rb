class Scene_Map
  # List of RMXP Group that should be treated as "wild battle"
  RMXP_WILD_BATTLE_GROUPS = [1, 30]
  # List of scene triggers
  @triggers = {}
  # List of Battle modes
  @battle_modes = []
  class << self
    # List of call_xxx trigger
    # @return [Hash{ Symbol => Proc }]
    attr_reader :triggers

    # Add a call scene in Scene_Map
    # @param method_name [Symbol] name of the method to call (no argument)
    # @param block [Proc] block to execute in order to be sure the scene callable
    def add_call_scene(method_name, &block)
      triggers[method_name] = block
    end

    # List all the battle modes
    # @return [Array<Proc>]
    attr_reader :battle_modes

    # Add a battle mode
    # @param id [Integer] ID of the battle mode
    # @param block [Proc]
    # @yieldparam scene [Scene_Map]
    def register_battle_mode(id, &block)
      battle_modes[id] = block
    end
  end

  # Ensure the battle will start without any weird behaviour
  # @param klass [Class<Battle::Scene>] class of the scene to setup
  # @param battle_info [Battle::Logic::BattleInfo]
  def setup_start_battle(klass, battle_info)
    return unless battle_info

    Graphics.freeze
    $game_temp.menu_calling = false
    $game_temp.menu_beep = false
    $game_player.make_encounter_count
    $game_temp.map_bgm = $game_system.playing_bgm.clone if $game_system.playing_bgm
    $game_system.bgm_stop if $game_variables[::Yuki::Var::BT_Mode] != 1
    $game_system.se_play($data_system.battle_start_se)
    $game_player.straighten
    $scene = klass.new(battle_info)
    @running = false
    Yuki::FollowMe.set_battle_entry
  end

  private

  # Function responsive of testing all the scene calling and doing the job
  def update_scene_calling
    # Trigger the menu if the player press on the menu button
    if player_menu_trigger
      # We ensure we don't set the flag if it's not possible
      unless $game_system.map_interpreter.running? ||
             $game_system.menu_disabled || $game_player.moving? || $game_player.sliding?
        $game_temp.menu_calling = true
        $game_temp.menu_beep = true
      end
    end
    # We can call scene only if the player is not moving
    unless $game_player.moving?
      # All the thing to call because of end_step process
      send(*@update_to_call.shift) until @update_to_call.empty?
      Scene_Map.triggers.each do |method_name, block|
        if instance_exec(&block)
          send(method_name)
          break
        end
      end
    end
  end
  add_call_scene(:call_battle) { $game_temp.battle_calling }
  add_call_scene(:call_shop) { $game_temp.shop_calling }
  add_call_scene(:call_name) { $game_temp.name_calling }
  add_call_scene(:call_menu) { $game_temp.menu_calling }
  add_call_scene(:call_save) { $game_temp.save_calling }
  add_call_scene(:call_debug) { $game_temp.debug_calling }
  add_call_scene(:call_shortcut) { Input.trigger?(:Y) }

  # Detect if the player clicked on the Player sprite to open the menu
  # @return [Boolean]
  def player_menu_trigger
    return Input.trigger?(:X) || (Mouse.trigger?(:left) && @spriteset.game_player_sprite&.mouse_in?)
  end

  # Call the Battle scene if the play encounter Pokemon or trainer and its party has Pokemon that can fight
  def call_battle
    $game_temp.battle_calling = false
    return log_error('Battle were called but you have no Pokemon able to fight in your party') unless $pokemon_party.alive?

    battle = Scene_Map.battle_modes[$game_variables[::Yuki::Var::BT_Mode]]
    return log_error('This mode is not programmed yet in .25') unless battle.respond_to?(:call)

    battle.call(self)
  end

  register_battle_mode(0) do |scene|
    if RMXP_WILD_BATTLE_GROUPS.include?($game_temp.battle_troop_id)
      battle_info = $wild_battle.setup
    else
      battle_info = Battle::Logic::BattleInfo.from_old_psdk_settings($game_variables[Yuki::Var::Trainer_Battle_ID],
                                                                     $game_variables[Yuki::Var::Second_Trainer_ID],
                                                                     $game_variables[Yuki::Var::Allied_Trainer_ID])
    end

    scene.setup_start_battle(Battle::Scene, battle_info)
  end

  # Call the shop ui
  def call_shop
    $game_player.straighten
    items = $game_temp.shop_goods.map { |good| good[1] }
    call_scene(GamePlay::Shop, items)
    $game_temp.shop_calling = false
  end

  # Call the name input scene
  def call_name
    $game_temp.name_calling = false
    $game_player.straighten
    Graphics.freeze
    window_message_close(false)
    actor = $game_actors[$game_temp.name_actor_id]
    if $game_temp.name_actor_id == 1
      character = $game_player.character_name
    else
      character = actor.character_name
    end
    call_scene(GamePlay::NameInput, actor.name, $game_temp.name_max_char, character.empty? ? nil : character) do |scene|
      name = scene.return_name
      $trainer.name = name if $game_temp.name_actor_id == 1
      actor.name = name
    end
  end

  # Call the Menu interface
  def call_menu
    $game_temp.menu_calling = false
    if $game_temp.menu_beep
      $game_system.se_play($data_system.decision_se)
      $game_temp.menu_beep = false
    end
    $game_player.straighten
    menu = nil
    @cfo_type = @cfi_type = :none
    call_scene(GamePlay::Menu) { |scene| menu = scene }
    @cfo_type = @cfi_type = nil
    if menu.call_skill_process
      process = menu.call_skill_process.shift
      process.call(*menu.call_skill_process)
    end
  end

  # Call the save interface
  def call_save
    $game_player.straighten
    $game_temp.save_calling = false
    call_scene(GamePlay::Save)
  end

  # Call the debug interface (not present in PSDK)
  def call_debug
    $game_temp.debug_calling = false
    play_decision_se
    $game_player.straighten
  end

  # Call the shortcut interface
  def call_shortcut
    unless $game_system.menu_disabled == true
        call_scene(GamePlay::Shortcut)
    end
  end
end
