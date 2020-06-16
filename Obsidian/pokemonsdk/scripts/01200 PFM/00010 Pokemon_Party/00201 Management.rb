module PFM
  class Pokemon_Party
    # Return the size of the party
    # @return [Integer]
    def size
      return @actors.size
    end

    # Is the party empty ?
    # @return [Boolean]
    def empty?
      return @actors.empty?
    end

    # Is the party full ?
    # @return [Boolean]
    def full?
      return @actors.size == 6
    end

    # Is the party not able to start a battle ?
    # @return [Boolean]
    def dead?
      return empty? || @actors.all?(&:dead?)
    end

    # Is the party able to start a battle ?
    # @return [Boolean]
    def alive?
      return !dead?
    end

    # Number of pokemon alive in the party
    # @param max [Integer] the number of Pokemon to check from the begining of the party
    def pokemon_alive(max = @actors.size)
      alive = 0
      max.times do |i|
        alive += 1 if @actors[i] && !@actors[i].dead?
      end
      return alive
    end

    # Index of the first pokemon alive in the party
    def first_pokemon_alive_index
      return @actors.index { |pokemon| !pokemon.dead? }
    end

    # Test if a specific Pokémon is able to fight or not
    # @param id [Integer] ID of the Pokemon
    # @return [Boolean]
    # @example Checking if Pikachu is alive in the party
    #   $pokemon_party.specific_alive?(25)
    # @example Checking if alolan Meowth is alive in the party
    #   $pokemon_party.specific_alive?(52) { |pokemon| pokemon.form == 1 }
    def specific_alive?(id)
      if block_given?
        return @actors.any? { |pokemon| !pokemon.dead? && (pokemon.id == id || !id) && yield(pokemon) }
      else
        return @actors.any? { |pokemon| !pokemon.dead? && pokemon.id == id }
      end
    end

    # Add a Pokemon to the pary (also update the Pokedex Informations)
    # @param pkmn [PFM::Pokemon]
    # @return [Boolean, Integer] Box index if stored in a box, false if failed, true if stored in the Party
    def add_pokemon(pkmn)
      unless pkmn.egg?
        @pokedex.mark_seen(pkmn.id, pkmn.form, forced: true)
        @pokedex.mark_captured(pkmn.id)
        @pokedex.pokemon_fought_inc(pkmn.id)
        @pokedex.pokemon_captured_inc(pkmn.id)
      end

      if full?
        return @storage.current_box if @storage.store(pkmn)
        return false
      else
        @actors << pkmn
        return true
      end
    end

    # Remove a pokemon from the party
    # @param var [Integer, Symbol] the var value (index or id)
    # @param by_id [Boolean] if the pokemon are removed by their id
    # @param all [Boolean] if every pokemon that has the id are removed
    def remove_pokemon(var, by_id = false, all = false)
      var = GameData::Pokemon.get_id(var) if var.is_a?(Symbol)
      if by_id
        @actors.each_with_index do |pokemon, index|
          if pokemon.id == var
            @actors[index] = nil
            break unless all
          end
        end
      else
        @actors[var] = nil
      end
      @actors.compact!
    end

    # Switch pokemon in the party
    # @param first [Integer] index of the first pokemon to switch
    # @param second [Integer] index of the second pokemon to switch
    def switch_pokemon(first, second)
      @actors[first], @actors[second] = @actors[second], @actors[first]
      @actors.compact!
    end

    # Check if the player has a specific Pokemon in its party
    # @param id [Integer, Symbol] id of the Pokemon in the database
    # @param level [Integer, nil] the level required
    # @param form [Integer, nil] the form of the Pokemon
    # @param shiny [Boolean, nil] if the Pokemon should be shiny or not
    # @param index [Boolean] if you want an index when found
    # @return [Boolean, Integer] if the Pokemon has been found
    def contain_matching_pokemon?(id, level = nil, form = nil, shiny = nil, index: false)
      id = GameData::Pokemon.get_id(id) if id.is_a?(Symbol)
      @actors.each_with_index do |pokemon, i|
        next unless pokemon.id == id
        bool = true
        bool &&= pokemon.level == level if level
        bool &&= pokemon.form == form if form
        bool &&= pokemon.shiny == shiny unless shiny.nil?
        next unless bool
        return i if index
        return true
      end
      return false
    end
    alias has_pokemon? contain_matching_pokemon?

    # Check if the player has enough Pokemon to choose in its party
    # Doesn't count banned Pokemon
    # @param arr [Array] ids of the banned Pokemon
    def contain_enough_selectable_pokemon?(arr = [])
      if arr.any?
        count = @actors.count { |pokemon| !arr.include?(pokemon.id) }
      else
        count = $actors.size
      end

      return false unless $game_variables[Yuki::Var::Max_Pokemon_Select].between(1, size)
      return $game_variables[Yuki::Var::Max_Pokemon_Select] <= count
    end
    alias has_enough_selectable_pokemon? contain_enough_selectable_pokemon?

    # Find a specific Pokemon index in the party
    # @param id [Integer, Symbol] id of the Pokemon in the database
    # @param level [Integer, nil] the level required
    # @param form [Integer, nil] the form of the Pokemon
    # @param shiny [Boolean, nil] if the Pokemon should be shiny or not
    # @param index [Boolean] if you want an index when found
    # @return [Integer, false] index of the Pokemon in the party
    def pokemon_index(id, level = nil, form = nil, shiny = nil)
      has_pokemon?(id, level, form, shiny, index: true)
    end

    # Heal the pokemon in the Party
    def heal_party
      @actors.each do |pokemon|
        next unless pokemon
        pokemon.cure
        pokemon.hp = pokemon.max_hp
        pokemon.skills_set.each do |skill|
          skill&.pp = skill.ppmax
        end
      end
    end

    # Return the maximum level of the Pokemon in the Party
    # @return [Integer]
    def max_level
      @actors.max_by(&:level)&.level || 0
    end

    # Check if the party has a Pokemon with a specific skill
    # @param id [Integer, Symbol] ID of the skill in the database
    # @param index [Boolean] if the method return the index of the Pokemon that has the skill
    # @return [Boolean, Integer]
    def contain_pokemon_with_the_skill?(id, index = false)
      id = GameData::Skill.get_id(id) if id.is_a?(Symbol)
      @actors.each_with_index do |pokemon, i|
        next unless pokemon
        pokemon.skills_set.each do |skill|
          if skill&.id == id
            return index ? i : true
          end
        end
      end
      return false
    end
    alias has_skill? contain_pokemon_with_the_skill?

    # Get the index of the Pokemon that has the specified skill
    # @param id [Integer, Symbol] ID of the skill in the database
    # @return [Integer, false]
    def pokemon_skill_index(id)
      has_skill?(id, true)
    end

    # Check if the party has a Pokemon with a specific ability
    # @param id [Integer, Symbol] ID of the ability in the database
    # @param index [Boolean] if the method return the index of the Pokemon that has the ability
    # @return [Boolean, Integer]
    def contain_pokemon_with_the_ability?(id, index = false)
      id = GameData::Abilities.find_using_symbol(id) if id.is_a?(Symbol)
      @actors.each_with_index do |pokemon, i|
        if pokemon&.ability == id
          return index ? i : true
        end
      end
      return false
    end
    alias has_ability? contain_pokemon_with_the_ability?

    # Get the index of the Pokemon that has the specified ability
    # @param id [Integer, Symbol] ID of the ability in the database
    # @return [Integer, false]
    def pokemon_ability_index(id)
      has_ability?(id, true)
    end

    # Checks if one Pokemon of the party can learn the requested skill.
    # @overload can_learn?(id)
    #   @param id [Integer, Symbol] the id of the skill in the database
    #   @return [Boolean]
    # @overload can_learn?(id, index)
    #   Returns the position of the first pokemon that meets conditions
    #   @param id [Integer, Symbol] the id of the skill in the database
    #   @param index [true] indicating to return the index
    #   @return [Integer, false]
    def can_learn?(id, index = false)
      id = GameData::Skill.get_id(id) if id.is_a?(Symbol)
      @actors.each_with_index do |pokemon, i|
        if pokemon&.can_learn?(id)
          return index ? i : true
        end
      end
      return false
    end

    # Return the index of the Pokemon who can learn the specified skill
    # @param id [Integer, Symbol] the id of the skill in the database
    # @return [Integer, false]
    def can_learn_index(id)
      can_learn?(id, true)
    end

    # Checks if one Pokemon of the party can learn or has learnt the requested skill.
    # @overload can_learn_or_learnt?(id)
    #   @param id [Integer, Symbol] the id of the skill in the database
    #   @return [Boolean]
    # @overload can_learn_or_learnt?(id, index)
    #   Returns the position of the first pokemon that meets conditions
    #   @param id [Integer, Symbol] the id of the skill in the database
    #   @param index [true] indicating to return the index
    #   @return [Integer, false]
    def can_learn_or_learnt?(id, index = false)
      id = GameData::Skill.get_id(id) if id.is_a?(Symbol)
      @actors.each_with_index do |pokemon, i|
        next unless pokemon
        if pokemon.can_learn?(id) != false
          return index ? i : true
        end
      end
      return false
    end

    # Return the index of the Pokemon who can learn or has learn the specified skill
    # @param id [Integer, Symbol] the id of the skill in the database
    # @return [Integer, false]
    def can_learn_or_learnt_index(id)
      can_learn_or_learnt?(id, true)
    end

    # Return the Pokemon that match the specific criteria
    # @param criteria [Hash] list of property linked to a value to check in order to find the Pokemon
    # @return [PFM::Pokemon, nil]
    def find_pokemon(criteria)
      @actors.find do |pokemon|
        criteria.each do |property, value|
          break(false) unless pokemon.send(property) == value
        end
      end
    end
  end
end
