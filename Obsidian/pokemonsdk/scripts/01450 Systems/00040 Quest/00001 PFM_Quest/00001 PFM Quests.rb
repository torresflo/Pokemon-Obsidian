module PFM
  # The quest management
  #
  # The main object is stored in $quests and $pokemon_party.quests
  class Quests
    # Tell if the system should check the signal when we test finished?(id) or failed?(id)
    AUTO_CHECK_SIGNAL_ON_TEST = true
    # Tell if the system should check the signal when we check the quest termination
    AUTO_CHECK_SIGNAL_ON_ALL_OBJECTIVE_VALIDATED = false
    # The list of active_quests
    # @return [Hash<Integer => Quest>]
    attr_accessor :active_quests
    # The list of finished_quests
    # @return [Hash<Integer => Quest>]
    attr_accessor :finished_quests
    # The list of failed_quests
    # @return [Hash<Integer => Quest>]
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

    # Start a new quest if possible
    # @param quest_id [Integer] the ID of the quest in the database
    # @return [Boolean] if the quest started
    def start(quest_id)
      return false unless GameData::Quest.id_valid?(quest_id)
      return false if finished?(quest_id)
      return false if @active_quests.fetch(quest_id, nil)

      @active_quests[quest_id] = Quest.new(quest_id)
      @signal[:start] << quest_id
      return true
    end

    # Return an active quest by its id
    # @param quest_id [Integer]
    # @return [Quest]
    def active_quest(quest_id)
      return @active_quests[quest_id]
    end

    # Return a finished quest by its id
    # @param quest_id [Integer]
    # @return [Quest]
    def finished_quest(quest_id)
      return @finished_quests[quest_id]
    end

    # Return a failed quest by its id
    # @param quest_id [Integer]
    # @return [Quest]
    def failed_quest(quest_id)
      return @failed_quests[quest_id]
    end

    # Show a goal of a quest
    # @param quest_id [Integer] the ID of the quest in the database
    # @param goal_index [Integer] the index of the goal in the goal order
    def show_goal(quest_id, goal_index)
      return unless (quest = active_quest(quest_id))

      quest.data_set(:goals_visibility, goal_index, true)
    end

    # Tell if a goal is shown or not
    # @param quest_id [Integer] the ID of the quest in the database
    # @param goal_index [Integer] the index of the goal in the goal order
    # @return [Boolean]
    def goal_shown?(quest_id, goal_index)
      return false unless (quest = active_quest(quest_id))

      return quest.data_get(:goals_visibility, goal_index, false)
    end

    # Get the goal data index (if array like items / speak_to return the index of the goal in the array info from
    # data/quest data)
    # @param quest_id [Integer] the ID of the quest in the database
    # @param goal_index [Integer] the index of the goal in the goal order
    # @return [Integer]
    def get_goal_data_index(quest_id, goal_index)
      raise ScriptError, 'This method should be removed!!!!'
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

    # Inform the manager that a NPC has been beaten
    # @param quest_id [Integer] the ID of the quest in the database
    # @param npc_name_index [Integer] the index of the name of the NPC in the quest data
    # @return [Boolean] if the quest has been updated
    def beat_npc(quest_id, npc_name_index)
      return false unless (quest = active_quest(quest_id))
      return false unless quest.objective?(:objective_beat_npc, npc_name_index)

      old_count = quest.data_get(:npc_beaten, npc_name_index, 0)
      quest.data_set(:npc_beaten, npc_name_index, old_count + 1)
      check_quest(quest_id)
      return true
    end

    # Inform the manager that a NPC has been spoken to
    # @param quest_id [Integer] the ID of the quest in the database
    # @param npc_name_index [Integer] the index of the name of the NPC in the quest data
    # @return [Boolean] if the quest has been updated
    def speak_to_npc(quest_id, npc_name_index)
      return false unless (quest = active_quest(quest_id))
      return false unless quest.objective?(:objective_speak_to, npc_name_index)

      quest.data_set(:spoken, npc_name_index, true)
      check_quest(quest_id)
      return true
    end

    # Inform the manager that an item has been added to the bag of the Player
    # @param item_id [Integer] ID of the item in the database
    def add_item(item_id)
      active_quests.each_value do |quest|
        next unless quest.objective?(:objective_obtain_item, item_id)

        old_count = quest.data_get(:obtained_items, item_id, 0)
        quest.data_set(:obtained_items, item_id, old_count + 1)
        check_quest(quest.quest_id)
      end
    end

    # Inform the manager that a Pokemon has been beaten
    # @param pokemon_id [Integer] ID of the Pokemon in the database
    def beat_pokemon(pokemon_id)
      active_quests.each_value do |quest|
        next unless quest.objective?(:objective_beat_pokemon, pokemon_id)

        old_count = quest.data_get(:pokemon_beaten, pokemon_id, 0)
        quest.data_set(:pokemon_beaten, pokemon_id, old_count + 1)
        check_quest(quest.quest_id)
      end
    end

    # Inform the manager that a Pokemon has been captured
    # @param pokemon [PFM::Pokemon] the Pokemon captured
    def catch_pokemon(pokemon)
      active_quests.each_value do |quest|
        next unless quest.objective?(:objective_catch_pokemon)

        # @type [GameData::Quest]
        quest_data = GameData::Quest[quest.quest_id]
        quest_data.objectives.each do |objective|
          next unless objective.test_method_name != :objective_catch_pokemon

          pokemon_id = objective.test_method_args.first
          next unless quest.objective_catch_pokemon_test(pokemon_id, pokemon)

          old_count = quest.data_get(:pokemon_caught, pokemon_id, 0)
          quest.data_set(:pokemon_caught, pokemon_id, old_count + 1)
          check_quest(quest.quest_id)
        end
      end
    end

    # Inform the manager that a Pokemon has been seen
    # @param pokemon_id [Integer] ID of the Pokemon in the database
    def see_pokemon(pokemon_id)
      active_quests.each_value do |quest|
        next unless quest.objective?(:objective_see_pokemon, pokemon_id)

        quest.data_set(:pokemon_seen, pokemon_id, true)
        check_quest(quest.quest_id)
      end
    end

    # Inform the manager an egg has been found
    def egg_found
      active_quests.each_value do |quest|
        next unless quest.objective?(:objective_obtain_egg)

        old_count = quest.data_get(:obtained_eggs, 0)
        quest.data_set(:obtained_eggs, old_count + 1)
        check_quest(quest.quest_id)
      end
    end
    alias get_egg egg_found

    # Inform the manager an egg has hatched
    def hatch_egg
      active_quests.each_value do |quest|
        next unless quest.objective?(:objective_hatch_egg)

        old_count = quest.data_get(:hatched_eggs, nil, 0)
        quest.data_set(:hatched_eggs, nil, old_count + 1)
        check_quest(quest.quest_id)
      end
    end

    # Check the signals and display them
    def check_up_signal
      return unless $scene.is_a?(Scene_Map)

      if @signal[:start].any?
        start_names = @signal[:start].map { |quest_id| GameData::Quest[quest_id].name }
        show_quest_inform(start_names, true)
      end
      if @signal[:finish].any?
        finish_names = @signal[:finish].collect { |quest_id| GameData::Quest[quest_id].name }
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
      return unless (quest = active_quest(quest_id))
      return if @signal[:finish].include?(quest_id)
      return unless quest.finished?

      @signal[:finish] << quest_id
      check_up_signal if AUTO_CHECK_SIGNAL_ON_ALL_OBJECTIVE_VALIDATED
    end

    # Is a quest finished ?
    # @param quest_id [Integer] ID of the quest in the database
    # @return [Boolean]
    def finished?(quest_id)
      check_up_signal if AUTO_CHECK_SIGNAL_ON_TEST
      return !@finished_quests.fetch(quest_id, nil).nil?
    end

    # Is a quest failed ?
    # @param quest_id [Integer] ID of the quest in the database
    # @return [Boolean]
    def failed?(quest_id)
      check_up_signal if AUTO_CHECK_SIGNAL_ON_TEST
      return !@failed_quests.fetch(quest_id, nil).nil?
    end

    # Get the earnings of a quest
    # @param quest_id [Integer] ID of the quest in the database
    # @return [Boolean] if the earning were givent to the player
    def get_earnings(quest_id)
      return false unless (quest = finished_quest(quest_id))
      return false if quest.data_get(:earnings_distributed, false)

      quest.distribute_earnings
      return true
    end

    # Does the earning of a quest has been taken
    # @param quest_id [Integer] ID of the quest in the database
    def earnings_got?(quest_id)
      check_up_signal if AUTO_CHECK_SIGNAL_ON_TEST
      return false unless (quest = finished_quest(quest_id))

      return quest.data_get(:earnings_distributed, false)
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
    safe_code('Setup Quest in Pokemon_Party') do
      on_player_initialize(:quests) { @quests = PFM::Quests.new }
      on_expand_global_variables(:quests) do
        # Variable containing all the quests information
        $quests = @quests
      end
    end
  end
end
