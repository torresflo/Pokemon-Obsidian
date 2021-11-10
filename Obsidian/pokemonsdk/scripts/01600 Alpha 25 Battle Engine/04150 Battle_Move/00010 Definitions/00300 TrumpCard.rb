module Battle
  class Move
    # Trump Card inflicts more damage when fewer PP are left, as per the table.
    # @see https://pokemondb.net/move/trump-card
    # @see https://bulbapedia.bulbagarden.net/wiki/Trump_Card_(move)
    # @see https://www.pokepedia.fr/Atout
    class TrumpCard < Basic
      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        res = power_table[pp] || default_power
        log_data("power = #{res} # trump card (pp:#{pp})")
        return res
      end

      private

      # Check if the move bypass chance of hit and cannot fail
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Boolean]
      def bypass_chance_of_hit?(user, target)
        return true unless target.effects.has?(&:out_of_reach?)

        super
      end

      # Power table
      # Array<Integer>
      POWER_TABLE = [200, 80, 60, 50]

      # Power table
      # @return [Array<Integer>]
      def power_table
        POWER_TABLE
      end

      # Power of the move if the power table is nil at pp index
      # @return [Integer]
      def default_power
        40
      end
    end
    register(:s_trump_card, TrumpCard)
  end
end
