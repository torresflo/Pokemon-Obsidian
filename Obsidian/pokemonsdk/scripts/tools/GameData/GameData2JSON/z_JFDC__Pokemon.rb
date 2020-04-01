module GameData
  class JSONFromDataCollection
    private

    # Return the JSON ruby Object corresponding to a 2D Array of GameData::Pokemon
    # @return [Array]
    def convert_all_pokemon
      pokemon_json = []
      @data.each_with_index do |pokemons, id|
        forms = []
        pokemon_json << {
          regionalId: pokemons.first.id_bis,
          db_symbol: pokemons.first.db_symbol || :__undef__,
          id: id,
          forms: forms
        }
        pokemons.each { |pokemon| forms << convert_single_pokemon(pokemon) if pokemon }
      end
      return pokemon_json
    end

    # Return the JSON Ruby Object corresponding to a GameData::Pokemon
    # @param pokemon [GameData::Pokemon]
    # @return [Hash]
    def convert_single_pokemon(pokemon)
      {
        index: pokemon.form || 0,
        name: pokemon.id || 0,
        height: pokemon.height,
        weight: pokemon.weight,
        baseHp: pokemon.base_hp,
        baseAtk: pokemon.base_atk,
        baseDef: pokemon.base_dfe,
        baseSpeAtk: pokemon.base_ats,
        baseSpeDef: pokemon.base_dfs,
        baseSpeed: pokemon.base_spd,
        hpEvs: pokemon.ev_hp,
        atkEvs: pokemon.ev_atk,
        defEvs: pokemon.ev_dfe,
        speAtkEvs: pokemon.ev_ats,
        speDefEvs: pokemon.ev_dfs,
        speedEvs: pokemon.ev_spd,
        xpType: pokemon.exp_type,
        baseXp: pokemon.base_exp,
        baseHappiness: pokemon.base_loyalty,
        evolutionLvl: pokemon.evolution_level,
        specialEvolution: pokemon.special_evolution,
        catchRate: pokemon.rareness,
        hatchingSteps: pokemon.hatch_step,
        femaleRate: pokemon.female_rate,
        isGenderless: pokemon.female_rate == -1,
        breedGroups: pokemon.breed_groupes
      }.merge!(get_pokemon_info(pokemon))
    end

    # Return the complex info of a GameData::Pokemon
    # @param pokemon [GameData::Pokemon]
    # @return [Hash]
    def get_pokemon_info(pokemon)
      if @no_symbol_conv
        move_set = {}
        pokemon.move_set.each_slice(2) do |level, move|
          move_set[move] = level
        end
        items = {}
        pokemon.items.each_slice(2) do |item, rate|
          items[item] = rate
        end
        return {
          primaryType: pokemon.type1,
          secondaryType: pokemon.type2,
          firstAbility: pokemon.abilities[0] || -1,
          secondAbility: pokemon.abilities[1] || -1,
          hiddenAbility: pokemon.abilities[2] || -1,
          evolutionId: pokemon.evolution_id || 0,
          babyId: pokemon.baby,
          moveSet: move_set,
          techSet: pokemon.tech_set,
          breedMoves: pokemon.breed_moves,
          masterMoves: pokemon.master_moves,
          items: items
        }
      end
      # db_symbol converions
      evolution_id = pokemon.evolution_id || -1
      evolution_id = -1 if evolution_id.zero?
      move_set = {}
      pokemon.move_set.each_slice(2) do |level, move|
        move_set[Skill.db_symbol(move)] = level
      end
      items = {}
      pokemon.items.each_slice(2) do |item, rate|
        items[Item.db_symbol(item)] = rate
      end
      return {
        primaryType: pokemon.type1,
        secondaryType: pokemon.type2,
        firstAbility: Abilities.db_symbol(pokemon.abilities[0] || -1),
        secondAbility: Abilities.db_symbol(pokemon.abilities[1] || -1),
        hiddenAbility: Abilities.db_symbol(pokemon.abilities[2] || -1),
        evolutionId: Pokemon.db_symbol(evolution_id),
        babyId: Pokemon.db_symbol(pokemon.baby || -1),
        moveSet: move_set,
        techSet: pokemon.tech_set.collect { |move| Skill.db_symbol(move) },
        breedMoves: pokemon.breed_moves.collect { |move| Skill.db_symbol(move) },
        masterMoves: pokemon.master_moves.collect { |move| Skill.db_symbol(move) },
        items: items
      }
    end
  end

  class Pokemon
    class << self
      # Convert all the Pokemon to a JSON file
      # @param filename [String] name of the file
      # @param use_id [Boolean] if the ID used in the various data part should not be converted to Symbol
      def to_json(filename, use_id = false)
        load if all.empty?
        JSONFromDataCollection.new(all, use_id).convert(filename)
      end
    end
  end
end
