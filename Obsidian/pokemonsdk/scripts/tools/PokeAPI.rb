# This script purpose is to update DATA according to the PokeAPI references
#
# To get access to this call :
#   ScriptLoader.load_tool('PokeAPI')
#
# To update the data according to PokeAPI use
#   PokeAPI.update(path, version_group_id)
# Where path is the location of all the PokeAPI csv files
# and version_group_id is the version you want for data
module PokeAPI
  module_function

  # Update the PSDK data according to the PokeAPI files
  # @param path [String] folder containing all the PokeAPI csv files
  # @param version_groupd_id [Integer] version on which you want the data
  def update(path, version_group_id)
    puts 'Loading data'
    Version.load(path)
    Type.load(path)
    MoveChangeLog.load(path)
    Move.load(path)
    MoveFlags.load(path)
    MoveFlags.map
    MoveFlagMap.load(path)
    PokemonMoves.load(path)
    Pokemon.load(path)
    process_moves(version_group_id)
    process_pokemon(version_group_id)
  end

  def process_moves(version_group_id)
    puts 'Processing moves'
    # @type [Hash{ Integer => Move }]
    move_by_psdk_id = Move.all.map { |move| [move.psdk_id, move.updated_to(version_group_id)] }.to_h
    GameData::Skill.all.each do |skill|
      move = move_by_psdk_id[skill.id]
      next unless move

      skill.type = move.psdk_type
      skill.power = move.power
      skill.pp_max = move.pp
      skill.accuracy = move.accuracy
      skill.priority = move.psdk_priority
      # skill.target = ...move.target_id
      skill.atk_class = move.atk_class
      # move.effect => convert to PSDK effect
      # skill.effect_chance = move.effect_chance # => inaccurate
      apply_flags(move.id, skill)
    end

    File.write('Data/PSDK/SkillData.rxdata.yml', YAML.dump(GameData::Skill.all))
  end

  def process_pokemon(version_group_id)
    puts 'Processing Pokemon'
    pokemon_moves = PokemonMoves.all.select { |move| move.version_group_id == version_group_id }
    psdk_pokemon = GameData::Pokemon.all
    Pokemon.all.each do |pokemon|
      next unless (pokemon_array = psdk_pokemon[pokemon.species_id])

      form = FORM_MAPPING[pokemon.identifier]
      # @type [GameData::Pokemon]
      curr = (pokemon_array[form] ||= Marshal.load(Marshal.dump(pokemon_array.first)))
      curr.form = form
      next unless curr

      curr.height = pokemon.height / 10.0
      curr.weight = pokemon.weight / 10.0
      curr.base_exp = pokemon.base_experience
      process_pokemon_move(pokemon, curr, pokemon_moves)
    end

    File.write('Data/PSDK/PokemonData.rxdata.yml', YAML.dump(GameData::Pokemon.all))
  end

  # @param pokemon [Pokemon]
  # @param curr [GameData::Pokemon]
  # @param pokemon_moves [Array<PokemonMoves>]
  def process_pokemon_move(pokemon, curr, pokemon_moves)
    curr_moves = pokemon_moves.select { |move| move.pokemon_id == pokemon.id }
    all_moves = Move.all
    curr.move_set =
      curr_moves.select { |move| move.pokemon_move_method_id == PokemonMoves::LEVEL_UP }
                .sort do |a, b|
                  v = a.level <=> b.level
                  next v if v != 0

                  a.order <=> b.order
                end
                .map { |move| [move.level, all_moves.find { |skill| skill.id == move.move_id }.psdk_id] }
                .flatten
    curr.tech_set =
      curr_moves.select { |move| move.pokemon_move_method_id == PokemonMoves::TECH }
                .map { |move| all_moves.find { |skill| skill.id == move.move_id }.psdk_id }
    curr.tech_set.sort!
    curr.breed_moves =
      curr_moves.select { |move| move.pokemon_move_method_id == PokemonMoves::EGG }
                .map { |move| all_moves.find { |skill| skill.id == move.move_id }.psdk_id }
    curr.breed_moves.sort!
    curr.master_moves =
      curr_moves.select { |move| move.pokemon_move_method_id == PokemonMoves::TUTOR }
                .map { |move| all_moves.find { |skill| skill.id == move.move_id }.psdk_id }
  end

  # @param id [Integer] ID of the move in PokeAPI
  # @param skill [GameData::Skill] skill that should get the flags
  def apply_flags(id, skill)
    flags = MoveFlagMap.all.select { |flag| flag.move_id == id }.map(&:move_flag_id)
    skill.contact = flags.include?(MoveFlags.contact)
    skill.charge = flags.include?(MoveFlags.charge)
    skill.recharge = flags.include?(MoveFlags.recharge)
    skill.protect = flags.include?(MoveFlags.protect)
    skill.reflectable = flags.include?(MoveFlags.reflectable)
    skill.snatchable = flags.include?(MoveFlags.snatch)
    skill.mirror_move = flags.include?(MoveFlags.mirror)
    skill.punch = flags.include?(MoveFlags.punch)
    skill.sound_attack = flags.include?(MoveFlags.sound)
    skill.gravity = flags.include?(MoveFlags.gravity)
    skill.unfreeze = flags.include?(MoveFlags.defrost)
    skill.distance = flags.include?(MoveFlags.distance)
    skill.heal = flags.include?(MoveFlags.heal)
    skill.authentic = flags.include?(MoveFlags.authentic)
    skill.powder = flags.include?(MoveFlags.powder)
    skill.bite = flags.include?(MoveFlags.bite)
    skill.pulse = flags.include?(MoveFlags.pulse)
    skill.ballistics = flags.include?(MoveFlags.ballistics)
    skill.mental = flags.include?(MoveFlags.mental)
    skill.non_sky_battle = flags.include?(MoveFlags.non_sky_battle)
    skill.dance = flags.include?(MoveFlags.dance)
  end

  module Attributes
    # Function defining an attribute for the PokeAPI
    # @param name [Symbol] name of the attribute
    # @param cast [String, nil] cast added after initialize (@name = row[indexes[i]]cast)
    def attr_reader(name, cast = nil)
      @attributes ||= []
      @attributes << [name, cast]
      super name
    end

    # Function responsive of creating the #initialize and ClassName.load
    # @param filename [String] name of the file in the PokeAPI
    def commit(filename)
      initialize_lines = @attributes.map.with_index do |attribute, index|
        format('@%<name>s = row[indexes[%<index>d]]%<cast>s',
               name: attribute.first,
               index: index,
               cast: attribute.last)
      end.join("\n")
      load_lines = @attributes.map do |attribute|
        format('header.index("%<name>s") || 0', name: attribute.first)
      end.join(',')
      definition = format <<~CLASS_DEF, initialize_lines: initialize_lines, load_lines: load_lines
        def initialize(row, indexes)
          %<initialize_lines>s
        end
        class << self
          def load(path)
            rows = CSV.read(File.join(path, '#{filename}'))
            header = rows.shift
            indexes = [%<load_lines>s]
            return @all = rows.map { |row| self.new(row, indexes) }
          end
        end
      CLASS_DEF
      class_eval(definition)
    end
  end

  class Version
    extend Attributes
    # @return [Integer]
    attr_reader :id, '.to_i'
    # @return [Integer]
    attr_reader :version_group_id, '.to_i'
    # @return [String]
    attr_reader :identifier, '.to_s'

    commit('versions.csv')

    class << self
      # All the loaded versions
      # @return [Array<Version>]
      attr_accessor :all
      # @!method load
      #   Load all versions
      #   @param path [String] path to the folder containing the file
    end
  end

  class MoveChangeLog
    extend Attributes
    # @return [Integer]
    attr_reader :id, '.to_i'
    # @return [Integer]
    attr_reader :changed_in_version_group_id, '.to_i'
    # @return [Integer, nil]
    attr_reader :type_id, '&.to_i'
    # @return [Integer, nil]
    attr_reader :power, '&.to_i'
    # @return [Integer, nil]
    attr_reader :pp, '&.to_i'
    # @return [Integer, nil]
    attr_reader :accuracy, '&.to_i'
    # @return [Integer, nil]
    attr_reader :priority, '&.to_i'
    # @return [Integer, nil]
    attr_reader :target_id, '&.to_i'
    # @return [Integer, nil]
    attr_reader :effect_id, '&.to_i'
    # @return [Integer, nil]
    attr_reader :effect_chance, '&.to_i'

    commit('move_changelog.csv')

    class << self
      # All the loaded move changelog
      # @return [Array<MoveChangeLog>]
      attr_accessor :all
      # @!method load
      #   Load all move changelog
      #   @param path [String] path to the folder containing the file
    end
  end

  class Move
    extend Attributes
    # @return [Integer]
    attr_reader :id, '.to_i'
    # @return [String]
    attr_reader :identifier, '.to_s'
    # @return [Integer]
    attr_reader :generation_id, '.to_i'
    # @return [Integer]
    attr_reader :type_id, '.to_i'
    # @return [Integer]
    attr_reader :power, '.to_i'
    # @return [Integer]
    attr_reader :pp, '.to_i'
    # @return [Integer]
    attr_reader :accuracy, '.to_i'
    # @return [Integer]
    attr_reader :priority, '.to_i'
    # @return [Integer]
    attr_reader :target_id, '.to_i'
    # @return [Integer]
    attr_reader :damage_class_id, '.to_i'
    # @return [Integer]
    attr_reader :effect_id, '.to_i'
    # @return [Integer]
    attr_reader :effect_chance, '.to_i'
    # @return [Integer]
    attr_reader :contest_type_id, '.to_i'
    # @return [Integer]
    attr_reader :contest_effect_id, '.to_i'
    # @return [Integer]
    attr_reader :super_contest_effect_id, '.to_i'

    commit('moves.csv')

    # Return an updated version of the move to the said version group
    # @param version_group_id [Integer] ID of the version group
    # @return [Move]
    def updated_to(version_group_id)
      version = MoveChangeLog.all.find do |changelog|
        changelog.id == @id && changelog.changed_in_version_group_id == version_group_id
      end
      return self unless version

      (updated_move = clone).instance_eval do
        @type_id = version.type_id if version.type_id
        @power = version.power if version.power
        @pp = version.pp if version.pp
        @accuracy = version.accuracy if version.accuracy
        @priority = version.priority if version.priority
        @target_id = version.target_id if version.target_id
        @effect_id = version.effect_id if version.effect_id
        @effect_chance = version.effect_chance if version.effect_chance
      end

      return updated_move
    end

    # @return [Integer]
    def psdk_id
      Move.psdk_move_string.index(@identifier) || @id
    end

    # @return [Integer]
    def psdk_type
      Type.all.find { |type| type.id == @type_id }.psdk_id
    end

    # @return [Integer]
    def atk_class
      return 3 if @damage_class_id == 1
      return 1 if @damage_class_id == 2

      return 2
    end

    # @return [Integer]
    def psdk_priority
      @priority + 7
    end

    class << self
      # All the loaded moves
      # @return [Array<Move>]
      attr_accessor :all

      # All the psdk move string
      # @return [Array<String>]
      def psdk_move_string
        @psdk_move_string ||= GameData::Skill.all.map do |skill|
          skill.db_symbol.to_s.gsub('_', '-').gsub(',', '-').gsub('’', '')
        end
      end
      # @!method load
      #   Load all moves
      #   @param path [String] path to the folder containing the file
    end
  end

  class MoveFlags
    extend Attributes
    # @return [Integer]
    attr_reader :id, '.to_i'
    # @return [String]
    attr_reader :identifier, '.to_s'

    commit('move_flags.csv')

    class << self
      attr_reader :contact, :charge, :recharge, :protect, :reflectable, :snatch,
                  :mirror, :punch, :sound, :gravity, :defrost, :distance, :heal,
                  :authentic, :powder, :bite, :pulse, :ballistics, :mental,
                  :non_sky_battle, :dance
      # Function that generates the flag map (MoveFlags.contact = 1)
      def map
        all.each do |flag|
          instance_variable_set("@#{flag.identifier.tr('-', '_')}", flag.id)
        end
      end
      # All the loaded types
      # @return [Array<MoveFlags>]
      attr_accessor :all
      # @!method load
      #   Load all move flags
      #   @param path [String] path to the folder containing the file
    end
  end

  class MoveFlagMap
    extend Attributes
    # @return [Integer]
    attr_reader :move_id, '.to_i'
    # @return [Integer]
    attr_reader :move_flag_id, '.to_i'

    commit('move_flag_map.csv')

    class << self
      # All the loaded types
      # @return [Array<MoveFlagMap>]
      attr_accessor :all
      # @!method load
      #   Load all move flag map
      #   @param path [String] path to the folder containing the file
    end
  end

  class Type
    extend Attributes
    # @return [Integer]
    attr_reader :id, '.to_i'
    # @return [String]
    attr_reader :identifier, '.to_s'
    # @return [Integer]
    attr_reader :generation_id, '.to_i'
    # @return [Integer]
    attr_reader :damage_class_id, '.to_i'

    commit('types.csv')

    # @return [Integer]
    def psdk_id
      PSDK_TYPES[@identifier] || @id
    end

    PSDK_TYPES = {
      'normal' => GameData::Types::NORMAL,
      'fighting' => GameData::Types::FIGHTING,
      'flying' => GameData::Types::FLYING,
      'poison' => GameData::Types::POISON,
      'ground' => GameData::Types::GROUND,
      'rock' => GameData::Types::ROCK,
      'bug' => GameData::Types::BUG,
      'ghost' => GameData::Types::GHOST,
      'steel' => GameData::Types::STEEL,
      'fire' => GameData::Types::FIRE,
      'water' => GameData::Types::WATER,
      'grass' => GameData::Types::GRASS,
      'electric' => GameData::Types::ELECTRIC,
      'psychic' => GameData::Types::PSYCHIC,
      'ice' => GameData::Types::ICE,
      'dragon' => GameData::Types::DRAGON,
      'dark' => GameData::Types::DARK,
      'fairy' => GameData::Types::FAIRY,
      'unknown' => GameData::Types::T？？？
    }

    class << self
      # All the loaded types
      # @return [Array<Type>]
      attr_accessor :all
      # @!method load
      #   Load all types
      #   @param path [String] path to the folder containing the file
    end
  end

  class Pokemon
    extend Attributes
    # @return [Integer]
    attr_reader :id, '.to_i'
    # @return [String]
    attr_reader :identifier, '.to_s'
    # @return [Integer]
    attr_reader :species_id, '.to_i'
    # @return [Integer]
    attr_reader :height, '.to_i'
    # @return [Integer]
    attr_reader :weight, '.to_i'
    # @return [Integer]
    attr_reader :base_experience, '.to_i'

    commit('pokemon.csv')

    class << self
      # All the loaded Pokemon
      # @return [Array<Pokemon>]
      attr_accessor :all
      # @!method load
      #   Load all Pokemon
      #   @param path [String] path to the folder containing the file
    end
  end

  class PokemonMoves
    # ID of the level up method
    LEVEL_UP = 1
    # ID of the egg method
    EGG = 2
    # ID of the tutor method
    TUTOR = 3
    # ID of the tech method
    TECH = 4
    # ID of the form change method (not implemented)
    FORM_CHANGE = 10
    extend Attributes
    # @return [Integer]
    attr_reader :pokemon_id, '.to_i'
    # @return [String]
    attr_reader :version_group_id, '.to_i'
    # @return [Integer]
    attr_reader :move_id, '.to_i'
    # @return [Integer]
    attr_reader :pokemon_move_method_id, '.to_i'
    # @return [Integer]
    attr_reader :level, '.to_i'
    # @return [Integer]
    attr_reader :base_experience, '.to_i'
    # @return [Integer]
    attr_reader :order, '.to_i'

    commit('pokemon_moves.csv')

    class << self
      # All the loaded PokemonMoves
      # @return [Array<PokemonMoves>]
      attr_accessor :all
      # @!method load
      #   Load all PokemonMoves
      #   @param path [String] path to the folder containing the file
    end
  end
end

# Load dependancy to properly save the output to YAML
# (Please do the ProjectToYAML.convert before PokeAPI.update(path))
ScriptLoader.load_tool('ProjectToYAML')
ScriptLoader.load_tool('PokeAPILinkData')
