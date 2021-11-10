module Battle
  module Effects
    # Implement the ability suppression (Gastro Acid)
    class AbilitySuppressed < PokemonTiedEffectBase
      # Get the name of the effect
      # @return [Symbol]
      def name
        return :ability_suppressed
      end

      private

      # Transfer the effect to the given pokemon via baton switch
      # @param with [PFM::Battler] the pokemon switched in
      # @return [Battle::Effects::PokemonTiedEffectBase, nil] the effect to give to the switched in pokemon, nil if there is this effect isn't transferable via baton pass
      def baton_switch_transfer(with)
        return self.class.new(@logic, with)
      end
    end
  end
end
