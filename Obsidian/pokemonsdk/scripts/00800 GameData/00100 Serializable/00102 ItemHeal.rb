module GameData
  # Specific data of an healing item
  # @author Nuri Yuri
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
    class << self
      # Safely return the hp value of a heal item
      # @param id [Integer, Symbol] id of the heal item in the database
      # @return [Integer]
      def hp(id)
        return 0 unless (heal_data = Item.heal_data(id))
        return heal_data.hp
      end

      # Safely return the hp_rate value of a heal item
      # @param id [Integer, Symbol] id of the heal item in the database
      # @return [Integer]
      def hp_rate(id)
        return 0 unless (heal_data = Item.heal_data(id))
        return heal_data.hp_rate
      end

      # Safely return the pp value of a heal item
      # @param id [Integer, Symbol] id of the heal item in the database
      # @return [Integer, nil]
      def pp(id)
        return nil unless (heal_data = Item.heal_data(id))
        return heal_data.pp
      end

      # Safely return the all_pp value of a heal item
      # @param id [Integer, Symbol] id of the heal item in the database
      # @return [Integer, nil]
      def all_pp(id)
        return nil unless (heal_data = Item.heal_data(id))
        return heal_data.all_pp
      end

      # Safely return the states value of a heal item
      # @param id [Integer, Symbol] id of the heal item in the database
      # @return [Array<Integer>, nil]
      def states(id)
        return nil.to_a unless (heal_data = Item.heal_data(id))
        return heal_data.states
      end

      # Safely return the loyalty value of a heal item
      # @param id [Integer, Symbol] id of the heal item in the database
      # @return [Integer, nil]
      def loyalty(id)
        return nil unless (heal_data = Item.heal_data(id))
        return heal_data.loyalty
      end

      # Safely return the level value of a heal item
      # @param id [Integer, Symbol] id of the heal item in the database
      # @return [Integer, nil]
      def level(id)
        return nil unless (heal_data = Item.heal_data(id))
        return heal_data.level
      end

      # Safely return the boost_stat value of a heal item
      # @param id [Integer, Symbol] id of the heal item in the database
      # @return [Integer, nil]
      def boost_stat(id)
        return nil unless (heal_data = Item.heal_data(id))
        return heal_data.boost_stat
      end

      # Safely return the battle_boost value of a heal item
      # @param id [Integer, Symbol] id of the heal item in the database
      # @return [Integer, nil]
      def battle_boost(id)
        return nil unless (heal_data = Item.heal_data(id))
        return heal_data.battle_boost
      end

      # Safely return the add_pp value of a heal item
      # @param id [Integer, Symbol] id of the heal item in the database
      # @return [Integer, nil]
      def add_pp(id)
        return nil unless (heal_data = Item.heal_data(id))
        return heal_data.add_pp
      end
    end
  end
end
