#encoding: utf-8

# Class that describe a troop of enemies
class Game_Troop
  # Default initializer.
  def initialize
    # エネミーの配列を作成
    @enemies = []
  end
  # Returns the list of enemies
  # @return [Array<Game_Enemy>]
  def enemies
    return @enemies
  end
  # Setup the troop with a troop from the database
  # @param troop_id [Integer] the id of the troop in the database
  def setup(troop_id)
    # トループに設定されているエネミーを配列に設定
    @enemies = []
    troop = $data_troops[troop_id]
    for i in 0...troop.members.size
      enemy = $data_enemies[troop.members[i].enemy_id]
      if enemy != nil
        @enemies.push(Game_Enemy.new(troop_id, i))
      end
    end
  end
  # Select a random enemy
  # @param hp0 [Boolean] if true, select an enemy that has 0 hp
  # @return [Game_Enemy, nil]
  def random_target_enemy(hp0 = false)
    # ルーレットを初期化
    roulette = []
    # ループ
    for enemy in @enemies
      # 条件に該当する場合
      if (not hp0 and enemy.exist?) or (hp0 and enemy.hp0?)
        # ルーレットにエネミーを追加
        roulette.push(enemy)
      end
    end
    # ルーレットのサイズが 0 の場合
    if roulette.size == 0
      return nil
    end
    # ルーレットを回し、エネミーを決定
    return roulette[rand(roulette.size)]
  end
  # Select a random enemy that has 0 hp
  # @return [Game_Enemy, nil]
  def random_target_enemy_hp0
    return random_target_enemy(true)
  end
end

