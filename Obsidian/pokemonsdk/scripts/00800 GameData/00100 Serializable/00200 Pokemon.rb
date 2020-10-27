module GameData
  # Pokemon Data Structure
  # @author Nuri Yuri
  class Pokemon < Base
    extend DataSource2D
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
    attr_writer :front_offset_y
    # Create a new GameData::Pokemon object
    def initialize
      super
      @height = 1.60
      @weight = 52
      @id_bis = 0
      @type1 = 1
      @type2 = 1
      @base_hp = @base_atk = @base_dfe = @base_spd = @base_ats = @base_dfs = 1
      @ev_hp = @ev_atk = @ev_dfe = @ev_spd = @ev_ats = @ev_dfs = 0
      @move_set = []
      @tech_set = []
      @evolution_level = 0
      @evolution_id = 0
      @special_evolution = nil
      @exp_type = 1
      @base_exp = 100
      @base_loyalty = 0
      @rareness = 0
      @female_rate = 60
      @abilities = [0, 0, 0]
      @breed_groupes = [15, 15]
      @breed_moves = []
      @master_moves = []
      @hatch_step = 1_000_000_000
      @items = [0, 0, 0, 0]
      @baby = 0
    end

    # Name of the Pokemon
    # @return [String]
    def name
      return text_get(0, id)
    end

    # Description of the Pokemon
    # @return [String]
    def descr
      return text_get(2, id)
    end

    # Species of the Pokemon
    # @return [String]
    def species
      return text_get(1, id)
    end

    # Front offset y of the Pokemon for Summary & Dex UI
    # @return [Integer]
    def front_offset_y
      @front_offset_y || 0
    end

    class << self
      # Name of the file containing the data
      def data_filename
        return 'Data/PSDK/PokemonData.rxdata'
      end

      # Safely return the list of Form of the Pokemon including the regular form (index = 0)
      # @param id [Intger, Symbol] id of the Pokemon in the database
      # @return [Array<GameData::Pokemon>]
      def get_forms(id)
        id = get_id(id) if id.is_a?(Symbol)
        return @data[id] || @data.first
      end

      # Return the list of the zone id where the pokemon spawn
      # @param id [Integer] the id of pokemon
      # @return [Array<Integer>]
      def spawn_zones(id)
        result = []
        GameData::Zone.all.each_with_index do |zone, index|
          is_here = false
          zone.groups&.each do |group|
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
    end
  end
end
