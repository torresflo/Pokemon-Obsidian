module Battle
  module Effects
    class Status
      class Toxic < Status
        # Create a new toxic effect
        # @param logic [Battle::Logic]
        # @param target [PFM::PokemonBattler]
        # @param status_id [Integer] ID of the status
        def initialize(logic, target, status_id)
          super
          @toxic_counter = 1
        end

        # Reset the toxic counter
        def reset
          @toxic_counter = 1
        end

        # Prevent toxic from being applied twice
        # @param handler [Battle::Logic::StatusChangeHandler]
        # @param status [Symbol] :poison, :toxic, :confusion, :sleep, :freeze, :paralysis, :burn, :flinch, :cure
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        # @return [:prevent, nil] :prevent if the status cannot be applied
        def on_status_prevention(handler, status, target, launcher, skill)
          # Ignore if status is not toxic or the taget is not the target of this effect
          return if target != self.target
          return if status != :poison && status != :toxic

          # Prevent change by telling the target is already poisoned
          return handler.prevent_change do
            handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 249, target))
          end
        end

        # Apply toxic effect on end of turn
        # @param logic [Battle::Logic] logic of the battle
        # @param scene [Battle::Scene] battle scene
        # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
        def on_end_turn_event(logic, scene, battlers)
          return unless battlers.include?(target)
          return if target.dead?
          return if target.has_ability?(:magic_guard)

          # Show the effect and apply it
          scene.display_message_and_wait(parse_text_with_pokemon(19, 243, target))
          scene.visual.show_rmxp_animation(target, 469 + status_id)
          logic.damage_handler.damage_change(toxic_effect, target)

          # Increase the toxic counter
          @toxic_counter += 1

          # Ensure the procedure does not get blocked by this effect
          nil
        end

        private

        # Return the Poison effect on HP of the Pokemon
        # @return [Integer] number of HP loosen
        def toxic_effect
          return (target.max_hp * @toxic_counter / 16).clamp(1, Float::INFINITY)
        end
      end

      register(GameData::States::TOXIC, Toxic)
    end
  end
end

Hooks.register(PFM::PokemonBattler, :on_reset_states, 'PSDK reset toxic') do
  status_effect.reset if status_effect.is_a?(Battle::Effects::Status::Toxic)
end
