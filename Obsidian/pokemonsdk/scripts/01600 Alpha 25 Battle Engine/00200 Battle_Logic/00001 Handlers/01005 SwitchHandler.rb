module Battle
  class Logic
    # Handler responsive of processing switch events that happens during switch
    class SwitchHandler < ChangeHandlerBase
      include Hooks

      # Test if the switch is possible
      # @param pokemon [PFM::PokemonBattler] pokemon to switch
      # @param skill [Battle::Move, nil] potential move
      # @param reason [Symbol] the reason why the SwitchHandler is called (:switch or :flee)
      # @return [Boolean] if it can switch or not
      def can_switch?(pokemon, skill = nil, reason: :switch)
        log_data("# can_switch?(#{pokemon}, #{skill})")
        return false if pokemon.hp <= 0

        reset_prevention_reason
        exec_hooks(SwitchHandler, :switch_passthrough, binding)
        exec_hooks(SwitchHandler, :switch_prevention, binding)
        return true
      rescue Hooks::ForceReturn => e
        log_data("# FR: can_switch? #{e.data} from #{e.hook_name} (#{e.reason})")
        return e.data
      end

      # Execute the events before the pokemon switch out
      # @param who [PFM::PokemonBattler] Pokemon who is switched out
      # @param with [PFM::PokemonBattler, nil] Pokemon who is switched in
      # @note In the event we're starting the battle who & with should be identic, this help to process effect like Intimidate
      def execute_pre_switch_events(who, with)
        exec_hooks(SwitchHandler, :pre_switch_event, binding)
      end

      # Perform the switch between two Pokemon
      # @param who [PFM::PokemonBattler] Pokemon who is switched out
      # @param with [PFM::PokemonBattler, nil] Pokemon who is switched in
      # @note In the event we're starting the battle who & with should be identic, this help to process effect like Intimidate
      def execute_switch_events(who, with)
        if with != who
          with.turn_count = 0
        end
        exec_hooks(SwitchHandler, :switch_event, binding)
      end

      class << self
        # Register a switch passthrough. If the block returns :passthrough, it will say that Pokemon can switch in can_switch?
        # @param reason [String] reason of the switch_passthrough hook
        # @yieldparam handler [SwitchHandler]
        # @yieldparam pokemon [PFM::PokemonBattler]
        # @yieldparam skill [Battle::Move, nil] potential skill used to switch
        # @yieldparam reason [Symbol] the reason why the SwitchHandler is called
        # @yieldreturn [:passthrough, nil] if :passthrough, can_switch? will return true without checking switch_prevention
        def register_switch_passthrough_hook(reason)
          Hooks.register(SwitchHandler, :switch_passthrough, reason) do |hook_binding|
            result = yield(
              self,
              hook_binding.local_variable_get(:pokemon),
              hook_binding.local_variable_get(:skill),
              hook_binding.local_variable_get(:reason)
            )
            force_return(true) if result == :passthrough
          end
        end

        # Register a switch prevention hook. If the block returns :prevent, it will say that Pokemon cannot switch in can_switch?
        # @param reason [String] reason of the switch_prevention hook
        # @yieldparam handler [SwitchHandler]
        # @yieldparam pokemon [PFM::PokemonBattler]
        # @yieldparam skill [Battle::Move, nil] potential skill used to switch
        # @yieldparam reason [Symbol] the reason why the SwitchHandler is called
        # @yieldreturn [:prevent, nil] if :prevent, can_switch? will return false
        def register_switch_prevention_hook(reason)
          Hooks.register(SwitchHandler, :switch_prevention, reason) do |hook_binding|
            result = yield(
              self,
              hook_binding.local_variable_get(:pokemon),
              hook_binding.local_variable_get(:skill),
              hook_binding.local_variable_get(:reason)
            )
            force_return(false) if result == :prevent
          end
        end

        # Register a pre switch event
        # @param reason [String] reason of the pre_switch_event hook
        # @yieldparam handler [SwitchHandler]
        # @yieldparam who [PFM::PokemonBattler] Pokemon that is switched out
        # @yieldparam with [PFM::PokemonBattler] Pokemon that is switched in
        def register_pre_switch_event_hook(reason)
          Hooks.register(SwitchHandler, :pre_switch_event, reason) do |hook_binding|
            yield(
              self,
              hook_binding.local_variable_get(:who),
              hook_binding.local_variable_get(:with)
            )
          end
        end

        # Register a switch event
        # @param reason [String] reason of the switch_event hook
        # @yieldparam handler [SwitchHandler]
        # @yieldparam who [PFM::PokemonBattler] Pokemon that is switched out
        # @yieldparam with [PFM::PokemonBattler] Pokemon that is switched in
        def register_switch_event_hook(reason)
          Hooks.register(SwitchHandler, :switch_event, reason) do |hook_binding|
            yield(
              self,
              hook_binding.local_variable_get(:who),
              hook_binding.local_variable_get(:with)
            )
          end
        end
      end
    end

    # Last sent turn
    SwitchHandler.register_switch_event_hook('Update last_sent_turn value') do |_, _, with|
      with.last_sent_turn = $game_temp.battle_turn
    end

    # Effects
    SwitchHandler.register_switch_passthrough_hook('PSDK switch pass: Effects') do |handler, pokemon, skill, reason|
      next handler.logic.each_effects(pokemon) do |e|
        next e.on_switch_passthrough(handler, pokemon, skill, reason)
      end
    end
    SwitchHandler.register_switch_prevention_hook('PSDK switch prev: Effects') do |handler, pokemon, skill, reason|
      # <= Here we need to scan all alive battlers to ensure the effects like Shadow Tag works
      next handler.logic.each_effects(*handler.logic.all_alive_battlers) do |e|
        next e.on_switch_prevention(handler, pokemon, skill, reason)
      end
    end
    SwitchHandler.register_switch_event_hook('PSDK switch: Effects') do |handler, who, with|
      next handler.logic.each_effects(*[who, with].uniq) do |e|
        next e.on_switch_event(handler, who, with)
      end
    end

    # U-Turn moves
    SwitchHandler.register_switch_passthrough_hook('PSDK switch pass: U-Turn moves') do |_, _, skill|
      next :passthrough if skill&.self_user_switch?
    end

    # Encounter list
    SwitchHandler.register_switch_event_hook('Update encounter list') do |handler, _, with|
      handler.logic.all_battlers do |battler|
        next if battler.position == -1 || battler.dead? || battler == with
        battler.add_battler_to_encounter_list(with)
        with.add_battler_to_encounter_list(battler)
      end
    end

    # Meloetta form
    SwitchHandler.register_switch_event_hook('Meloetta form') do |_, who, _|
      who.form_calibrate(:none) if who.db_symbol == :meloetta
    end
  end
end
