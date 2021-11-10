module Battle
  class Move
    # Class managing Facade move
    class Facade < Basic
      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        return 140 if user.burn? || user.paralyzed? || user.poisoned? || user.toxic?

        return power
      end
    end
    Move.register(:s_facade, Facade)
  end
end
