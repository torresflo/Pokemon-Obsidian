module Battle
  module Effects
    class Autotomize < PokemonTiedEffectBase
      # Constant containing the weight for each Autotomize-like move
      WEIGHT_MOVES = {
        autotomize: 100
      }
      WEIGHT_MOVES.default = 100
      # Create a new autotomize effect
      # @param logic [Battle::Logic]
      # @param pokemon [PFM::PokemonBattler]
      # @param move [Battle::Move] the move that created the effect
      def initialize(logic, pokemon, move)
        super(logic, pokemon)
        launch_effect(move)
      end

      # Get the effect name
      # @return [Symbol]
      def name
        return :autotomize
      end

      # Try to increase a stat of the Pokemon then change its weight
      # @param move [Battle::Move]
      def launch_effect(move)
        @pokemon.weight = (@pokemon.weight - weight(move)).clamp(0.1, Float::INFINITY)
        @logic.scene.display_message_and_wait(message)
      end

      # Function called when the effect has been deleted from the effects handler
      def on_delete
        @pokemon.restore_weight
      end

      private

      # Return the weight loss for the move
      def weight(move)
        WEIGHT_MOVES[move.db_symbol]
      end

      # Get the right message to display
      # @return [String]
      def message
        return parse_text_with_pokemon(19, 1108, @pokemon)
      end
    end
  end
end
