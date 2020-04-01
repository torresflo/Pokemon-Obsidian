module GameData
  # Pokemon Data Structure
  # @author Nuri Yuri
  class Pokemon < Base
    # Height of the Pokemon in metter
    # @return [Numeric]
    attr_accessor :height
    # Weight of the Pokemon in Kg
    # @return [Numeric]
    attr_accessor :weight
    # Regional id of the Pokemon
    # @return [Integer]
    attr_accessor :id_bis
    # First type of the Pokemon
    # @return [Integer]
    attr_accessor :type1
    # Second type of the Pokemon
    # @return [Integer]
    attr_accessor :type2
    # HP statistic of the Pokemon
    # @return [Integer]
    attr_accessor :base_hp
    # ATK statistic of the Pokemon
    # @return [Integer]
    attr_accessor :base_atk
    # DFE statistic of the Pokemon
    # @return [Integer]
    attr_accessor :base_dfe
    # SPD statistic of the Pokemon
    # @return [Integer]
    attr_accessor :base_spd
    # ATS statistic of the Pokemon
    # @return [Integer]
    attr_accessor :base_ats
    # DFS statistic of the Pokemon
    # @return [Integer]
    attr_accessor :base_dfs
    # HP EVs givent by the Pokemon when defeated
    # @return [Integer]
    attr_accessor :ev_hp
    # ATK EVs givent by the Pokemon when defeated
    # @return [Integer]
    attr_accessor :ev_atk
    # DFE EVs givent by the Pokemon when defeated
    # @return [Integer]
    attr_accessor :ev_dfe
    # SPD EVs givent by the Pokemon when defeated
    # @return [Integer]
    attr_accessor :ev_spd
    # ATS EVs givent by the Pokemon when defeated
    # @return [Integer]
    attr_accessor :ev_ats
    # DFS EVs givent by the Pokemon when defeated
    # @return [Integer]
    attr_accessor :ev_dfs
    # List of moves the Pokemon can learn by level.
    #   List formated like this : level_move1, id_move1, level_move2, id_move2, ...
    # @return [Array<Integer, Integer>]
    attr_accessor :move_set
    # List of moves (id in the database) the Pokemon can learn by using HM and TM
    # @return [Array<Integer>]
    attr_accessor :tech_set
    # Level when the Pokemon can naturally evolve
    # @return [Integer, nil]
    attr_accessor :evolution_level
    # ID of the Pokemon after its evolution
    # @return [Integer] 0 = No evolution
    attr_accessor :evolution_id
    # Special evolution informations
    # @return [Hash, nil]
    attr_accessor :special_evolution
    # Index of the Pokemon exp curve (GameData::EXP_TABLE)
    # @return [Integer]
    attr_accessor :exp_type
    # Base experience the Pokemon give when defeated (used in the exp caculation)
    # @return [Integer]
    attr_accessor :base_exp
    # Loyalty the Pokemon has at the begining
    # @return [Integer]
    attr_accessor :base_loyalty
    # Factor used during the catch_rate calculation
    # @return [Integer] 0 = Uncatchable (even with Master Ball)
    attr_accessor :rareness
    # Chance in % the Pokemon has to be a female, if -1 it'll have no gender.
    # @return [Integer]
    attr_accessor :female_rate
    # The two groupes of compatibility for breeding. If it includes 15, there's no compatibility.
    # @return [Array(Integer, Integer)]
    attr_accessor :breed_groupes
    # List of move ID the Pokemon can have after hatching if one of its parent has the move
    # @return [Array<Integer>]
    attr_accessor :breed_moves
    # Number of step before the egg hatch
    # @return [Integer]
    attr_accessor :hatch_step
    # List of items with change (in percent) the Pokemon can have when generated
    #   List formated like this : [id item1, chance item1, id item2, chance item2, ...]
    # @return [Array<Integer, Integer>]
    attr_accessor :items
    # ID of the baby the Pokemon can have while breeding
    # @return [Integer] 0 = no baby
    attr_accessor :baby
    # Current form of the Pokemon
    # @return [Integer] 0 = common form
    attr_accessor :form
    # List of ability id the Pokemon can have [common, rare, ultra rare]
    # @return [Array(Integer, Integer, Integer)]
    attr_accessor :abilities
    # List of moves the Pokemon can learn from a NPC
    # @return [Array<Integer>]
    attr_accessor :master_moves
    # Front offset y of the Pokemon for Summary & Dex UI
    # @return [Integer]
    attr_accessor :front_offset_y
    # Create a new GameData::Pokemon object
    def initialize(height, weight, id_bis, type1, type2, base_hp, base_atk, 
      base_dfe, base_spd, base_ats, base_dfs, ev_hp, ev_atk, ev_dfe, ev_spd, 
      ev_ats, ev_dfs, move_set, tech_set, evolution_level, evolution_id, 
      special_evolution, exp_type, base_exp, base_loyalty, rareness, 
      female_rate, abilities, breed_groupes, breed_moves, master_moves, 
      hatch_step, items, baby)
      @height = height
      @weight = weight
      @id_bis = id_bis
      @type1 = type1
      @type2 = type2
      @base_hp = base_hp
      @base_atk = base_atk
      @base_dfe = base_dfe
      @base_spd = base_spd
      @base_ats = base_ats
      @base_dfs = base_dfs
      @ev_hp = ev_hp
      @ev_atk = ev_atk
      @ev_dfe = ev_dfe
      @ev_spd = ev_spd
      @ev_ats = ev_ats
      @ev_dfs = ev_dfs
      @move_set = move_set
      @tech_set = tech_set
      @evolution_level = evolution_level
      @evolution_id = evolution_id
      @special_evolution = special_evolution
      @exp_type = exp_type
      @base_exp = base_exp
      @base_loyalty = base_loyalty
      @rareness = rareness
      @female_rate = female_rate
      @abilities = abilities
      @breed_groupes = breed_groupes
      @breed_moves = breed_moves
      @master_moves = master_moves
      @hatch_step = hatch_step
      @items = items
      @baby = baby
    end

    class << self
      # All the Pokemon with their form
      @data = []
      # Safely return the name of the Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @return [String]
      def name(id)
        id = get_id(id) if id.is_a?(Symbol)
        return text_get(0, id)
      end

      # Safely return the description of the Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @return [String]
      def descr(id)
        id = get_id(id) if id.is_a?(Symbol)
        return text_get(2, id)
      end

      # Safely return the species of the Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @return [String]
      def species(id)
        id = get_id(id) if id.is_a?(Symbol)
        return text_get(1, id)
      end

      # Safely return the data of a Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [GameData::Pokemon]
      def get_data(id, form)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[0][0] unless (data = @data[id])
        return data[0] unless (data = data[form])
        return data
      end

      # Safely return the list of Form of the Pokemon including the regular form (index = 0)
      # @param id [Intger, Symbol] id of the Pokemon in the database
      # @return [Array<GameData::Pokemon>]
      def get_forms(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id] || @data.first
      end

      # Safely return the height of a Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Numeric]
      def height(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).height
        end
        return @data[0][0].height
      end

      # Safely return the weight of a Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Numeric]
      def weight(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).weight
        end
        return @data[0][0].weight
      end

      # Safely return the id_bis of a Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Integer]
      def id_bis(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).id_bis
        end
        return @data[0][0].id_bis
      end

      # Safely return the firs type of a Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Integer]
      def type1(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).type1
        end
        return @data[0][0].type1
      end

      # Safely return the second type of a Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Integer]
      def type2(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).type2
        end
        return @data[0][0].type2
      end

      # Safely return the base hp of a Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Integer]
      def base_hp(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).base_hp
        end
        return @data[0][0].base_hp
      end

      # Safely return the base atk of a Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Integer]
      def base_atk(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).base_atk
        end
        return @data[0][0].base_atk
      end

      # Safely return the base dfe of a Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Integer]
      def base_dfe(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).base_dfe
        end
        return @data[0][0].base_dfe
      end

      # Safely return the base spd of a Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Integer]
      def base_spd(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).base_spd
        end
        return @data[0][0].base_spd
      end

      # Safely return the base ats of a Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Integer]
      def base_ats(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).base_ats
        end
        return @data[0][0].base_ats
      end

      # Safely return the base dfs of a Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Integer]
      def base_dfs(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).base_dfs
        end
        return @data[0][0].base_dfs
      end

      # Safely return the hp ev given by the Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Integer]
      def ev_hp(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).ev_hp
        end
        return @data[0][0].ev_hp
      end

      # Safely return the atk ev given by the Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Integer]
      def ev_atk(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).ev_atk
        end
        return @data[0][0].ev_atk
      end

      # Safely return the dfe ev given by the Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Integer]
      def ev_dfe(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).ev_dfe
        end
        return @data[0][0].ev_dfe
      end

      # Safely return the spd ev given by the Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Integer]
      def ev_spd(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).ev_spd
        end
        return @data[0][0].ev_spd
      end

      # Safely return the ats ev given by the Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Integer]
      def ev_ats(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).ev_ats
        end
        return @data[0][0].ev_ats
      end

      # Safely return the dfs ev given by the Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Integer]
      def ev_dfs(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).ev_dfs
        end
        return @data[0][0].ev_dfs
      end

      # Safely return the move set of a Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Array<Integer, Integer>]
      def move_set(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).move_set
        end
        return @data[0][0].move_set
      end

      # Safely return the tech set of a Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Array<Integer>]
      def tech_set(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).tech_set
        end
        return @data[0][0].tech_set
      end

      # Safely return the evolution level of a Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Integer]
      def evolution_level(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).evolution_level
        end
        return @data[0][0].evolution_level
      end

      # Safely return the evolution id of a Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Integer]
      def evolution_id(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).evolution_id
        end
        return @data[0][0].evolution_id
      end

      # Safely return the special evolution information of a Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Hash, nil]
      def special_evolution(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).special_evolution
        end
        return @data[0][0].special_evolution
      end

      # Safely return the exp type of a Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Integer]
      def exp_type(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).exp_type
        end
        return @data[0][0].exp_type
      end

      # Safely return the base exp of a Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Integer]
      def base_exp(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).base_exp
        end
        return @data[0][0].base_exp
      end

      # Safely return the base loyalty of a Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Integer]
      def base_loyalty(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).base_loyalty
        end
        return @data[0][0].base_loyalty
      end

      # Safely return the rareness of a Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Integer]
      def rareness(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).rareness
        end
        return @data[0][0].rareness
      end

      # Safely return the female rate of a Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Integer]
      def female_rate(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).female_rate
        end
        return @data[0][0].female_rate
      end

      # Safely return the abilities of a Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Array(Integer, Integer, Integer)]
      def abilities(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).abilities
        end
        return @data[0][0].abilities
      end

      # Safely return the breed groupes of a Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Array(Integer, Integer)]
      def breed_groupes(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).breed_groupes
        end
        return @data[0][0].breed_groupes
      end

      # Safely return the breed moves of a Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Array<Integer>]
      def breed_moves(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).breed_moves
        end
        return @data[0][0].breed_moves
      end

      # Safely return the master moves of a Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Array<Integer>]
      def master_moves(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).master_moves
        end
        return @data[0][0].master_moves
      end

      # Safely return the hatch step of a Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Integer]
      def hatch_step(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).hatch_step
        end
        return @data[0][0].hatch_step
      end

      # Safely return the items held by a Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Array<Integer, Integer>]
      def items(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).items
        end
        return @data[0][0].items
      end

      # Safely return the baby of a Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Integer]
      def baby(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).baby
        end
        return @data[0][0].baby
      end

      # Safely return the front offset y of a Pokemon
      # @param id [Integer, Symbol] id of the Pokemon in the database
      # @param form [Integer] form of the Pokemon
      # @return [Integer]
      def front_offset_y(id, form = 0)
        id = get_id(id) if id.is_a?(Symbol)
        if id_valid?(id)
          data = @data[id]
          return (data[form] || data[0]).front_offset_y || 0
        end
        return 0
      end

      # Safely return the db_symbol of an item
      # @param id [Integer] id of the item in the database
      # @return [Symbol]
      def db_symbol(id)
        return (@data[id][0].db_symbol || :__undef__) if id_valid?(id)
        return :__undef__
      end

      # Find a Pokemon using symbol
      # @note Returns first form if the form doesn't exists
      # @param symbol [Symbol]
      # @param form [Integer] requested form
      # @return [GameData::Pokemon]
      def find_using_symbol(symbol, form = 0)
        pokemon = @data.find { |data| data[0].db_symbol == symbol }
        return @data[0][0] unless pokemon
        pokemon.fetch(form) { pokemon.first }
      end

      # Get id using symbol
      # @param symbol [Symbol]
      # @return [Integer]
      def get_id(symbol)
        pokemon = @data.index { |data| data[0].db_symbol == symbol }
        return pokemon || 0
      end

      # Get all the Pokemon
      # @return [Array<Array<GameData::Pokemon>>]
      def all
        return @data
      end

      # Return the list of the zone id where the pokemon spawn
      # @param id [Integer] the id of pokemon
      # @return [Array<Integer>]
      def spawn_zones(id)
        result = []
        GameData::Zone.all.each_with_index do |zone, index|
          is_here = false
          zone.groups.each do |group|
            group.each do |pkm|
              next unless pkm.is_a?(Hash)
              next unless pkm[:id] == id
              result << index
              is_here = true
              break
            end
            break if is_here
          end
        end
        return result
      end

      # Tell if the ID is valid
      # @param id [Integer]
      # @return [Boolean]
      def id_valid?(id)
        return id.between?(1, LAST_ID)
      end

      # Load the Pokemon
      def load
        @data = load_data('Data/PSDK/PokemonData.rxdata')
        # set the LAST_ID of the Pokemon data
        GameData::Pokemon.const_set(:LAST_ID, @data.size - 1)
        @data[0] = [GameData::Pokemon.new(
          1.60, 52, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, [], [], 0, 0, nil, 1,
          100, 0, 0, 60, [0, 0, 0], [15, 15], [], [], 10**9, [0, 0, 0, 0], 0
        )]
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
