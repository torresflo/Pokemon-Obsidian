module Battle
  class Move
    # The user of Focus Punch will tighten its focus before any other moves are made. 
    # If any regular move (with a higher priority than -3) 
    # directly hits the focused Pokémon, it loses its focus and flinches, not carrying out the attack. 
    # If no direct hits are made, Focus Punch attacks as normal.
    # @see https://pokemondb.net/move/focus-punch
    # @see https://bulbapedia.bulbagarden.net/wiki/Focus_Punch_(move)
    # @see https://www.pokepedia.fr/Mitra-Poing
    class FocusPunch < Basic
      # Is the move doing something before any other attack ?
      # @return [Boolean]
      def pre_attack?
        true
      end

      # Proceed the procedure before any other attack.
      # @param user [PFM::PokemonBattler]
      def proceed_pre_attack(user)
        @scene.display_message_and_wait(parse_text_with_pokemon(19, 616, user))
        # @todo play charging animation
      end

      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super
        return show_usage_failure(user) && false if disturbed?(user)
        return true
      end

      private

      # Show the usage failure when move is not usable by user
      # @param user [PFM::PokemonBattler] user of the move
      def show_usage_failure(user)
        @scene.display_message_and_wait(parse_text_with_pokemon(19, 366, user))
      end

      # Is the pokemon unable to proceed the attack ?
      # @param user [PFM::PokemonBattler]
      # @return [Boolean]
      def disturbed?(user)
        user.damage_history.any?(&:current_turn?)
      end
    end
    Move.register(:s_focus_punch, FocusPunch)
  end
end
