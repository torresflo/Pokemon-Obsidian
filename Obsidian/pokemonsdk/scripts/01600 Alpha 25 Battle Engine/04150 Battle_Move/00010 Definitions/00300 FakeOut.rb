module Battle
  class Move
    # class managing Fake Out move
    class FakeOut < BasicWithSuccessfulEffect
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        if user.turn_count > 1
          show_usage_failure(user)
          return false
        end

        return true
      end
    end
    Move.register(:s_fake_out, FakeOut)
  end
end
