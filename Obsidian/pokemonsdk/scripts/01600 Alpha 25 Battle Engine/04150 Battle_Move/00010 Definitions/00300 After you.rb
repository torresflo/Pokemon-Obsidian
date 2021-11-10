module Battle
  class Move
    # Me First move
    class AfterYou < Move
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super

        if targets.empty? || logic.battler_attacks_after?(user, targets.first)
          show_usage_failure(user)
          return false
        end

        return true
      end

      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        target = actual_targets.first
        # @type [Array<Actions::Attack>]
        attacks = logic.actions.select { |action| action.is_a?(Actions::Attack) }
        target_action = attacks.find { |action| action.launcher == target }
        return unless target_action

        logic.actions.delete(target_action)
        logic.actions << target_action
        scene.display_message_and_wait(parse_text_with_pokemon(19, 1140, target))
      end
    end
    Move.register(:s_after_you, AfterYou)
  end
end
