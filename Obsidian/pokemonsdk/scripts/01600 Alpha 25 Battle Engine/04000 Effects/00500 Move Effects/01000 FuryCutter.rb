module Battle
  module Effects
    # Effect that manage Fury Cutter effect
    class FuryCutter < PokemonTiedEffectBase
      include Mechanics::SuccessiveSuccessfulUses

      # Create a new Pokemon tied effect
      # @param logic [Battle::Logic]
      # @param pokemon [PFM::PokemonBattler]
      # @param move [Battle::Move]
      def initialize(logic, pokemon, move)
        super(logic, pokemon)
        init_successive_successful_uses(pokemon, move)
      end

      # Return the symbol of the effect.
      # @return [Symbol]
      def name
        :fury_cutter
      end
    end
  end
end
