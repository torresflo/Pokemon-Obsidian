#encoding: utf-8

#noyard
module GamePlay
  class Pokemon_Shop < Shop
    def initialize(pokemon_ids, pokemon_prices, pokemon_levels)
      super()
      @goods = pokemon_ids
      @item_names = Array.new(pokemon_ids.size) { |i| ::GameData::Pokemon.name(pokemon_ids[i]) }
      @item_prices = Array.new(@goods.size) { |i| parse_text(22,159, NUM7R => pokemon_prices[i].to_s) }
      @pokemon_prices = pokemon_prices
      @pokemon_levels = pokemon_levels
      draw_item_list
      draw_descr
    end

    def buy_item(item_id)
      price = @pokemon_prices[index = @goods.index(item_id).to_i]
      if(price == 0 or price > $pokemon_party.money)
        display_message(parse_text(11, 24))
        return
      else
        c = display_message(parse_text(11,25, ITEM2[0] => ::GameData::Pokemon.name(item_id),
          NUM2[1] => "1", NUM7R => price.to_s), 1,
          text_get(11,27), text_get(11,28))
        return if(c != 0)
        if (level = @pokemon_levels[index]).is_a?(Hash)
          pokemon = PFM::Pokemon.generate_from_hash(level)
        else
          pokemon = PFM::Pokemon.new(item_id, level)
        end
        $pokemon_party.add_pokemon(pokemon)
        $pokemon_party.lose_money(price)
        draw_gold_window
        display_message(text_get(11,29))
        #> Jouer le bruit du shop
      end
    end

    def draw_descr
      if @index < @goods.size
        item_id = @goods[@index]
        @icon_sprite.bitmap = RPG::Cache.b_icon(format('%03d', item_id))
        @descr_text.multiline_text = GameData::Pokemon.descr(item_id)
      else
        @descr_text.text = " "
        @icon_sprite.bitmap = nil
      end
    end
  end
end
