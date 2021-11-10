module Battle
  module Effects
    # Implement the Minimize effect
    class Minimize < PokemonTiedEffectBase
      # Get the name of the effect
      # @return [Symbol]
      def name
        return :minimize
      end
    end
  end
end
