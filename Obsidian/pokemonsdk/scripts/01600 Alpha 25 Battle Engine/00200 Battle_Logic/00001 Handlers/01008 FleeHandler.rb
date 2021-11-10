module Battle
  class Logic
    # Handler responsive of processing flee attempt
    class FleeHandler < ChangeHandlerBase
      include Hooks

      # Try to flee
      # @param index [Integer] index of the Pokemon on the trainer bank
      # @note flee_block hooks are called to test if the flee is blocked for other reason than switch blocked
      # @return [Symbol] if success :success, if failure :failure, if blocked (trainer battle) :blocked
      def attempt(index)
        log_data("# flee#attempt(#{index})")
        exec_hooks(FleeHandler, :flee_block, binding)
        exec_hooks(FleeHandler, :flee_passthrough, binding)
        switch_handler = @logic.switch_handler
        unless switch_handler.can_switch?(@logic.battler(0, index), reason: :flee)
          switch_handler.process_prevention_reason
          return :failure
        end
        value = flee_value(index)
        @logic.battle_info.flee_attempt_count += 1
        result = @logic.generic_rng.rand(256) < value ? :success : :failure
        @scene.display_message_and_wait(parse_text(18, result == :success ? 75 : 76))
        return result
      rescue Hooks::ForceReturn => e
        log_data("# FR: flee#attempt #{e.data} from #{e.hook_name} (#{e.reason})")
        process_prevention_reason
        return e.data
      end

      private

      # Get the value used to test if the flee is successfull
      # @param index [Integer] index of the Pokemon on the trainer bank
      # @note formula ajusted according to: https://docs.google.com/document/d/1Jv-hDNpeEU-cLTiy1c1b3YSRgSEDt2ffbgk5vkPhkKE
      # @return [Integer]
      def flee_value(index)
        trainer_poke = @logic.battler(0, index)
        enemy_poke = @logic.battler(1, index) || @logic.battler(1, 0)

        a = trainer_poke&.spd_basis || 1
        b = (enemy_poke&.spd_basis || 4).clamp(4, Float::INFINITY) # clamped with 4 to prevent zero division
        c = @logic.battle_info.flee_attempt_count
        log_debug("flee_value: a = #{a}, b = #{b}, c = #{c}")
        return 256 if a > b # Faster mon always flee

        return ((a * 32 / (b / 4)) + 30 * c)
      end

      class << self
        # Function that registers a flee_block hook
        # @param reason [String] reason of the flee_block registration
        # @yieldparam handler [FleeHandler]
        # @yieldreturn [:prevent, nil] :prevent if the stat increase cannot apply
        def register_flee_block_hook(reason)
          Hooks.register(FleeHandler, :flee_block, reason) do
            result = yield(
              self
            )
            force_return(:blocked) if result == :prevent
          end
        end

        # Function that registers a flee_passthrough hook
        # @param reason [String] reason of the flee_passthrough registration
        # @yieldparam handler [FleeHandler]
        # @yieldparam pokemon [PFM::PokemonBattler] pokemon attempting to flee
        # @yieldreturn [:prevent, nil] :prevent if the stat increase cannot apply
        def register_flee_passthrough_hook(reason)
          Hooks.register(FleeHandler, :flee_passthrough, reason) do |hook_binding|
            result = yield(
              self,
              logic.battler(0, hook_binding.local_variable_get(:index))
            )
            force_return(:success) if result == :success
          end
        end
      end

      FleeHandler.register_flee_passthrough_hook('PSDK smoke ball') do |handler, pokemon|
        next if pokemon.item_db_symbol != :smoke_ball

        # Play smokeball animation over pokemon
        message = parse_text_with_pokemon(19, 1010, pokemon, PFM::Text::ITEM2[1] => pokemon.item_name)
        handler.scene.display_message_and_wait(message)
        next :success
      end

      # Run Away ability
      FleeHandler.register_flee_passthrough_hook('PSDK run away') do |handler, pokemon|
        next unless pokemon.has_ability?(:run_away)

        handler.scene.visual.show_ability(pokemon)
        message = parse_text_with_pokemon(19, 767, pokemon)
        handler.scene.display_message_and_wait(message)
        next :success
      end

      FleeHandler.register_flee_block_hook('No flee in trainer battle') do |handler|
        next unless handler.logic.battle_info.trainer_battle?

        next handler.prevent_change do
          handler.scene.display_message_and_wait(parse_text(18, 79))
        end
      end

      FleeHandler.register_flee_block_hook('No flee when BT_NoEscape is on') do |handler|
        next unless $game_switches[Yuki::Sw::BT_NoEscape]

        handler.prevent_change do
          handler.scene.display_message_and_wait(parse_text(18, 77))
        end
      end
    end
  end
end
