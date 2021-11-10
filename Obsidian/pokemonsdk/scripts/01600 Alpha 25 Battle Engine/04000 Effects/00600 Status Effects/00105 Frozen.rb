module Battle
  module Effects
    class Status
      class Frozen < Status
        # Prevent freeze from being applied twice
        # @param handler [Battle::Logic::StatusChangeHandler]
        # @param status [Symbol] :poison, :toxic, :confusion, :sleep, :freeze, :paralysis, :burn, :flinch, :cure
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        # @return [:prevent, nil] :prevent if the status cannot be applied
        def on_status_prevention(handler, status, target, launcher, skill)
          # Ignore if status is not freeze or the taget is not the target of this effect
          return if target != self.target
          return if status != :freeze

          # Prevent change by telling the target is already frozen
          return handler.prevent_change do
            handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 297, target))
          end
        end

        # Function called when we try to use a move as the user (returns :prevent if user fails)
        # @param user [PFM::PokemonBattler]
        # @param targets [Array<PFM::PokemonBattler>]
        # @param move [Battle::Move]
        # @return [:prevent, nil] :prevent if the move cannot continue
        def on_move_prevention_user(user, targets, move)
          return if user != target

          # We check if the user is still frozen during this turn
          if froze_check
            # If the move unfreeze we say so and we don't prevent the action
            if move.unfreeze?
              move.scene.display_message_and_wait(parse_text_with_pokemon(19, 303, user))
            else
              # Show that user is frozen and prevent action from happening
              move.scene.visual.show_rmxp_animation(user, 469 + status_id)
              move.scene.display_message_and_wait(parse_text_with_pokemon(19, 288, user))
              return :prevent
            end
          else
            # If the user unfroze this turn we say so
            move.scene.display_message_and_wait(parse_text_with_pokemon(19, 294, user))
          end
          # If we're there then the user unfroze, we ensure it's actually the case
          user.cure
          move.scene.visual.refresh_info_bar(user)
        end

        private

        # Check if the Pokemon is still frozen
        # @return [Boolean]
        def froze_check
          !bchance?(0.2, @logic)
        end
      end

      register(GameData::States::FROZEN, Frozen)
    end
  end
end
