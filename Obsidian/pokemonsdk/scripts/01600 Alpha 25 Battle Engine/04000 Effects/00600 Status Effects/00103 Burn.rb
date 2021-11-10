module Battle
  module Effects
    class Status
      class Burn < Status
        # Give the move mod1 mutiplier (before the +2 in the formula)
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def mod1_multiplier(user, target, move)
          return 1 if user != self.target
          return 1 unless move.physical?
          return 1 if user.has_ability?(:guts)

          return 0.5
        end

        # Prevent burn from being applied twice
        # @param handler [Battle::Logic::StatusChangeHandler]
        # @param status [Symbol] :poison, :toxic, :confusion, :sleep, :freeze, :paralysis, :burn, :flinch, :cure
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        # @return [:prevent, nil] :prevent if the status cannot be applied
        def on_status_prevention(handler, status, target, launcher, skill)
          # Ignore if status is not burn or the taget is not the target of this effect
          return if target != self.target
          return if status != :burn

          # Prevent change by telling the target is already paralysed
          return handler.prevent_change do
            handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 267, target))
          end
        end

        # Apply burn effect on end of turn
        # @param logic [Battle::Logic] logic of the battle
        # @param scene [Battle::Scene] battle scene
        # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
        def on_end_turn_event(logic, scene, battlers)
          return unless battlers.include?(target)
          return if target.dead?
          return if target.has_ability?(:magic_guard)

          hp = burn_effect
          # Apply heat proof protection
          hp /= 2 if target.has_ability?(:heatproof)
          scene.display_message_and_wait(parse_text_with_pokemon(19, 261, target))
          scene.visual.show_rmxp_animation(target, 469 + status_id)
          logic.damage_handler.damage_change(hp.clamp(1, Float::INFINITY), target)

          # Ensure the procedure does not get blocked by this effect
          nil
        end

        private

        # Return the Burn effect on HP of the Pokemon
        # @return [Integer] number of HP loosen
        def burn_effect
          return (target.max_hp / 8).clamp(1, Float::INFINITY)
        end
      end

      register(GameData::States::BURN, Burn)
    end
  end
end
