module Battle
  class Move
    # Move that inflict Spikes to the enemy bank
    class FollowMe < Move
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super

        if logic.battle_info.vs_type == 1 || logic.battler_attacks_last?(user) || any_battler_with_follow_me_effect?
          show_usage_failure(user)
          return false
        end

        return true
      end

      private

      # Test if any alive battler used followMe this turn
      # @return [Boolean]
      def any_battler_with_follow_me_effect?
        # @type [Array<PFM::PokemonBattler::MoveHistory>]
        last_move_history = logic.all_alive_battlers.map { |battler| battler.move_history.last }.compact
        return last_move_history.any? { |move_history| move_history.current_turn? && move_history.move.be_method == :s_follow_me }
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        scene.display_message_and_wait(parse_text_with_pokemon(19, 670, user))
      end
    end

    Move.register(:s_follow_me, FollowMe)
    Hooks.register(Move, :possible_targets, 'FollowMe redirection') do |hook_binding|
      # Add exception here if multi target (all_) moves should not be redirected
      next if target == :user || target == :user_or_adjacent_ally

      followed = logic.all_alive_battlers.find do |battler|
        last = battler.move_history.last
        next unless last

        next last.current_turn? && last.move.be_method == :s_follow_me
      end
      if followed
        hook_binding.local_variable_set(:possible_targets, [followed])
        hook_binding.local_variable_set(:target_bank, followed.bank)
      end
    end
  end
end
