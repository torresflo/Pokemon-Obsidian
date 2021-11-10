module Battle
  class Visual
    # Variable giving the position of the battlers to show from bank 0 in bag UI
    BAG_PARTY_POSITIONS = 0..5
    # Method that show the item choice
    # @return [PFM::ItemDescriptor::Wrapper, nil]
    def show_item_choice
      data_to_return = nil
      @scene.call_scene(GamePlay::Battle_Bag, retrieve_party) do |scene|
        data_to_return = GamePlay::Battle_Bag.from(scene).battle_item_wrapper
      end
      log_debug("show_item_choice returned #{data_to_return}")
      return data_to_return
    end

    # Method that show the pokemon choice
    # @param forced [Boolean]
    # @return [PFM::PokemonBattler, nil]
    def show_pokemon_choice(forced = false)
      data_to_return = nil
      @scene.call_scene(GamePlay::Party_Menu, party = retrieve_party, :battle, no_leave: forced) do |scene|
        return_data = scene.return_data
        data_to_return = party[return_data] if return_data != -1
      end
      log_debug("show_pokemon_choice returned #{data_to_return}")
      return data_to_return
    end

    private

    # Method that returns the party for the Bag & Party scene
    # @return [Array<PFM::PokemonBattler>]
    def retrieve_party
      return @scene.logic.all_battlers.select(&:from_party?)
    end
  end
end
