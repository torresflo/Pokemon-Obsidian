module PFM
  # The quest management
  #
  # The main object is stored in $quests and $pokemon_party.quests
  class Quests
    # The list of active_quests
    # @return [Hash<Integer => Hash>]
    attr_accessor :active_quests
    # The list of finished_quests
    # @return [Hash<Integer => Hash>]
    attr_accessor :finished_quests
    # The list of failed_quests
    # @return [Hash<Integer => Hash>]
    attr_accessor :failed_quests
    # The signals that inform the game what quest started or has been finished
    # @return [Hash<start: Array<Integer>, finish: Array<Integer>, failed: Array<Integer>>]
    attr_accessor :signal
    # Create a new Quest management object
    def initialize
      @active_quests = {}
      @finished_quests = {}
      @failed_quests = {}
      @signal = { start: [], finish: [], failed: [] }
    end

    # Convert the quest object for PSDK Alpha 23.0
    def __convert
      @failed_quests = {}
      @signal[:failed] = []
      @active_quests.each do |quest_id, quest|
        next unless GameData::Quest.id_valid?(quest_id) && quest
        quest_data = GameData::Quest.get(quest_id)
        quest[:order] = quest_data.get_goal_order
        quest[:shown] = quest_data.get_shown_goal
      end
      @finished_quests.each do |quest_id, quest|
        next unless GameData::Quest.id_valid?(quest_id) && quest
        quest_data = GameData::Quest.get(quest_id)
        quest[:order] = quest_data.get_goal_order
        quest[:shown] = Array.new(quest[:order].size, true)
      end
    end

    # Start a new quest if possible
    # @param quest_id [Integer] the ID of the quest in the database
    # @return [Boolean] if the quest started
    def start(quest_id)
      return false unless GameData::Quest.id_valid?(quest_id)
      return false if finished?(quest_id)
      return false if @active_quests.fetch(quest_id, nil)
      quest_data = GameData::Quest.get(quest_id)
      quest = @active_quests[quest_id] = {}
      quest[:items] = Array.new(quest_data.items.size, 0) if quest_data.items
      quest[:spoken] = Array.new(quest_data.speak_to.size, false) if quest_data.speak_to
      quest[:pokemon_seen] = Array.new(quest_data.see_pokemon.size, false) if quest_data.see_pokemon
      quest[:pokemon_beaten] = Array.new(quest_data.beat_pokemon.size, 0) if quest_data.beat_pokemon
      quest[:pokemon_catch] = Array.new(quest_data.catch_pokemon.size, 0) if quest_data.catch_pokemon
      quest[:npc_beaten] = Array.new(quest_data.beat_npc.size, 0) if quest_data.beat_npc
      quest[:egg_counter] = 0 if quest_data.number_of_egg_to_find.to_i > 0
      quest[:egg_hatched] = 0 if quest_data.number_of_egg_to_hatch.to_i > 0
      quest[:earnings] = false
      quest[:order] = quest_data.get_goal_order
      quest[:shown] = quest_data.get_shown_goal
      @signal[:start] << quest_id
      return true
    end

    # Show a goal of a quest
    # @param quest_id [Integer] the ID of the quest in the database
    # @param goal_index [Integer] the index of the goal in the goal order
    def show_goal(quest_id, goal_index)
      return if (quest = @active_quests.fetch(quest_id, nil)).nil?
      quest[:shown][goal_index] = true
    end

    # Tell if a goal is shown or not
    # @param quest_id [Integer] the ID of the quest in the database
    # @param goal_index [Integer] the index of the goal in the goal order
    # @return [Boolean]
    def goal_shown?(quest_id, goal_index)
      return false if (quest = @active_quests.fetch(quest_id, nil)).nil?
      return quest[:shown][goal_index]
    end

    # Get the goal data index (if array like items / speak_to return the index of the goal in the array info from
    # data/quest data)
    # @param quest_id [Integer] the ID of the quest in the database
    # @param goal_index [Integer] the index of the goal in the goal order
    # @return [Integer]
    def get_goal_data_index(quest_id, goal_index)
      if (quest = @active_quests.fetch(quest_id, nil)).nil?
        if (quest = @finished_quests.fetch(quest_id, nil)).nil?
          return 0 if (quest = @failed_quests.fetch(quest_id, nil)).nil?
        end
      end
      goal_sym = quest[:order][goal_index]
      cnt = 0
      quest[:order].each_with_index do |sym, i|
        break if i >= goal_index
        cnt += 1 if sym == goal_sym
      end
      return cnt
    end

    # Get the goal type
    # @param quest_id [Integer] the ID of the quest in the database
    # @param goal_index [Integer] the index of the goal in the goal order
    # @return [Symbol]
    def get_goal_type(quest_id, goal_index)
      if (quest = @active_quests.fetch(quest_id, nil)).nil?
        if (quest = @finished_quests.fetch(quest_id, nil)).nil?
          return 0 if (quest = @failed_quests.fetch(quest_id, nil)).nil?
        end
      end
      return quest[:order][goal_index]
    end

    # Inform the manager that a NPC has been beaten
    # @param quest_id [Integer] the ID of the quest in the database
    # @param npc_name_index [Integer] the index of the name of the NPC in the quest data
    # @return [Boolean] if the quest has been updated
    def beat_npc(quest_id, npc_name_index)
      return false if (quest = @active_quests.fetch(quest_id, nil)).nil?
      return false unless quest[:npc_beaten]
      quest[:npc_beaten][npc_name_index] += 1
      check_quest(quest_id)
      return true
    end

    # Inform the manager that a NPC has been spoken to
    # @param quest_id [Integer] the ID of the quest in the database
    # @param npc_name_index [Integer] the index of the name of the NPC in the quest data
    # @return [Boolean] if the quest has been updated
    def speak_to_npc(quest_id, npc_name_index)
      return false if (quest = @active_quests.fetch(quest_id, nil)).nil?
      return false unless quest[:spoken]
      quest[:spoken][npc_name_index] = true
      check_quest(quest_id)
      return true
    end

    # Inform the manager that an item has been added to the bag of the Player
    # @param item_id [Integer] ID of the item in the database
    def add_item(item_id)
      @active_quests.each do |quest_id, quest|
        next unless quest[:items]
        next unless GameData::Quest.id_valid?(quest_id)
        quest_data = GameData::Quest.get(quest_id)
        index = quest_data.items.index(item_id)
        quest[:items][index] += 1 if index
        check_quest(quest_id)
      end
    end

    # Inform the manager that a Pokemon has been beaten
    # @param pokemon_id [Integer] ID of the Pokemon in the database
    def beat_pokemon(pokemon_id)
      @active_quests.each do |quest_id, quest|
        next unless quest[:pokemon_beaten]
        next unless GameData::Quest.id_valid?(quest_id)
        quest_data = GameData::Quest.get(quest_id)
        index = quest_data.beat_pokemon.index(pokemon_id)
        quest[:pokemon_beaten][index] += 1 if index
        check_quest(quest_id)
      end
    end

    # Inform the manager that a Pokemon has been captured
    # @param pokemon [PFM::Pokemon] the Pokemon captured
    def catch_pokemon(pokemon)
      @active_quests.each do |quest_id, quest|
        next unless quest[:pokemon_catch]
        next unless GameData::Quest.id_valid?(quest_id)
        quest_data = GameData::Quest.get(quest_id)
        quest_data.catch_pokemon.each_with_index do |pkm, index|
          if pkm.is_a?(Hash)
            next unless check_pokemon_criterion(pkm, pokemon)
          else
            next unless pokemon.id == pkm
          end
          quest[:pokemon_catch][index] += 1
        end
        check_quest(quest_id)
      end
    end

    # Check the specific pokemon criterion in catch_pokemon
    # @param pkm [Hash] the criterions of the Pokemon
    #
    #   The criterions are :
    #     nature: opt Integer # ID of the nature of the Pokemon
    #     type: opt Integer # One required type id
    #     min_level: opt Integer # The minimum level the Pokemon should have
    #     max_level: opt Integer # The maximum level the Pokemon should have
    #     level: opt Integer # The level the Pokemon must be
    # @param pokemon [PFM::Pokemon] the Pokemon that should be check with the criterions
    # @return [Boolean] if the Pokemon pokemon check the criterions
    def check_pokemon_criterion(pkm, pokemon)
      return false if pkm[:nature] && pokemon.nature_id != pkm[:nature]
      return false if pkm[:type] && pokemon.type1 != pkm[:type] && pokemon.type2 != pkm[:type]
      return false if pkm[:min_level] && pokemon.level < pkm[:min_level]
      return false if pkm[:max_level] && pokemon.level > pkm[:max_level]
      return false if pkm[:level] && pokemon.level != pkm[:level]

      return true
    end

    # Inform the manager that a Pokemon has been seen
    # @param pokemon_id [Integer] ID of the Pokemon in the database
    def see_pokemon(pokemon_id)
      @active_quests.each do |quest_id, quest|
        next unless quest[:pokemon_seen]
        next unless GameData::Quest.id_valid?(quest_id)
        quest_data = GameData::Quest.get(quest_id)
        index = quest_data.see_pokemon.index(pokemon_id)
        quest[:pokemon_seen][index] = true if index
        check_quest(quest_id)
      end
    end

    # Inform the manager an egg has been found
    def egg_found
      @active_quests.each do |quest_id, quest|
        next unless quest[:egg_counter]
        next unless GameData::Quest.id_valid?(quest_id)
        quest[:egg_counter] += 1
        check_quest(quest_id)
      end
    end
    alias get_egg egg_found

    # Inform the manager an egg has hatched
    def hatch_egg
      @active_quests.each do |quest_id, quest|
        next unless quest[:egg_hatched]
        next unless GameData::Quest.id_valid?(quest_id)
        quest[:egg_hatched] += 1
        check_quest(quest_id)
      end
    end

    # Check the signals and display them
    def check_up_signal
      return unless $scene.is_a?(Scene_Map)
      if @signal[:start].any?
        start_names = @signal[:start].collect { |quest_id| GameData::Quest.name(quest_id) }
        show_quest_inform(start_names, true)
      end
      if @signal[:finish].any?
        finish_names = @signal[:finish].collect { |quest_id| GameData::Quest.name(quest_id) }
        show_quest_inform(finish_names, false)
        # Switch the quests from stack to stack
        @signal[:finish].each do |quest_id|
          @finished_quests[quest_id] = @active_quests[quest_id] if @active_quests[quest_id]
          @active_quests.delete(quest_id)
        end
      end
      @signal[:start].clear
      @signal[:finish].clear
    end

    # Check if a quest is done or not
    # @param quest_id [Integer] ID of the quest in the database
    def check_quest(quest_id)
      quest = @active_quests.fetch(quest_id, nil)
      return unless quest && GameData::Quest.id_valid?(quest_id)
      quest_data = GameData::Quest.get(quest_id)
      # Item check
      if (infos = quest[:items]) && quest_data.item_amount
        quest_data.item_amount.each_with_index do |amount, index|
          return if infos[index] < amount
        end
      end
      # Check spoken to
      return if quest[:spoken]&.include?(false)
      # Check seen Pokemon
      return if quest[:pokemon_seen]&.include?(false)
      # Check beaten Pokemon
      if (infos = quest[:pokemon_beaten]) && quest_data.beat_pokemon_amount
        quest_data.beat_pokemon_amount.each_with_index do |amount, index|
          return if infos[index] < amount
        end
      end
      # Check cautch Pokemon
      if (infos = quest[:pokemon_catch]) && quest_data.catch_pokemon_amount
        quest_data.catch_pokemon_amount.each_with_index do |amount, index|
          return if infos[index] < amount
        end
      end
      # Check beaten NPC
      if (infos = quest[:npc_beaten])
        quest_data.beat_npc_amount.each_with_index do |amount, index|
          return if infos[index] < amount
        end
      end
      # Check egg got
      if (infos = quest[:egg_counter]) && quest_data.number_of_egg_to_find
        return if infos < quest_data.number_of_egg_to_find
      end
      # Check egg hatched
      if (infos = quest[:egg_hatched]) && quest_data.number_of_egg_to_hatch
        return if infos < quest_data.number_of_egg_to_hatch
      end
      @signal[:finish] << quest_id
    end

    # Is a quest finished ?
    # @param quest_id [Integer] ID of the quest in the database
    # @return [Boolean]
    def finished?(quest_id)
      return !@finished_quests.fetch(quest_id, nil).nil?
    end

    # Is a quest failed ?
    # @param quest_id [Integer] ID of the quest in the database
    # @return [Boolean]
    def failed?(quest_id)
      return !@failed_quests.fetch(quest_id, nil).nil?
    end

    # Get the earnings of a quest
    # @param quest_id [Integer] ID of the quest in the database
    # @return [Boolean] if the earning were givent to the player
    def get_earnings(quest_id)
      return false unless @finished_quests.fetch(quest_id, nil)
      return false unless GameData::Quest.id_valid?(quest_id)
      quest_data = GameData::Quest.get(quest_id)
      quest_data.earnings.each { |earning| give_earning(earning) }
      return @finished_quests.fetch(quest_id, nil)[:earnings] = true
    end

    # Does the earning of a quest has been taken
    # @param quest_id [Integer] ID of the quest in the database
    def earnings_got?(quest_id)
      return false unless @finished_quests.fetch(quest_id, nil)
      return @finished_quests.fetch(quest_id, nil)[:earnings]
    end

    private

    # Give a specific earning
    # @param earning [Hash]
    def give_earning(earning)
      if earning[:money]
        $pokemon_party.add_money(earning[:money])
      elsif earning[:item]
        $bag.add_item(earning[:item], earning[:item_amount])
      end
    end

    # Show the new/finished quest info
    # @param names [Array<String>]
    # @param is_new [Boolean]
    def show_quest_inform(names, is_new)
      return unless $scene.is_a?(Scene_Map)
      # @type [Spriteset_Map]
      helper = $scene.spriteset
      names.each { |name| helper.inform_quest(name, is_new) }
    end
  end

  class Pokemon_Party
    # The player quests informations
    # @return [PFM::Quests]
    attr_accessor :quests
    on_player_initialize(:quests) { @quests = PFM::Quests.new }
    on_expand_global_variables(:quests) {
      # Variable containing all the quests information
      $quests = @quests
    }
  end
end
