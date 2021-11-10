module Battle
  module Effects
    class Charge < PokemonTiedEffectBase
      # Create a new Pokemon tied effect
      # @param logic [Battle::Logic]
      # @param pokemon [PFM::PokemonBattler]
      # @param turncount [Integer] amount of turn the effect is active
      def initialize(logic, pokemon, turncount)
        super(logic, pokemon)
        self.counter = turncount
      end

      # Give the move base power mutiplier
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @param move [Battle::Move] move
      # @return [Float, Integer] multiplier
      def base_power_multiplier(user, target, move)
        return 1 if user != @pokemon

        return move.type_electric? ? 2 : 1
      end

      # Name of the effect
      # @return [Symbol]
      def name
        :charge
      end
    end
  end
end
