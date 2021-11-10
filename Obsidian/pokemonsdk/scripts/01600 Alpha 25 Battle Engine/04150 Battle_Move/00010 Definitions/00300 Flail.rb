module Battle
  class Move
    class Flail < Basic
      Flail_Pow = [20, 40, 80, 100, 150, 200]
      Flail_HP  = [0.7, 0.35, 0.2, 0.10, 0.04, 0]

      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        return Flail_Pow[Flail_HP.find_index { |i| i < user.hp_rate }].to_i
      end
    end
    Move.register(:s_flail, Flail)
  end
end
