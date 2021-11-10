module Battle
  class Move
    class PsychoShift < Move
      private

      # Test if the target is immune
      # @param user [PFM::PokemonBattler]
      # @param target [PFM::PokemonBattler]
      # @return [Boolean]
      def target_immune?(user, target)
        return true if logic.status_change_handler.status_appliable?(right_status_symbol(user), target, user, self)

        return super
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each { |target| logic.status_change_handler.status_change(right_status_symbol(user), target, user, self) }
        logic.status_change_handler.status_change(:cure, user, user, self)
      end

      # Get the right symbol for a status of a Pokemon
      # @param pokemon [PFM::PokemonBattler]
      # @return [Symbol]
      def right_status_symbol(pokemon)
        Logic::StatusChangeHandler::STATUS_ID_TO_SYMBOL[pokemon.status]
      end
    end
    Move.register(:s_psycho_shift, PsychoShift)
  end
end
