module Battle
  module AI
    class Base
      private

      # Find the mega evolve actions for the said Pokemon
      # @param pokemon [PFM::PokemonBattler]
      # @return [Actions::Mega]
      def mega_evolve_action_for(pokemon)
        return nil unless @scene.logic.mega_evolve.can_pokemon_mega_evolve?(pokemon)

        return Actions::Mega.new(@scene, pokemon)
      end
    end
  end
end
