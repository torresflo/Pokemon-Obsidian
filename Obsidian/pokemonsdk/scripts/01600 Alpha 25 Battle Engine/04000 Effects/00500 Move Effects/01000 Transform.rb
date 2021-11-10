module Battle
  module Effects
    # Implement the Transform effect
    class Transform < PokemonTiedEffectBase
      # Function called when a Pokemon has actually switched with another one
      # @param handler [Battle::Logic::SwitchHandler]
      # @param who [PFM::PokemonBattler] Pokemon that is switched out
      # @param with [PFM::PokemonBattler] Pokemon that is switched in
      def on_switch_event(handler, who, with)
        return if who != @pokemon || with == @pokemon

        @pokemon.transform = nil
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        return :transform
      end
    end
  end
end
