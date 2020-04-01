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
    # If the move is a direct move or not
    # @return [Boolean]
    attr_accessor :direct
    # Critical rate indicator : 0 => 0, 1 => 6.25%, 2 => 12.5%, 3 => 25%, 4 => 33%, 5 => 50%, 6 => 100%
    # @return [Integer]
    attr_accessor :critical_rate
    # Priority of the move
    # @return [Integer]
    attr_accessor :priority
    # If the move is affected by Detect or Protect
    # @return [Boolean]
    attr_accessor :blocable
    # If the move is affected by Snatch
    # @return [Boolean]
    attr_accessor :snatchable
    # If the move can be used by Mirror Move
    # @return [Boolean]
    attr_accessor :mirror_move
    # If the move is affected by Gravity
    # @return [Boolean]
    attr_accessor :gravity
    # If the move is affected by Magic Coat
    # @return [Boolean]
    attr_accessor :magic_coat_affected
    # If the move unfreeze the opponent Pokemon
    # @return [Boolean]
    attr_accessor :unfreeze
    # If the move is a sound attack
    # @return [Boolean]
    attr_accessor :sound_attack
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
    def initialize(map_use, be_method, type, power, accuracy, pp_max, target, 
      atk_class, direct, critical_rate, priority, blocable, snatchable, gravity,
      magic_coat_affected, mirror_move, unfreeze, sound_attack, 
      king_rock_utility, effect_chance, battle_stage_mod, status)
      @map_use = map_use
      @be_method = be_method
      @type = type
      @power = power
      @accuracy = accuracy
      @pp_max = pp_max
      @target = target
      @atk_class = atk_class
      @direct = direct
      @critical_rate = critical_rate
      @priority = priority
      @blocable = blocable
      @snatchable = snatchable
      @gravity = gravity
      @magic_coat_affected = magic_coat_affected
      @mirror_move = mirror_move
      @unfreeze = unfreeze
      @sound_attack = sound_attack
      @king_rock_utility = king_rock_utility
      @effect_chance = effect_chance
      @battle_stage_mod = battle_stage_mod
      @status = status
    end

    # Is the move a punch move ?
    # @return [Boolean]
    def punching?
      return Punching_Moves.include?(@db_symbol)
    end
    class << self
      # All the skill
      @data = []
      # Safely return the name of a move
      # @param id [Integer, Symbol] id of the move in the database
      # @return [String]
      def name(id)
        id = get_id(id) if id.is_a?(Symbol)
        return text_get(6, id) if id_valid?(id)
        return '???'
      end

      # Safely tell if a move works when the Pokemon is asleep
      # @param id [Symbol, Integer] db_symbol or id of the move in the database
      # @return [Boolean]
      def is_sleeping_attack?(id)
        id = db_symbol(id) if id.is_a?(Integer)
        SleepingAttack.include?(id)
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

      # Safely return the map_use info of a move
      # @param id [Integer, Symbol] id of the move in the database
      # @return [Integer]
      def map_use(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].map_use if id_valid?(id)
        return @data[0].map_use
      end

      # Safely return the be_method of a move
      # @param id [Integer, Symbol] id of the move in the database
      # @return [Symbol]
      def be_method(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].be_method if id_valid?(id)
        return @data[0].be_method
      end

      # Safely return the type of a move
      # @param id [Integer, Symbol] id of the move in the database
      # @return [Integer]
      def type(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].type if id_valid?(id)
        return @data[0].type
      end

      # Safely return the power of a move
      # @param id [Integer, Symbol] id of the move in the database
      # @return [Integer]
      def power(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].power if id_valid?(id)
        return @data[0].power
      end

      # Safely return the accuracy of a move
      # @param id [Integer, Symbol] id of the move in the database
      # @return [Integer]
      def accuracy(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].accuracy if id_valid?(id)
        return @data[0].accuracy
      end

      # Safely return the pp_max of a move
      # @param id [Integer, Symbol] id of the move in the database
      # @return [Integer]
      def pp_max(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].pp_max if id_valid?(id)
        return @data[0].pp_max
      end

      # Safely return the target of a move
      # @param id [Integer, Symbol] id of the move in the database
      # @return [Symbol]
      def target(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].target if id_valid?(id)
        return @data[0].target
      end

      # Safely return the atk_class of a move
      # @param id [Integer, Symbol] id of the move in the database
      # @return [Integer]
      def atk_class(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].atk_class if id_valid?(id)
        return @data[0].atk_class
      end

      # Safely return the direct attribute of a move
      # @param id [Integer, Symbol] id of the move in the database
      # @return [Boolean]
      def direct(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].direct if id_valid?(id)
        return @data[0].direct
      end

      # Safely return the critical_rate attribute of a move
      # @param id [Integer, Symbol] id of the move in the database
      # @return [Integer]
      def critical_rate(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].critical_rate if id_valid?(id)
        return @data[0].critical_rate
      end

      # Safely return the priority attribute of a move
      # @param id [Integer, Symbol] id of the move in the database
      # @return [Integer]
      def priority(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].priority if id_valid?(id)
        return @data[0].priority
      end

      # Safely return the blocable attribute of a move
      # @param id [Integer, Symbol] id of the move in the database
      # @return [Boolean]
      def blocable(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].blocable if id_valid?(id)
        return @data[0].blocable
      end

      # Safely return the snatchable attribute of a move
      # @param id [Integer, Symbol] id of the move in the database
      # @return [Boolean]
      def snatchable(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].snatchable if id_valid?(id)
        return @data[0].snatchable
      end

      # Safely return the gravity attribute of a move
      # @param id [Integer, Symbol] id of the move in the database
      # @return [Boolean]
      def gravity(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].gravity if id_valid?(id)
        return @data[0].gravity
      end

      # Safely return the magic_coat_affected attribute of a move
      # @param id [Integer, Symbol] id of the move in the database
      # @return [Boolean]
      def magic_coat_affected(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].magic_coat_affected if id_valid?(id)
        return @data[0].magic_coat_affected
      end

      # Safely return the mirror_move attribute of a move
      # @param id [Integer, Symbol] id of the move in the database
      # @return [Boolean]
      def mirror_move(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].mirror_move if id_valid?(id)
        return @data[0].mirror_move
      end

      # Safely return the unfreeze attribute of a move
      # @param id [Integer, Symbol] id of the move in the database
      # @return [Boolean]
      def unfreeze(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].unfreeze if id_valid?(id)
        return @data[0].unfreeze
      end

      # Safely return the sound_attack attribute of a move
      # @param id [Integer, Symbol] id of the move in the database
      # @return [Boolean]
      def sound_attack(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].sound_attack if id_valid?(id)
        return @data[0].sound_attack
      end

      # Safely return the king_rock_utility attribute of a move
      # @param id [Integer, Symbol] id of the move in the database
      # @return [Boolean]
      def king_rock_utility(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].king_rock_utility if id_valid?(id)
        return @data[0].king_rock_utility
      end

      # Safely return the effect_chance attribute of a move
      # @param id [Integer, Symbol] id of the move in the database
      # @return [Integer]
      def effect_chance(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].effect_chance if id_valid?(id)
        return @data[0].effect_chance
      end

      # Safely return the battle_stage_mod attribute of a move
      # @param id [Integer, Symbol] id of the move in the database
      # @return [Array]
      def battle_stage_mod(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].battle_stage_mod if id_valid?(id)
        return @data[0].battle_stage_mod
      end

      # Safely return the status attribute of a move
      # @param id [Integer, Symbol] id of the move in the database
      # @return [Integer, nil]
      def status(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id].status if id_valid?(id)
        return @data[0].status
      end

      # Tell if a move is a puch move
      # @param id [Symbol, Integer] id of the move in the database or db_symbol
      # @return [Boolean]
      def punching?(id)
        id = db_symbol(id) if id.is_a?(Integer)
        return Punching_Moves.include?(id)
      end

      # Safely return the db_symbol of an item
      # @param id [Integer] id of the item in the database
      # @return [Symbol]
      def db_symbol(id)
        return (@data[id].db_symbol || :__undef__) if id_valid?(id)
        return :__undef__
      end

      # Find a skill using symbol
      # @param symbol [Symbol]
      # @return [GameData::Skill]
      def find_using_symbol(symbol)
        skill = @data.find { |data| data.db_symbol == symbol }
        return @data[0] unless skill
        skill
      end

      # Get id using symbol
      # @param symbol [Symbol]
      # @return [Integer]
      def get_id(symbol)
        skill = @data.index { |data| data.db_symbol == symbol }
        skill.to_i
      end

      # Get a skill
      # @param id [Integer, Symbol]
      # @return [Skill]
      def get(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id] if id_valid?(id)
        return @data.first
      end

      # Tell if the id is valid
      # @param id [Integer]
      # @return [Boolean]
      def id_valid?(id)
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
        @data[0] = GameData::Skill.new(
          0, :s_basic, 0, 0, 0, 5, :none, 2, false, 0, 0, false, false, false, false,
          false, false, false, false, 0, Array.new(8, 0), 0
        )
        @data.freeze
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
