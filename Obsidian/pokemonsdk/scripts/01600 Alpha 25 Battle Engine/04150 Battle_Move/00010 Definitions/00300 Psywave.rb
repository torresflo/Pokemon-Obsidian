module Battle
  class Move
    # Class managing Psywave
    class Psywave < Basic
      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        n = (user.level * (logic.move_damage_rng.rand(1..100) + 50) / 100).floor
        n.clamp(1, Float::INFINITY)
        return n || power
      end
    end
    Move.register(:s_psywave, Psywave)
  end
end
