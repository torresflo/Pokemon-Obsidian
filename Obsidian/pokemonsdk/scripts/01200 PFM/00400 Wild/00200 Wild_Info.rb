module PFM
  # Wild remaining Pokemon group informations
  # @author Nuri Yuri
  class Wild_Info
    # List of ability giving the max level of the pokemon we can encounter
    MAX_POKEMON_LEVEL_ABILITY = %i[hustle pressure vital_spirit]
    # The type of battle (1v1 2v2)
    # @return [Integer]
    attr_accessor :vs_type
    # The list of Pokemon ID
    # @return [Array<Integer>]
    attr_accessor :ids
    # The list of Pokemon level or Hash descriptor
    # @return [Array<Integer, Hash>]
    attr_accessor :levels
    # The list of chance to see the Pokemon (0 = delta level)
    # @return [Array<Integer>]
    attr_accessor :chances
    # Create a new Wild_Info object
    def initialize
      @vs_type = 1
      @ids = []
      @levels = []
      @chances = [0]
    end

    # Get the delta_level attribute
    # @return [Integer]
    def delta_level
      return @chances[0]
    end

    # Change the delta_level attribute
    # @param v [Array, Integer] the disparity in level
    def delta_level=(v)
      @chances[0] = v.to_i
    end

    # Get the list of Pokemon for this iteration
    # @return [Array<PFM::Pokemon>]
    def pokemon
      hashes = levels.map.with_index { |l, i| l.is_a?(Integer) ? { id: @ids[i], level: l } : l.merge(id: @ids[i]) }
      hashes *= vs_type
      maxed = MAX_POKEMON_LEVEL_ABILITY.include?($actors[0].ability_db_symbol) && rand(100) < 50
      delta = delta_level
      # Setup the right level
      adjusted_level = hashes.map do |hash|
        level = hash[:level] - delta / 2 + (maxed ? delta - 1 : rand(delta))
        next hash.merge(level: level)
      end

      return adjusted_level.map { |hash| PFM::Pokemon.generate_from_hash(hash) }
    end
  end
end
