module Battle
  module Effects
    class Status
      class Paralysis < Status
        # Prevent paralysis from being applied twice
        # @param handler [Battle::Logic::StatusChangeHandler]
        # @param status [Symbol] :poison, :toxic, :confusion, :sleep, :freeze, :paralysis, :burn, :flinch, :cure
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        # @return [:prevent, nil] :prevent if the status cannot be applied
        def on_status_prevention(handler, status, target, launcher, skill)
          # Ignore if status is not paralysis or the taget is not the target of this effect
          return if target != self.target
          return if status != :paralysis

          # Prevent change by telling the target is already paralysed
          return handler.prevent_change do
            handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 282, target))
          end
        end

        # Function called when we try to use a move as the user (returns :prevent if user fails)
        # @param user [PFM::PokemonBattler]
        # @param targets [Array<PFM::PokemonBattler>]
        # @param move [Battle::Move]
        # @return [:prevent, nil] :prevent if the move cannot continue
        def on_move_prevention_user(user, targets, move)
          return if user != target

          if user.paralyzed? && paralysis_check
            move.scene.visual.show_rmxp_animation(user, 469 + status_id)
            move.scene.display_message_and_wait(parse_text_with_pokemon(19, 276, user))
            return :prevent
          end
        end

        # Give the speed modifier over given to the Pokemon with this effect
        # @return [Float, Integer] multiplier
        def spd_modifier
          return 0.25
        end

        private

        # Check if the pokemon cannot move due to paralysis
        # @return [Boolean]
        def paralysis_check
          bchance?(0.25, @logic)
        end
      end

      register(GameData::States::PARALYZED, Paralysis)
    end
  end
end
