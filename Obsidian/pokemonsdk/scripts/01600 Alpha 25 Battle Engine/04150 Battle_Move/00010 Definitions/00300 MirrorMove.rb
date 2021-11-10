module Battle
  class Move
    # Move that mimics the last move of the choosen target
    class MirrorMove < Move
      COPY_CAT_MOVE_EXCLUDED = %i[
        baneful_bunker beak_blast behemoth_blade bestow celebrate chatter circle_throw copycat counter covet destiny_bond
        detect dragon_tail endure feint focus_punch follow_me helping_hand hold_hands king_s_shield mat_block assist
        me_first metronome mimic mirror_coat mirror_move protect rage_powder roar shell_trap sketch sleep_talk snatch
        struggle spiky_shield spotlight switcheroo thief transform trick whirlwind
      ]
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super

        last_used_move = last_move(user, targets)
        if !last_used_move || move_excluded?(last_used_move)
          show_usage_failure(user)
          return false
        end

        return true
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        move = last_move(user, actual_targets).dup

        def move.move_usable_by_user(user, targets)
          return true
        end
        use_another_move(move, user)
      end

      private

      # Tell if the move is usable or not
      # @param move [Battle::Move]
      # @return [Boolean]
      def move_excluded?(move)
        return !move.mirror_move_affected? if db_symbol == :mirror_move

        return COPY_CAT_MOVE_EXCLUDED.include?(move.db_symbol)
      end

      # Function that gets the last used move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @return [Battle::Move, nil] the last move
      def last_move(user, targets)
        if db_symbol == :mirror_move
          return nil unless (target = targets.first)
          return nil unless (move_history = target.move_history.last)
          return nil if move_history.turn < ($game_temp.battle_turn - 1)

          return move_history.move
        end
        return copy_cat_last_move
      end

      # Function that gets the last used move for copy cat
      # @return [Battle::Move, nil] the last move
      def copy_cat_last_move
        # @type [Array<PFM::PokemonBattler::MoveHistory>]
        last_move_history = logic.all_alive_battlers.map { |battler| battler.move_history.last }.compact
        max_turn = last_move_history.map(&:turn).max
        last_turn_history = last_move_history.select { |history| history.turn == max_turn }
        # @type [PFM::PokemonBattler::MoveHistory]
        last_history = last_turn_history.max_by(&:attack_order)
        return last_history&.move
      end
    end

    Move.register(:s_mirror_move, MirrorMove)
  end
end
