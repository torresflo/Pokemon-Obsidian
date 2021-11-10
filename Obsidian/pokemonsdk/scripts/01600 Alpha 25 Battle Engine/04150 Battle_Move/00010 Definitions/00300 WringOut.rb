module Battle
  class Move
    class WringOut < Basic
      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        return (power * target.hp_rate).clamp(1, Float::INFINITY)
      end
    end
    Move.register(:s_wring_out, WringOut)
  end
end
