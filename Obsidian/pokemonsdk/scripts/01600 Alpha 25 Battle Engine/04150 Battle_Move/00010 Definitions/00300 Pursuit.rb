module Battle
  class Move
    # Pursuit move, double the power if hitting switching out Pokemon
    class Pursuit < Basic
      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        return super * 2 if target.switching? && target.last_sent_turn != $game_temp.battle_turn

        return super
      end
    end

    Move.register(:s_pursuit, Pursuit)
  end
end
