module Battle
  class Move
    # Power doubles if the user was attacked first.
    # @see https://pokemondb.net/move/payback
    # @see https://bulbapedia.bulbagarden.net/wiki/Payback_(move)
    # @see https://www.pokepedia.fr/Repr%C3%A9sailles
    class PayBack < Basic
      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        last_damage = user.damage_history.last
        mult = (last_damage&.current_turn? && last_damage&.launcher ? damage_multiplier : 1)
        log_data("real_base_power = #{super * mult} # Payback multiplier: #{mult}")
        return super * mult
      end

      private

      # Damage multiplier if the effect proc
      # @return [Integer, Float]
      def damage_multiplier
        2
      end
    end
    Move.register(:s_payback, PayBack)
  end
end
