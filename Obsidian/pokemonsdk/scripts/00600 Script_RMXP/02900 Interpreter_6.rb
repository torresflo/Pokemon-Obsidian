#encoding: utf-8

class Interpreter_RMXP
  # Start battle command
  def command_301
    # 無効なトループでなければ
    if $data_troops[@parameters[0]] != nil
      # バトル中断フラグをセット
      $game_temp.battle_abort = true
      # バトル呼び出しフラグをセット
      $game_temp.battle_calling = true
      $game_temp.battle_troop_id = @parameters[0]
      $game_temp.battle_can_escape = @parameters[1]
      $game_temp.battle_can_lose = @parameters[2]
      # コールバックを設定
      current_indent = @list[@index].indent
      $game_temp.battle_proc = Proc.new { |n| @branch[current_indent] = n }
    end
    # インデックスを進める
    @index += 1
    # 終了
    return false
  end
  # 勝った場合
  def command_601
    # バトル結果が勝ちの場合
    if @branch[@list[@index].indent] == 0
      # 分岐データを削除
      @branch.delete(@list[@index].indent)
      # 継続
      return true
    end
    # 条件に該当しない場合 : コマンドスキップ
    return command_skip
  end
  # 逃げた場合
  def command_602
    # バトル結果が逃げの場合
    if @branch[@list[@index].indent] == 1
      # 分岐データを削除
      @branch.delete(@list[@index].indent)
      # 継続
      return true
    end
    # 条件に該当しない場合 : コマンドスキップ
    return command_skip
  end
  # 負けた場合
  def command_603
    # バトル結果が負けの場合
    if @branch[@list[@index].indent] == 2
      # 分岐データを削除
      @branch.delete(@list[@index].indent)
      # 継続
      return true
    end
    # 条件に該当しない場合 : コマンドスキップ
    return command_skip
  end
  # Call a shop command
  def command_302
    # バトル中断フラグをセット
    $game_temp.battle_abort = true
    # ショップ呼び出しフラグをセット
    $game_temp.shop_calling = true
    # 商品リストに新しい項目を設定
    $game_temp.shop_goods = [@parameters]
    # ループ
    loop do
      # インデックスを進める
      @index += 1
      # 次のイベントコマンドがショップ 2 行目以降の場合
      if @list[@index].code == 605
        # 商品リストに新しい項目を追加
        $game_temp.shop_goods.push(@list[@index].parameters)
      # イベントコマンドがショップ 2 行目以降ではない場合
      else
        # 終了
        return false
      end
    end
  end
  # Name calling command
  def command_303
    # 無効なアクターでなければ
    if $data_actors[@parameters[0]] != nil
      # バトル中断フラグをセット
      $game_temp.battle_abort = true
      # 名前入力呼び出しフラグをセット
      $game_temp.name_calling = true
      $game_temp.name_actor_id = @parameters[0]
      $game_temp.name_max_char = @parameters[1]
    end
    # インデックスを進める
    @index += 1
    # 終了
    return false
  end
  # Add or remove HP command
  def command_311
    # 操作する値を取得
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # イテレータで処理
    iterate_actor(@parameters[0]) do |actor|
      # HP が 0 でない場合
      if actor.hp > 0
        # HP を変更 (戦闘不能が許可されていなければ 1 にする)
        if @parameters[4] == false and actor.hp + value <= 0
          actor.hp = 1
        else
          actor.hp += value
        end
      end
    end
    # ゲームオーバー判定
    $game_temp.gameover = $game_party.all_dead?
    # 継続
    return true
  end
  # Add or remove SP command
  def command_312
    # 操作する値を取得
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # イテレータで処理
    iterate_actor(@parameters[0]) do |actor|
      # アクターの SP を変更
      actor.sp += value
    end
    # 継続
    return true
  end
  # Add or remove state command
  def command_313
    # イテレータで処理
    iterate_actor(@parameters[0]) do |actor|
      # ステートを変更
      if @parameters[1] == 0
        actor.add_state(@parameters[2])
      else
        actor.remove_state(@parameters[2])
      end
    end
    # 継続
    return true
  end
  # Heal command
  def command_314
    # イテレータで処理
    iterate_actor(@parameters[0]) do |actor|
      # アクターを全回復
      actor.recover_all
    end
    # 継続
    return true
  end
  # Add exp command
  def command_315
    # 操作する値を取得
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # イテレータで処理
    iterate_actor(@parameters[0]) do |actor|
      # アクターの EXP を変更
      actor.exp += value
    end
    # 継続
    return true
  end
  # Add level command
  def command_316
    # 操作する値を取得
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # イテレータで処理
    iterate_actor(@parameters[0]) do |actor|
      # アクターのレベルを変更
      actor.level += value
    end
    # 継続
    return true
  end
  # Change stat command
  def command_317
    # 操作する値を取得
    value = operate_value(@parameters[2], @parameters[3], @parameters[4])
    # アクターを取得
    actor = $game_actors[@parameters[0]]
    # パラメータを変更
    if actor != nil
      case @parameters[1]
      when 0  # MaxHP
        actor.maxhp += value
      when 1  # MaxSP
        actor.maxsp += value
      when 2  # 腕力
        actor.str += value
      when 3  # 器用さ
        actor.dex += value
      when 4  # 素早さ
        actor.agi += value
      when 5  # 魔力
        actor.int += value
      end
    end
    # 継続
    return true
  end
  # Skill learn/forget command
  def command_318
    # アクターを取得
    actor = $game_actors[@parameters[0]]
    # スキルを増減
    if actor != nil
      if @parameters[1] == 0
        actor.learn_skill(@parameters[2])
      else
        actor.forget_skill(@parameters[2])
      end
    end
    # 継続
    return true
  end
  # Equip command
  def command_319
    # アクターを取得
    actor = $game_actors[@parameters[0]]
    # 装備を変更
    if actor != nil
      actor.equip(@parameters[1], @parameters[2])
    end
    # 継続
    return true
  end
  # Name change command
  def command_320
    # アクターを取得
    actor = $game_actors[@parameters[0]]
    # 名前を変更
    if actor != nil
      actor.name = @parameters[1]
    end
    # 継続
    return true
  end
  # Class change command
  def command_321
    # アクターを取得
    actor = $game_actors[@parameters[0]]
    # クラスを変更
    if actor != nil
      actor.class_id = @parameters[1]
    end
    # 継続
    return true
  end
  # Actor graphic change command
  def command_322
    # アクターを取得
    actor = $game_actors[@parameters[0]]
    # グラフィックを変更
    if actor != nil
      actor.set_graphic(@parameters[1], @parameters[2],
        @parameters[3], @parameters[4])
    end
    # プレイヤーをリフレッシュ
    $game_player.refresh
    # 継続
    return true
  end
end
