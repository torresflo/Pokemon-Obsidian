# The map gameplay scene
class Scene_Map
  # All the procedure to call at the end of the update
  @@update_to_call = []
  # Access to the spriteset of the map
  # @return [Spriteset_Map]
  attr_reader :spriteset
  # Access to the window message of the map
  # @return [Window_Message]
  attr_reader :message_window
  # The entry point of the scene
  def main
    ::Scheduler.start(:on_init, self.class)
    # スプライトセットを作成
    @spriteset = Spriteset_Map.new($env.update_zone)
    # メッセージウィンドウを作成
    @message_window = Yuki::Message.new(Viewport.create(:main, 10_000), self)#Window_Message.new
    #> Retour de combat
    if $game_temp.player_transferring
      transfer_player
    else
      #> Définition des groupes
      $wild_battle.reset
      $wild_battle.load_groups
    end
    # トランジション実行
    Graphics.transition
    #> Vérification des quêtes
    $quests.check_up_signal
    # メインループ
    loop do
      # ゲーム画面を更新
      Graphics.update
      # 入力情報を更新
      # フレーム更新
      update
      # 画面が切り替わったらループを中断
      if $scene != self
        break
      end
    end
    # トランジション準備
    Graphics.freeze
    # スプライトセットを解放
    Yuki::Particles.dispose
    Yuki::FollowMe.dispose
    @spriteset.dispose
    # メッセージウィンドウを解放
    @message_window.dispose(with_viewport: true)
    #> Evènement on_scene_switch
    ::Scheduler.start(:on_scene_switch, self.class)
    # タイトル画面に切り替え中の場合
    if $scene.is_a?(Scene_Title)
      # 画面をフェードアウト
      Graphics.transition
      Graphics.freeze
    end
  end

  # Update the scene process
  def update
    # ループ
    loop do
      # マップ、インタプリタ、プレイヤーの順に更新
      # (この更新順序は、イベントを実行する条件が満たされているときに
      #  プレイヤーに一瞬移動する機会を与えないなどの理由で重要)
      $game_map.update
      $game_system.map_interpreter.update
      $game_player.update
      # システム (タイマー)、画面を更新
      $game_system.update
      $game_screen.update
      # プレイヤーの場所移動中でなければループを中断
      unless $game_temp.player_transferring
        break
      end
      # 場所移動を実行
      transfer_player
      # トランジション処理中の場合、ループを中断
      if $game_temp.transition_processing
        break
      end
    end
    # スプライトセットを更新
    @spriteset.update
    #Yuki::TJN.update
    #Yuki::Particles.update
    # メッセージウィンドウを更新
    @message_window.update
    # ゲームオーバーの場合
    if $game_temp.gameover
      # ゲームオーバー画面に切り替え
      $scene = Scene_Gameover.new
      return
    end
    # タイトル画面に戻す場合
    if $game_temp.to_title
      # タイトル画面に切り替え
      $scene = Scene_Title.new
      return
    end
    # トランジション処理中の場合
    if $game_temp.transition_processing
      # トランジション処理中フラグをクリア
      $game_temp.transition_processing = false
      # トランジション実行
      if $game_temp.transition_name.empty? #if $game_temp.transition_name == ""
        Graphics.transition(20)
      else
        Graphics.transition(60, RPG::Cache.transition($game_temp.transition_name))
      end
    end
    # メッセージウィンドウ表示中の場合
    if $game_temp.message_window_showing
      return
    end
    # B ボタンが押された場合
    if Input.trigger?(:X) or player_menu_trigger
      # イベント実行中かメニュー禁止中でなければ
      unless $game_system.map_interpreter.running? or
             $game_system.menu_disabled or $game_player.moving? or $game_player.sliding?
        # メニュー呼び出しフラグと SE 演奏フラグをセット
        $game_temp.menu_calling = true
        $game_temp.menu_beep = true
      end
    end
    # プレイヤーの移動中ではない場合
    unless $game_player.moving?
      # All the thing to call because of end_step process
      send(*@@update_to_call.shift) until @@update_to_call.empty?
      # 各種画面の呼び出しを実行
      if $game_temp.battle_calling
        call_battle
      elsif $game_temp.shop_calling
        call_shop
      elsif $game_temp.name_calling
        call_name
      elsif $game_temp.menu_calling
        call_menu
      elsif $game_temp.save_calling
        call_save
      elsif $game_temp.debug_calling
        call_debug
      #> Raccourcis
      elsif Input.trigger?(:Y)
        call_shortcut
      end
    end
  end

  # Call the Battle scene if the play encounter Pokemon or trainer and its party has Pokemon that can fight
  def call_battle
    # バトル呼び出しフラグをクリア
    $game_temp.battle_calling = false
    # メニュー呼び出しフラグをクリア
    $game_temp.menu_calling = false
    $game_temp.menu_beep = false
    return unless $pokemon_party.alive?
