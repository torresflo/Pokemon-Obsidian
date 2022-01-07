module PFM
  class Quests
    # Class describing a running quest
    class Quest
      # Get the quest id
      # @return [Integer]
      attr_reader :quest_id
      # Create a new quest
      def initialize(quest_id)
        @quest_id = quest_id
        @data = {}
        quest = GameData::Quest[quest_id]
        data_set(:goals_visibility, quest.objectives.map { |objective| !objective.hidden_by_default })
      end

      # Get a specific data information
      # @param path [Array<Symbol, Integer>] path used to obtain the data
      # @param default [Object] default value
      # @return [Object, default]
      def data_get(*path, default)
        return @data.dig(*path) || default
      end

      # Set a specific data information
      # @param path [Array<Symbol, Integer>] path used to obtain the data
      # @param value [Object]
      def data_set(*path, value)
        data = @data
        last_part = path.pop
        path.each do |part|
          data = (data[part] ||= {})
        end
        data[last_part] = value
      end

      # Test if the quest has a specific kind of objective
      # @param objective_method_name [Symbol] name of the method to call to validate the objective
      # @param args [Array] double check to ensure the arguments match the test
      def objective?(objective_method_name, *args)
        # @type [GameData::Quest]
        quest = GameData::Quest[quest_id]
        # @type [Array<Boolean>]
        objective_visibility = data_get(:goals_visibility, nil.to_a)
        quest.objectives.each_with_index do |objective, index|
          next if objective.hidden_by_default && !objective_visibility[index]
          next unless objective.test_method_name == objective_method_name
          next unless args.each_with_index.all? { |arg, i| objective.test_method_args[i] == arg }

          return true
        end
        return false
      end

      # Distribute the earning of the quest
      def distribute_earnings
        data = GameData::Quest[@quest_id]
        data.earnings.each do |earning|
          send(earning.give_method_name, *earning.give_args)
        end
        data_set(:earnings_distributed, true)
      end

      # Tell if all the objective of the quest are finished
      # @return [Boolean]
      def finished?
        data = GameData::Quest[@quest_id]
        return data.objectives.all? do |objective|
          send(objective.test_method_name, *objective.test_method_args)
        end
      end

      # Get the list of objective texts with their validation state
      # @return [Array<Array(String, Boolean)>]
      # @note Does not return text of hidden objectives
      def objective_text_list
        # @type [Array<Boolean>]
        objective_visibility = data_get(:goals_visibility, nil.to_a)
        data = GameData::Quest[@quest_id]
        visible_objectives = data.objectives.select.with_index { |_, index| objective_visibility[index] }
        return visible_objectives.map do |objective|
          [
            send(objective.text_format_method_name, *objective.test_method_args),
            send(objective.test_method_name, *objective.test_method_args)
          ]
        end
      end

      # Check the specific pokemon criterion in catch_pokemon
      # @param pkm [Hash, Integer] the criterions of the Pokemon
      #
      #   The criterions are :
      #     nature: opt Integer # ID of the nature of the Pokemon
      #     type: opt Integer # One required type id
      #     min_level: opt Integer # The minimum level the Pokemon should have
      #     max_level: opt Integer # The maximum level the Pokemon should have
      #     level: opt Integer # The level the Pokemon must be
      # @param pokemon [PFM::Pokemon] the Pokemon that should be check with the criterions
      # @return [Boolean] if the Pokemon pokemon check the criterions
      def objective_catch_pokemon_test(pkm, pokemon)
        return pokemon.id == pkm unless pkm.is_a?(Hash)
        return false if pkm[:nature] && pokemon.nature_id != pkm[:nature]
        return false if pkm[:type] && pokemon.type1 != pkm[:type] && pokemon.type2 != pkm[:type]
        return false if pkm[:min_level] && pokemon.level < pkm[:min_level]
        return false if pkm[:max_level] && pokemon.level > pkm[:max_level]
        return false if pkm[:level] && pokemon.level != pkm[:level]

        return true
      end

      private

      # Test if the objective speak to is validated
      # @param index [Integer] index of the npc
      # @param _name [String] name of the npc (ignored)
      # @return [Boolean]
      def objective_speak_to(index, _name)
        return data_get(:spoken, index, false)
      end

      # Get the text related to the speak to objective
      # @param _index [Integer] index of the npc (ignored)
      # @param name [String] name of the npc
      # @return [String]
      def text_speak_to(index, name)
        return format(ext_text(9000, 53), name: name)
      end

      # Test if the objective obtain item is validated
      # @param item_id [Integer] ID of the item in the database
      # @param amount [Integer] number of item to obtain
      # @return [Boolean]
      def objective_obtain_item(item_id, amount)
        return data_get(:obtained_items, item_id, 0) >= amount
      end

      # Text of the obtain item objective
      # @param item_id [Integer] ID of the item in the database
      # @param amount [Integer] number of item to obtain
      # @return [String]
      def text_obtain_item(item_id, amount)
        found = data_get(:obtained_items, item_id, 0).clamp(0, amount)
        name = GameData::Item[item_id].name
        return format(ext_text(9000, 52), amount: amount, item_name: name, found: found)
      end

      # Test if the objective see pokemon is validated
      # @param pokemon_id [Integer] ID of the pokemon to see
      # @return [Boolean]
      def objective_see_pokemon(pokemon_id)
        return data_get(:pokemon_seen, pokemon_id, false)
      end

      # Text of the see pokemon objective
      # @param pokemon_id [Integer] ID of the pokemon to see
      # @return [String]
      def text_see_pokemon(pokemon_id)
        return format(ext_text(9000, 54), name: GameData::Pokemon[pokemon_id].name)
      end

      # Test if the beat pokemon objective is validated
      # @param pokemon_id [Integer] ID of the pokemon to beat
      # @param amount [Integer] number of pokemon to beat
      # @return [Boolean]
      def objective_beat_pokemon(pokemon_id, amount)
        return data_get(:pokemon_beaten, pokemon_id, 0) >= amount
      end

      # Text of the beat pokemon objective
      # @param pokemon_id [Integer] ID of the pokemon to beat
      # @param amount [Integer] number of pokemon to beat
      # @return [String]
      def text_beat_pokemon(pokemon_id, amount)
        name = GameData::Pokemon[pokemon_id].name
        found = data_get(:pokemon_beaten, pokemon_id, 0).clamp(0, amount)
        return format(ext_text(9000, 55), amount: amount, name: name, found: found)
      end

      # Test if the catch pokemon objective is validated
      # @param pokemon_id [Integer] ID of the pokemon to beat
      # @param amount [Integer] number of pokemon to beat
      # @return [Boolean]
      def objective_catch_pokemon(pokemon_id, amount)
        return data_get(:pokemon_caught, pokemon_id, 0) >= amount
      end

      # Text of the catch pokemon objective
      # @param pokemon_id [Integer] ID of the pokemon to beat
      # @param amount [Integer] number of pokemon to beat
      # @return [String]
      def text_catch_pokemon(pokemon_id, amount)
        name = text_catch_pokemon_name(pokemon_id)
        found = data_get(:pokemon_caught, pokemon_id, 0).clamp(0, amount)
        format(ext_text(9000, 56), amount: amount, name: name, found: found)
      end

      # Get the exact text for the name of the caught pokemon
      # @param data [Integer, Hash]
      # @return [String]
      def text_catch_pokemon_name(data)
        return GameData::Pokemon[data].name if data.is_a?(Integer)

        str = 'Pokémon'
        str << format(ext_text(9000, 63), GameData::Type.get(data[:type]).name) if data[:type]
        str << format(ext_text(9000, 64), text_get(8, data[:nature])) if data[:nature]
        if (id = data[:min_level])
          str << format(ext_text(9000, 66), id)
          str << format(ext_text(9000, 67), data[:max_level]) if data[:max_level]
        elsif (id = data[:max_level])
          str << format(ext_text(9000, 68), id) # " de niveau #{id} maximum"
        end
        str << format(ext_text(9000, 65), data[:level]) if data[:level]
        return str
      end

      # Test if the beat NPC objective is validated
      # @param index [Integer] index of the npc
      # @param _name [String] name of the npc (ignored)
      # @param amount [Integer] number of time the npc should be beaten
      # @return [Boolean]
      def objective_beat_npc(index, _name, amount)
        return data_get(:npc_beaten, index, 0) >= amount
      end

      # Text of the beat NPC objective
      # @param _index [Integer] index of the npc (ignored)
      # @param name [String] name of the npc
      # @param amount [Integer] number of time the npc should be beaten
      # @return [String]
      def text_beat_npc(_index, name, amount)
        if amount > 1
          found = data_get(:npc_beaten, index, 0).clamp(0, amount)
          return format(ext_text(9000, 57), amount: amount, name: name, found: found)
        end
        return format(ext_text(9000, 58), name: name)
      end

      # Test if the obtain egg objective is validated
      # @param amount [Integer] amount of egg to obtain
      # @return [Boolean]
      def objective_obtain_egg(amount)
        return data_get(:obtained_eggs, 0) >= amount
      end

      # Text of the obtain egg objective
      # @param amount [Integer] amount of egg to obtain
      # @return [Boolean]
      def text_obtain_egg(amount)
        if amount > 1
          found = data_get(:obtained_eggs, 0).clamp(0, amount)
          return format(ext_text(9000, 59), amount: amount, found: found)
        end
        return ext_text(9000, 60)
      end

      # Test if the hatch egg objective is validated
      # @param unk [nil] ???
      # @param amount [Integer] amount of egg to obtain
      # @return [Boolean]
      def objective_hatch_egg(unk, amount)
        return data_get(:hatched_eggs, unk, 0) >= amount
      end

      # Text of the hatch egg objective
      # @param unk [nil] ???
      # @param amount [Integer] amount of egg to obtain
      # @return [Boolean]
      def text_hatch_egg(unk, amount)
        if amount > 1
          found = data_get(:hatched_eggs, unk, 0).clamp(0, amount)
          return format(ext_text(9000, 61), amount: amount, found: found)
        end
        return ext_text(9000, 62)
      end

      # Getting money from a quest
      # @param amount [Integer] amount of money gotten
      def earning_money(amount)
        return if data_get(:earnings, :money, false)

        PFM.game_state.add_money(amount)
        data_set(:earnings, :money, true)
      end

      # Earning money text
      # @param amount [Integer] amount of money gotten
      # @return [String]
      def text_earn_money(amount)
        return parse_text(11, 9, ::PFM::Text::NUM7R => amount.to_s)
      end

      # Getting item from a quest
      # @param item_id [Integer, Symbol] ID of the item to give
      # @param amount [Integer] number of item to give
      def earning_item(item_id, amount)
        item_id = GameData::Item.db_symbol(item_id) unless item_id.is_a?(Symbol)
        return if data_get(:earnings, :items, item_id, false)

        $bag.add_item(item_id, amount)
        data_set(:earnings, :items, item_id, true)
      end

      # Earning item text
      # @param item_id [Integer, Symbol] ID of the item to give
      # @param amount [Integer] number of item to give
      def text_earn_item(item_id, amount)
        return format('%<amount>d %<name>s', amount: amount, name: GameData::Item[item_id].name)
      end
    end
  end
end
