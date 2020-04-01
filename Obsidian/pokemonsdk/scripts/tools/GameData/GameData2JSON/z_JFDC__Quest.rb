module GameData
  class JSONFromDataCollection
    private

    # Convert all the Quest to JSON Ruby Object
    # @return [Array]
    def convert_all_quests
      return @data.collect do |quest|
        {
          id: quest.id,
          db_symbol: quest.db_symbol,
          items: items_symbol(quest.items),
          item_amount: quest.item_amount,
          speak_to: quest.speak_to,
          see_pokemon: pokemons_symbol(quest.see_pokemon),
          beat_pokemon: pokemons_symbol(quest.beat_pokemon),
          beat_pokemon_amount: quest.beat_pokemon_amount,
          catch_pokemon: pokemons_symbol(quest.catch_pokemon),
          catch_pokemon_amount: quest.catch_pokemon_amount,
          beat_npc: quest.beat_npc,
          beat_npc_amount: quest.beat_npc_amount,
          get_egg_amount: quest.get_egg_amount,
          hatch_egg_amount: quest.hatch_egg_amount,
          earnings: earning_symbol(quest.earnings),
          primary: quest.primary,
          goal_order: quest.get_goal_order,
          shown_goal: quest.get_shown_goal
        }
      end
    end

    # Convert items ID to Symbol
    # @param items [Array<Integer>]
    # @return [Array]
    def items_symbol(items)
      return items if @no_symbol_conv || items.nil?
      return items.collect do |id|
        GameData::Item.db_symbol(id)
      end
    end

    # Convert Pokemons ID to Symbol
    # @param pokemons [Array]
    # @return [Array]
    def pokemons_symbol(pokemons)
      return pokemons if @no_symbol_conv || pokemons.nil?
      return pokemons.collect do |id|
        GameData::Pokemon.db_symbol(id)
      end
    end

    # Convert items, pokemon ID to Symbol from earnings
    # @param earnings [Array<Hash>]
    # @return [Array<Hash>]
    def earning_symbol(earnings)
      return earnings if @no_symbol_conv || earnings.nil?
      return earnings.collect do |hash|
        hash = hash.clone
        hash[:item] = GameData::Item.db_symbol(hash[:item]) if hash.key?(:item)
        hash[:items] = items_symbol(hash[:items]) if hash.key?(:items)
        hash[:pokemon] = GameData::Pokemon.db_symbol(hash[:pokemon]) if hash.key?(:pokemon)
        hash[:pokemons] = pokemons_symbol(hash[:pokemons]) if hash.key?(:pokemons)
        next(hash)
      end
    end
  end

  class Quest
    class << self
      # Convert all the quests to a JSON file
      # @param filename [String] name of the file
      # @param use_id [Boolean] if the ID used in the various data part should not be converted to Symbol
      def to_json(filename, use_id = false)
        load if all.empty?
        JSONFromDataCollection.new(all, use_id).convert(filename)
      end
    end
  end
end
