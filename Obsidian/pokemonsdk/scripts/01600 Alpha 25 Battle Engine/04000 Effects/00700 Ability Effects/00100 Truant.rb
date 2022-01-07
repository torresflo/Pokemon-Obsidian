module Battle
  module Effects
    class Ability
      class Truant < Ability
        # Function called when we try to use a move as the user (returns :prevent if user fails)
        # @param user [PFM::PokemonBattler]
        # @param targets [Array<PFM::PokemonBattler>]
        # @param move [Battle::Move]
        # @return [:prevent, nil] :prevent if the move cannot continue
        def on_move_prevention_user(user, targets, move)
          return if user != @target

          if user.ability_used
            move.scene.display_message_and_wait(parse_text_with_pokemon(19, 445, user))
            user.ability_used = false
            return :prevent
          end
          user.ability_used = true
        end

        # Function called when a Pokemon has actually switched with another one
        # @param handler [Battle::Logic::SwitchHandler]
        # @param who [PFM::PokemonBattler] Pokemon that is switched out
        # @param with [PFM::PokemonBattler] Pokemon that is switched in
        def on_switch_event(handler, who, with)
          return unless who == @target

          @target.ability_used = false
        end
      end
      register(:truant, Truant)
    end
  end
end
