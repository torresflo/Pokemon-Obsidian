module Battle
  class Move
    class SuckerPunch < Basic
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super

        if targets.all? { |target| !logic.battler_attacks_after?(user, target) && target_move_is_status_move?(target) }
          return show_usage_failure(user) && false
        end

        return true
      end

      # Function that tells if the target is using a Move & if it's a status move
      # @return [Boolean]
      def target_move_is_status_move?(target)
        # @type [Array<Actions::Attack>]
        attacks = logic.actions.select { |action| action.is_a?(Actions::Attack) }
        return true unless (move = attacks.find { |action| action.launcher == target }&.move)
        return false if move&.db_symbol == :me_first

        return move&.status?
      end
    end
    Move.register(:s_sucker_punch, SuckerPunch)
  end
end
