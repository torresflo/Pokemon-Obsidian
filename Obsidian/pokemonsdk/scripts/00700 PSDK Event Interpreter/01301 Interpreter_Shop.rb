class Interpreter
  # Open a shop
  # @overload open_shop(items, prices)
  #   @param items [Symbol]
  #   @param prices [Hash] (optional)
  # @overload open_shop(items,prices)
  #   @param items [Array<Integer>]
  #   @param prices [Hash] (optional)
  def open_shop(items, prices = {}, show_background: true)
    $scene.call_scene(GamePlay::Shop, items, prices, show_background: show_background)
    @wait_count = 2
  end
  alias ouvrir_magasin open_shop

  # Create a limited shop (in the main PFM::Shop object)
  def add_limited_shop(symbol_of_new_shop, list_of_item_id = [], list_of_item_quantity = [], shop_rewrite: false)
    PFM.game_state.shop.create_new_limited_shop(symbol_of_new_shop, list_of_item_id, list_of_item_quantity, shop_rewrite: shop_rewrite)
  end
  alias ajouter_un_magasin_limite add_limited_shop

  # Add items to a limited shop
  def add_items_to_limited_shop(symbol_of_shop, list_item_id_to_refill = [], list_quantity_to_refill = [])
    PFM.game_state.shop.refill_limited_shop(symbol_of_shop, list_item_id_to_refill, list_quantity_to_refill)
  end
  alias ajouter_objets_magasin add_items_to_limited_shop

  # Remove items from a limited shop
  def remove_items_from_limited_shop(symbol_of_shop, list_item_id_to_remove, list_quantity_to_remove)
    PFM.game_state.shop.remove_from_limited_shop(symbol_of_shop, list_item_id_to_remove, list_quantity_to_remove)
  end
  alias enlever_objets_magasin remove_items_from_limited_shop

  # Open a Pokemon shop
  def pokemon_shop_open(symbol_or_list, prices = [], param = [], show_background: true)
    if symbol_or_list.is_a?(Symbol)
      GamePlay.open_existing_pokemon_shop(symbol_or_list, prices.is_a?(Hash) ? prices : {}, show_background: show_background)
    else
      GamePlay.open_pokemon_shop(symbol_or_list, prices, param, show_background: show_background)
    end
    @wait_count = 2
  end
  alias ouvrir_magasin_pokemon pokemon_shop_open

  # Create a limited Pokemon Shop
  def add_new_pokemon_shop(sym_new_shop, list_id_mon, list_prices, list_param_mon, list_quantity_mon = [], shop_rewrite: false)
    PFM.game_state.shop.create_new_pokemon_shop(sym_new_shop, list_id_mon, list_prices, list_param_mon, list_quantity_mon, shop_rewrite: shop_rewrite)
  end
  alias ajouter_nouveau_magasin_pokemon add_new_pokemon_shop

  # Add Pokemon to a Pokemon Shop

  def add_pokemon_to_shop(symbol_of_shop, list_id_mon, list_prices, list_param_mon, list_quantity_mon = [], pkm_rewrite: false)
    PFM.game_state.shop.refill_pokemon_shop(symbol_of_shop, list_id_mon, list_prices, list_param_mon, list_quantity_mon, pkm_rewrite: pkm_rewrite)
  end
  alias ajouter_pokemon_au_magasin add_pokemon_to_shop

  # Remove Pokemon from a Pokemon Shop

  def remove_pokemon_from_shop(symbol_of_shop, remove_list_mon, param_form, list_quantity_to_remove = [])
    PFM.game_state.shop.remove_from_pokemon_shop(symbol_of_shop, remove_list_mon, param_form, list_quantity_to_remove)
  end
  alias enlever_pokemon_du_magasin remove_pokemon_from_shop
end
