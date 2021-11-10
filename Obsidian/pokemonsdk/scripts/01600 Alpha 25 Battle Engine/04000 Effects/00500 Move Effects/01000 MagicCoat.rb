module Battle
  module Effects
    # Implement the change type effect (Electrify)
    class MagicCoat < PokemonTiedEffectBase
      # Create a new Electrify effect
      # @param logic [Battle::Logic]
      # @param target [PFM::PokemonBattler]
      def initialize(logic, target)
        super(logic, target)
        self.counter = 1
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        return :magic_coat
      end
    end
  end
end
