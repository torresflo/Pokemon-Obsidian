#encoding: utf-8

class Interpreter_RMXP
  # Warp command
  def command_201
    # 戦闘中の場合
    if $game_temp.in_battle
      # 継続
      return true
    end
    # 場所移動中、メッセージ表示中、トランジション処理中の場合
    if $game_temp.player_transferring or
       $game_temp.message_window_showing or
       $game_temp.transition_processing
      # 終了
      return false
    end
    # 場所移動フラグをセット
    $game_temp.player_transferring = true
    # 指定方法が [直接指定] の場合
    if @parameters[0] == 0
      # プレイヤーの移動先を設定
      $game_temp.player_new_map_id = @parameters[1]
      $game_temp.player_new_x = @parameters[2] + ::Yuki::MapLinker.get_OffsetX
      $game_temp.player_new_y = @parameters[3] + ::Yuki::MapLinker.get_OffsetY
      $game_temp.player_new_direction = @parameters[4]
    # 指定方法が [変数で指定] の場合
    else
      # プレイヤーの移動先を設定
      $game_temp.player_new_map_id = $game_variables[@parameters[1]]
      $game_temp.player_new_x = $game_variables[@parameters[2]] + ::Yuki::MapLinker.get_OffsetX
      $game_temp.player_new_y = $game_variables[@parameters[3]] + ::Yuki::MapLinker.get_OffsetY
      $game_temp.player_new_direction = @parameters[4]
    end
    # インデックスを進める
    @index += 1
    # フェードありの場合
    if @parameters[5] == 0
      # トランジション準備
      Graphics.freeze
      # トランジション処理中フラグをセット
      $game_temp.transition_processing = true
      $game_temp.transition_name = nil.to_s
    end
    # 終了
    return false
  end
  # Displace command
  def command_202
    # 戦闘中の場合
    if $game_temp.in_battle
      # 継続
      return true
    end
    # キャラクターを取得
    character = get_character(@parameters[0])
    # キャラクターが存在しない場合
    if character == nil
      # 継続
      return true
    end
    # 指定方法が [直接指定] の場合
    if @parameters[1] == 0
      # キャラクターの位置を設定
      character.moveto(@parameters[2] + ::Yuki::MapLinker.current_OffsetX, 
      @parameters[3] + ::Yuki::MapLinker.current_OffsetY)
    # 指定方法が [変数で指定] の場合
    elsif @parameters[1] == 1
      # キャラクターの位置を設定
      character.moveto($game_variables[@parameters[2]] + 
        ::Yuki::MapLinker.current_OffsetX,  $game_variables[@parameters[3]] + 
        ::Yuki::MapLinker.current_OffsetY)
    # 指定方法が [他のイベントと交換] の場合
    else
      old_x = character.x
      old_y = character.y
      character2 = get_character(@parameters[2])
      if character2 != nil
        character.moveto(character2.x, character2.y)
        character2.moveto(old_x, old_y)
      end
    end
    # キャラクターの向きを設定
    case @parameters[4]
    when 8  # 上
      character.turn_up
    when 6  # 右
      character.turn_right
    when 2  # 下
      character.turn_down
    when 4  # 左
      character.turn_left
    end
    # 継続
    return true
  end
  # Map scroll command
  def command_203
    # 戦闘中の場合
    if $game_temp.in_battle
      # 継続
      return true
    end
    # すでにスクロール中の場合
    if $game_map.scrolling?
      # 終了
      return false
    end
    # スクロールを開始
    $game_map.start_scroll(@parameters[0], @parameters[1], @parameters[2])
    # 継続
    return true
  end
  # Map property change command
  def command_204
    case @parameters[0]
    when 0  # パノラマ
      $game_map.panorama_name = @parameters[1]
      $game_map.panorama_hue = @parameters[2]
    when 1  # フォグ
      $game_map.fog_name = @parameters[1]
      $game_map.fog_hue = @parameters[2]
      $game_map.fog_opacity = @parameters[3]
      $game_map.fog_blend_type = @parameters[4]
      $game_map.fog_zoom = @parameters[5]
      $game_map.fog_sx = @parameters[6]
      $game_map.fog_sy = @parameters[7]
    when 2  # バトルバック
      $game_map.battleback_name = @parameters[1]
      $game_temp.battleback_name = @parameters[1]
