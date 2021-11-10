module Battle
  class Move
    # Class managing the Pluck move
    class Belch < Basic
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super
        return true if user.item_consumed && Effects::Item.new(logic, user, user.consumed_item).is_a?(Effects::Item::Berry)

        show_usage_failure(user)
        return false
      end
    end
    Move.register(:s_belch, Belch)
  end
end
