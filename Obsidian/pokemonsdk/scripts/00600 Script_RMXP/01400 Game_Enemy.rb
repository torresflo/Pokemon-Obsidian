#encoding: utf-8

#noyard
# @deprecated Not used by the core.
class Game_Enemy < Game_Battler
  # オブジェクト初期化
  def initialize(troop_id, member_index)
    super()
    @troop_id = troop_id
    @member_index = member_index
    troop = $data_troops[@troop_id]
    @enemy_id = troop.members[@member_index].enemy_id
    enemy = $data_enemies[@enemy_id]
    @battler_name = enemy.battler_name
    @battler_hue = enemy.battler_hue
    @hp = maxhp
    @sp = maxsp
    @hidden = troop.members[@member_index].hidden
    @immortal = troop.members[@member_index].immortal
  end
  # エネミー ID 取得
  def id
    return @enemy_id
  end
  # インデックス取得
  def index
    return @member_index
  end
  # 名前の取得
  def name
    return $data_enemies[@enemy_id].name
  end
  # 基本 MaxHP の取得
  def base_maxhp
    return $data_enemies[@enemy_id].maxhp
  end
  # 基本 MaxSP の取得
  def base_maxsp
    return $data_enemies[@enemy_id].maxsp
  end
  # 基本腕力の取得
  def base_str
    return $data_enemies[@enemy_id].str
  end
  # 基本器用さの取得
  def base_dex
    return $data_enemies[@enemy_id].dex
  end
  # 基本素早さの取得
  def base_agi
    return $data_enemies[@enemy_id].agi
  end
  # 基本魔力の取得
  def base_int
    return $data_enemies[@enemy_id].int
  end
  # 基本攻撃力の取得
  def base_atk
    return $data_enemies[@enemy_id].atk
  end
  # 基本物理防御の取得
  def base_pdef
    return $data_enemies[@enemy_id].pdef
  end
  # 基本魔法防御の取得
  def base_mdef
    return $data_enemies[@enemy_id].mdef
  end
  # 基本回避修正の取得
  def base_eva
    return $data_enemies[@enemy_id].eva
  end
  # 通常攻撃 攻撃側アニメーション ID の取得
  def animation1_id
    return $data_enemies[@enemy_id].animation1_id
  end
  # 通常攻撃 対象側アニメーション ID の取得
  def animation2_id
    return $data_enemies[@enemy_id].animation2_id
  end
  # 属性補正値の取得
  def element_rate(element_id)
    # 属性有効度に対応する数値を取得
    table = [0,200,150,100,50,0,-100]
    result = table[$data_enemies[@enemy_id].element_ranks[element_id]]
    # ステートでこの属性が防御されている場合は半減
    for i in @states
      if $data_states[i].guard_element_set.include?(element_id)
        result /= 2
      end
    end
    # メソッド終了
    return result
  end
  # ステート有効度の取得
  def state_ranks
    return $data_enemies[@enemy_id].state_ranks
  end
  # ステート防御判定
  #     state_id : ステート ID
  def state_guard?(state_id)
    return false
  end
  # 通常攻撃の属性取得
  def element_set
    return []
  end
  # 通常攻撃のステート変化 (+) 取得
  def plus_state_set
    return []
  end
  # 通常攻撃のステート変化 (-) 取得
  def minus_state_set
    return []
  end
  # アクションの取得
  def actions
    return $data_enemies[@enemy_id].actions
  end
  # EXP の取得
  def exp
    return $data_enemies[@enemy_id].exp
  end
  # ゴールドの取得
  def gold
    return $data_enemies[@enemy_id].gold
  end
  # アイテム ID の取得
  def item_id
    return $data_enemies[@enemy_id].item_id
  end
  # 武器 ID の取得
  def weapon_id
    return $data_enemies[@enemy_id].weapon_id
  end
  # 防具 ID の取得
  def armor_id
    return $data_enemies[@enemy_id].armor_id
  end
  # トレジャー出現率の取得
  def treasure_prob
    return $data_enemies[@enemy_id].treasure_prob
  end
  # バトル画面 X 座標の取得
  def screen_x
    return $data_troops[@troop_id].members[@member_index].x
  end
  # バトル画面 Y 座標の取得
  def screen_y
    return $data_troops[@troop_id].members[@member_index].y
  end
  # バトル画面 Z 座標の取得
  def screen_z
    return screen_y
  end
  # 逃げる
  def escape
    # ヒドゥンフラグをセット
    @hidden = true
    # カレントアクションをクリア
    self.current_action.clear
  end
  # 変身
  def transform(enemy_id)
    # エネミー ID を変更
    @enemy_id = enemy_id
    # バトラー グラフィックを変更
    @battler_name = $data_enemies[@enemy_id].battler_name
    @battler_hue = $data_enemies[@enemy_id].battler_hue
    # アクション再作成
    make_action
  end
  # アクション作成
  def make_action

  end
  # exclude pointless actions
  def exclude_pointless_actions(action)
    return false
  end
end
