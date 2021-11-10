module Battle
  class Move
    # Move that deals Revenge to the target
    class Revenge < Basic
      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        check = user.damage_history.any? { |history| history.turn == $game_temp.battle_turn && history.launcher == target }
        return check ? power * 2 : power
      end
    end
    Move.register(:s_revenge, Revenge)
  end
end
