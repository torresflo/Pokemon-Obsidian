module Battle
  module Effects
    # Class that describe an effect that is tied to a Pokemon
    class PokemonTiedEffectBase < EffectBase
      # Create a new Pokemon tied effect
      # @param logic [Battle::Logic]
      # @param pokemon [PFM::PokemonBattler]
      def initialize(logic, pokemon)
        super(logic)
        @pokemon = pokemon
      end

      # Function called when we the effect is passed to another pokemon via Baton Pass
      # @param with [PFM::PokemonBattler] pokemon switched in
      # @return [Boolean, nil] True if the effect is passed
      def on_baton_pass_switch(with)
        return false unless (effect = baton_switch_transfer(with))

        with.effects.add(effect)
        return true
      end

      private

      # Transfer the effect to the given pokemon via baton switch
      # @param with [PFM::Battler] the pokemon switched in
      # @return [Battle::Effects::PokemonTiedEffectBase, nil] the effect to give to the switched in pokemon when transferable via baton pass, nil otherwise
      def baton_switch_transfer(with)
        return nil
      end
    end
  end
end
