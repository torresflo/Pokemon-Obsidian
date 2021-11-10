module Battle
  module Effects
    class Ability
      # Stance Change allows Aegislash to switch between its Shield Forme and Blade Forme.
      # @see https://pokemondb.net/ability/stance-change
      # @see https://bulbapedia.bulbagarden.net/wiki/Stance_Change_(Ability)
      # @see https://www.pokepedia.fr/Déclic_Tactique
      class StanceChange < Ability        
        # Function called when we try to use a move as the user (returns :prevent if user fails)
        # @param user [PFM::PokemonBattler]
        # @param targets [Array<PFM::PokemonBattler>]
        # @param move [Battle::Move]
        # @return [:prevent, nil] :prevent if the move cannot continue
        def on_move_prevention_user(user, targets, move)
          return if user != @target

          blade if move.real_base_power(user, targets.first) > 0
          shield if move.db_symbol == :king_s_shield
        end

        private

        # Apply Blade Forme        
        def blade
          original_form = @target.form
          @target.form_calibrate(:blade)
          apply_change_form(252) unless @target.form == original_form
        end

        # Apply Shield Forme        
        def shield
          original_form = @target.form
          @target.form_calibrate
          apply_change_form(253) unless @target.form == original_form
        end

        # Apply change form        
        # @param text_id [Integer] id of the message text
        def apply_change_form(text_id)
          @logic.scene.visual.show_ability(@target)
          @logic.scene.visual.show_switch_form_animation(@target)
          @logic.scene.visual.wait_for_animation
          @logic.scene.display_message_and_wait(parse_text(18, text_id))
        end
      end
      register(:stance_change, StanceChange)
    end
  end
end
