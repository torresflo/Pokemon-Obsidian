module Battle
  class Move
    class GyroBall < Basic
      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        power = 25 * (target.spd / user.spd)
        power.clamp(1, 150)
        log_data("Gyro Ball power: #{power}")
        return power
      end
    end
    Move.register(:s_gyro_ball, GyroBall)
  end
end
