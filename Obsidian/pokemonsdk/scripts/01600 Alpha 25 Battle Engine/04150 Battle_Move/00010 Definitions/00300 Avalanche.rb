module Battle
  class Move
    # Class that manage Avalanche move
    # @see https://bulbapedia.bulbagarden.net/wiki/Avalanche_(move)
    # @see https://pokemondb.net/move/avalanche
    # @see https://www.pokepedia.fr/Avalanche
    class Avalanche < Basic
      # Base power calculation
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def calc_base_power(user, target)
        result = super
        damage_took = user.damage_history.any? { |dh| dh.current_turn? && dh.launcher == target }
        log_data("power = #{result * (damage_took ? 2 : 1)} # after Move::Avalanche calc")
        return result * (damage_took ? 2 : 1)
      end
    end
    Move.register(:s_avalanche, Avalanche)
    Move.register(:s_assurance, Avalanche)
  end
end
