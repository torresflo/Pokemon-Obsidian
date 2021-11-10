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
    # @param actions [Array<Actions::Base>] the list of the actions
    def add_actions(actions)
      # Select the usefull action & merge them
      @actions.concat(actions.select(&:valid?))
    end

    # Execute the next action
    # @return [Boolean] if there was an action or not
    def perform_next_action
      return false if @actions.empty? || !can_battle_continue?

      # @type [Actions::Base]
      action = @actions.pop
      log_debug("Current action : #{action}")
      @scene.message_window.blocking = false
      PFM::Text.reset_variables # Prevent wrong pokemon name from being shown
      action.execute
      battle_phase_switch_exp_check
      return true
    end

    # Sort the actions
    # @note The last action in the stack is the first action to pop out from the stack
    def sort_actions
      refine_actions
      sorted_actions = sort_action_and_add_effects
      @actions.clear
      @actions.concat(sorted_actions.reverse)
      define_pokemon_action_properties
    end

    # Sort the actions
    # @param block [Block] block used to sort the actions take |Actions::Base, Actions::Base| as arguments
    def force_sort_actions(&block)
      @actions.sort!(&block)
    end

    private

    # Process specific behaviours
    def refine_actions
      handle_pre_attack_action
      handle_dancer
    end

    # Define all pokemon action properties based on the actions
    def define_pokemon_action_properties
      # Set all alive battler as attacking last
      all_alive_battlers.each { |battler| battler.attack_order = Float::INFINITY }
      # Getting index of last attack action
      index = @actions.count { |action| action.is_a?(Actions::Attack) } - 1
      @actions.each do |action|
        next unless action.is_a?(Actions::Attack)

        Actions::Attack.from(action).launcher.attack_order = index
        index -= 1
      end
    end

    # Group the action by priority
    # @return [Array<Actions::Base>]
    def sort_action_and_add_effects
      highest_priority = @actions.reject { |action| action.is_a?(Actions::Attack) }
      switching = process_and_list_switching_actions(highest_priority)
      # @type [Array<Actions::Attack>]
      move_action = @actions.select { |action| action.is_a?(Actions::Attack) }
      # Setting pursuit priority
      if switching.any?
        move_action.each do |action|
          next unless action.move.db_symbol == :pursuit

          target = action.target
          action.pursuit_enabled = switching.any? { |switch| switch.who == target }
        end
      end
      # Setting the high priority items
      move_by_priority = move_action.group_by(&:priority)
      move_by_priority.each { |_, attacks| check_priority_item_trigger(attacks) }
      # Sort actions
      actions = highest_priority.concat(move_by_priority.values.flatten)
      return actions.sort
    end

    # List & add effect of switching actions
    # @param highest_priority [Array<Actions::Base>] list of actions that are not attack
    # @return [Array<Actions::Switch>] list of switch action
    def process_and_list_switching_actions(highest_priority)
      # @type [Array<Actions::Switch>]
      switching_actions = highest_priority.select { |action| action.is_a?(Actions::Switch) && action.who }
      # Tell that the Pokemon are switching (for moves)
      switching_actions.each do |action|
        action.who.switching = true
        action.with.switching = true
      end
      return switching_actions
    end

    # Check for item held that gives more priority and put the pokemon on top
    # @param actions [Array<Actions::Attack>]
    def check_priority_item_trigger(actions)
      return if actions.size <= 1

      # @type [Actions::Attack]
      triggered_action = actions[1..-1].find do |action|
        message = ITEM_PRIORITY_BOOST_IN_PRIORITY[action.launcher.battle_item_db_symbol]
        log_debug("#{action.launcher.battle_item_db_symbol} held by #{action.launcher}") if message
        result = (message ? send(message, action.launcher) : false)
        log_debug("#{message} returned #{result}") if message
        next(result)
      end
      return unless triggered_action

      # Make sure the action will get highest speed inside the priority
      triggered_action.ignore_speed = true
      # Add the message of the item activation
      actions << Actions::HighPriorityItem.new(@scene, triggered_action.launcher)
    end

    # Function that handle the dancer ability
    def handle_dancer
      # @type [Array<Actions::Attack>]
      dancing_moves = @actions.select { |action| action.is_a?(Actions::Attack) && action.move.dance? }
      # @type [Array<PFM::PokemonBattler>]
      dancers = all_alive_battlers.select { |battler| battler.has_ability?(:dancer) }
      # Add all dancer as sub launcher
      dancing_moves.each do |move|
        move.sub_launchers.concat(dancers.reject { |dancer| dancer == move.launcher })
      end
    end

    # Handle the attakcs with pre attack effects
    def handle_pre_attack_action
      attack_actions = @actions.select { |action| action.is_a?(Actions::Attack) && action.move.pre_attack? }.sort
      return if attack_actions.empty?

      add_actions([Actions::PreAttack.new(@scene, attack_actions)])
    end

    # Test the quick claw trigger
    # @param pokemon [PFM::PokemonBattler]
    # @return [Boolean] if the item triggered
    def check_priority_trigger_quick_claw(pokemon)
      return bchance?(0.2, self)
    end

    # Test the custap berry trigger
    # @param pokemon [PFM::PokemonBattler]
    # @return [Boolean] if the item triggered
    def check_priority_trigger_custap_berry(pokemon)
      return pokemon.has_ability?(:gluttony) ? pokemon.hp_rate < 0.5 : pokemon.hp_rate < 0.25
    end
  end
end
