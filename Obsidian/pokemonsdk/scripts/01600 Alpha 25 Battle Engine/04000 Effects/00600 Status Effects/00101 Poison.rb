module Battle
  module Effects
    class Status
      class Poison < Status
        # Prevent poison from being applied twice
        # @param handler [Battle::Logic::StatusChangeHandler]
        # @param status [Symbol] :poison, :toxic, :confusion, :sleep, :freeze, :paralysis, :burn, :flinch, :cure
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        # @return [:prevent, nil] :prevent if the status cannot be applied
        def on_status_prevention(handler, status, target, launcher, skill)
          # Ignore if status is not poison or the taget is not the target of this effect
          return if target != self.target
          return if status != :poison && status != :toxic

          # Prevent change by telling the target is already poisoned
          return handler.prevent_change do
            handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 249, target))
          end
        end

        # Apply poison effect on end of turn
        # @param logic [Battle::Logic] logic of the battle
        # @param scene [Battle::Scene] battle scene
        # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
        def on_end_turn_event(logic, scene, battlers)
          return unless battlers.include?(target)
          return if target.dead?
          return if target.has_ability?(:magic_guard)

          # If target of the effect has poison heal, we attempt to heal
          if target.has_ability?(:poison_heal)
            logic.damage_handler.heal(target, poison_effect)
            return
          end

          # Give damage to the Pokemon
          scene.display_message_and_wait(parse_text_with_pokemon(19, 243, target))
          scene.visual.show_rmxp_animation(target, 469 + status_id)
          logic.damage_handler.damage_change(poison_effect, target)

          # Ensure the procedure does not get blocked by this effect
          nil
        end

        private

        # Return the Poison effect on HP of the Pokemon
        # @return [Integer] number of HP loosen
        def poison_effect
          return (target.max_hp / 8).clamp(1, Float::INFINITY)
        end
      end

      register(GameData::States::POISONED, Poison)
    end
  end
end
