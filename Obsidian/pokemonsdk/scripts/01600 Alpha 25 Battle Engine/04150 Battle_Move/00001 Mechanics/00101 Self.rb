module Battle
  class Move
    # Class describing a self stat move (damage + potential status + potential stat to user)
    class SelfStat < Basic
      # Function that deals the stat to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_stats(user, actual_targets)
        super(user, [user])
      end
    end

    # Class describing a self status move (damage + potential status + potential stat to user)
    class SelfStatus < Basic
      # Function that deals the status condition to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_status(user, actual_targets)
        super(user, [user])
      end
    end

    Move.register(:s_self_stat, SelfStat)
    Move.register(:s_self_status, SelfStatus)
  end
end
