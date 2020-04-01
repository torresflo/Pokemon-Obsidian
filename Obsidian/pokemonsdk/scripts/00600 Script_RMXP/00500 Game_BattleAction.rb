#encoding: utf-8

#noyard
# @deprecated No longer used...
class Game_BattleAction
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :speed                    # スピード
  attr_accessor :kind                     # 種別 (基本 / スキル / アイテム)
  attr_accessor :basic                    # 基本 (攻撃 / 防御 / 逃げる)
  attr_accessor :skill_id                 # スキル ID
  attr_accessor :item_id                  # アイテム ID
  attr_accessor :target_index             # 対象インデックス
  attr_accessor :forcing                  # 強制フラグ
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    clear
  end
  #--------------------------------------------------------------------------
  # ● クリア
  #--------------------------------------------------------------------------
  def clear
    @speed = 0
    @kind = 0
    @basic = 3
    @skill_id = 0
    @item_id = 0
    @target_index = -1
    @forcing = false
  end
  #--------------------------------------------------------------------------
  # ● 有効判定
  #--------------------------------------------------------------------------
  def valid?
    return (not (@kind == 0 and @basic == 3))
  end
  #--------------------------------------------------------------------------
  # ● 味方単体用判定
  #--------------------------------------------------------------------------
  def for_one_friend?
    # 種別がスキルで、効果範囲が味方単体 (HP 0 を含む) の場合
    if @kind == 1 and [3, 5].include?($data_skills[@skill_id].scope)
      return true
    end
    # 種別がアイテムで、効果範囲が味方単体 (HP 0 を含む) の場合
    if @kind == 2 and [3, 5].include?($data_items[@item_id].scope)
      return true
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● 味方単体用 (HP 0) 判定
  #--------------------------------------------------------------------------
  def for_one_friend_hp0?
    # 種別がスキルで、効果範囲が味方単体 (HP 0 のみ) の場合
    if @kind == 1 and [5].include?($data_skills[@skill_id].scope)
      return true
    end
    # 種別がアイテムで、効果範囲が味方単体 (HP 0 のみ) の場合
    if @kind == 2 and [5].include?($data_items[@item_id].scope)
      return true
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ● ランダムターゲット (アクター用)
  #--------------------------------------------------------------------------
  def decide_random_target_for_actor
    # 効果範囲で分岐
    if for_one_friend_hp0?
      battler = $game_party.random_target_actor_hp0
    elsif for_one_friend?
      battler = $game_party.random_target_actor
    else
      battler = $game_troop.random_target_enemy
    end
    # 対象が存在するならインデックスを取得し、
    # 対象が存在しない場合はアクションをクリア
    if battler != nil
      @target_index = battler.index
    else
      clear
    end
  end
  #--------------------------------------------------------------------------
  # ● ランダムターゲット (エネミー用)
  #--------------------------------------------------------------------------
  def decide_random_target_for_enemy
    # 効果範囲で分岐
    if for_one_friend_hp0?
      battler = $game_troop.random_target_enemy_hp0
    elsif for_one_friend?
      battler = $game_troop.random_target_enemy
    else
      battler = $game_party.random_target_actor
    end
    # 対象が存在するならインデックスを取得し、
    # 対象が存在しない場合はアクションをクリア
    if battler != nil
      @target_index = battler.index
    else
      clear
    end
  end
  #--------------------------------------------------------------------------
  # ● ラストターゲット (アクター用)
  #--------------------------------------------------------------------------
  def decide_last_target_for_actor
    # 効果範囲が味方単体ならアクター、それ以外ならエネミー
    if @target_index == -1
      battler = nil
    elsif for_one_friend?
      battler = $game_party.actors[@target_index]
    else
      battler = $game_troop.enemies[@target_index]
    end
    # 対象が存在しない場合はアクションをクリア
    if battler == nil or not battler.exist?
      clear
    end
  end
  #--------------------------------------------------------------------------
  # ● ラストターゲット (エネミー用)
  #--------------------------------------------------------------------------
  def decide_last_target_for_enemy
    # 効果範囲が味方単体ならエネミー、それ以外ならアクター
    if @target_index == -1
      battler = nil
    elsif for_one_friend?
      battler = $game_troop.enemies[@target_index]
    else
      battler = $game_party.actors[@target_index]
    end
    # 対象が存在しない場合はアクションをクリア
    if battler == nil or not battler.exist?
      clear
    end
  end
end
