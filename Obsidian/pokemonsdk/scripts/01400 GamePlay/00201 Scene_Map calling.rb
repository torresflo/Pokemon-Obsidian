class Scene_Map
  @triggers = {}
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
    unless $pokemon_party.alive?
      log_error('Battle were called but you have no Pokemon able to fight in your party')
      return
    end
    $game_temp.menu_calling = false
    $game_temp.menu_beep = false
    $game_player.make_encounter_count
    $game_temp.map_bgm = $game_system.playing_bgm.clone if $game_system.playing_bgm
    $game_system.bgm_stop if $game_variables[::Yuki::Var::BT_Mode] != 1
    $game_system.se_play($data_system.battle_start_se)
    $game_player.straighten
    case $game_variables[::Yuki::Var::BT_Mode]
    when 0
      $scene = Scene_Battle.new
    when 1
      $scene = Scene_Battle_Server.new
    when 2
      $scene = Scene_Battle_Client.new
    when 3
      $scene = Scene_Battle_Magneto.new
    end
    @running = false
    Graphics.wait(2)
    $scene.screenshot = snap_to_bitmap
    Yuki::FollowMe.set_battle_entry
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
