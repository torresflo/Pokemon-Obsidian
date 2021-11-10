module Battle
  class Move
    class ElectroBall < Basic
      # List of all base power depending on the speed ration between target & user
      BASE_POWERS = [
        [0.25, 150], # ratio < first => power = last
        [0.33, 120],
        [0.5, 80],
        [1, 60],
        [Float::INFINITY, 40]
      ]
      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        ratio = target.spd / user.spd
        return BASE_POWERS.find { |(first)| first > ratio }&.last || 40
      end
    end
    Move.register(:s_electro_ball, ElectroBall)
  end
end
