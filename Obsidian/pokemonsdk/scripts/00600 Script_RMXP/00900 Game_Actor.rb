#encoding: utf-8

# Describe a player
class Game_Actor < Game_Battler
  attr_reader   :name                     # 名前
  attr_reader   :character_name           # キャラクター ファイル名
  attr_reader   :character_hue            # キャラクター 色相
  attr_reader   :battler_name #Name of the battler
  attr_reader   :class_id                 # クラス ID
  attr_reader   :weapon_id                # 武器 ID
  attr_reader   :armor1_id                # 盾 ID
  attr_reader   :armor2_id                # 頭防具 ID
  attr_reader   :armor3_id                # 体防具 ID
  attr_reader   :armor4_id                # 装飾品 ID
  attr_reader   :level                    # レベル
  attr_reader   :exp                      # EXP
  attr_reader   :skills                   # スキル
  # Initialize a new Game_Actor
  # @param actor_id [Integer] the id of the actor in the database
  def initialize(actor_id)
    super()
    setup(actor_id)
  end
  # setup the Game_Actor object
  # @param actor_id [Integer] the id of the actor in the database
  def setup(actor_id)
    actor = $data_actors[actor_id]
    @actor_id = actor_id
    @name = actor.name
    @character_name = actor.character_name
    @character_hue = actor.character_hue
    @battler_name = actor.battler_name
    @battler_hue = actor.battler_hue
  end
  # id of the Game_Actor in the database
  # @return [Integer]
  def id
    return @actor_id
  end
  # index of the Game_Actor in the $game_party.
  # @return [Integer, nil]
  def index
    return $game_party.actors.index(self)
  end
  # @deprecated will be removed.
  def make_exp_list

  end
  # @deprecated will be removed.
  def element_rate(element_id)
    return 1
  end
  # @deprecated will be removed.
  def state_ranks
    return 0
  end
  # @deprecated will be removed.
  def state_guard?(state_id)
    return false
  end
  # @deprecated will be removed.
  def element_set
    return []
  end
  # @deprecated will be removed.
  def plus_state_set
    return []
  end
  # @deprecated will be removed.
  def minus_state_set
    return []
  end
  # @deprecated will be removed.
  def maxhp
    return 1
  end
  # @deprecated will be removed.
  def base_maxhp
    return 1
  end
  # @deprecated will be removed.
  def base_maxsp
    return 1
  end
  # @deprecated will be removed.
  def base_str
    return 1
  end
  # @deprecated will be removed.
  def base_dex
    return 1
  end
  # @deprecated will be removed.
  def base_agi
    return 1
  end
  # @deprecated will be removed.
  def base_int
    return 1
  end
  # @deprecated will be removed.
  def base_atk
    return 1
  end
  # @deprecated will be removed.
  def base_pdef
    return 1
  end
  # @deprecated will be removed.
  def base_mdef
    return 1
  end
  # @deprecated will be removed.
  def base_eva
    return 1
  end
  # @deprecated will be removed.
  def animation1_id
    return 0
  end
  # @deprecated will be removed.
  def animation2_id
    return 0
  end
  # @deprecated will be removed.
  def class_name
    return nil.to_s
  end
  # @deprecated will be removed.
  def exp_s
    return nil.to_s
  end
  # @deprecated will be removed.
  def next_exp_s
    return nil.to_s
  end
  # @deprecated will be removed.
  def next_rest_exp_s
    return nil.to_s
  end
  # @deprecated will be removed.
  def update_auto_state(old_armor, new_armor)

  end
  # @deprecated will be removed.
  def equip_fix?(equip_type)
    return false
  end
  # @deprecated will be removed.
  def equip(equip_type, id)

  end
  # @deprecated will be removed.
  def equippable?(item)
    return false
  end
  # @deprecated will be removed.
  def exp=(exp)

  end
  # @deprecated will be removed.
  def level=(level)

  end
  # @deprecated will be removed.
  def learn_skill(skill_id)

  end
  # @deprecated will be removed.
  def forget_skill(skill_id)

  end
  # @deprecated will be removed.
  def skill_learn?(skill_id)
    return false
  end
  # @deprecated will be removed.
  def skill_can_use?(skill_id)
    return false
  end
  # sets the name of the Game_Actor
  # @param name [String] the name
  def name=(name)
    @name = name
  end
  # @deprecated will be removed.
  def class_id=(class_id)

  end
  # Update the graphics of the Game_Actor
  # @param character_name [String] name of the character in Graphics/Characters
  # @param character_hue [0] ignored by the cache
  # @param battler_name [String] name of the battler in Graphics/Battlers
  # @param battler_hue [0] ignored by the cache
  def set_graphic(character_name, character_hue, battler_name, battler_hue)
    @character_name = character_name
    @character_hue = character_hue
    @battler_name = battler_name
    @battler_hue = battler_hue
  end
  # @deprecated will be removed.
  def screen_x
    return 0
  end
  # @deprecated will be removed.
  def screen_y
    return 464
  end
  # @deprecated will be removed.
  def screen_z
    return 0
  end
  # @deprecated will be removed.
  def base_maxhp
    return 1
  end
  # @deprecated will be removed.
  def base_maxsp
    return 1
  end
  # @deprecated will be removed.
  def base_str
    return 1
  end
  # @deprecated will be removed.
  def base_dex
    return 1
  end
  # @deprecated will be removed.
  def base_agi
    return 1
  end
  # @deprecated will be removed.
  def base_int
    return 1
  end
  # @deprecated will be removed.
  def base_atk
    return 1
  end
  # @deprecated will be removed.
  def base_pdef
    return 1
  end
  # @deprecated will be removed.
  def base_mdef
    return 1
  end
end
