module Battle
  class Move
    # Me First move
    class MeFirst < Move
      CANNOT_BE_SELECTED_MOVES = %i[
        me_first sucker_punch fake_out
      ]

      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super

        if targets.empty? || logic.battler_attacks_after?(user, targets.first) || CANNOT_BE_SELECTED_MOVES.include?(target_move(targets.first))
          show_usage_failure(user)
          return false
        end

        return true
      end

      private

      # Function that retrieve the target move from the action stack
      # @return [Symbol]
      def target_move(target)
        # @type [Array<Actions::Attack>]
        attacks = logic.actions.select { |action| action.is_a?(Actions::Attack) }
        attacks.find { |action| action.launcher == target }&.move&.db_symbol || CANNOT_BE_SELECTED_MOVES.first
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        skill = GameData::Skill[target_move(actual_targets.first)]
        move = Battle::Move[skill.be_method].new(skill.id, 1, 1, @scene)
        def move.calc_mod2(user, target)
          super * 1.5
        end

        def move.chance_of_hit(user, target)
          return 100
        end
        use_another_move(move, user)
      end
    end
    Move.register(:s_me_first, MeFirst)
  end
end
