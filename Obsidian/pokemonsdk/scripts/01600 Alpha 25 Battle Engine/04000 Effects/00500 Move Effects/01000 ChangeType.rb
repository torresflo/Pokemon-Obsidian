module Battle
  module Effects
    # ChangeType Effects
    class ChangeType < PokemonTiedEffectBase
      # Create a new Pokemon tied effect
      # @param logic [Battle::Logic]
      # @param pokemon [PFM::PokemonBattler]
      # @param type [Integer] the ID of the type to apply to the Pokemon
      def initialize(logic, pokemon, type)
        super(logic, pokemon)
        @pokemon.change_types(type)
      end

      # Function called when a Pokemon initialize a transformation
      # @param handler [Battle::Logic::TransformHandler]
      # @param target [PFM::PokemonBattler]
      def on_transform_event(handler, target)
        return unless @pokemon == target

        @pokemon.restore_types
        kill
      end

      # TODO : Add a method to check for form changing

      # Get the effect name
      # @return [Symbol]
      def name
        :change_type
      end
    end
  end
end
