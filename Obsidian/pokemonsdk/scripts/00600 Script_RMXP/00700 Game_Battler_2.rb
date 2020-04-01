#encoding: utf-8

#noyard
class Game_Battler
  #--------------------------------------------------------------------------
  # ● ステートの検査
  #     state_id : ステート ID
  #--------------------------------------------------------------------------
  def state?(state_id)
    # 該当するステートが付加されていれば true を返す
    return @states.include?(state_id)
  end
  #--------------------------------------------------------------------------
  # ● ステートがフルかどうかの判定
  #     state_id : ステート ID
  #--------------------------------------------------------------------------
  def state_full?(state_id)
    # 該当するステートが付加されていなけば false を返す
    unless self.state?(state_id)
      return false
    end
    # 持続ターン数が -1 (オートステート) なら true を返す
    if @states_turn[state_id] == -1
      return true
    end
    # 持続ターン数が自然解除の最低ターン数と同じなら true を返す
    return @states_turn[state_id] == $data_states[state_id].hold_turn
  end
  #--------------------------------------------------------------------------
  # ● ステートの付加
  #     state_id : ステート ID
  #     force    : 強制付加フラグ (オートステートの処理で使用)
  #--------------------------------------------------------------------------
  def add_state(state_id, force = false)
    # 無効なステートの場合
    if $data_states[state_id] == nil
      # メソッド終了
      return
    end
    # 強制付加ではない場合
    unless force
      # 既存のステートのループ
      for i in @states
        # 新しいステートが既存のステートのステート変化 (-) に含まれており、
        # そのステートが新しいステートのステート変化 (-) には含まれない場合
        # (ex : 戦闘不能のときに毒を付加しようとした場合)
        if $data_states[i].minus_state_set.include?(state_id) and
           not $data_states[state_id].minus_state_set.include?(i)
          # メソッド終了
          return
        end
      end
    end
    # このステートが付加されていない場合
    unless state?(state_id)
      # ステート ID を @states 配列に追加
      @states.push(state_id)
      # オプション [HP 0 の状態とみなす] が有効の場合
      if $data_states[state_id].zero_hp
        # HP を 0 に変更
        @hp = 0
      end
      # 全ステートのループ
      for i in 1...$data_states.size
        # ステート変化 (+) 処理
        if $data_states[state_id].plus_state_set.include?(i)
          add_state(i)
        end
        # ステート変化 (-) 処理
        if $data_states[state_id].minus_state_set.include?(i)
          remove_state(i)
        end
      end
      # レーティングの大きい順 (同値の場合は制約の強い順) に並び替え
      @states.sort! do |a, b|
        state_a = $data_states[a]
        state_b = $data_states[b]
        if state_a.rating > state_b.rating
          -1
        elsif state_a.rating < state_b.rating
          +1
        elsif state_a.restriction > state_b.restriction
          -1
        elsif state_a.restriction < state_b.restriction
          +1
        else
          a <=> b
        end
      end
    end
    # 強制付加の場合
    if force
      # 自然解除の最低ターン数を -1 (無効) に設定
      @states_turn[state_id] = -1
    end
    # 強制付加ではない場合
    unless  @states_turn[state_id] == -1
      # 自然解除の最低ターン数を設定
      @states_turn[state_id] = $data_states[state_id].hold_turn
    end
    # 行動不能の場合
    unless movable?
      # アクションをクリア
      @current_action.clear
    end
    # HP および SP の最大値チェック
    @hp = [@hp, self.maxhp].min
    @sp = [@sp, self.maxsp].min
  end
  #--------------------------------------------------------------------------
  # ● ステートの解除
  #     state_id : ステート ID
  #     force    : 強制解除フラグ (オートステートの処理で使用)
  #--------------------------------------------------------------------------
  def remove_state(state_id, force = false)
    # このステートが付加されている場合
    if state?(state_id)
      # 強制付加されたステートで、かつ解除が強制ではない場合
      if @states_turn[state_id] == -1 and not force
        # メソッド終了
        return
      end
      # 現在の HP が 0 かつ オプション [HP 0 の状態とみなす] が有効の場合
      if @hp == 0 and $data_states[state_id].zero_hp
        # ほかに [HP 0 の状態とみなす] ステートがあるかどうか判定
        zero_hp = false
        for i in @states
          if i != state_id and $data_states[i].zero_hp
            zero_hp = true
          end
        end
        # 戦闘不能を解除してよければ、HP を 1 に変更
        if zero_hp == false
          @hp = 1
        end
      end
      # ステート ID を @states 配列および @states_turn ハッシュから削除
      @states.delete(state_id)
      @states_turn.delete(state_id)
    end
    # HP および SP の最大値チェック
    @hp = [@hp, self.maxhp].min
    @sp = [@sp, self.maxsp].min
  end
  #--------------------------------------------------------------------------
  # ● ステートのアニメーション ID 取得
  #--------------------------------------------------------------------------
  def state_animation_id
    # ステートがひとつも付加されていない場合
    if @states.size == 0
      return 0
    end
    # レーティング最大のステートのアニメーション ID を返す
    return $data_states[@states[0]].animation_id
  end
  #--------------------------------------------------------------------------
  # ● 制約の取得
  #--------------------------------------------------------------------------
  def restriction
    restriction_max = 0
    # 現在付加されているステートから最大の restriction を取得
    for i in @states
      if $data_states[i].restriction >= restriction_max
        restriction_max = $data_states[i].restriction
      end
    end
    return restriction_max
  end
  #--------------------------------------------------------------------------
  # ● ステート [EXP を獲得できない] 判定
  #--------------------------------------------------------------------------
  def cant_get_exp?
    for i in @states
      if $data_states[i].cant_get_exp
        return true
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● ステート [攻撃を回避できない] 判定
  #--------------------------------------------------------------------------
  def cant_evade?
    for i in @states
      if $data_states[i].cant_evade
        return true
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● ステート [スリップダメージ] 判定
  #--------------------------------------------------------------------------
  def slip_damage?
    for i in @states
      if $data_states[i].slip_damage
        return true
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● バトル用ステートの解除 (バトル終了時に呼び出し)
  #--------------------------------------------------------------------------
  def remove_states_battle
    for i in @states.clone
      if $data_states[i].battle_only
        remove_state(i)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● ステート自然解除 (ターンごとに呼び出し)
  #--------------------------------------------------------------------------
  def remove_states_auto
    for i in @states_turn.keys.clone
      if @states_turn[i] > 0
        @states_turn[i] -= 1
      elsif rand(100) < $data_states[i].auto_release_prob
        remove_state(i)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● ステート衝撃解除 (物理ダメージごとに呼び出し)
  #--------------------------------------------------------------------------
  def remove_states_shock
    for i in @states.clone
      if rand(100) < $data_states[i].shock_release_prob
        remove_state(i)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● ステート変化 (+) の適用
  #     plus_state_set  : ステート変化 (+)
  #--------------------------------------------------------------------------
  def states_plus(plus_state_set)
    # 有効フラグをクリア
    effective = false
    # ループ (付加するステート)
    for i in plus_state_set
      # このステートが防御されていない場合
      unless self.state_guard?(i)
        # このステートがフルでなければ有効フラグをセット
        effective |= self.state_full?(i) == false
        # ステートが [抵抗しない] の場合
        if $data_states[i].nonresistance
          # ステート変化フラグをセット
          @state_changed = true
          # ステートを付加
          add_state(i)
        # このステートがフルではない場合
        elsif self.state_full?(i) == false
          # ステート有効度を確率に変換し、乱数と比較
          if rand(100) < [0,100,80,60,40,20,0][self.state_ranks[i]]
            # ステート変化フラグをセット
            @state_changed = true
            # ステートを付加
            add_state(i)
          end
        end
      end
    end
    # メソッド終了
    return effective
  end
  #--------------------------------------------------------------------------
  # ● ステート変化 (-) の適用
  #     minus_state_set : ステート変化 (-)
  #--------------------------------------------------------------------------
  def states_minus(minus_state_set)
    # 有効フラグをクリア
    effective = false
    # ループ (解除するステート)
    for i in minus_state_set
      # このステートが付加されていれば有効フラグをセット
      effective |= self.state?(i)
      # ステート変化フラグをセット
      @state_changed = true
      # ステートを解除
      remove_state(i)
    end
    # メソッド終了
    return effective
  end
end

