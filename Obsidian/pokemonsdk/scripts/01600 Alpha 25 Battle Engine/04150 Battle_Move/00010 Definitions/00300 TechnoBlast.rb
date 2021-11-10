module Battle
  class Move
    class TechnoBlast < Basic
      private

      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        unless user.db_symbol == :genesect
          show_usage_failure(user)
          return false
        end
        return true if super
      end
    end
    Move.register(:s_techno_blast, TechnoBlast)
  end
end
