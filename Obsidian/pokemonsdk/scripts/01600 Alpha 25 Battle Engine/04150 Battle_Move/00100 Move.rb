module Battle
  # Generic class describing a move
  class Move
    # @return [Hash{Symbol => Class}] list of the registered moves
    REGISTERED_MOVES = Hash.new(Move)

    # @return [Integer] number of pp the move currently has
    attr_reader :pp
    # @return [Integer] maximum number of ppg the move currently has
    attr_reader :ppmax
    # @return [Boolean] if the move has been used
    attr_accessor :used
    # @return [Integer] Number of time the move was used consecutively
    attr_accessor :consecutive_use_count
    # @return [Battle::Logic]
    attr_reader :logic
    # @return [Battle::Scene]
    attr_reader :scene

    # Create a new move
    # @param id [Integer] ID of the move in the database
    # @param pp [Integer] number of pp the move currently has
    # @param ppmax [Integer] maximum number of pp the move currently has
    # @param scene [Battle::Scene] current battle scene
    def initialize(id, pp, ppmax, scene)
      @id = id
      @pp = pp
      @ppmax = ppmax
      @used = false
      @consecutive_use_count = 0
      @effectiveness = 1
      @scene = scene
      @logic = scene.logic
    end

    def to_s
      "<PM:#{name},#{@consecutive_use_count} pp=#{@pp}>"
    end
    alias inspect to_s

    # Return the data of the skill
    # @return [GameData::Skill]
    def data
      GameData::Skill[@id]
    end

    # Return the name of the skill
    def name
      text_get(6, @id)
    end

    # Return the skill description
    # @return [String]
    def description
      text_get(7, @id)
    end

    # Return the text of the PP of the skill
    # @return [String]
    def pp_text
      "#{@pp} / #{@ppmax}"
    end

    # Return the actual base power of the move
    # @return [Integer]
    def power
      data.power
    end

    # Return the text of the power of the skill (for the UI)
    # @return [String]
    def power_text
      power = data.power
      return text_get(11, 12) if power == 0

      return power.to_s
    end

    # Return the current type of the move
    # @return [Integer]
    def type
      data.type
    end

    # Return the current accuracy of the move
    # @return [Integer]
    def accuracy
      data.accuracy
    end

    # Return the accuracy text of the skill (for the UI)
    # @return [String]
    def accuracy_text
      acc = data.accuracy
      return text_get(11, 12) if acc == 0

      return acc.to_s
    end

    # Return the priority of the skill
    # @return [Integer]
    def priority
      return data.priority
    end

    # Return the chance of effect of the skill
    # @return [Integer]
    def effect_chance
      return data.effect_chance
    end

    # Return the status effect the skill can inflict
    # @return [Integer, nil]
    def status_effect
      return data.status
    end

    # Return the target symbol the skill can aim
    # @return [Symbol]
    def target
      return data.target
    end

    # Return the critical rate index of the skill
    # @return [Integer]
    def critical_rate
      return data.critical_rate
    end

    # Is the skill affected by gravity
    # @return [Boolean]
    def gravity_affected?
      return data.gravity
    end

    # Return the stat tage modifier the skill can apply
    # @return [Array<Integer>]
    def battle_stage_mod
      return data.battle_stage_mod
    end

    # Is the skill direct ?
    # @return [Boolean]
    def direct?
      return data.direct
    end

    # Is the skill affected by Mirror Move
    # @return [Boolean]
    def mirror_move_affected?
      return data.mirror_move
    end

    # Is the skill blocable by Protect and skill like that ?
    # @return [Boolean]
    def blocable?
      return data.blocable
    end

    # Does the skill has recoil ?
    # @return [Boolean]
    def recoil?
      false
    end

    # Is the skill a punching move ?
    # @return [Boolean]
    def punching?
      return data.punch
    end

    # Is the skill a sound attack ?
    # @return [Boolean]
    def sound_attack?
      return data.sound_attack
    end

    # Does the skill unfreeze
    # @return [Boolean]
    def unfreeze?
      return data.unfreeze
    end

    # Does the skill trigger the king rock
    # @return [Boolean]
    def trigger_king_rock?
      return data.status != 7
    end

    # Is the skill snatchable ?
    # @return [Boolean]
    def snatchable?
      return data.snatchable
    end

    # Is the skill affected by magic coat ?
    # @return [Boolean]
    def magic_coat_affected?
      return data.magic_coat_affected
    end

    # Is the skill physical ?
    # @return [Boolean]
    def physical?
      return data.atk_class == 1
    end

    # Is the skill special ?
    # @return [Boolean]
    def special?
      return data.atk_class == 2
    end

    # Is the skill status ?
    # @return [Boolean]
    def status?
      return data.atk_class == 3
    end

    # Return the class of the skill (used by the UI)
    # @return [Integer] 1, 2, 3
    def atk_class
      return data.atk_class
    end

    # Return the symbol of the move in the database
    # @return [Symbol]
    def db_symbol
      return data.db_symbol
    end

    # Change the PP
    # @param value [Integer] the new pp value
    def pp=(value)
      @pp = value.to_i
      @pp = @ppmax if @pp > @ppmax
      @pp = 0 if @pp < 0
    end

    # Was the move a critical hit
    # @return [Boolean]
    def critical_hit?
      @critical
    end

    # Was the move super effective ?
    # @return [Boolean]
    def super_effective?
      @effectiveness >= 2
    end

    # Was the move not very effective ?
    # @return [Boolean]
    def not_very_effective?
      @effectiveness > 0 && @effectiveness < 1
    end

    # Was the move not affective
    # @return [Boolean]
    def not_affective?
      @effectiveness == 0
    end

    class << self
      # Retrieve a registered move
      # @param symbol [Symbol] be_method of the move
      # @return [Class]
      def [](symbol)
        REGISTERED_MOVES[symbol]
      end

      # Register a move
      # @param symbol [Symbol] be_method of the move
      # @param klass [Class] class of the move
      def register(symbol, klass)
        raise format('%<klass>s is not a "Move" and cannot be registered', klass: klass) unless klass.ancestors.include?(Move)

        REGISTERED_MOVES[symbol] = klass
      end
    end
  end
end
