#encoding: utf-8

class Interpreter_RMXP
  # Multiple switch set
  def command_121
    # 一括操作のためにループ
    for i in @parameters[0] .. @parameters[1]
      # スイッチを変更
      $game_switches[i] = (@parameters[2] == 0)
    end
    # マップをリフレッシュ
    $game_map.need_refresh = true
    # 継続
    return true
  end
  # Variable set
  def command_122
    # 値を初期化
    value = 0
    # オペランドで分岐
    case @parameters[3]
    when 0  # 定数
      value = @parameters[4]
    when 1  # 変数
      value = $game_variables[@parameters[4]]
    when 2  # 乱数
      value = @parameters[4] + rand(@parameters[5] - @parameters[4] + 1)
    when 3  # アイテム
      value = $bag.item_quantity(@parameters[4]) #$game_party.item_number(@parameters[4])
    when 4  # アクター
      actor = PFM::BattleInterface.get_actor(@parameters[4]) #$game_actors[@parameters[4]]
      if actor != nil
        case @parameters[5]
        when 0  # レベル
          value = actor.level
        when 1  # EXP
          value = actor.exp
        when 2  # HP
          value = actor.hp
        when 3  # SP
          value = 0 #actor.sp
        when 4  # MaxHP
          value = actor.max_hp
        when 5  # MaxSP
          value = 0 #actor.maxsp
        when 6  # 腕力 / Force => Bonheur ?
          value = actor.loyalty #actor.str
        when 7  # 器用さ / Dextérité => Précision
          value = actor.acc_stage #actor.dex
        when 8  # 素早さ / Agilité => Vitesse
          value = actor.spd #actor.agi
        when 9  # 魔力 / Intelligence => Attaque spéciale
          value = actor.ats #actor.int
        when 10  # 攻撃力 / Attaque
          value = actor.atk
        when 11  # 物理防御 / Défense physique => Défense
          value = actor.dfe #actor.pdef
        when 12  # 魔法防御 / Défense magique => Défense spéciale
          value = actor.dfs #actor.mdef
        when 13  # 回避修正 / Evasion => Esquive
          value = actor.eva_stage #actor.eva
        end
      end
    when 5  # エネミー
      enemy = PFM::BattleInterface.get_enemy(@parameters[4])#$game_troop.enemies[@parameters[4]]
      if enemy != nil
        case @parameters[5]
        when 0  # HP
          value = enemy.hp
        when 1  # SP
          value = 0 #enemy.sp
        when 2  # MaxHP
          value = enemy.max_hp
        when 3  # MaxSP
          value = 0 #enemy.maxsp
        when 4  # 腕力 / Force => Bonheur ?
          value = enemy.loyalty #enemy.str
        when 5  # 器用さ / Dextérité => Précision
          value = enemy.acc_stage #enemy.dex
        when 6  # 素早さ / Agilité => Vitess
          value = enemy.spd #enemy.agi
        when 7  # 魔力 / Intelligence => Attaque spéciale
          value = enemy.ats #enemy.int
        when 8  # 攻撃力 / Attaque
          value = enemy.atk
        when 9  # 物理防御 / Défense physique => Défense
          value = enemy.dfe #enemy.pdef
        when 10  # 魔法防御 / Défense magique => Défense spéciale
          value = enemy.dfs #enemy.mdef
        when 11  # 回避修正 / Evasion => Esquive
          value = enemy.eva_stage #enemy.eva
        end
      end
    when 6  # キャラクター
      character = get_character(@parameters[4])
      if character != nil
        case @parameters[5]
        when 0  # X 座標
          value = character.x - ::Yuki::MapLinker.current_OffsetX
        when 1  # Y 座標
          value = character.y - ::Yuki::MapLinker.current_OffsetY
        when 2  # 向き
          value = character.direction
        when 3  # 画面 X 座標
          value = character.screen_x
        when 4  # 画面 Y 座標
          value = character.screen_y
        when 5  # 地形タグ
          value = character.terrain_tag
        end
      end
    when 7  # その他
      case @parameters[4]
      when 0  # マップ ID
        value = $game_map.map_id
      when 1  # パーティ人数
        value = $actors.size #$game_party.actors.size
      when 2  # ゴールド
        value = $pokemon_party.money #$game_party.gold
      when 3  # 歩数
        value = $pokemon_party.steps
      when 4  # プレイ時間
        value = Graphics.frame_count / 60#Graphics.frame_rate
      when 5  # タイマー
        value = $game_system.timer / 60#Graphics.frame_rate
      when 6  # セーブ回数
        value = $game_system.save_count
      end
    end
    # 一括操作のためにループ
    for i in @parameters[0] .. @parameters[1]
      # 操作で分岐
      case @parameters[2]
      when 0  # 代入
        $game_variables[i] = value
      when 1  # 加算
        $game_variables[i] += value
      when 2  # 減算
        $game_variables[i] -= value
      when 3  # 乗算
        $game_variables[i] *= value
      when 4  # 除算
        if value != 0
          $game_variables[i] /= value
        end
      when 5  # 剰余
        if value != 0
          $game_variables[i] %= value
        end
      end
      # 上限チェック
      if $game_variables[i] > 99999999
        $game_variables[i] = 99999999
      end
      # 下限チェック
      if $game_variables[i] < -99999999
        $game_variables[i] = -99999999
      end
    end
    # マップをリフレッシュ
    $game_map.need_refresh = true
    # 継続
    return true
  end
  # Self Switch set
  def command_123
    # イベント ID が有効の場合
    if @event_id > 0
      # セルフスイッチのキーを作成
      #key = [$game_map.map_id, @event_id, @parameters[0]]
      #> MapLinkerPatch
      event = $game_map.events[@event_id]
      return unless event
      event = event.event
      key = [event.original_map || $game_map.map_id, 
        event.original_id || @event_id, 
        @parameters[0]]
      # セルフスイッチを変更
      $game_self_switches[key] = (@parameters[1] == 0)
    end
    # マップをリフレッシュ
    $game_map.need_refresh = true
    # 継続
    return true
  end
  # Timer start / stop
  def command_124
    # 始動の場合
    if @parameters[0] == 0
      $game_system.timer = @parameters[1] * 60#Graphics.frame_rate
      $game_system.timer_working = true
    end
    # 停止の場合
    if @parameters[0] == 1
      $game_system.timer_working = false
    end
    # 継続
    return true
  end
  # Earn gold command
  def command_125
    # 操作する値を取得
    value = operate_value(@parameters[0], @parameters[1], @parameters[2])
    # ゴールドの増減
    $game_party.gain_gold(value)
    # 継続
    return true
  end

  # Get item command
  def command_126
    # 操作する値を取得
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # アイテムの増減
    $bag.add_item(@parameters[0], value)
    Audio.me_play(GameData::Item[@parameters[0]].me, 80) if value > 0
    # 継続
    return true
  end
  # Gain weapon command
  def command_127
    # 操作する値を取得
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # 武器の増減
    $game_party.gain_weapon(@parameters[0], value)
    # 継続
    return true
  end
  # Gain armor command
  def command_128
    # 操作する値を取得
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # 防具の増減
    $game_party.gain_armor(@parameters[0], value)
    # 継続
    return true
  end
  # Add or remove actor command
  def command_129
    # アクターを取得
    actor = $game_actors[@parameters[0]]
    # アクターが有効の場合
    if actor != nil
      # 操作で分岐
      if @parameters[1] == 0
        if @parameters[2] == 1
          $game_actors[@parameters[0]].setup(@parameters[0])
        end
        $game_party.add_actor(@parameters[0])
      else
        $game_party.remove_actor(@parameters[0])
      end
    end
    # 継続
    return true
  end
  # Window skin change command
  def command_131
    # ウィンドウスキン ファイル名を設定
    $game_system.windowskin_name = @parameters[0]
    # 継続
    return true
  end
  # Battle BGM change command
  def command_132
    # バトル BGM を設定
    $game_system.battle_bgm = @parameters[0]
    # 継続
    return true
  end
  # Battle end ME change command
  def command_133
    # バトル終了 ME を設定
    $game_system.battle_end_me = @parameters[0]
    # 継続
    return true
  end
  # Save disable command
  def command_134
    # セーブ禁止フラグを変更
    $game_system.save_disabled = (@parameters[0] == 0)
    # 継続
    return true
  end
  # Menu disable command
  def command_135
    # メニュー禁止フラグを変更
    $game_system.menu_disabled = (@parameters[0] == 0)
    # 継続
    return true
  end
  # Encounter disable command
  def command_136
    # エンカウント禁止フラグを変更
    $game_system.encounter_disabled = (@parameters[0] == 0)
    # エンカウント カウントを作成
    $game_player.make_encounter_count
    # 継続
    return true
  end
end
