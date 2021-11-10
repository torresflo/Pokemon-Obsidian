module Battle
  class Move
    class Frustration < Basic
      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        power = (255 - user.loyalty) / 2.5
        power.floor.clamp(1, 102)
        log_data("Frustration power: #{power}")
        return power
      end
    end
    Move.register(:s_frustration, Frustration)
  end
end
