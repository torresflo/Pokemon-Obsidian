#encoding: utf-8

#noyard
class Game_Battler
  #--------------------------------------------------------------------------
  # ● スキルの使用可能判定
  #     skill_id : スキル ID
  #--------------------------------------------------------------------------
  def skill_can_use?(skill_id)
    # SP が足りない場合は使用不可
    if $data_skills[skill_id].sp_cost > self.sp
      return false
    end
    # 戦闘不能の場合は使用不可
    if dead?
      return false
    end
    # 沈黙状態の場合、物理スキル以外は使用不可
    if $data_skills[skill_id].atk_f == 0 and self.restriction == 1
      return false
    end
    # 使用可能時を取得
    occasion = $data_skills[skill_id].occasion
    # 戦闘中の場合
    if $game_temp.in_battle
      # [常時] または [バトルのみ] なら使用可
      return (occasion == 0 or occasion == 1)
    # 戦闘中ではない場合
    else
      # [常時] または [メニューのみ] なら使用可
      return (occasion == 0 or occasion == 2)
    end
  end
  #--------------------------------------------------------------------------
  # ● 通常攻撃の効果適用
  #     attacker : 攻撃者 (バトラー)
  #--------------------------------------------------------------------------
  def attack_effect(attacker)
    # クリティカルフラグをクリア
    self.critical = false
    # 第一命中判定
    hit_result = (rand(100) < attacker.hit)
    # 命中の場合
    if hit_result == true
      # 基本ダメージを計算
      atk = [attacker.atk - self.pdef / 2, 0].max
      self.damage = atk * (20 + attacker.str) / 20
      # 属性修正
      self.damage *= elements_correct(attacker.element_set)
      self.damage /= 100
      # ダメージの符号が正の場合
      if self.damage > 0
        # クリティカル修正
        if rand(100) < 4 * attacker.dex / self.agi
          self.damage *= 2
          self.critical = true
        end
        # 防御修正
        if self.guarding?
          self.damage /= 2
        end
      end
      # 分散
      if self.damage.abs > 0
        amp = [self.damage.abs * 15 / 100, 1].max
        self.damage += rand(amp+1) + rand(amp+1) - amp
      end
      # 第二命中判定
      eva = 8 * self.agi / attacker.dex + self.eva
      hit = self.damage < 0 ? 100 : 100 - eva
      hit = self.cant_evade? ? 100 : hit
      hit_result = (rand(100) < hit)
    end
    # 命中の場合
    if hit_result == true
      # ステート衝撃解除
      remove_states_shock
      # HP からダメージを減算
      self.hp -= self.damage
      # ステート変化
      @state_changed = false
      states_plus(attacker.plus_state_set)
      states_minus(attacker.minus_state_set)
    # ミスの場合
    else
      # ダメージに "Miss" を設定
      self.damage = "Miss"
      # クリティカルフラグをクリア
      self.critical = false
    end
    # メソッド終了
    return true
  end
  #--------------------------------------------------------------------------
  # ● スキルの効果適用
  #     user  : スキルの使用者 (バトラー)
  #     skill : スキル
  #--------------------------------------------------------------------------
  def skill_effect(user, skill)
    # クリティカルフラグをクリア
    self.critical = false
    # スキルの効果範囲が HP 1 以上の味方で、自分の HP が 0、
    # またはスキルの効果範囲が HP 0 の味方で、自分の HP が 1 以上の場合
    if ((skill.scope == 3 or skill.scope == 4) and self.hp == 0) or
       ((skill.scope == 5 or skill.scope == 6) and self.hp >= 1)
      # メソッド終了
      return false
    end
    # 有効フラグをクリア
    effective = false
    # コモンイベント ID が有効の場合は有効フラグをセット
    effective |= skill.common_event_id > 0
    # 第一命中判定
    hit = skill.hit
    if skill.atk_f > 0
      hit *= user.hit / 100
    end
    hit_result = (rand(100) < hit)
    # 不確実なスキルの場合は有効フラグをセット
    effective |= hit < 100
    # 命中の場合
    if hit_result == true
      # 威力を計算
      power = skill.power + user.atk * skill.atk_f / 100
      if power > 0
        power -= self.pdef * skill.pdef_f / 200
        power -= self.mdef * skill.mdef_f / 200
        power = [power, 0].max
      end
      # 倍率を計算
      rate = 20
      rate += (user.str * skill.str_f / 100)
      rate += (user.dex * skill.dex_f / 100)
      rate += (user.agi * skill.agi_f / 100)
      rate += (user.int * skill.int_f / 100)
      # 基本ダメージを計算
      self.damage = power * rate / 20
      # 属性修正
      self.damage *= elements_correct(skill.element_set)
      self.damage /= 100
      # ダメージの符号が正の場合
      if self.damage > 0
        # 防御修正
        if self.guarding?
          self.damage /= 2
        end
      end
      # 分散
      if skill.variance > 0 and self.damage.abs > 0
        amp = [self.damage.abs * skill.variance / 100, 1].max
        self.damage += rand(amp+1) + rand(amp+1) - amp
      end
      # 第二命中判定
      eva = 8 * self.agi / user.dex + self.eva
      hit = self.damage < 0 ? 100 : 100 - eva * skill.eva_f / 100
      hit = self.cant_evade? ? 100 : hit
      hit_result = (rand(100) < hit)
      # 不確実なスキルの場合は有効フラグをセット
      effective |= hit < 100
    end
    # 命中の場合
    if hit_result == true
      # 威力 0 以外の物理攻撃の場合
      if skill.power != 0 and skill.atk_f > 0
        # ステート衝撃解除
        remove_states_shock
        # 有効フラグをセット
        effective = true
      end
      # HP からダメージを減算
      last_hp = self.hp
      self.hp -= self.damage
      effective |= self.hp != last_hp
      # ステート変化
      @state_changed = false
      effective |= states_plus(skill.plus_state_set)
      effective |= states_minus(skill.minus_state_set)
      # 威力が 0 の場合
      if skill.power == 0
        # ダメージに空文字列を設定
        self.damage = nil.to_s
        # ステートに変化がない場合
        unless @state_changed
          # ダメージに "Miss" を設定
          self.damage = "Miss"
        end
      end
    # ミスの場合
    else
      # ダメージに "Miss" を設定
      self.damage = "Miss"
    end
    # 戦闘中でない場合
    unless $game_temp.in_battle
      # ダメージに nil を設定
      self.damage = nil
    end
    # メソッド終了
    return effective
  end
  #--------------------------------------------------------------------------
  # ● アイテムの効果適用
  #     item : アイテム
  #--------------------------------------------------------------------------
  def item_effect(item)
    # クリティカルフラグをクリア
    self.critical = false
    # アイテムの効果範囲が HP 1 以上の味方で、自分の HP が 0、
    # またはアイテムの効果範囲が HP 0 の味方で、自分の HP が 1 以上の場合
    if ((item.scope == 3 or item.scope == 4) and self.hp == 0) or
       ((item.scope == 5 or item.scope == 6) and self.hp >= 1)
      # メソッド終了
      return false
    end
    # 有効フラグをクリア
    effective = false
    # コモンイベント ID が有効の場合は有効フラグをセット
    effective |= item.common_event_id > 0
    # 命中判定
    hit_result = (rand(100) < item.hit)
    # 不確実なスキルの場合は有効フラグをセット
    effective |= item.hit < 100
    # 命中の場合
    if hit_result == true
      # 回復量を計算
      recover_hp = maxhp * item.recover_hp_rate / 100 + item.recover_hp
      recover_sp = maxsp * item.recover_sp_rate / 100 + item.recover_sp
      if recover_hp < 0
        recover_hp += self.pdef * item.pdef_f / 20
        recover_hp += self.mdef * item.mdef_f / 20
        recover_hp = [recover_hp, 0].min
      end
      # 属性修正
      recover_hp *= elements_correct(item.element_set)
      recover_hp /= 100
      recover_sp *= elements_correct(item.element_set)
      recover_sp /= 100
      # 分散
      if item.variance > 0 and recover_hp.abs > 0
        amp = [recover_hp.abs * item.variance / 100, 1].max
        recover_hp += rand(amp+1) + rand(amp+1) - amp
      end
      if item.variance > 0 and recover_sp.abs > 0
        amp = [recover_sp.abs * item.variance / 100, 1].max
        recover_sp += rand(amp+1) + rand(amp+1) - amp
      end
      # 回復量の符号が負の場合
      if recover_hp < 0
        # 防御修正
        if self.guarding?
          recover_hp /= 2
        end
      end
      # HP 回復量の符号を反転し、ダメージの値に設定
      self.damage = -recover_hp
      # HP および SP を回復
      last_hp = self.hp
      last_sp = self.sp
      self.hp += recover_hp
      self.sp += recover_sp
      effective |= self.hp != last_hp
      effective |= self.sp != last_sp
      # ステート変化
      @state_changed = false
      effective |= states_plus(item.plus_state_set)
      effective |= states_minus(item.minus_state_set)
      # パラメータ上昇値が有効の場合
      if item.parameter_type > 0 and item.parameter_points != 0
        # パラメータで分岐
        case item.parameter_type
        when 1  # MaxHP
          @maxhp_plus += item.parameter_points
        when 2  # MaxSP
          @maxsp_plus += item.parameter_points
        when 3  # 腕力
          @str_plus += item.parameter_points
        when 4  # 器用さ
          @dex_plus += item.parameter_points
        when 5  # 素早さ
          @agi_plus += item.parameter_points
        when 6  # 魔力
          @int_plus += item.parameter_points
        end
        # 有効フラグをセット
        effective = true
      end
      # HP 回復率と回復量が 0 の場合
      if item.recover_hp_rate == 0 and item.recover_hp == 0
        # ダメージに空文字列を設定
        self.damage = nil.to_s
        # SP 回復率と回復量が 0、パラメータ上昇値が無効の場合
        if item.recover_sp_rate == 0 and item.recover_sp == 0 and
           (item.parameter_type == 0 or item.parameter_points == 0)
          # ステートに変化がない場合
          unless @state_changed
            # ダメージに "Miss" を設定
            self.damage = "Miss"
          end
        end
      end
    # ミスの場合
    else
      # ダメージに "Miss" を設定
      self.damage = "Miss"
    end
    # 戦闘中でない場合
    unless $game_temp.in_battle
      # ダメージに nil を設定
      self.damage = nil
    end
    # メソッド終了
    return effective
  end
  #--------------------------------------------------------------------------
  # ● スリップダメージの効果適用
  #--------------------------------------------------------------------------
  def slip_damage_effect
    # ダメージを設定
    self.damage = self.maxhp / 10
    # 分散
    if self.damage.abs > 0
      amp = [self.damage.abs * 15 / 100, 1].max
      self.damage += rand(amp+1) + rand(amp+1) - amp
    end
    # HP からダメージを減算
    self.hp -= self.damage
    # メソッド終了
    return true
  end
  #--------------------------------------------------------------------------
  # ● 属性修正の計算
  #     element_set : 属性
  #--------------------------------------------------------------------------
  def elements_correct(element_set)
    # 無属性の場合
    if element_set == []
      # 100 を返す
      return 100
    end
    # 与えられた属性の中で最も弱いものを返す
    # ※メソッド element_rate は、このクラスから継承される Game_Actor
    #   および Game_Enemy クラスで定義される
    weakest = -100
    for i in element_set
      weakest = [weakest, self.element_rate(i)].max
    end
    return weakest
  end
end

