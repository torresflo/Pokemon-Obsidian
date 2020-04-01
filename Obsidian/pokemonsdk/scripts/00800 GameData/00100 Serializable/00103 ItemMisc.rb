module GameData
  # Miscellaneous Item Data structure
  # @author Nuri Yuri
  class ItemMisc < Base
    # ID of the common event to call when using this item
    # @return [Integer]
    attr_accessor :event_id
    # Number of step the item repel lower level Pokemon
    # @return [Integer]
    attr_accessor :repel_count
    # ID of the CT if the item teach a skill
    # @return [Integer, nil]
    attr_accessor :ct_id
    # ID of the CS if the item teach a skill
    # @return [Integer, nil]
    attr_accessor :cs_id
    # ID of the skill in the database the item teach to a Pokemon
    # @return [Integer, nil]
    attr_accessor :skill_learn
    # If the item is an evolutive stone
    # @return [Boolean]
    attr_accessor :stone
    # If the item helps the player to flee a wild battle
    # @return [Boolean]
    attr_accessor :flee
    # ID of the Pokemon on which the item can be used
    # @return [Integer, nil]
    attr_accessor :need_user_id
    # ID of the attack class (1 = Physical, 2 = Special, 3 = Status) the item need to *1.1 the power
    # @return [Integer, nil]
    attr_accessor :check_atk_class
    # First possible skill type the item can *1.2 its power
    # @return [Integer, nil]
    attr_accessor :powering_skill_type1
    # Second possible skill type the item can *1.2 its power
    # @return [Integer, nil]
    attr_accessor :powering_skill_type2
    # List of Pokemon ids the item can *2 the power of their physical moves
    # @return [Array<Integer>, nil]
    attr_accessor :need_ids_ph_2
    # List of Pokemon ids the item can *2 the power of their special moves
    # @return [Array<Integer>, nil]
    attr_accessor :need_ids_sp_2
    # List of Pokemon ids the item can *2 the power of their special moves
    # @return [Array<Integer>, nil]
    attr_accessor :need_ids_sp_1_5
    # Accuracy multiplier the item gives to the Pokemon
    # @return [Integer, nil]
    attr_accessor :acc
    # Evade multiplier the item gives to the Pokemon
    # @return [Integer, nil]
    attr_accessor :eva
    # Informations related to the berry
    #
    #   bonus: Array(Integer, Integer, Integer, Integer, Integer, Integer) = list of EV add
    #   type: Integer type id the berry change the skill (natural gift) or reduce the power by two on super effective
    #   power: Integer power of the natural gift move with this berry
    #   time_to_grow: Integer # The time the berry need to grow
    # @return [Hash, nil]
    attr_accessor :berry
    class << self
      # Safely return the event_id value of a special item
      # @param id [Integer, Symbol] id of the special item in the database
      # @return [Integer]
      def event_id(id)
        return 0 unless (misc_data = Item.misc_data(id))
        return misc_data.event_id
      end

      # Safely return the repel_count value of a special item
      # @param id [Integer, Symbol] id of the special item in the database
      # @return [Integer]
      def repel_count(id)
        return 0 unless (misc_data = Item.misc_data(id))
        return misc_data.repel_count
      end

      # Safely return the ct_id value of a special item
      # @param id [Integer, Symbol] id of the special item in the database
      # @return [Integer, nil]
      def ct_id(id)
        return nil unless (misc_data = Item.misc_data(id))
        return misc_data.ct_id
      end

      # Safely return the cs_id value of a special item
      # @param id [Integer, Symbol] id of the special item in the database
      # @return [Integer, nil]
      def cs_id(id)
        return nil unless (misc_data = Item.misc_data(id))
        return misc_data.cs_id
      end

      # Safely return the skill_learn value of a special item
      # @param id [Integer, Symbol] id of the special item in the database
      # @return [Integer, nil]
      def skill_learn(id)
        return nil unless (misc_data = Item.misc_data(id))
        return misc_data.skill_learn
      end

      # Safely return the stone value of a special item
      # @param id [Integer, Symbol] id of the special item in the database
      # @return [Boolean]
      def stone(id)
        return false unless (misc_data = Item.misc_data(id))
        return misc_data.stone
      end

      # Safely return the flee value of a special item
      # @param id [Integer, Symbol] id of the special item in the database
      # @return [Boolean]
      def flee(id)
        return false unless (misc_data = Item.misc_data(id))
        return misc_data.flee
      end

      # Safely return the berry value of a special item
      # @param id [Integer, Symbol] id of the special item in the database
      # @return [Hash, nil]
      def berry(id)
        return nil unless (misc_data = Item.misc_data(id))
        return misc_data.berry
      end

      # Safely return the need_user_id value of a special item
      # @param id [Integer, Symbol] id of the special item in the database
      # @return [Integer, nil]
      def need_user_id(id)
        return nil unless (misc_data = Item.misc_data(id))
        return misc_data.need_user_id
      end

      # Safely return the check_atk_class value of a special item
      # @param id [Integer, Symbol] id of the special item in the database
      # @return [Integer, nil]
      def check_atk_class(id)
        return nil unless (misc_data = Item.misc_data(id))
        return misc_data.check_atk_class
      end

      # Safely return the powering_skill_type1 value of a special item
      # @param id [Integer, Symbol] id of the special item in the database
      # @return [Integer, nil]
      def powering_skill_type1(id)
        return nil unless (misc_data = Item.misc_data(id))
        return misc_data.powering_skill_type1
      end

      # Safely return the powering_skill_type2 value of a special item
      # @param id [Integer, Symbol] id of the special item in the database
      # @return [Integer, nil]
      def powering_skill_type2(id)
        return nil unless (misc_data = Item.misc_data(id))
        return misc_data.powering_skill_type2
      end

      # Safely return the need_ids_ph_2 value of a special item
      # @param id [Integer, Symbol] id of the special item in the database
      # @return [Array<Integer>, nil] list of Pokemon ids
      def need_ids_ph_2(id)
        return nil unless (misc_data = Item.misc_data(id))
        return misc_data.need_ids_ph_2
      end

      # Safely return the need_ids_sp_2 value of a special item
      # @param id [Integer, Symbol] id of the special item in the database
      # @return [Array<Integer>, nil] lis of Pokemon ids
      def need_ids_sp_2(id)
        return nil unless (misc_data = Item.misc_data(id))
        return misc_data.need_ids_sp_2
      end

      # Safely return the need_ids_sp_1_5 value of a special item
      # @param id [Integer, Symbol] id of the special item in the database
      # @return [Array<Integer>, nil]
      def need_ids_sp_1_5(id)
        return nil unless (misc_data = Item.misc_data(id))
        return misc_data.need_ids_sp_1_5
      end

      # Safely return the acc value of a special item
      # @param id [Integer, Symbol] id of the special item in the database
      # @return [Integer, nil]
      def acc(id)
        return nil unless (misc_data = Item.misc_data(id))
        return misc_data.acc
      end

      # Safely return the eva value of a special item
      # @param id [Integer, Symbol] id of the special item in the database
      # @return [Integer, nil]
      def eva(id)
        return nil unless (misc_data = Item.misc_data(id))
        return misc_data.eva
      end
    end
  end
end
