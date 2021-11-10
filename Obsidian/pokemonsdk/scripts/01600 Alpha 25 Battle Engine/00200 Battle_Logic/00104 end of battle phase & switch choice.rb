module Battle
  class Logic
    # Function that distribute the exp to all Pokemon and switch dead pokemon
    def battle_phase_end
      log_debug('Entering battle_phase_end')
      end_turn_handler.process_events
      log_debug('end_turn_handler called')
      # Add all dead enemy to the switch request
      @switch_request.concat(dead_enemy_battler_during_this_turn.map { |battler| { who: battler } })
      log_data("Number of switch request (ennemy) : #{@switch_request.size}")
      @switch_request.concat(dead_friend_battler_during_this_turn.map { |battler| { who: battler } })
      log_data("Number of switch request (friend) : #{@switch_request.size}")
      # Add all dead actors to switch request
      turn = $game_temp.battle_turn
      @switch_request.concat(
        trainer_battlers.select { |battler| battler.last_battle_turn == turn && battler.dead? }.map { |battler| { who: battler } }
      )
      log_data("Number of switch request (enemy + actors) : #{@switch_request.size}")
      @switch_request.uniq! { |h| h[:who] }
      battle_phase_switch_exp_check
      log_debug('battle_phase_switch_exp_check called')
      all_alive_battlers.each { |pokemon| pokemon.switching = false }
    end

    # Function that test the experience distribution
    def battle_phase_exp
      exp_distributions = exp_handler.distribute_exp_grouped(dead_enemy_battler_during_this_turn)
      @scene.visual.show_exp_distribution(exp_distributions) if exp_distributions.any?
    end

    # Function that process the switches and give exp
    def battle_phase_switch_exp_check
      return unless can_battle_continue?

      log_debug('battle_phase_switch_exp_check working')
      battle_phase_exp
      @switch_request.each { |h| battle_phase_switch_execute(**h) }
      @switch_request.clear
    end

    # Function that executes the switch request
    # @param who [PFM::PokemonBattler] Pokemon being switched out
    # @param with [PFM::PokemonBattler, nil] Pokemon replacing who
    def battle_phase_switch_execute(who:, with: nil)
      return Actions::Switch.new(@scene, who, with).execute if who && with

      log_data("Attempting to switch #{who}")
      return unless can_battler_be_replaced?(who)

      with = switch_choose_with(who)
      log_data("Pokemon switched with #{who} : #{with}")
      return unless with

      during_end_of_turn = @actions.empty?
      request_switch_to_trainer(with) if who.bank != 0 && during_end_of_turn
      Actions::Switch.new(@scene, who, with).execute
    end

    # Function that process the battle end when Pokemon was caught
    def battle_phase_end_caught
      pokemon = alive_battlers(1).find { |enemy| @battle_info.caught_pokemon == enemy }
      @scene.visual.show_exp_distribution(exp_handler.distribute_exp_for(pokemon))
    end

    private

    # Function that guess who we should switch the pokemon with
    # @param who [PFM::PokemonBattler]
    # @return [PFM::PokemonBattler, nil]
    def switch_choose_with(who)
      if who.from_party?
        return nil if trainer_battlers.all?(&:dead?)

        return @scene.visual.show_pokemon_choice(true)
      end

      # @type [Battle::AI::Base]
      right_ai = @scene.artificial_intelligences.find { |ai| ai.party_id == who.party_id && ai.bank == who.bank }
      return right_ai&.request_switch(who)
    end

    # Function that ask the player if he wants to switch
    # @param enemy [PFM::PokemonBattler]
    def request_switch_to_trainer(enemy)
      battlers = trainer_battlers
      who = battlers[0]
      if $options.battle_mode && @battle_info.vs_type == 1 && battlers.count(&:alive?) > 1 && can_battler_be_replaced?(who) && !who.dead?
        text = parse_text(
          18, 21,
          '[VAR 010E(0000)]' => @battle_info.trainer_class(enemy),
          '[VAR TRNAME(0001)]' => @battle_info.trainer_name(enemy),
          '[VAR 019E(0000)]' => "#{@battle_info.trainer_class(enemy)} #{@battle_info.trainer_name(enemy)}",
          '[VAR PKNICK(0002)]' => enemy.given_name
        )
        choice = @scene.display_message_and_wait(text, 1, text_get(11, 27), text_get(11, 28))
        if choice == 0 && (result = @scene.visual.show_pokemon_choice)
          Actions::Switch.new(@scene, who, result).execute if result != who
        end
      end
    end
  end
end
