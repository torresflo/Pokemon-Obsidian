#encoding: utf-8

class Interpreter_RMXP
  # Enemy HP change command
  def command_331
    # 操作する値を取得
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # イテレータで処理
    iterate_enemy(@parameters[0]) do |enemy|
      # HP が 0 でない場合
      if enemy.hp > 0
        # HP を変更 (戦闘不能が許可されていなければ 1 にする)
        if @parameters[4] == false and enemy.hp + value <= 0
          enemy.hp = 1
        else
          enemy.hp += value
        end
      end
    end
    # 継続
    return true
  end
  # Enemy SP change command
  def command_332
    # 操作する値を取得
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # イテレータで処理
    iterate_enemy(@parameters[0]) do |enemy|
      # SP を変更
      enemy.sp += value
    end
    # 継続
    return true
  end
  # Enemy state change command
  def command_333
    # イテレータで処理
    iterate_enemy(@parameters[0]) do |enemy|
      # ステートのオプション [HP 0 の状態とみなす] が有効の場合
      if $data_states[@parameters[2]].zero_hp
        # 不死身フラグをクリア
        enemy.immortal = false
      end
      # ステートを変更
      if @parameters[1] == 0
        enemy.add_state(@parameters[2])
      else
        enemy.remove_state(@parameters[2])
      end
    end
    # 継続
    return true
  end
  # Enemy heal command
  def command_334
    # イテレータで処理
    iterate_enemy(@parameters[0]) do |enemy|
      # 全回復
      enemy.recover_all
    end
    # 継続
    return true
  end
  # Enemy show command
  def command_335
    # エネミーを取得
    enemy = $game_troop.enemies[@parameters[0]]
    # 隠れフラグをクリア
    if enemy != nil
      enemy.hidden = false
    end
    # 継続
    return true
  end
  # Enemy transform command
  def command_336
    # エネミーを取得
    enemy = $game_troop.enemies[@parameters[0]]
    # 変身処理
    if enemy != nil
      enemy.transform(@parameters[1])
    end
    # 継続
    return true
  end
  # Play animation on battler
  def command_337
    # イテレータで処理
    iterate_battler(@parameters[0], @parameters[1]) do |battler|
      # バトラーが存在する場合
      if battler.exist?
        # アニメーション ID を設定
        battler.animation_id = @parameters[2]
      end
    end
    # 継続
    return true
  end
  # Damage on battler command
  def command_338
    # 操作する値を取得
    value = operate_value(0, @parameters[2], @parameters[3])
    # イテレータで処理
    iterate_battler(@parameters[0], @parameters[1]) do |battler|
      # バトラーが存在する場合
      if battler.exist?
        # HP を変更
        battler.hp -= value
        # 戦闘中なら
        if $game_temp.in_battle
          # ダメージを設定
          battler.damage = value
          battler.damage_pop = true
        end
      end
    end
    # 継続
    return true
  end
  # Battler force action command
  def command_339
    # 戦闘中でなければ無視
    unless $game_temp.in_battle
      return true
    end
    # ターン数が 0 なら無視
    if $game_temp.battle_turn == 0
      return true
    end
    # イテレータで処理 (便宜的なもので、複数になることはない)
    iterate_battler(@parameters[0], @parameters[1]) do |battler|
      # バトラーが存在する場合
      if battler.exist?
        # アクションを設定
        battler.current_action.kind = @parameters[2]
        if battler.current_action.kind == 0
          battler.current_action.basic = @parameters[3]
        else
          battler.current_action.skill_id = @parameters[3]
        end
        # 行動対象を設定
        if @parameters[4] == -2
          if battler.is_a?(Game_Enemy)
            battler.current_action.decide_last_target_for_enemy
          else
            battler.current_action.decide_last_target_for_actor
          end
        elsif @parameters[4] == -1
          if battler.is_a?(Game_Enemy)
            battler.current_action.decide_random_target_for_enemy
          else
            battler.current_action.decide_random_target_for_actor
          end
        elsif @parameters[4] >= 0
          battler.current_action.target_index = @parameters[4]
        end
        # 強制フラグを設定
        battler.current_action.forcing = true
        # アクションが有効かつ [すぐに実行] の場合
        if battler.current_action.valid? and @parameters[5] == 1
          # 強制対象のバトラーを設定
          $game_temp.forcing_battler = battler
          # インデックスを進める
          @index += 1
          # 終了
          return false
        end
      end
    end
    # 継続
    return true
  end
  # End battle command
  def command_340
    # バトル中断フラグをセット
    $game_temp.battle_abort = true
    # インデックスを進める
    @index += 1
    # 終了
    return false
  end
  # Call menu command
  def command_351
    # バトル中断フラグをセット
    $game_temp.battle_abort = true
    # メニュー呼び出しフラグをセット
    $game_temp.menu_calling = true
    # インデックスを進める
    @index += 1
    # 終了
    return false
  end
  # Call save command
  def command_352
    # バトル中断フラグをセット
    $game_temp.battle_abort = true
    # セーブ呼び出しフラグをセット
    $game_temp.save_calling = true
    # インデックスを進める
    @index += 1
    # 終了
    return false
  end
  # Game Over command
  def command_353
    # ゲームオーバーフラグをセット
    $game_temp.gameover = true
    # 終了
    return false
  end
  # Go to title command
  def command_354
    # タイトル画面に戻すフラグをセット
    $game_temp.to_title = true
    # 終了
    return false
  end
  # Execute script command
  def command_355
    # script に 1 行目を設定
    script = @list[@index].parameters[0] + "\n"
    # ループ
    loop do
      # 次のイベントコマンドがスクリプト 2 行目以降の場合
      if @list[@index+1].code == 655
        # script に 2 行目以降を追加
        script += @list[@index+1].parameters[0] + "\n"
      # イベントコマンドがスクリプト 2 行目以降ではない場合
      else
        # ループ中断
        break
      end
      # インデックスを進める
      @index += 1
    end
    # 評価
    eval_script(script)
    return true
  end

  # Function that execute a script
  # @param script [String]
  def eval_script(script)
    last_eval = Yuki::EXC.get_eval_script
    script = script.force_encoding('UTF-8')
    Yuki::EXC.set_eval_script(script)
    Yuki::ErrorHandler.critical_section("Eval from script command (EVENT_ID = #{@event_id.to_i})\nScript:\n#{script}") do
      eval(script)
    end
    Yuki::EXC.set_eval_script(last_eval)
  end
end
