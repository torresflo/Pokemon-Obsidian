module Battle
  class Scene
    private

    # Method that ask for the player choice (it calls @visual.show_player_choice)
    def player_action_choice
      # If the method was called and the player cannot make another choice it's a bug so we end the battle
      return @next_update = :battle_end unless can_player_make_another_action_choice?
      choice = @visual.show_player_choice(@player_actions.size)
      log_debug("Player action choice : #{choice}")
      case choice
      when :attack
        # The player choose to attack, at next update will be skill_choice
        @next_update = :skill_choice
      when :bag
        # The player choose to open the bag, next update will be item_choice
        @next_update = :item_choice
      when :pokemon
        # The player choose to open the party, next update will be switch_choice
        @next_update = :switch_choice
      when :flee
        # The player wants to flee from the battle
        flee_attempt
      when :cancel
        # The player canceled, he wants to try an other strategy, we remove the last actions
        while (action = @player_actions.pop)
          clean_action(action)
          # If the action is not empty it was a Pokemon we could control so we stop poping
          break unless action.empty?
        end
      when :try_next
        # The visual interface detected that the current Pokemon is dead
        @player_actions << {}
      else
        # The visual interface detected an anomaly, we go to the end of the battle
        @next_update = :battle_end
      end
    ensure
      @skip_frame = true
    end

    # Method that asks for the skill the current Pokemon should use
    def skill_choice
      if @visual.show_skill_choice(@player_actions.size)
        # The player choosed a move
        @next_update = :target_choice
      else
        # The player canceled
        @next_update = :player_action_choice
      end
    ensure
      @skip_frame = true
    end

    # Method that asks the target of the choosen move
    def target_choice
      launcher, skill, target_bank, target_position = @visual.show_target_choice
      if launcher
        # The player made a choice we store the action and check if he can make other choices
        @player_actions << { type: :attack, launcher: launcher, skill: skill, target_bank: target_bank, target_position: target_position }
        log_debug("Action : #{@player_actions.last}") if debug? # To prevent useless overhead outside debug
        @next_update = can_player_make_another_action_choice? ? :player_action_choice : :trigger_all_AI
      else
        # If the player canceled we return to the player action
        @next_update = :player_action_choice
      end
    ensure
      @skip_frame = true
    end

    # Check if the player can make another action choice
    # @note push empty hash where Pokemon cannot be controlled
    # @return [Boolean]
    def can_player_make_another_action_choice?
      @player_actions.size.upto(@logic.battle_info.vs_type - 1) do |position|
        next_pokemon = @logic.battler(0, position)
        # If there's no Pokemon at this position, then it's probably the end of the team
        break unless next_pokemon
        # If it's not our Pokemon we don't control it
        next(@player_actions << {}) if next_pokemon.party_id != 0
        # If the Pokemon is dead, we also don't control it
        next(@player_actions << {}) if next_pokemon.dead?
        # This Pokemon can be controlled
        return true
      end
      return false
    end

    # Method that asks the item to use
    def item_choice
      item_id, target = @visual.show_item_choice
      if item_id
        # The player made a choice we store the action and we check if he can make other choices
        @player_actions << { type: :item, item_id: item_id, target: target, bag: @logic.bags[0] }
        log_debug("Action : #{@player_actions.last}") if debug? # To prevent useless overhead outside debug
        @next_update = can_player_make_another_action_choice? ? :player_action_choice : :trigger_all_AI
      else
        # If the player canceled we return to the player action
        @next_update = :player_action_choice
      end
    end

    # Method that asks the pokemon to switch with
    def switch_choice
      pokemon_to_send = @visual.show_pokemon_choice
      if pokemon_to_send
        pokemon_to_switch = @logic.battler(0, @player_actions.size)
        # The player made a choice we store the action and we check if he can make other choices
        @player_actions << { type: :switch, who: pokemon_to_switch, with: pokemon_to_send }
        pokemon_to_send.switching = true
        pokemon_to_switch.switching = true
        log_debug("Action : #{@player_actions.last}") if debug? # To prevent useless overhead outside debug
        @next_update = can_player_make_another_action_choice? ? :player_action_choice : :trigger_all_AI
      else
        # If the player canceled we return to the player action
        @next_update = :player_action_choice
      end
    end

    # Clean the action that was removed from the stack (Make sure we don't lock things)
    def clean_action(action)
      return unless action
      case action[:type]
      when :switch
        action[:who].switching = false
        action[:with].switching = false
      end
    end

    # Method that checks if the flee is possible
    def flee_attempt
      result = @logic.flee_attempt_from_player
      if result == :success
        @battle_result = :flee
        @next_update = :battle_end
      else
        display_message(result)
        @next_update = :trigger_all_AI
      end
    end
  end
end