#    Yuki::VisualDebug.clear #£VisualDebug
    # エンカウント カウントを作成
    $game_player.make_encounter_count
    # マップ BGM を記憶し、BGM を停止
    $game_temp.map_bgm = $game_system.playing_bgm.clone if $game_system.playing_bgm
    $game_system.bgm_stop if $game_variables[::Yuki::Var::BT_Mode] != 1
    # バトル開始 SE を演奏
    $game_system.se_play($data_system.battle_start_se)
    # プレイヤーの姿勢を矯正
    $game_player.straighten
    # バトル画面に切り替え
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
    Graphics.wait(2)
    $scene.screenshot = @spriteset.map_viewport.snap_to_bitmap
    Yuki::FollowMe.set_battle_entry
  end

  # Call the Shop scene
  def call_shop
    # プレイヤーの姿勢を矯正
    $game_player.straighten
    # ショップ画面に切り替え
    ::GamePlay::Shop.new.main
    # ショップ呼び出しフラグをクリア
    $game_temp.shop_calling = false
    Graphics.transition
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
    scene = GamePlay::NameInput.new(actor.name, $game_temp.name_max_char, character.empty? ? nil : character).main
    name = scene.return_name
    $trainer.name = name if $game_temp.name_actor_id == 1
    actor.name = name
    Graphics.transition
  end

  # Call the Menu interface
  def call_menu
    # メニュー呼び出しフラグをクリア
    $game_temp.menu_calling = false
