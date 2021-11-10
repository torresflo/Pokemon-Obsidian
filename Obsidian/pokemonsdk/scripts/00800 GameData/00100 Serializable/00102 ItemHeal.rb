module GameData
  # Specific data of an healing item
  # @author Nuri Yuri
  # @deprecated This class is deprecated in .25, please stop using it!
  class ItemHeal < Base
    # Number of HP healed by the Item
    # @return [Integer] 0 if no hp heal
    attr_accessor :hp
    # Percent of total HP the item heals
    # @return [Integer] 0 if no hp_rate heal
    attr_accessor :hp_rate
    # Number of PP the item heals on ONE move
    # @return [Integer, nil] nil if no pp add
    attr_accessor :pp
    # Number of PP the iteam heals on each moves of the Pokemon
    # @return [Integer, nil] nil if no pp add
    attr_accessor :all_pp
    # Add 1/8 of the max PP of a move (add_pp = 1) or set it to the maximum number possible (add_pp = 2)
    # @return [Integer, nil] nil if no max_pp change
    attr_accessor :add_pp
    # List of states the item heals
    # @return [Array<Integer>, nil] nil if no state heal
    attr_accessor :states
    # Number of loyalty point the item add or remove
    # @return [Integer] nil if no loyalty change
    attr_accessor :loyalty
    # Index of the stat that receive +10 EV (boost_stat < 10) or +1 EV (boost_stat >= 10, index = boost_stat % 10).
    # See GameData::EV to know the index
    # @return [Integer, nil] nil if no ev boost
    attr_accessor :boost_stat
    # Number of level the item gives to the Pokemon
    # @return [Integer, nil] nil if no level up
    attr_accessor :level
    # ID of the battle_stage stat the item boost. 0 = atk, 1 = dfe, 2 = spd, 3 = ats, 4 = dfs, 5 = eva, 6 = acc
    # @return [Integer, nil] nil if no boost
    attr_accessor :battle_boost
  end
end
