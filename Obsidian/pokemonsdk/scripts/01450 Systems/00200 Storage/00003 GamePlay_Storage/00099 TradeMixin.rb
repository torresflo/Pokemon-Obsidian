module GamePlay
  # Mixin definin the Input/Output of the PokemonTradeStorage class
  module PokemonTradeStorageMixin
    # Get the selected Pokemon index (1~30) = current box, (31~36) = party
    # @return [Integer, nil]
    attr_reader :return_data

    # Tell if a Pokemon was selected
    # @return [Boolean]
    def pokemon_selected?
      return false unless return_data

      return !selected_pokemon.nil?
    end

    # Get the selected Pokemon
    # @return [PFM::Pokemon, nil]
    def selected_pokemon
      return $storage.info(return_data - 1) if pokemon_selected_in_box?
      return $actors[return_data - 31] if pokemon_selected_in_party?

      return nil
    end

    # Tell if the selected Pokemon is from box
    # @return [Boolean]
    def pokemon_selected_in_box?
      return false unless return_data

      return return_data.to_i.between?(1, 30)
    end

    # Tell if the selected Pokemon is from party
    # @return [Boolean]
    def pokemon_selected_in_party?
      return false unless return_data

      return return_data.to_i.between?(31, 36)
    end
  end
end

GamePlay.pokemon_trade_storage_mixin = GamePlay::PokemonTradeStorageMixin
