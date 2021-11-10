module Battle
  class Move
    class Eruption < Basic
      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        return (power * user.hp_rate).clamp(1, Float::INFINITY)
      end
    end
    Move.register(:s_eruption, Eruption)
  end
end
