module Battle
  class Move
    # Power doubles if opponent's HP is 50% or less.
    class Brine < Basic
      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        return target.hp <= (target.max_hp / 2) ? power * 2 : power
      end
    end
    Move.register(:s_brine, Brine)
  end
end
