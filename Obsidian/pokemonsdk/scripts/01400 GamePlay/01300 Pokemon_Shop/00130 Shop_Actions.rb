module GamePlay
  class Pokemon_Shop < Shop
    private

    # Method describing the process of buying an unlimited use item
    def buy_pokemon
      price = @list_item[@index][:price].to_s
      id_text = 94
      pkm_name = GameData::Pokemon[@list_item[@index][:id]].name
      hash = { ITEM2[0] => pkm_name, NUM7R => price }
      c = display_message(parse_text(11, id_text, hash), 1, text_get(11, 27), text_get(11, 28))
      money_checkout(1) if c == 0
    end

    # Take the good amount of money from the player and some other things
    # @param nb [Integer] the number of items that the player is buying
    def money_checkout(nb)
      display_message(parse_text(11, 29))
      $pokemon_party.lose_money(nb * @list_item[@index][:price])
      pokemon = PFM::Pokemon.generate_from_hash(@list_item[@index])
      test = pokemon.shiny
      puts test
      $pokemon_party.add_pokemon(pokemon)
      @what_was_buyed << @list_item[@index][:id] unless @what_was_buyed.include?(@list_item[@index][:id])
      @shop.remove_from_pokemon_shop(@symbol_or_list, [@list_item[@index][:id]],
                                     [@list_item[@index]], [1]) if @symbol_or_list.is_a?(Symbol)
      update_shop_ui_after_buying(@index)
    end

    # Make sure the Shop UI gets updated after buying something
    # @param index [Integer] previous index value
    def update_shop_ui_after_buying(index)
      # Adjust the bag info
      reload_item_list
      unless @force_close 
        @index = index.clamp(0, @last_index)
        @item_list.index = @index
        # Reload the graphics
        update_item_button_list
        update_scrollbar
        update_item_desc
        update_money_text
      end
    end

    # Check the scenario in which the player leaves
    # @return [Integer] the number of the scenario for the player leaving
    def how_do_the_player_leave
      return 0 if @what_was_buyed.empty?
      return 1 if @what_was_buyed.size == 1
      if @what_was_buyed.size >= 2 && @what_was_buyed[0] != @what_was_buyed[1]
        return 2
      else 
        return 1
      end
    end

  end
end
