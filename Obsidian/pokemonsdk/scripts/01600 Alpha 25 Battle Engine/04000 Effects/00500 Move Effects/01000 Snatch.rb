module Battle
  module Effects
    class Snatch < PokemonTiedEffectBase
      # Create a new Pokemon tied effect
      # @param logic [Battle::Logic]
      # @param pokemon [PFM::PokemonBattler]
      # @param turncount [Integer]
      def initialize(logic, pokemon, turncount = 1)
        super(logic, pokemon)
        self.counter = turncount
      end

      # Function giving the name of the effect
      # @return [Symbol]
      def name
        :snatch
      end
    end
  end
end