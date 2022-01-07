module GamePlay
  class Pokemon_Shop < Shop
    # Create a new Pokemon Shop
    # @overload initialize(symbol_shop)
    #   @param symbol_shop [Symbol] the symbol of the pokemon shop to open
    # @overload initialize(symbol_shop, prices)
    #   @param symbol_shop [Symbol] the symbol of the pokemon shop to open
    #   @param prices [Hash] the hash containing the new price (value) of a pokemon id (key)
    # @overload initialize(list_id_pokemon, prices, parameters)
    #   @param list_id_pkm [Array] the array containing the id of the pokemon to sell
    #   @param prices [Array] the array containing the price of each pokemon
    # @example Opening an already defined shop with limited Pokemon
    #   GamePlay::Pokemon_Shop.new(:pkm_shop_celadon) # Will open the Shop with symbol :pkm_shop_celadon (the shop must be already defined beforehand)
    # @example Opening an already defined shop with limited pokemon but with temporarily overwritten price
    #   GamePlay::Pokemon_Shop.new(:pkm_shop_celadon, {17: 300, 25: 3000}) # Will open the Shop with symbol :pkm_shop_celadon while overwritting the price for pokemon with ID 17 or 25
    # @example Opening a simple pokemon shop
    #   GamePlay::Pokemon_Shop.new([25, 52], [2500, 500], [50, { level: 15, form: 1 }]) # Will open a Shop selling Pikachu lvl 50 at 2500 P$ and Alolan Meowth lvl 15 at 500 P$
    def initialize(symbol_or_list, prices = {}, parameters = [], show_background: true)
      super(false)
      validate_param(:initialize, :symbol_or_list, symbol_or_list => [Symbol, Array])
      validate_param(:initialize, :symbol_or_list, symbol_or_list => { Array => Integer }) if symbol_or_list.class == Array
      if symbol_or_list.is_a?(Symbol)
        validate_param(:initialize, :prices, prices => Hash)
      else
        validate_param(:initialize, :prices, prices => Array)
      end
      validate_param(:initialize, :params, parameters => Array) if symbol_or_list.class == Array
      @force_close = nil
      @shop = PFM.game_state.shop
      @show_background = :show_background
      @symbol_or_list = symbol_or_list
      @prices = prices
      @parameters = parameters
      @what_was_buyed = []
      load_item_list
      unless @force_close == true
        @index = @index.clamp(0, @last_index)
        @running = true
      end
    end

    private

    # Launch the process that gets all lists
    def load_item_list
      @list_item = Array.new
      get_list_item
      get_definitive_list_price
      check_if_shop_empty
      @index = 0
      @last_index = @list_item.size - 1
    end
    alias reload_item_list load_item_list

    # Create the initial list from symbol_or_list
    def get_list_item
      if @symbol_or_list.is_a? Symbol
        if @shop.pokemon_shop_list.key?(@symbol_or_list)
          @list_item = @shop.pokemon_shop_list[@symbol_or_list]
        else
          raise 'Pokemon Shop with symbol :' + @symbol_or_list.to_s + ' must be created before calling it'
          @running = false
        end
      elsif @symbol_or_list.is_a? Array
        @symbol_or_list.each_with_index do |id, index|
          @list_item[index] = Hash.new
          @list_item[index][:id] = id
          @parameters[index].class == Hash ? @list_item[index].merge!(@parameters[index]) : @list_item[index][:level] = @parameters[index]
          @list_item[index][:price] = @prices[index].to_i != 0 ? @prices[index] : 0
        end
      end
      check_if_shop_empty
      @index = 0
      @last_index = @list_item.size - 1
    end

    # Get the definitive lists by checking the @price_overwrite variable
    def get_definitive_list_price
      temp_list_item = []
      price = 0
      @list_item.each_with_index do |hash, index|
        if @symbol_or_list.class == Symbol
          price = @prices.key?(hash[:id]) ? @prices[hash[:id]] : @list_item[index][:price]
        else
          price = @list_item[index][:price]
        end
        next if price <= 0
        @list_item[index][:price] = price
        temp_list_item << @list_item[index]
      end
      @list_item = temp_list_item
    end

    # Method that checks if the shop is empty, closing it if that's the case
    def check_if_shop_empty
      if @list_item.empty?
        $game_variables[::Yuki::Var::TMP1] = (@what_was_buyed.empty? ? -1 : 3)
        @force_close = true
        update_mouse(false)
      end
    end
  end
end

GamePlay.pokemon_shop_class = GamePlay::Pokemon_Shop