#      Yuki::GemmeProc::battle_back_skip unless Yuki::GemmeProc::set_battle_back_var(@parameters[1])
    end
    # 継続
    return true
  end
  # Map Tone change command
  def command_205
    # 色調変更を開始
    $game_map.start_fog_tone_change(@parameters[0], @parameters[1] * 2)
    # 継続
    return true
  end
  # Map fog opacity change command
  def command_206
    # 不透明度変更を開始
    $game_map.start_fog_opacity_change(@parameters[0], @parameters[1] * 2)
    # 継続
    return true
  end
  # Display animation on character command
  def command_207
    # キャラクターを取得
    character = get_character(@parameters[0])
    # キャラクターが存在しない場合
    if character == nil
      # 継続
      return true
    end
    # アニメーション ID を設定
    character.animation_id = @parameters[1]
    # 継続
    return true
  end
  # Make player transparent command
  def command_208
    # プレイヤーの透明状態を設定
    $game_player.transparent = (@parameters[0] == 0)
    # 継続
    return true
  end
  # Move route set command
  def command_209
    # キャラクターを取得
    character = get_character(@parameters[0])
    # キャラクターが存在しない場合
    if character == nil
      # 継続
      return true
    end
    # 移動ルートを強制
    character.force_move_route(@parameters[1])
    # 継続
    return true
  end
  # Wait until end of events move route
  def command_210
    # 戦闘中でなければ
    unless $game_temp.in_battle
      # 移動完了待機中フラグをセット
      @move_route_waiting = true
    end
    # 継続
    return true
  end
  # Prepare transition command
  def command_221
    # メッセージウィンドウ表示中の場合
    if $game_temp.message_window_showing
      # 終了
      return false
    end
    # トランジション準備
    Graphics.freeze
    # 継続
    return true
  end
  # Execute transition command
  def command_222
    # トランジション処理中フラグがすでにセットされている場合
    if $game_temp.transition_processing
      # 終了
      return false
    end
    # トランジション処理中フラグをセット
    $game_temp.transition_processing = true
    $game_temp.transition_name = @parameters[0]
    # インデックスを進める
    @index += 1
    # 終了
    return false
  end
  # Screen tone change command
  def command_223
    # 色調変更を開始
    if @parameters[0] != Game_Screen::NEUTRAL_TONE
      $game_screen.start_tone_change(@parameters[0], @parameters[1] * 2)
    else
      $game_screen.start_tone_change(Yuki::TJN.current_tone, @parameters[1] * 2)
    end
    # 継続
    return true
  end
  # Flash screen command
  def command_224
    # フラッシュを開始
    $game_screen.start_flash(@parameters[0], @parameters[1] * 2)
    # 継続
    return true
  end
  # Shake screen command
  def command_225
    # シェイクを開始
    $game_screen.start_shake(@parameters[0], @parameters[1],
      @parameters[2] * 2)
    # 継続
    return true
  end
  # Picture display command
  def command_231
    # ピクチャ番号を取得
    number = @parameters[0] + ($game_temp.in_battle ? 50 : 0)
    # 指定方法が [直接指定] の場合
    if @parameters[3] == 0
      x = @parameters[4]
      y = @parameters[5]
    # 指定方法が [変数で指定] の場合
    else
      x = $game_variables[@parameters[4]]
      y = $game_variables[@parameters[5]]
    end
    # ピクチャを表示
    $game_screen.pictures[number].show(@parameters[1], @parameters[2],
      x, y, @parameters[6], @parameters[7], @parameters[8], @parameters[9])
    # 継続
    return true
  end
  # Picture move command
  def command_232
    # ピクチャ番号を取得
    number = @parameters[0] + ($game_temp.in_battle ? 50 : 0)
    # 指定方法が [直接指定] の場合
    if @parameters[3] == 0
      x = @parameters[4]
      y = @parameters[5]
    # 指定方法が [変数で指定] の場合
    else
      x = $game_variables[@parameters[4]]
      y = $game_variables[@parameters[5]]
    end
    # ピクチャを移動
    $game_screen.pictures[number].move(@parameters[1] * 2, @parameters[2],
      x, y, @parameters[6], @parameters[7], @parameters[8], @parameters[9])
    # 継続
    return true
  end
  # Picture rotate command
  def command_233
    # ピクチャ番号を取得
    number = @parameters[0] + ($game_temp.in_battle ? 50 : 0)
    # 回転速度を設定
    $game_screen.pictures[number].rotate(@parameters[1])
    # 継続
    return true
  end
  # Picture tone change command
  def command_234
    # ピクチャ番号を取得
    number = @parameters[0] + ($game_temp.in_battle ? 50 : 0)
    # 色調変更を開始
    $game_screen.pictures[number].start_tone_change(@parameters[1],
      @parameters[2] * 2)
    # 継続
    return true
  end
  # Picture erase command
  def command_235
    # ピクチャ番号を取得
    number = @parameters[0] + ($game_temp.in_battle ? 50 : 0)
    # ピクチャを消去
    $game_screen.pictures[number].erase
    # 継続
    return true
  end
  # Weather change command
  def command_236
    # 天候を設定
    $game_screen.weather(@parameters[0], @parameters[1], @parameters[2])
    # 継続
    return true
  end
  # BGM play command
  def command_241
    # BGM を演奏
    $game_system.bgm_play(@parameters[0])
    # 継続
    return true
  end
  # BGM fade command
  def command_242
    # BGM をフェードアウト
    $game_system.bgm_fade(@parameters[0])
    # 継続
    return true
  end
  # BGS play command
  def command_245
    # BGS を演奏
    $game_system.bgs_play(@parameters[0])
    # 継続
    return true
  end
  # BGS Fade command
  def command_246
    # BGS をフェードアウト
    $game_system.bgs_fade(@parameters[0])
    # 継続
    return true
  end
  # BGM & BGS memorize command
  def command_247
    # BGM / BGS を記憶
    $game_system.bgm_memorize
    $game_system.bgs_memorize
    # 継続
    return true
  end
  # BGM & BGS restore command
  def command_248
    # BGM / BGS を復帰
    $game_system.bgm_restore
    $game_system.bgs_restore
    # 継続
    return true
  end
  # ME play command
  def command_249
    # ME を演奏
    $game_system.me_play(@parameters[0])
    # 継続
    return true
  end
  # SE play command
  def command_250
    # SE を演奏
    $game_system.se_play(@parameters[0])
    # 継続
    return true
  end
  # SE stop command
  def command_251
    # SE を停止
    Audio.se_stop
    # 継続
    return true
  end
end
