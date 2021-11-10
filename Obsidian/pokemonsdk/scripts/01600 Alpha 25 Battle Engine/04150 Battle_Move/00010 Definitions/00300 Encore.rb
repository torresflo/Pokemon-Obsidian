module Battle
  class Move
    # Move that forces the target to use the move previously used during 3 turns
    class Encore < BasicWithSuccessfulEffect
      # List of move the target cannot use with encore
      NO_ENCORE_MOVES = %i[encore mimic mirror_move sketch struggle transform]

      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super

        target = targets.first
        last_move = target.move_history.last
        has_forced_effect = target.effects.has? { |e| e.force_next_move? && !e.dead? }
        if !last_move || has_forced_effect || move_disallowed?(last_move.db_symbol) || last_move.original_move.pp <= 0
          show_usage_failure(user)
          return false
        end

        return true
      end

      private

      # Test if the move that should be forced is disallowed to be forced or not
      # @param db_symbol [Symbol]
      # @return [Boolean]
      def move_disallowed?(db_symbol)
        return NO_ENCORE_MOVES.include?(db_symbol)
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        # Add effect
        target = actual_targets.first
        move_history = target.move_history.last
        target.effects.add(effect = create_effect(move_history.original_move, target, move_history.targets))
        # Poison actions
        if (index = logic.actions.find_index { |action| action.is_a?(Actions::Attack) && action.launcher == target })
          logic.actions[index] = effect.make_action
        end
      end

      # Create the effect
      # @param move [Battle::Move] move that was used by target
      # @param target [PFM::PokemonBattler] target that used the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      # @return [Effects::Encore]
      def create_effect(move, target, actual_targets)
        Effects::Encore.new(logic, target, move, actual_targets)
      end
    end

    Move.register(:s_encore, Encore)
  end
end
