module GameData
  # Data structure of Pokemon moves
  # @author Nuri Yuri
  class Skill < Base
    # ID of the common event called when used on map
    # @return [Integer]
    attr_accessor :map_use
    # Symbol of the method to call in the Battle Engine to perform the move
    # @return [Symbol, nil]
    attr_accessor :be_method
    # Type of the move
    # @return [Integer]
    attr_accessor :type
    # Power of the move
    # @return [Integer]
    attr_accessor :power
    # Accuracy of the move
    # @return [Integer]
    attr_accessor :accuracy
    # Maximum amount of PP the move has when unused
    # @return [Integer]
    attr_accessor :pp_max
    # The Pokemon targeted by the move
    # @return [Symbol]
    attr_accessor :target
    # Kind of move 1 = Physical, 2 = Special, 3 = Status
    # @return [Integer]
    attr_accessor :atk_class
    # Critical rate indicator : 0 => 0, 1 => 6.25%, 2 => 12.5%, 3 => 25%, 4 => 33%, 5 => 50%, 6 => 100%
    # @return [Integer]
    attr_accessor :critical_rate
    # Priority of the move
    # @return [Integer]
    attr_accessor :priority
    # If the move makes conctact.
    # PokeAPI Prose: User touches the target.  This triggers some abilities (e.g., []{ability:static}) and
    # items (e.g., []{item:sticky-barb}).
    # @return [Boolean]
    attr_accessor :direct
    alias contact direct
    alias contact= direct=
    # If the move is a charging move
    # PokeAPI Prose: This move has a charging turn that can be skipped with a []{item:power-herb}.
    # @return [Boolean]
    attr_accessor :charge
    # If the move requires recharging turn
    # PokeAPI Prose : The turn after this move is used, the Pokemon's action is skipped so it can recharge.
    # @return [Boolean]
    attr_accessor :recharge
    # If the move is affected by Detect or Protect
    # PokeAPI Prose : This move will not work if the target has used []{move:detect} or []{move:protect} this turn.
    # @return [Boolean]
    attr_accessor :blocable
    alias protect blocable
    alias protect= blocable=
    # If the move is affected by Snatch
    # PokeAPI Prose : This move will be stolen if another Pokemon has used []{move:snatch} this turn.
    # @return [Boolean]
    attr_accessor :snatchable
    # If the move can be used by Mirror Move
    # PokeAPI Prose : A Pokemon targeted by this move can use []{move:mirror-move} to copy it.
    # @return [Boolean]
    attr_accessor :mirror_move
    # If the move is punch based
    # PokeAPI Prose : This move has 1.2x its usual power when used by a Pokemon with []{ability:iron-fist}.
    # @return [Boolean]
    attr_accessor :punch
    # If the move is affected by Gravity
    # PokeAPI Prose : This move cannot be used in high []{move:gravity}.
    # @return [Boolean]
    attr_accessor :gravity
    # If the move is affected by Magic Coat
    # PokeAPI Prose : This move may be reflected back at the user with []{move:magic-coat} or []{ability:magic-bounce}.
    # @return [Boolean]
    attr_accessor :magic_coat_affected
    alias reflectable magic_coat_affected
    alias reflectable= magic_coat_affected=
    # If the move unfreeze the opponent Pokemon
    # PokeAPI Prose : This move can be used while frozen to force the Pokemon to defrost.
    # @return [Boolean]
    attr_accessor :unfreeze
    # If the move is a sound attack
    # PokeAPI Prose : Pokemon with []{ability:soundproof} are immune to this move.
    # @return [Boolean]
    attr_accessor :sound_attack
    # If the move can reach any target of the specied side/bank
    # PokeAPI Prose : In triple battles, this move can be used on either side to target the farthest away foe Pokemon.
    # @return [Boolean]
    attr_accessor :distance
    # If the move can be blocked by Heal Block
    # PokeAPI Prose : This move is blocked by []{move:heal-block}.
    # @return [Boolean]
    attr_accessor :heal
    # If the move ignore the substitute
    # PokeAPI Prose : This move ignores the target's []{move:substitute}.
    # @return [Boolean]
    attr_accessor :authentic
    # If the move is a powder move
    # PokeAPI Prose : Pokemon with []{ability:overcoat} and []{type:grass}-type Pokemon are immune to this move.
    # @return [Boolean]
    attr_accessor :powder
    # If the move is bite based
    # PokeAPI Prose : This move has 1.5x its usual power when used by a Pokemon with []{ability:strong-jaw}.
    # @return [Boolean]
    attr_accessor :bite
    # If the move is pulse based
    # PokeAPI Prose : This move has 1.5x its usual power when used by a Pokemon with []{ability:mega-launcher}.
    # @return [Boolean]
    attr_accessor :pulse
    # If the move is a ballistics move
    # PokeAPI Prose : This move is blocked by []{ability:bulletproof}.
    # @return [Boolean]
    attr_accessor :ballistics
    # If the move has mental effect
    # PokeAPI Prose : This move is blocked by []{ability:aroma-veil} and cured by []{item:mental-herb}.
    # @return [Boolean]
    attr_accessor :mental
    # If the move cannot be used in Fly Battles
    # PokeAPI Prose : This move is unusable during Sky Battles.
    # @return [Boolean]
    attr_accessor :non_sky_battle
    # If the move is a dancing move
    # PokeAPI Prose : This move triggers []{ability:dancer}.
    # @return [Boolean]
    attr_accessor :dance
    # If the move triggers King's Rock
    # @return [Boolean]
    attr_accessor :king_rock_utility
    # Chance (in percent) the effect (stat/status) triggers
    # @return [Integer]
    attr_accessor :effect_chance
    # Stat change effect
    # @return [Array(Integer, Integer, Integer, Integer, Integer, Integer, Integer)]
    attr_accessor :battle_stage_mod
    # The status effect
    # @return [Integer, nil]
    attr_accessor :status
    # List of moves that works when the Pokemon is asleep
    SleepingAttack = %i[snore sleep_talk]
    # Out of reach moves
    #   OutOfReach[sb_symbol] => oor_type
    OutOfReach = { dig: 1, fly: 2, dive: 3, bounce: 4, phantom_force: 5, shadow_force: 5, sky_drop: 6 }
    # List of move that can hit a Pokemon when he's out of reach
    #   OutOfReach_hit[oor_type] = [move db_symbol list]
    OutOfReach_hit = [
      [], # Nothing
      %i[earthquake toxic], # Dig
      %i[gust twister sky_uppercut toxic smack_down], # Fly
      [:surf], # Dive
      %i[gust sky_uppercut twister smack_down], # Bounce
      [], # Phantom force / Shadow Force
      [:smack_down] # Sky drop
    ]
    # List of specific announcement for 2 turn moves
    #   Announce_2turns[db_symbol] = text_id
    Announce_2turns = { dig: 538, fly: 529, dive: 535, bounce: 544,
                        phantom_force: 541, shadow_force: 541, solar_beam: 553,
                        skull_bash: 556, razor_wind: 547, freeze_shock: 866,
                        ice_burn: 869, geomancy: 1213, sky_attack: 550,
                        focus_punch: 1213 }
    # List of Punch moves
    Punching_Moves = %i[dynamic_punch mach_punch hammer_arm focus_punch bullet_punch
                        power-up_punch comet_punch needle_arm fire_punch meteor_mash
                        shadow_punch thunder_punch ice_punch sky_uppercut mega_punch
                        dizzy_punch drain_punch karate_chop]

    # Create a new GameData::Skill object
    def initialize
      super
      @map_use = 0
      @be_method = :s_basic
      @type = 0
      @power = 0
      @accuracy = 0
      @pp_max = 5
      @target = :none
      @atk_class = 2
      @direct = false
      @critical_rate = 0
      @priority = 0
      @blocable = false
      @snatchable = false
      @gravity = false
      @magic_coat_affected = false
      @mirror_move = false
      @unfreeze = false
      @sound_attack = false
      @king_rock_utility = false
      @effect_chance = 0
      @battle_stage_mod = [0, 0, 0, 0, 0, 0, 0, 0]
      @status = 0
      @charge = false
      @recharge = false
      @punch = false
      @distance = false
      @heal = false
      @authentic = false
      @powder = false
      @pulse = false
      @ballistics = false
      @mental = false
      @non_sky_battle = false
      @dance = false
    end

    # Return the name of the move
    # @return [String]
    def name
      GameData::Skill.id_valid?(@id) ? text_get(6, @id) : '???'
    end

    # Is the move a punch move ?
    # @return [Boolean]
    def punching?
      return @punch || Punching_Moves.include?(@db_symbol)
    end

    # Is the move a sleeping attack ?
    # @return [Boolean]
    def sleeping_attack?
      SleepingAttack.include?(db_symbol)
    end

    # Get the out of reach type of the move
    # @return [Integer, nil] nil if not an oor move
    def out_of_reach_type
      return OutOfReach[db_symbol]
    end

    class << self
      # All the skill
      # @type [Array<GameData::Skill>]
      @data = []

      # Get a move by its ID or DB Symbol
      # @param id [Integer, Symbol] ID of the move in database
      # @return [GameData::Skill]
      def [](id)
        id = get_id(id) if id.is_a?(Symbol)
        id = 0 unless id.is_a?(Integer) && id_valid?(id)
        return @data[id]
      end

      # Safely return the out of reach type of a move
      # @param id [Symbol, Integer] db_symbol or id of the move in the database
      # @return [Integer, nil] nil if not an oor move
      def get_out_of_reach_type(id)
        id = db_symbol(id) if id.is_a?(Integer)
        return OutOfReach[id]
      end

      # Tell if the move can hit de out of reach Pokemon
      # @param oor [Integer] out of reach type
      # @param id [Symbol, Integer] db_symbol or id of the move in the database
      # @return [Boolean]
      def can_hit_out_of_reach?(oor, id)
        return false if oor >= OutOfReach_hit.size || oor < 0
        id = db_symbol(id) if id.is_a?(Integer)
        return OutOfReach_hit[oor].include?(id)
      end

      # Return the id of the 2 turn announce text
      # @param id [Symbol, Integer] db_symbol or id of the move in the database
      # @return [Integer, nil]
      def get_2turns_announce(id)
        id = db_symbol(id) if id.is_a?(Integer)
        return Announce_2turns[id]
      end

      # Safely return the db_symbol of an item
      # @param id [Integer] id of the item in the database
      # @return [Symbol]
      def db_symbol(id)
        return (@data[id].db_symbol || :__undef__) if id_valid?(id)

        return :__undef__
      end

      # Get id using symbol
      # @param symbol [Symbol]
      # @return [Integer]
      def get_id(symbol)
        return 0 if symbol == :__undef__

        skill = @data.index { |data| data.db_symbol == symbol }
        skill.to_i
      end

      # Tell if the id is valid
      # @param id [Integer, Symbol]
      # @return [Boolean]
      def id_valid?(id)
        id = get_id(id) if id.is_a?(Symbol)
        return id.between?(1, LAST_ID)
      end

      # Return all the skill
      # @return [Array<Skill>]
      def all
        return @data
      end

      # Load the skill
      def load
        @data = load_data('Data/PSDK/SkillData.rxdata')
        # set the LAST_ID of the Skill data
        GameData::Skill.const_set(:LAST_ID, @data.size - 1)
        @data[0] = GameData::Skill.new
        @data.freeze
        @data.each_with_index { |skill, index| skill&.id = index }
      end

      # Convert a collection to symbolized collection
      # @param collection [Enumerable]
      # @param keys [Boolean] if hash keys are converted
      # @param values [Boolean] if hash values are converted
      # @return [Enumerable] the collection
      def convert_to_symbols(collection, keys: false, values: false)
        if collection.is_a?(Hash)
          new_collection = {}
          collection.each do |key, value|
            key = db_symbol(key) if keys && key.is_a?(Integer)
            if value.is_a?(Enumerable)
              value = convert_to_symbols(value, keys: keys, values: values)
            elsif values && value.is_a?(Integer)
              value = db_symbol(value)
            end
            new_collection[key] = value
          end
          collection = new_collection
        else
          collection.each_with_index do |value, index|
            if value.is_a?(Enumerable)
              collection[index] = convert_to_symbols(value, keys: keys, values: values)
            elsif value.is_a?(Integer)
              collection[index] = db_symbol(value)
            end
          end
        end
        collection
      end
    end
  end
end
