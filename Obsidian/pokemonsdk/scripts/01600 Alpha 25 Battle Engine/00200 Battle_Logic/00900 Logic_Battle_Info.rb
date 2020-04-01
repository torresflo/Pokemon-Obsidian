module Battle
  class Logic
    # Class describing the informations about the battle
    class BattleInfo
      # @return [Array<Array<String>>] List of the name of the battlers according to the bank & their position
      attr_accessor :names
      # @return [Array<Array<String>>] List of the classes of the battlers according to the bank & their position
      attr_accessor :classes
      # @return [Array<Array<String>>] List of the battler (image) name of the battlers according to the bank
      attr_accessor :battlers
      # @return [Array<Array<PFM::Bag>>] List of the bags of the battlers according to the bank
      attr_accessor :bags
      # @return [Array<Array<Array<PFM::Pokemon>>>] List of the "Party" of the battlers according to the bank & their position
      attr_accessor :parties
      # @return [Integer, nil] Maximum level allowed for the battle
      attr_accessor :max_level
      # @return [Integer] Number of Pokemon fighting at the same time
      attr_accessor :vs_type
      # @return [Integer] Reason of the wild battle
      attr_accessor :wild_battle_reason
      # @return [Boolean] if the trainer battle is a "couple" battle
      attr_accessor :trainer_is_couple
      # @return [Integer] ID of the battle (for event loading)
      attr_accessor :battle_id

      # Create a new Battle Info
      # @param hash [Hash] basic info about the battle
      def initialize(hash = {})
        @names = hash[:names] || [[], []]
        @classes = hash[:classes] || [[], []]
        @battlers = hash[:battlers] || [[], []]
        @bags = hash[:bags] || [[], []]
        @parties = hash[:parties] || [[], []]
        @max_level = hash[:max_level] || nil
        @vs_type = hash[:vs_type] || 1
        @trainer_is_couple = hash[:couple] || false
        @battle_id = hash[:battle_id] || -1
      end

      # Tell if the battle is a trainer battle
      # @return [Boolean]
      def trainer_battle?
        !@names[1].empty?
      end

      # Add a party to a bank
      # @param bank [Integer] bank where the party should be defined
      # @param party [Array<PFM::Pokemon>] Pokemon of the battler
      # @param name [String, nil] name of the battler (don't set it if Wild Battle)
      # @param klass [String, nil] name of the battler (don't set it if Wild Battle)
      # @param battler [String, nil] name of the battler image (don't set it if Wild Battle)
      # @param bag [String, nil] bag used by the party
      def add_party(bank, party, name = nil, klass = nil, battler = nil, bag = nil)
        @parties[bank] ||= []
        @parties[bank] << party
        @names[bank] ||= []
        @names[bank] << name if name
        @classes[bank] ||= []
        @classes[bank] << klass if klass
        @battlers[bank] ||= []
        @battlers[bank] << battler if battler
        @bags[bank] ||= []
        @bags[bank] << (bag || PFM::Bag.new)
      end
    end
  end
end
