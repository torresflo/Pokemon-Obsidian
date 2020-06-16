module GamePlay
  class Pokemon_Shop < Shop
    include UI::Shop

    # Update the graphics every frame
    def update_graphics
      unless @force_close
        @base_ui.update_background_animation if @show_background
        @animation&.call
        update_arrow
      end
    end

    # Create the item list for the items to sell
    def create_item_list
      @item_list = PkmList.new(@viewport)
      update_item_button_list
    end

    # Update the item list
    def update_item_button_list
      @item_list.item_list = @item_list.item_price = @list_item
      @item_list.index = @index
    end

    # Create the item description window
    def create_item_desc_window
      @item_desc_window = PkmDesc.new(@viewport)
      update_item_desc
    end

    # Method that calls all the informations updating method of the description window
    def update_item_desc
      update_item_desc_name(GameData::Pokemon[@list_item[@index][:id]].name)
      update_item_desc_text(@list_item[@index][:level])
      update_pkm_specie_text(GameData::Pokemon[@list_item[@index][:id]].species)
      update_in_stock_item(@list_item[@index][:quantity]) if @symbol_or_list.class == Symbol
    end

    # Update the name of the item currently shown
    def update_item_desc_name(name)
      @item_desc_window.name = name
    end

    # Update the description of the item currently shown
    def update_item_desc_text(text)
      @item_desc_window.text = text
    end

    def update_pkm_specie_text(species)
      @item_desc_window.species = species
    end

    # Update the number of the actual item currently in stock
    def update_in_stock_item(nb)
      @item_desc_window.nb_in_stock = nb
    end

    # Create the scrollbar
    def create_scrollbar
      @scroll_bar = PkmScrollBar.new(@viewport)
      update_scrollbar
    end

  end
end
