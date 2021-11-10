module Battle
  class Move
    class Return < Basic
      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        power = (user.loyalty / 2.5).clamp(1, 255)
        log_data("Power of Return: #{power}")
        return power
      end
    end
    Move.register(:s_return, Return)
  end
end
