module Battle
  module Effects
    # Implement the Miracle Eye effect
    class HealBlock < PokemonTiedEffectBase
      # Create a new Pokemon HealBlock effect
      # @param logic [Battle::Logic]
      # @param target [PFM::PokemonBattler]
      def initialize(logic, target)
        super(logic, target)
        self.counter = 5
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        return :heal_block
      end
    end
  end
end
