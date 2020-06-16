module PFM
  # Class describing the shop logic
  class Shop
    # Hash containing the defined shops
    # @return [Hash]
    attr_accessor :shop_list
    # Hash containing the defined Pokemon shops
    # @return [Hash]
    attr_accessor :pokemon_shop_list

    def initialize
      @shop_list = {}
      @pokemon_shop_list = {}
    end

    # Create a new limited Shop
    # @param symbol_of_new_shop [Symbol] the symbol to link to the new shop
    # @param list_of_item_id [Array<Integer>] the array containing the id of the items to sell
    # @param list_of_item_quantity [Array<Integer>] the array containing the quantity of the items to sell
    # @param shop_rewrite [Boolean] if the system must completely overwrite an already existing shop
    def create_new_limited_shop(symbol_of_new_shop, list_of_item_id = [], list_of_item_quantity = [], shop_rewrite: false)
      return unless shop_param_legit?(symbol_of_new_shop, list_of_item_id, list_of_item_quantity)

      if @shop_list.key?(symbol_of_new_shop) && shop_rewrite
        @shop_list.delete(symbol_of_new_shop)
      elsif @shop_list.key?(symbol_of_new_shop) && shop_rewrite == false
        return refill_limited_shop(symbol_of_new_shop, list_of_item_id, list_of_item_quantity)

      end
      @shop_list[symbol_of_new_shop] = {}
      list_of_item_id.each_with_index do |id, index|
        if GameData::Item[id].limited
          @shop_list[symbol_of_new_shop][id] = (list_of_item_quantity[index] != nil ? list_of_item_quantity[index] : 1)
        else
          @shop_list[symbol_of_new_shop][id] = 1
        end
      end
    end

    # Refill an already existing shop with items (Create the shop if it does not exist)
    # @param symbol_of_shop [Symbol] the symbol of the existing shop
    # @param list_item_id_to_refill [Array<Integer>] the array of the items' id
    # @param list_quantity_to_refill [Array<Integer>] the array of the quantity to refill
    def refill_limited_shop(symbol_of_shop, list_item_id_to_refill = [], list_quantity_to_refill = [])
      return unless shop_param_legit?(symbol_of_shop, list_item_id_to_refill, list_quantity_to_refill)

      if @shop_list.key?(symbol_of_shop)
        list_item_id_to_refill.each_with_index do |id, index|
          @shop_list[symbol_of_shop][id] = 0 unless @shop_list[symbol_of_shop].key?(id)
          if GameData::Item[id].limited
            @shop_list[symbol_of_shop][id] += (list_quantity_to_refill[index] != nil ? list_quantity_to_refill[index] : 1)
          else
            @shop_list[symbol_of_shop][id] = 1
          end
        end
      else # We create a shop if one do not already exist
        create_new_limited_shop(symbol_of_shop, list_item_id_to_refill, list_quantity_to_refill)
      end
    end

    # Remove items from an already existing shop (return if do not exist)
    # @param symbol_of_shop [Symbol] the symbol of the existing shop
    # @param list_item_id_to_remove [Array<Integer>] the array of the items' id
    # @param list_quantity_to_remove [Array<Integer>] the array of the quantity to remove
    def remove_from_limited_shop(symbol_of_shop, list_item_id_to_remove, list_quantity_to_remove)
      return unless shop_param_legit?(symbol_of_shop, list_item_id_to_remove, list_quantity_to_remove)
      return unless @shop_list.key?(symbol_of_shop)

      list_item_id_to_remove.each_with_index do |id, index|
        next unless @shop_list[symbol_of_shop].key?(id)

        @shop_list[symbol_of_shop][id] -= (list_quantity_to_remove[index].nil? ? 999 : list_quantity_to_remove[index])
        @shop_list[symbol_of_shop].delete(id) if @shop_list[symbol_of_shop][id] <= 0
      end
    end

    # Check the legitimity of the parameters
    # @param symbol_of_shop [Symbol]
    # @param list_item_id_to_remove [Array<Integer>]
    # @param list_quantity_to_remove [Array<Integer>]
    # @return [Boolean] return true if all params are legit
    def shop_param_legit?(symbol, arr1, arr2)
      validate_param(:shop_param_legit?, :symbol, symbol => Symbol)
      validate_param(:shop_param_legit?, :arr1, arr1 => { Array => Integer })
      validate_param(:shop_param_legit?, :arr2, arr2 => { Array => Integer })
      return true
    end

    # Create a new Pokemon Shop
    # @param sym_new_shop [Symbol] the symbol to link to the new shop
    # @param list_id_mon [Array<Integer>] the array containing the id of the Pokemon to sell
    # @param list_param_mon [Array] the array containing the infos of the Pokemon to sell
    # @param list_price [Array<Integer>] the array containing the prices of the Pokemon to sell
    # @param list_quantity_mon [Array<Integer>] the array containing the quantity of the Pokemon to sell
    # @param shop_rewrite [Boolean] if the system must completely overwrite an already existing shop
    def create_new_pokemon_shop(sym_new_shop, list_id_mon, list_price, list_param_mon, list_quantity_mon = [],
                                shop_rewrite: false)
      return unless mon_shop_param_legit?(sym_new_shop,
                                          list_id: list_id_mon,
                                          list_param: list_param_mon,
                                          list_price: list_price,
                                          list_quantity: list_quantity_mon)

      if @pokemon_shop_list.key?(sym_new_shop) && shop_rewrite
        @pokemon_shop_list.delete(sym_new_shop)
      elsif @pokemon_shop_list.key?(sym_new_shop) && shop_rewrite == false
        return refill_pokemon_shop(sym_new_shop, list_id_mon, list_param_mon, list_price, list_quantity_mon)
      end

      @pokemon_shop_list[sym_new_shop] = []

      list_id_mon.each_with_index do |id, index|
        register_new_pokemon_in_shop(sym_new_shop, id, list_price[index], list_param_mon[index], list_quantity_mon[index])
      end
      sort_pokemon_shop(sym_new_shop)
    end

    # Refill an already existing Pokemon Shop (create it if it does not exist)
    # @param symbol_of_shop [Symbol] the symbol of the shop
    # @param list_id_mon [Array<Integer>] the array containing the id of the Pokemon to sell
    # @param list_param_mon [Array] the array containing the infos of the Pokemon to sell
    # @param list_price [Array<Integer>] the array containing the prices of the Pokemon to sell
    # @param list_quantity_mon [Array<Integer>] the array containing the quantity of the Pokemon to sell
    def refill_pokemon_shop(symbol_of_shop, list_id_mon = [], list_price = [], list_param_mon = [], list_quantity_mon = [], pkm_rewrite: false)
      return unless mon_shop_param_legit?(symbol_of_shop,
                                          list_id: list_id_mon,
                                          list_param: list_param_mon,
                                          list_price: list_price,
                                          list_quantity: list_quantity_mon)

      if @pokemon_shop_list.key?(symbol_of_shop)
        list_id_mon.each_with_index do |id, index|
          register_new_pokemon_in_shop(symbol_of_shop, id, list_price[index], list_param_mon[index],
                                       list_quantity_mon[index], rewrite: pkm_rewrite)
        end
        sort_pokemon_shop(symbol_of_shop)
      else # We create a shop if one do not already exist
        create_new_pokemon_shop(symbol_of_shop, list_id_mon, list_price, list_param_mon, list_quantity_mon)
      end
    end

    # Remove Pokemon from an already existing shop (return if do not exist)
    # @param symbol_of_shop [Symbol] the symbol of the existing shop
    # @param list_item_id_to_remove [Array<Integer>] the array of the Pokemon id
    # @param param_form [Array<Hash>] the form of the Pokemon to delete (only if there is more than one form of a Pokemon in the list)
    # @param list_quantity_to_remove [Array<Integer>] the array of the quantity to remove
    def remove_from_pokemon_shop(symbol_of_shop, remove_list_mon, param_form = [], list_quantity_to_remove = [])
      return unless mon_shop_param_legit?(symbol_of_shop,
                                          list_id: remove_list_mon,
                                          list_param: param_form,
                                          list_quantity: list_quantity_to_remove)
      return unless @pokemon_shop_list.key?(symbol_of_shop)

      pkm_list = @pokemon_shop_list[symbol_of_shop]
      remove_list_mon.each_with_index do |id, index|
        form = param_form[index].is_a?(Hash) ? param_form[index][:form].to_i : 0
        result = pkm_list.find_index { |hash| hash[:id] == id && hash[:form].to_i == form }
        next unless result

        pkm_list[result][:quantity] -= (list_quantity_to_remove[index].nil? ? 999 : list_quantity_to_remove[index])
        pkm_list.delete_at(result) if pkm_list[result][:quantity] <= 0
      end
      @pokemon_shop_list[symbol_of_shop] = pkm_list
      sort_pokemon_shop(symbol_of_shop)
    end

    # Register the Pokemon into the Array under certain conditions
    # @param sym_shop [Symbol] the symbol of the shop
    # @param id [Integer] the ID of the Pokemon to register
    # @param price [Integer] the price of the Pokemon
    # @param param [Hash] the hash of the Pokemon (might be a single Integer)
    # @param quantity [Integer] the quantity of the Pokemon to register
    # @param rewrite [Boolean] if an existing Pokemon should be rewritten or not
    def register_new_pokemon_in_shop(sym_shop, id, price, param, quantity, rewrite: false)
      param = { level: param } if param.is_a?(Integer) # <= param is always hash from here @Rey
      index_condition = proc { |hash| hash[:id] == id && hash[:form].to_i == param[:form].to_i }

      if (result = @pokemon_shop_list[sym_shop].index(&index_condition)) && rewrite
        @pokemon_shop_list[sym_shop].delete_at(result)
      elsif (result = @pokemon_shop_list[sym_shop].index(&index_condition))
        return @pokemon_shop_list[sym_shop][result][:quantity] += quantity || 1
      end

      hash_pkm = param.dup
      hash_pkm[:id] = id
      hash_pkm[:price] = price
      hash_pkm[:quantity] = quantity || 1

      @pokemon_shop_list[sym_shop] << hash_pkm
    end

    # Sort the Pokemon Shop list
    # @param symbol_of_shop [Symbol] the symbol of the shop to sort
    def sort_pokemon_shop(symbol_of_shop)
      @pokemon_shop_list[symbol_of_shop].sort_by! { |hash| [hash[:id], hash[:form].to_i] }
    end

    # Check the legitimity of the parameters
    # @param sym[Symbol]
    # @param list_id [Array<Integer>]
    # @param list_param [Array]
    # @param list_price [Array<Integer>]
    # @param list_quantity_to_remove [Array<Integer>]
    # @return [Boolean] return true if all params are legit
    def mon_shop_param_legit?(sym, list_id: nil, list_param: nil, list_price: nil, list_quantity: nil)
      validate_param(:mon_shop_param_legit?, :sym, sym => Symbol)
      validate_param(:mon_shop_param_legit?, :list_id, list_id => { Array => Integer }) if list_id
      validate_param(:mon_shop_param_legit?, :list_param, list_param => Array) if list_param
      validate_param(:mon_shop_param_legit?, :list_price, list_price => { Array => Integer }) if list_price
      validate_param(:mon_shop_param_legit?, :list_quantity, list_quantity => { Array => Integer }) if list_quantity
      return true
    end
  end

  class Pokemon_Party
    # The list of the limited shops
    # @return [PFM::Shop]
    attr_accessor :shop
    on_player_initialize(:shop) { @shop = PFM::Shop.new }
    on_expand_global_variables(:shop) do
      # Variable containing the limited shops information
      @shop ||= PFM::Shop.new
      # Migration of old saves
      @shop.pokemon_shop_list ||= {}
    end
  end
end