#    return if Yuki::SystemTag.running?
    # メニュー SE 演奏フラグがセットされている場合
    if $game_temp.menu_beep
      # 決定 SE を演奏
      $game_system.se_play($data_system.decision_se)
      # メニュー SE 演奏フラグをクリア
      $game_temp.menu_beep = false
    end
    # プレイヤーの姿勢を矯正
    $game_player.straighten
    # メニュー画面に切り替え
    #>Lancement du menu
    menu = GamePlay::Menu.new
    menu.main
    Graphics.transition(1)
    if(menu.call_skill_process)
      process = menu.call_skill_process.shift
      process.call(*menu.call_skill_process)
    end
  end

  # Call the save interface
  def call_save
    # プレイヤーの姿勢を矯正
    $game_player.straighten
    # セーブ画面に切り替え
    #$scene = Scene_Save.new
    $game_temp.save_calling = false
    GamePlay::Save.new.main
    Graphics.transition
  end

  # Call the debug interface (not present in PSDK)
  def call_debug
    # デバッグ呼び出しフラグをクリア
    $game_temp.debug_calling = false
    # 決定 SE を演奏
    $game_system.se_play($data_system.decision_se)
    # プレイヤーの姿勢を矯正
    $game_player.straighten
    # デバッグ画面に切り替え
  end

  # Call the shortcut interface
  def call_shortcut
    scene = GamePlay::Shortcut.new
    scene.main
    Graphics.transition
  end

  # Execute the begin calculation of the transfer_player processing
  def transfer_player_begin
    ::Scheduler.start(:on_warp_start)
    # 移動先が現在のマップと異なる場合
    if $game_map.map_id != $game_temp.player_new_map_id
      # 新しいマップをセットアップ
      $game_map.setup($game_temp.player_new_map_id)
    end
    # プレイヤー場所移動フラグをクリア
    $game_temp.player_transferring = false # Moved here to prevent some event starting during warp process
    # プレイヤーの位置を設定
    $game_player.moveto($game_temp.player_new_x, $game_temp.player_new_y)
    # プレイヤーの向きを設定
    case $game_temp.player_new_direction
    when 2  # 下
      $game_player.turn_down
    when 4  # 左
      $game_player.turn_left
    when 6  # 右
      $game_player.turn_right
    when 8  # 上
      $game_player.turn_up
    end
    # プレイヤーの姿勢を矯正
    $game_player.straighten
    # マップを更新 (並列イベント実行)
    $game_map.update
  end

  # Teleport the play between map or inside the map
  def transfer_player
    Yuki::ElapsedTime.start(:transfer_player)
    #> Clear the Pathfinding system
    Pathfinding.clear
    #> Calculations
    transfer_player_begin
    #> Adjustment of the Spriteset Data
    zone = $env.update_zone
    ::Scheduler.start(:on_warp_process)
    #>Transition spéciale
    wrp_anime = $game_switches[::Yuki::Sw::WRP_Transition]
    if(!$env.get_current_zone_data.warp_disallowed or $game_temp.transition_processing )
      $game_switches[::Yuki::Sw::WRP_Transition] = false
    end
    transition_sprite = @spriteset.dispose(true)
    Graphics.sort_z
    $game_switches[::Yuki::Sw::WRP_Transition] = wrp_anime
    #@spriteset = Spriteset_Map.new(zone)
    transfer_player_specific_transition unless transition_sprite
    @spriteset.reload(zone)
    ::Scheduler.start(:on_warp_end)
    Yuki::ElapsedTime.show(:transfer_player, 'Transfering player took')
    # フレームリセット
    Graphics.frame_reset
    #> Transition processing
    transfer_player_end(transition_sprite)
  end

  # End of the transfer player processing (transitions)
  def transfer_player_end(transition_sprite)
    if(transition_sprite)
      ::Yuki::Transitions.bw_zoom(transition_sprite)
      $game_map.autoplay
    elsif (transition_id = $game_variables[::Yuki::Var::MapTransitionID]) > 0
      $game_variables[::Yuki::Var::MapTransitionID] = 0
      Graphics.brightness = 255
      $game_map.autoplay
      case transition_id
      when 1 # Circular transition
        ::Yuki::Transitions.circular(1)
      when 2 # Directed transition
        ::Yuki::Transitions.directed(1)
      end
      $game_temp.transition_processing = false
    elsif $game_temp.transition_processing
      $game_map.autoplay
      $game_temp.transition_processing = false
      Graphics.transition(20)
    else
      $game_map.autoplay
    end
  end

  # Start a specific transition
  def transfer_player_specific_transition
    if (transition_id = $game_variables[::Yuki::Var::MapTransitionID]) > 0
      Graphics.transition(1) if $game_temp.transition_processing
      case transition_id
      when 1 # Circular transition
        ::Yuki::Transitions.circular
      when 2 # Directed transition
        ::Yuki::Transitions.directed
      end
      Graphics.brightness = 0
      Graphics.wait(15)
    end
  end

  # Update everything related to the graphics of the map (used in Interfaces that require that)
  def sprite_set_update
    $game_screen.update
    $game_map.refresh if $game_map.need_refresh
    @spriteset.update
    Yuki::TJN.update
    Yuki::Particles.update
  end

  # Change the spriteset visibility
  # @param v [Boolean] the new visibility of the spriteset
  def sprite_set_visible=(v)
    @spriteset.visible=v
  end

  # Display the repel check sequence
  def display_repel_check
    display_message(parse_text(39, 0))
  end

  # Display the end of poisoning sequence
  # @param pokemon [PFM::Pokemon] previously poisoned pokemon
  def display_poison_end(pokemon)
    PFM::Text.set_pknick(pokemon, 0)
    display_message(parse_text(22, 110))
  end

  # Display the poisoning animation sequence
  def display_poison_animation
    Audio.se_play('Audio/SE/psn')
    $game_screen.start_flash(GameData::Colors::PSN, 20)
    $game_screen.start_shake(1, 20, 2)
  end

  # Display the Egg hatch sequence
  # @param pokemon [PFM::Pokemon] haching pokemon
  def display_egg_hatch(pokemon)
    GamePlay::Hatch.new(pokemon).main
    Graphics.transition
    $quests.hatch_egg
  end

  # Prepare the call of a display_ method
  # @param args [Array] the send method parameter
  def delay_display_call(*args)
    @@update_to_call << args
  end

  # Display a message with choice or not
  # @param str [String] the message to display
  # @param start [Integer] the start choice index (1..nb_choice)
  # @param choices [Array<String>] the list of choice options
  # @return [Integer, nil] the choice result
  def display_message(str,start=1,*choices)
    $game_temp.message_text = str #@message_window.contents.multiline_calibrate(str)
    b = true
    $game_temp.message_proc = Proc.new { b = false }
    c = nil
    if(choices.size>0)
      $game_temp.choice_max=choices.size
      $game_temp.choice_cancel_type=choices.size
      $game_temp.choice_proc=Proc.new{|i|c=i}
      $game_temp.choice_start=start
      $game_temp.choices=choices
    end
    while b
      Graphics.update
      update
    end
    Graphics.update
    return c
  end

  # Force the message window to close
  # @param smooth [Boolean] if the message window is closed smoothly or not
  def window_message_close(smooth)
    if(smooth)
      while $game_temp.message_window_showing
        Graphics.update
        @message_window.update
      end
    else
      $game_temp.message_window_showing = false
      @message_window.visible = false
      @message_window.opacity = 255
    end
  end

  # Detect if the player clicked on the Player sprite to open the menu
  # @return [Boolean]
  def player_menu_trigger
    return true if Mouse.trigger?(:left) and sp = @spriteset.game_player_sprite and sp.mouse_in?
    return false
  end

  # Change the tileset
  # @param filename [String] filename of the new tileset
  def change_tileset(filename)
    $game_map.tileset_name = $game_map.get_tileset_name(filename)
    @spriteset.init_tilemap
  end
end
