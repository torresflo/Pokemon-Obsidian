module GamePlay
  class Shop
    include UI::Shop

    # Create the different graphics for the UI
    def create_graphics
      super()
      unless @force_close
        create_base_ui if @show_background
        create_money_window
        create_shop_banner
        create_item_list
        create_arrow
        create_item_desc_window
        create_scrollbar
      end
    end

    # Update the graphics every frame
    def update_graphics
      unless @force_close
        @base_ui.update_background_animation if @show_background
        @animation&.call
        update_arrow
      end
    end

    # Create the generic background for the UI
    def create_base_ui
      @base_ui = UI::GenericBase.new(@viewport, hide_background_and_button: true)
    end

    # Create the money window showing the player money
    def create_money_window
      @gold_window = MoneyWindow.new(@viewport)
      update_money_text
    end

    # Update the money the player has
    def update_money_text
      @gold_window.text = parse_text(11, 9, NUM7R => $pokemon_party.money.to_s)
    end

    # Create the banner spelling "shop" in different languages
    def create_shop_banner
      @banner = ShopBanner.new(@viewport)
    end

    # Create the item list for the items to sell
    def create_item_list
      @item_list = ItemList.new(@viewport)
      update_item_button_list
    end

    # Update the item list
    def update_item_button_list
      @item_list.item_list = @list_item
      @item_list.item_price = @list_price
      @item_list.index = @index
    end

    # Create the selection arrow
    def create_arrow
      @arrow = Arrow.new(@viewport)
    end

    # Update the selection arrow animation
    def update_arrow
      @arrow.update
    end

    # Create the item description window
    def create_item_desc_window
      @item_desc_window = ItemDesc.new(@viewport)
      update_item_desc
    end

    # Method that calls all the informations updating method of the description window
    def update_item_desc
      update_item_desc_name(GameData::Item[@list_item[@index]].name)
      update_item_desc_text(GameData::Item[@list_item[@index]].descr)
      update_nb_item($bag.item_quantity(@list_item[@index]))
      update_in_stock_item(@item_quantity[@index]) if @item_quantity != []
    end

    # Update the name of the item currently shown
    def update_item_desc_name(name)
      @item_desc_window.name = name
    end

    # Update the description of the item currently shown
    def update_item_desc_text(text)
      @item_desc_window.text = text
    end

    # Update the number of the actual item possessed by the player
    def update_nb_item(nb)
      @item_desc_window.nb_item = nb
    end

    # Update the number of the actual item currently in stock
    def update_in_stock_item(nb)
      @item_desc_window.nb_in_stock = nb
    end

    # Create the scrollbar
    def create_scrollbar
      @scroll_bar = ScrollBar.new(@viewport)
      update_scrollbar
    end

    # Update the scrollbar's max index information
    def update_scrollbar
      @scroll_bar.max_index = @last_index
    end
  end
end
