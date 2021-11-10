module Battle
  class Move
    # Protect move
    class Protect < Move
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super

        if user.effects.has?(:substitute) || logic.battler_attacks_last?(user)
          show_usage_failure(user)
          return false
        end

        turn = $game_temp.battle_turn
        consecutive_uses = user.move_history.reverse.take_while do |history|
          if history.move.be_method == :s_protect
            turn -= 1
            next turn == history.turn
          end
        end

        unless bchance?(2**-consecutive_uses.size)
          show_usage_failure(user)
          return false
        end

        return true
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          target.effects.add(Effects::Protect.new(logic, target, self))
          scene.display_message_and_wait(deal_message(target))
        end
      end

      def deal_message(user)
        msg_id = 517
        msg_id = 511 if db_symbol == :endure
        msg_id = 800 if db_symbol == :quick_guard
        msg_id = 797 if db_symbol == :wide_guard

        return parse_text_with_pokemon(19, msg_id, user)
      end
    end
    Move.register(:s_protect, Protect)
  end
end
