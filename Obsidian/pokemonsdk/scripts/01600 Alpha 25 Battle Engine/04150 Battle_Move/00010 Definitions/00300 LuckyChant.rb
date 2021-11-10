module Battle
  class Move
    # class managing HappyHour move
    class LuckyChant < Move
      private

      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param _targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, _targets)
        return false if logic.bank_effects[user.bank].has?(:lucky_chant)

        return true
      end

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param _actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, _actual_targets)
        @logic.add_bank_effect(Effects::LuckyChant.new(@logic, user.bank))
        @scene.display_message_and_wait(parse_text(18, 152 + user.bank))
      end
    end

    Move.register(:s_lucky_chant, LuckyChant)
  end
end
