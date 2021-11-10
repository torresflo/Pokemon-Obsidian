module GameData
  # Miscellaneous Item Data structure
  # @author Nuri Yuri
  # @deprecated This class is deprecated in .25, please stop using it!
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
  end
end
