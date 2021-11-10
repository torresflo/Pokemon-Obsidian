module Battle
  class Move
    # Class managing Acrobatics move
    class Acrobatics < Basic
      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        return power * 2 unless user.item_db_symbol != :__undef__

        return super
      end
    end
    Move.register(:s_acrobatics, Acrobatics)
  end
end
