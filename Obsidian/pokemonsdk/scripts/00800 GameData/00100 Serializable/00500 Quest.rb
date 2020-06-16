module GameData
  # Quest data structure
  # @author Nuri Yuri
  class Quest < Base
    # List of required items to find (IDs)
    # @return [Array<Integer>, nil]
    attr_accessor :items
    # On the same index as items, the amount of items required
    # @return [Array<Integer>, nil]
    attr_accessor :item_amount
    # List of NPC name the player has to speack to
    # @return [Array<String>, nil]
    attr_accessor :speak_to
    # List of Pokemon (ID) to see
    # @return [Array<Integer>, nil]
    attr_accessor :see_pokemon
    # List of Pokemon (ID) to beat
    # @return [Array<Integer>, nil]
    attr_accessor :beat_pokemon
    # On the same index as beat, the number of Pokemon to beat
    # @return [Array<Integer>, nil]
    attr_accessor :beat_pokemon_amount
    # List of Pokemon (ID) to catch
    # @return [Array<Integer>, nil]
    attr_accessor :catch_pokemon
    # On the same index as catch_pokemon, the number of Pokemon to catch
    # @return [Array<Integer>, nil]
    attr_accessor :catch_pokemon_amount
    # List of NPC name to beat
    # @return [Array<String>, nil]
    attr_accessor :beat_npc
    # On the same index, the number of time to beat the NPC
    # @return [Array<Integer>, nil]
    attr_accessor :beat_npc_amount
    # Amount of egg to get
    # @return [Integer, nil]
    attr_accessor :get_egg_amount
    # Amount of egg to hatch
    # @return [Integer, nil]
    attr_accessor :hatch_egg_amount
    # List of earnings
    # @return [Array<Hash>, nil]
    attr_accessor :earnings
    # If the quest is a primary quest
    # @return [Boolean]
    attr_accessor :primary
    # The goal order of the quest
    attr_writer :goal_order
    # The shown goal when the quest starts
    attr_writer :shown_goal
    # Get the goal order of the quest
    # @return [Array<Symbol>]
    def goal_order
      return @goal_order if @goal_order
      arr = @goal_order = []
      arr.concat(Array.new(@speak_to.size, :speak_to)) if @speak_to
      arr.concat(Array.new(@items.size, :items)) if @items
      arr.concat(Array.new(@see_pokemon.size, :see_pokemon)) if @see_pokemon
      arr.concat(Array.new(@beat_pokemon.size, :beat_pokemon)) if @beat_pokemon
      arr.concat(Array.new(@catch_pokemon.size, :catch_pokemon)) if @catch_pokemon
      arr.concat(Array.new(@beat_npc.size, :beat_npc)) if @beat_npc
      arr << :get_egg_amount if @get_egg_amount
      arr << :hatch_egg_amount if @hatch_egg_amount
      return arr
    end
    alias get_goal_order goal_order
    # Get the shown goal when the quest starts
    # @return [Array<Boolean>]
    def shown_goal
      return @shown_goal if @shown_goal
      return @shown_goal = Array.new(get_goal_order.size, true)
    end
    alias get_shown_goal shown_goal

    alias number_of_egg_to_find get_egg_amount
    alias number_of_egg_to_hatch hatch_egg_amount

    class << self
      # All the quests
      # @type [Array<GameData::Quest>]
      @data = []
      # If the quest is a primary quest
      # @param quest_id [Integer] ID of the quest in the database
      # @return [Boolean]
      def primary?(quest_id)
        return false unless id_valid?(quest_id)
        return @data[quest_id].primary
      end

      # Retrieve the quest name
      # @param quest_id [Integer] ID of the quest in the database
      # @return [String]
      def name(quest_id = Class)
        return super() if quest_id == Class

        return nil.to_s unless id_valid?(quest_id)
        return text_get(45, quest_id)
      end

      # Retrieve the quest description
      # @param quest_id [Integer] ID of the quest
      def descr(quest_id)
        return nil.to_s unless id_valid?(quest_id)
        return text_get(46, quest_id)
      end

      # If the quest require to get items
      # @param quest_id [Integer] ID of the quest in the database
      # @return [Boolean]
      def requires_to_get_item?(quest_id)
        return false unless id_valid?(quest_id)
        return (@data[quest_id].items&.size || 0) > 0
      end
      alias has_item? requires_to_get_item?

      # List of item to get for a quest
      # @param quest_id [Integer] ID of the quest in the database
      # @return [Array<Integer>]
      def items(quest_id)
        return nil.to_a unless requires_to_get_item?(quest_id)
        return @data[quest_id].items
      end

      # The quantity of item to get for a quest
      # @param quest_id [Integer] ID of the quest in the database
      # @param item_id [Integer] ID of the item in the database
      # @return [Integer]
      def item_amount(quest_id, item_id)
        return 0 unless requires_to_get_item?(quest_id)
        quest = @data[quest_id]
        index = quest.items.index(item_id)
        return 0 unless index && quest.item_amount
        return quest.item_amount[index] || 0
      end

      # Does the quest require to speak to a NPC
      # @param quest_id [Integer] ID of the quest in the database
      # @return [Boolean]
      def requires_to_speak_to_npc?(quest_id)
        return false unless id_valid?(quest_id)
        return (@data[quest_id].speak_to&.size || 0) > 0
      end
      alias has_to_speak? requires_to_speak_to_npc?

      # List of NPC to speak to
      # @param quest_id [Integer] ID of the quest in the database
      # @return [Array<String>]
      def speak_to(quest_id)
        return nil.to_a unless requires_to_speak_to_npc?(quest_id)
        return @data[quest_id].speak_to
      end

      # Does the quest require to see Pokemon
      # @param quest_id [Integer] ID of the quest in the database
      # @return [Boolean]
      def requires_to_see_pokemon?(quest_id)
        return false unless id_valid?(quest_id)
        return (@data[quest_id].see_pokemon&.size || 0) > 0
      end
      alias has_to_see_pokemon? requires_to_see_pokemon?

      # List of Pokemon to see
      # @param quest_id [Integer] ID of the quest in the database
      # @return [Array<Integer>]
      def see_pokemon(quest_id)
        return nil.to_a unless requires_to_see_pokemon?(quest_id)
        return @data[quest_id].see_pokemon
      end

      # Does the quest require to beat pokemon
      # @param quest_id [Integer] ID of the quest in the database
      # @return [Boolean]
      def requires_to_beat_pokemon?(quest_id)
        return false unless id_valid?(quest_id)
        return (@data[quest_id].beat_pokemon&.size || 0) > 0
      end
      alias has_to_beat_pokemon? requires_to_beat_pokemon?

      # List of Pokemon to beat
      # @param quest_id [Integer] ID of the quest in the database
      # @return [Array<Integer>]
      def beat_pokemon(quest_id)
        return nil.to_a unless requires_to_beat_pokemon?(quest_id)
        return @data[quest_id].beat_pokemon
      end

      # How many time the Pokemon should be defeated
      # @param quest_id [Integer] ID of the quest in the database
      # @param pokemon_id [Integer] ID of the Pokemon in the database
      # @return [Integer]
      def beat_pokemon_amount(quest_id, pokemon_id)
        return 0 unless requires_to_beat_pokemon?(quest_id)
        quest = @data[quest_id]
        index = quest.beat_pokemon.index(pokemon_id)
        return 0 unless index && quest.beat_pokemon_amount
        return quest.beat_pokemon_amount[index] || 0
      end

      # Does the quest require to catch Pokemon
      # @param quest_id [Integer] ID of the quest in the database
      # @return [Boolean]
      def requires_to_catch_pokemon?(quest_id)
        return false unless id_valid?(quest_id)
        return (@data[quest_id].catch_pokemon&.size || 0) > 0
      end
      alias has_to_catch_pokemon? requires_to_catch_pokemon?

      # List of Pokemon to catch
      # @param quest_id [Integer] ID of the quest in the database
      # @return [Array<Integer>]
      def catch_pokemon(quest_id)
        return nil.to_a unless requires_to_catch_pokemon?(quest_id)
        return @data[quest_id].catch_pokemon
      end

      # Number of specific Pokemon to catch
      # @param quest_id [Integer] ID of the quest in the database
      # @param pokemon_id [Integer] ID of the Pokemon in the database
      # @return [Integer]
      def catch_pokemon_amount(quest_id, pokemon_id)
        return 0 unless requires_to_catch_pokemon?(quest_id)
        quest = @data[quest_id]
        index = quest.catch_pokemon.index(pokemon_id)
        return 0 unless index && quest.catch_pokemon_amount
        return quest.catch_pokemon_amount[index] || 0
      end

      # Does the quest require to beat NPC
      # @param quest_id [Integer] ID of the quest in the database
      # @return [Boolean]
      def requires_to_beat_npc?(quest_id)
        return false unless id_valid?(quest_id)
        return (@data[quest_id].beat_npc&.size || 0) > 0
      end
      alias has_to_beat_npc? requires_to_beat_npc?

      # List of NPC to beat (Names)
      # @param quest_id [Integer] ID of the quest in the database
      # @return [Array<String>]
      def beat_npc(quest_id)
        return nil.to_a unless requires_to_beat_npc?(quest_id)
        return @data[quest_id].beat_npc
      end

      # List of number of time a NPC should be defeated
      # @param quest_id [Integer] ID of the quest in the database
      # @return [Array<Integer>]
      def beat_npc_amount(quest_id)
        return nil.to_a unless requires_to_beat_npc?(quest_id)
        return @data[quest_id].beat_npc_amount || nil.to_a
      end

      # Does the quest require to find an egg
      # @param quest_id [Integer] ID of the quest in the database
      # @return [Boolean]
      def requires_to_find_egg?(quest_id)
        return false unless id_valid?(quest_id)
        return (@data[quest_id].get_egg_amount || 0) > 0
      end
      alias has_to_get_egg? requires_to_find_egg?

      # Number of egg to find
      # @param quest_id [Integer] ID of the quest in the database
      # @return [Integer]
      def number_of_egg_to_find(quest_id)
        return 0 unless requires_to_find_egg?(quest_id)
        return @data[quest_id].get_egg_amount
      end
      alias get_egg_amount number_of_egg_to_find

      # Does the quest require to hatch egg
      # @param quest_id [Integer] ID of the quest in the database
      # @return [Boolean]
      def requires_to_hatch_egg?(quest_id)
        return false unless id_valid?(quest_id)
        return (@data[quest_id].hatch_egg_amount || 0) > 0
      end
      alias has_to_hatch_egg? requires_to_hatch_egg?

      # Number of egg to hatch
      # @param quest_id [Integer] ID of the quest in the database
      # @return [Integer]
      def number_of_egg_to_hatch(quest_id)
        return 0 unless requires_to_hatch_egg?(quest_id)
        return @data[quest_id].hatch_egg_amount
      end
      alias hatch_egg_amount number_of_egg_to_hatch

      # Tell if the quest ID is valid
      # @param id [Integer]
      # @return [Boolean]
      def id_valid?(id)
        return id.between?(0, @data.size - 1)
      end

      # Retrieve a specific quest
      # @param id [Integer]
      # @return [GameData::Quest]
      def get(id)
        return @data[id] if id_valid?(id)
        return @data.first
      end

      # Get all the quests
      # @return [Array<GameData::Quest>]
      def all
        return @data
      end

      # Load the quests
      def load
        # @type [GameData::Quest]
        @data = load_data('Data/PSDK/Quests.rxdata').freeze
      end
    end
  end
end
