module Battle
  module AI
    class Base
      private

      # Find the mega evolve actions for the said Pokemon
      # @param pokemon [PFM::PokemonBattler]
      # @return [Array<[Float, Actions::Flee]>, nil]
      def flee_action_for(pokemon)
        return nil unless @scene.logic.switch_handler.can_switch?(pokemon)

        return [Float::INFINITY, Actions::Flee.new(@scene, pokemon)]
      end
    end
  end
end
