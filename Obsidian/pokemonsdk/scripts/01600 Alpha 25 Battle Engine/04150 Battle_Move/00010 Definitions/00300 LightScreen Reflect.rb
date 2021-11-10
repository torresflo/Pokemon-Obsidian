module Battle
  class Move
    # Move that adds a field on the bank protecting from physicial or special moves
    class Reflect < Move
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super

        if logic.bank_effects[user.bank].has?(db_symbol)
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
        turn_count = user.hold_item?(:light_clay) ? 8 : 5
        if db_symbol == :light_screen
          logic.bank_effects[user.bank].add(Effects::LightScreen.new(logic, user.bank, 0, turn_count))
          scene.display_message_and_wait(parse_text(18, 134 + user.bank.clamp(0, 1)))
        else
          logic.bank_effects[user.bank].add(Effects::Reflect.new(logic, user.bank, 0, turn_count))
          scene.display_message_and_wait(parse_text(18, 130 + user.bank.clamp(0, 1)))
        end
      end
    end

    Move.register(:s_reflect, Reflect)
  end
end
