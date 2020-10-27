module Util
  # Module adding the give / take item functionality to a scene
  module GiveTakeItem
    # Give an item to a Pokemon
    # @param pokemon [PFM::Pokemon] pokemon that will receive the item
    # @param item [Integer, Symbol] item to give, -1 to open the bag
    # @yieldparam pokemon [PFM::Pokemon] block we call with pokemon before and after the form calibration
    # @return [Boolean] if the item was given
    def givetake_give_item(pokemon, item = -1)
      if item == -1
        call_scene(GamePlay::Bag, :hold) do |scene|
          item = scene.return_data
        end
        Graphics.wait(4) { update_graphics if respond_to?(:update_graphics) }
      end
      return false if item == -1

      item = GameData::Item[item].id
      item1 = pokemon.item_holding
      givetake_give_item_message(item1, item, pokemon)
      givetake_give_item_update_state(item1, item, pokemon)
      yield(pokemon) if block_given?
      return true unless pokemon.form_calibrate # Form adjustment

      pokemon.hp = (pokemon.max_hp * pokemon.hp_rate).round
      yield(pokemon) if block_given?
      display_message(parse_text(22, 157, ::PFM::Text::PKNAME[0] => pokemon.given_name))
      return true
    end

    # Display the give item message
    # @param item1 [Integer] taken item
    # @param item2 [Integer] given item
    # @param pokemon [PFM::Pokemon] Pokemong getting the item
    def givetake_give_item_message(item1, item2, pokemon)
      if item1 != 0 && item1 != item2
        display_message(parse_text(22, 91, PFM::Text::ITEM2[0] => pokemon.item_name, PFM::Text::ITEM2[1] => GameData::Item[item2].name))
      elsif item1 != item2
        display_message(parse_text(22, 90, PFM::Text::ITEM2[0] => GameData::Item[item2].name))
      end
    end

    # Update the bag and pokemon state when giving an item
    # @param item1 [Integer] taken item
    # @param item2 [Integer] given item
    # @param pokemon [PFM::Pokemon] Pokemong getting the item
    def givetake_give_item_update_state(item1, item2, pokemon)
      pokemon.item_holding = item2
      $bag.remove_item(item2, 1)
      $bag.add_item(item1, 1) if item1 != 0
    end

    # Action of taking the item from the Pokemon
    # @param pokemon [PFM::Pokemon] pokemon we take item from
    # @yieldparam pokemon [PFM::Pokemon] block we call with pokemon before and after the form calibration
    def givetake_take_item(pokemon)
      item = pokemon.item_holding
      $bag.add_item(item, 1)
      pokemon.item_holding = 0
      yield(pokemon) if block_given?
      display_message(parse_text(23, 78, ::PFM::Text::PKNICK[0] => pokemon.given_name, ::PFM::Text::ITEM2[1] => ::GameData::Item[item].name))
      return unless pokemon.form_calibrate # Form ajustment

      pokemon.hp = (pokemon.max_hp * pokemon.hp_rate).round
      yield(pokemon) if block_given?
      display_message(parse_text(22, 157, ::PFM::Text::PKNAME[0] => pokemon.given_name))
    end
  end
end
