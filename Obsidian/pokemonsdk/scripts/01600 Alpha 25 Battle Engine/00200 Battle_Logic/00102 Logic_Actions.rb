module Battle
  class Logic
    # Constant giving an offset for the move priority : In RH moves start their priority from 0 (-7) and end at 14 (+7)
    MOVE_PRIORITY_OFFSET = -7
    # Priority of pursuit when a switch will occur
    PURSUIT_PRIORITY = 7
    # Priority of MEGA
    MEGA_PRIORITY = 8
    # Priority of other things
    OTHER_PRIORITY = 6
    # List of move first handler by item held
    ITEM_PRIORITY_BOOST_IN_PRIORITY = {
      quick_claw: :check_priority_trigger_quick_claw,
      custap_berry: :check_priority_trigger_custap_berry
    }
    # Value that contains 0.25
    VAL_0_25 = 0.25
    # Add actions to process in the next step
    # @param actions [Array<Hash>] the list of the actions
    def add_actions(actions)
      # Remove the empty action (dead pokemon)
      actions.delete_if(&:empty?)
      # Merge the actions
      @actions.concat(actions)
    end

    # Execute the next action
    # @return [Boolean] if there was an action or not
    def perform_next_action
      return false if @actions.empty?
      action = @actions.pop
      log_debug("Current action : #{action}")
      send("perform_action_#{action[:type]}", action)
      return true
    end

    # Sort the actions
    # @note The last action in the stack is the first action to pop out from the stack
    def sort_actions
      action_by_priority = group_action_by_priority
      action_by_priority.each_value do |actions|
        sort_action_in_priority(actions)
      end
      @actions.clear
      priority_order(action_by_priority).each do |priority|
        @actions.concat(action_by_priority[priority])
      end
    end

    private

    # Group the action by priority
    # @return [Hash{Integer => Hash}]
    def group_action_by_priority
      # Retrieve the pursuit action with priority boost
      switching = @actions.any? { |action| action[:type] == :switch }
      pursuit_actions = retrieve_prioritary_pursuit_actions if switching
      # Group action by priority
      actions = @actions.group_by do |action|
        next(action[:skill].priority + MOVE_PRIORITY_OFFSET) if action[:type] == :attack
        next(MEGA_PRIORITY) if action[:type] == :mega
        next(OTHER_PRIORITY)
      end
      # Add pursuit with priority boost to the hash (if any)
      (actions[PURSUIT_PRIORITY] ||= []).concat(pursuit_actions) if pursuit_actions
      return actions
    end

    # Get the pursuit actions that got priority boost
    # @return [Array<Hash>]
    def retrieve_prioritary_pursuit_actions
      pursuit_selector = proc { |action| action[:type] == :attack && action[:skill].db_symbol == :pursuit }
      pursuit_actions = @actions.select(&pursuit_selector)
      @actions.reject!(&pursuit_selector)
      non_prio_pursuit = pursuit_actions.select! do |action|
        !battler(action[:target_bank], action[:target_position]).switching?
      end
      @actions.concat(non_prio_pursuit || [])
      return pursuit_actions
    end

    # Sort the action by user speed in a priority array
    # @param actions [Array<Hash>]
    def sort_action_in_priority(actions)
      actions.sort! do |a, b|
        # @type [PFM::PokemonBattler]
        pokemon_a = a[:launcher] || a[:target] || a[:who]
        # @type [PFM::PokemonBattler]
        pokemon_b = b[:launcher] || b[:target] || b[:who]
        next(pokemon_a.spd <=> pokemon_b.spd)
      end
      actions.reverse! if global_trick_room?
      check_priority_item_trigger(actions)
    end

    # Check for item held that gives more priority and put the pokemon on top
    # @param actions [Array<Hash>]
    def check_priority_item_trigger(actions)
      attacks = actions.select { |action| action[:type] == :attack }
      return if attacks.size <= 1
      triggered_action = attacks.find do |action|
        message = ITEM_PRIORITY_BOOST_IN_PRIORITY[action[:launcher].item_db_symbol]
        log_debug("#{action[:launcher].item_db_symbol} held by #{action[:launcher]}") if message
        result = (message ? send(message, action[:launcher]) : false)
        log_debug("#{message} returned #{result}") if message
        next(result)
      end
      return unless triggered_action
      # Add the triggered action at first in the priority stack with the right message
      if attacks.index(triggered_action) != attacks.size - 1 # <= Prevent dumb activation
        actions.delete(triggered_action)
        item_triger_action = { type: :high_priority_item, who: triggered_action[:launcher] }
        actions.push(triggered_action, item_triger_action)
      end
    end

    # Test the quick claw trigger
    # @param pokemon [PFM::PokemonBattler]
    # @return [Boolean] if the item triggered
    def check_priority_trigger_quick_claw(pokemon)
      return rand(100) < 20
    end

    # Test the custap berry trigger
    # @param pokemon [PFM::PokemonBattler]
    # @return [Boolean] if the item triggered
    def check_priority_trigger_custap_berry(pokemon)
      return pokemon.hp_rate < VAL_0_25
    end

    # Retrieve the priority order according to the group of action by priority
    # @param action_by_priority [Hash]
    # @return [Array<Integer>]
    def priority_order(action_by_priority)
      action_by_priority.keys.sort
    end
  end
end
