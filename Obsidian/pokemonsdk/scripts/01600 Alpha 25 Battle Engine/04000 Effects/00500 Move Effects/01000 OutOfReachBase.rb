module Battle
  module Effects
    # Implement the Out of Reach effect
    class OutOfReachBase < PokemonTiedEffectBase
      include Mechanics::OutOfReach

      # Create a new out reach effect
      # @param logic [Battle::Logic]
      # @param pokemon [PFM::PokemonBattler]
      # @param exceptions [Array<Symbol>] move that hit the target while out of reach
      def initialize(logic, pokemon, exceptions)
        super(logic, pokemon)
        initialize_out_of_reach(pokemon, exceptions)
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        return :out_of_reach_base
      end
    end
  end
end
