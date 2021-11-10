module Battle
  class Logic
    class MegaEvolve
      # List of tools that allow MEGA Evolution
      MEGA_EVOLVE_TOOLS = %i[mega_ring mega_bracelet mega_pendant mega_glasses mega_anchor mega_stickpin mega_tiara mega_anklet
                             mega_cuff]

      # Create the MegaEvolve checker
      # @param scene [Battle::Scene]
      def initialize(scene)
        @scene = scene
        # List of bags that already used the mega evolution
        # @type [Array<PFM::Bag>]
        @used_mega_tool_bags = []
      end

      # Test if a Pokemon can Mega Evolve
      # @param pokemon [PFM::PokemonBattler] Pokemon that should mega evolve
      # @return [Boolean]
      def can_pokemon_mega_evolve?(pokemon)
        bag = pokemon.bag
        return false unless MEGA_EVOLVE_TOOLS.any? { |item_db_symbol| bag.contain_item?(item_db_symbol) }
        return false if pokemon.from_party? && any_mega_player_action?

        return !@used_mega_tool_bags.include?(bag) && pokemon.can_mega_evolve?
      end

      # Mark a Pokemon as mega evolved
      # @param pokemon [PFM::PokemonBattler]
      def mark_as_mega_evolved(pokemon)
        @used_mega_tool_bags << pokemon.bag
      end

      # Give the name of the mega tool used by the trainer
      # @param pokemon [PFM::PokemonBattler]
      # @return [String]
      def mega_tool_name(pokemon)
        bag = pokemon.bag
        symbol = MEGA_EVOLVE_TOOLS.find { |item_db_symbol| bag.contain_item?(item_db_symbol) }
        return GameData::Item[symbol || 0].name
      end

      private

      # Function that checks if any action of the player is a mega evolve
      # @return [Boolean]
      def any_mega_player_action?
        @scene.player_actions.any? { |actions| actions.is_a?(Array) }
      end
    end
  end
end
