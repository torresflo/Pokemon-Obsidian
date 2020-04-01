#encoding: utf-8

# The RPG Maker description of a Party
class Game_Party
  attr_reader   :actors                   # アクター
  attr_accessor   :gold                     # ゴールド
  attr_accessor   :steps                    # 歩数
  # Default initialization
  def initialize
    # アクターの配列を作成
    @actors = []
    # ゴールドと歩数を初期化
    @gold = 0
    @steps = 0
    # アイテム、武器、防具の所持数ハッシュを作成
    @items = {}
    @weapons = {}
    @armors = {}
  end
  # Set up the party with default members
  def setup_starting_members
    @actors = []
    log_info("Initial party members : #{$data_system.party_members}")
    for i in $data_system.party_members
      @actors.push($game_actors[i])
    end
  end
  # Refresh the game party with right actors according to the RMXP data
  def refresh
    # ゲームデータをロードした直後はアクターオブジェクトが
    # $game_actors から分離してしまっている。
    # ロードのたびにアクターを再設定することで問題を回避する。
    new_actors = []
    for i in 0...@actors.size
      if $data_actors[@actors[i].id] != nil
        new_actors.push($game_actors[@actors[i].id])
      end
    end
    @actors = new_actors
  end
  # Returns the max level in the team
  # @return [Integer] 0 if no actors
  def max_level
    # パーティ人数が 0 人の場合
    if @actors.size == 0
      return 0
    end
    # ローカル変数 level を初期化
    level = 0
    # パーティメンバーの最大レベルを求める
    for actor in @actors
      if level < actor.level
        level = actor.level
      end
    end
    return level
  end
  # Add an actor to the party
  # @param actor_id [Integer] the id of the actor in the database
  def add_actor(actor_id)
    # アクターを取得
    actor = $game_actors[actor_id]
    # パーティ人数が 4 人未満で、このアクターがパーティにいない場合
    if @actors.size < 4 and not @actors.include?(actor)
      # アクターを追加
      @actors.push(actor)
      # プレイヤーをリフレッシュ
      $game_player.refresh
    end
  end
  # Remove an actor of the party
  # @param actor_id [Integer] the id of the actor in the database
  def remove_actor(actor_id)
    # アクターを削除
    @actors.delete($game_actors[actor_id])
    # プレイヤーをリフレッシュ
    $game_player.refresh
  end
  # gives gold to the party
  # @param n [Integer] amount of gold
  def gain_gold(n)
    @gold = [[@gold + n, 0].max, 9999999].min
  end
  # takes gold from the party
  # @param n [Integer] amount of gold
  def lose_gold(n)
    # 数値を逆転して gain_gold を呼ぶ
    gain_gold(-n)
  end
  # Increase steps of the party
  def increase_steps
    @steps = [@steps + 1, 9999999].min
  end
  # Returns the amount of a specific item the party has
  # @param item_id [Integer] id of the item in the database
  # @return [Integer]
  def item_number(item_id)
    # ハッシュに個数データがあればその数値を、なければ 0 を返す
    return @items.include?(item_id) ? @items[item_id] : 0
  end
  # Returns the amount of a specific weapon the party has
  # @param weapon_id [Integer] the id of the weapon in the database
  # @return [Integer]
  def weapon_number(weapon_id)
    # ハッシュに個数データがあればその数値を、なければ 0 を返す
    return @weapons.include?(weapon_id) ? @weapons[weapon_id] : 0
  end
  # Returns the amount of a specific armor the party has
  # @param armor_id [Integer] the id of the armor in the database
  # @return [Integer]
  def armor_number(armor_id)
    # ハッシュに個数データがあればその数値を、なければ 0 を返す
    return @armors.include?(armor_id) ? @armors[armor_id] : 0
  end
  # アイテムの増加 (減少)
  #     item_id : アイテム ID
  #     n       : 個数
  def gain_item(item_id, n)
    # ハッシュの個数データを更新
    if item_id > 0
      @items[item_id] = [[item_number(item_id) + n, 0].max, 99].min
    end
  end
  # 武器の増加 (減少)
  #     weapon_id : 武器 ID
  #     n         : 個数
  def gain_weapon(weapon_id, n)
    # ハッシュの個数データを更新
    if weapon_id > 0
      @weapons[weapon_id] = [[weapon_number(weapon_id) + n, 0].max, 99].min
    end
  end
  # 防具の増加 (減少)
  #     armor_id : 防具 ID
  #     n        : 個数
  def gain_armor(armor_id, n)
    # ハッシュの個数データを更新
    if armor_id > 0
      @armors[armor_id] = [[armor_number(armor_id) + n, 0].max, 99].min
    end
  end
  # アイテムの減少
  #     item_id : アイテム ID
  #     n       : 個数
  def lose_item(item_id, n)
    # 数値を逆転して gain_item を呼ぶ
    gain_item(item_id, -n)
  end
  # 武器の減少
  #     weapon_id : 武器 ID
  #     n         : 個数
  def lose_weapon(weapon_id, n)
    # 数値を逆転して gain_weapon を呼ぶ
    gain_weapon(weapon_id, -n)
  end
  # 防具の減少
  #     armor_id : 防具 ID
  #     n        : 個数
  def lose_armor(armor_id, n)
    # 数値を逆転して gain_armor を呼ぶ
    gain_armor(armor_id, -n)
  end
  # アイテムの使用可能判定
  #     item_id : アイテム ID
  def item_can_use?(item_id)
    # アイテムの個数が 0 個の場合
    if item_number(item_id) == 0
      # 使用不能
      return false
    end
    # 使用可能時を取得
    occasion = $data_items[item_id].occasion
    # バトルの場合
    if $game_temp.in_battle
      # 使用可能時が 0 (常時) または 1 (バトルのみ) なら使用可能
      return (occasion == 0 or occasion == 1)
    end
    # 使用可能時が 0 (常時) または 2 (メニューのみ) なら使用可能
    return (occasion == 0 or occasion == 2)
  end
  # 全員のアクションクリア
  def clear_actions
    # パーティ全員のアクションをクリア
    for actor in @actors
      actor.current_action.clear
    end
  end
  # コマンド入力可能判定
  def inputable?
    # 一人でもコマンド入力可能なら true を返す
    for actor in @actors
      if actor.inputable?
        return true
      end
    end
    return false
  end
  # 全滅判定
  def all_dead?
    # パーティ人数が 0 人の場合
    if $game_party.actors.size == 0
      return false
    end
    # HP 0 以上のアクターがパーティにいる場合
    for actor in @actors
      if actor.hp > 0
        return false
      end
    end
    # 全滅
    return true
  end
  # スリップダメージチェック (マップ用)
  def check_map_slip_damage
    for actor in @actors
      if actor.hp > 0 and actor.slip_damage?
        actor.hp -= [actor.maxhp / 100, 1].max
        if actor.hp == 0
          $game_system.se_play($data_system.actor_collapse_se)
        end
        $game_screen.start_flash(Color.new(255,0,0,128), 4)
        $game_temp.gameover = $game_party.all_dead?
      end
    end
  end
  # 対象アクターのランダムな決定
  #     hp0 : HP 0 のアクターに限る
  def random_target_actor(hp0 = false)
    # ルーレットを初期化
    roulette = []
    # ループ
    for actor in @actors
      # 条件に該当する場合
      if (not hp0 and actor.exist?) or (hp0 and actor.hp0?)
        # アクターのクラスの [位置] を取得
        position = $data_classes[actor.class_id].position
        # 前衛のとき n = 4、中衛のとき n = 3、後衛のとき n = 2
        n = 4 - position
        # ルーレットにアクターを n 回追加
        n.times do
          roulette.push(actor)
        end
      end
    end
    # ルーレットのサイズが 0 の場合
    if roulette.size == 0
      return nil
    end
    # ルーレットを回し、アクターを決定
    return roulette[rand(roulette.size)]
  end
  # 対象アクターのランダムな決定 (HP 0)
  def random_target_actor_hp0
    return random_target_actor(true)
  end
  # 対象アクターのスムーズな決定
  #     actor_index : アクターインデックス
  def smooth_target_actor(actor_index)
    # アクターを取得
    actor = @actors[actor_index]
    # アクターが存在する場合
    if actor != nil and actor.exist?
      return actor
    end
    # ループ
    for actor in @actors
      # アクターが存在する場合
      if actor.exist?
        return actor
      end
    end
  end
end
