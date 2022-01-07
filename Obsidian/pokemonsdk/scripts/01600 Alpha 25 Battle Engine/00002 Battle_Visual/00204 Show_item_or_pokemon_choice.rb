module Battle
  class Visual
    # Variable giving the position of the battlers to show from bank 0 in bag UI
    BAG_PARTY_POSITIONS = 0..5
    # Method that show the item choice
    # @return [PFM::ItemDescriptor::Wrapper, nil]
    def show_item_choice
      data_to_return = nil
      GamePlay.open_battle_bag(retrieve_party) do |battle_bag_scene|
        data_to_return = battle_bag_scene.battle_item_wrapper
      end
      log_debug("show_item_choice returned #{data_to_return}")
      return data_to_return
    end

    # Method that show the pokemon choice
    # @param forced [Boolean]
    # @return [PFM::PokemonBattler, nil]
    def show_pokemon_choice(forced = false)
      data_to_return = nil
      GamePlay.open_party_menu_to_switch(party = retrieve_party, forced) do |scene|
        data_to_return = party[scene.return_data] if scene.pokemon_selected?
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
