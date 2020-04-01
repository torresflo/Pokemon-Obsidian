module GamePlay
  class Bag
    include UI::Bag
    # List of button text according to the mode
    CTRL_TEXTS_PER_MODE = {
      menu: [
        [:ext_text, 9000, 152], # Action
        info = [:ext_text, 9000, 153], # Info
        sort = [:ext_text, 9000, 154], # Sort
        [:ext_text, 9000, 115]  # Quit
      ],
      battle: [
        [:ext_text, 9000, 159], # Use
        info, sort,
        cancel = [:ext_text, 9000, 17] # Cancel
      ],
      berry: [
        [:ext_text, 9000, 156], # Plant
        info, sort, cancel
      ],
      hold: [
        [:ext_text, 9000, 157], # Give
        info, sort, cancel
      ],
      shop: [
        [:ext_text, 9000, 155], # Sell
        info, sort, cancel
      ],
      map: [
        [:ext_text, 9000, 158], # Choose
        info, sort, cancel
      ]
    }
    CTRL_TEXTS_PER_MODE.default = CTRL_TEXTS_PER_MODE[:menu]

    def update_graphics
      @base_ui.update_background_animation
      @animation&.call
      update_arrow
    end

    private

    # Create all the graphics for the UI
    def create_graphics
      create_viewport
      create_base_ui
      create_pocket_ui
      create_scroll_bar
      create_bag_sprite
      create_item_list
      create_arrow
      create_info
      create_shadow
      create_search
      create_frame # Should always be last
    end

    # Create the base ui
    def create_base_ui
      @base_ui = UI::GenericBase.new(@viewport, button_texts)
    end

    # Fetch the button text
    # @return [Array<String>]
    def button_texts
      CTRL_TEXTS_PER_MODE[@mode].collect { |data| get_text(data) }
    end

    # Create the frame
    def create_frame
      @frame = Sprite.new(@viewport)
      filename = "bag/overlay_#{$options.language}"
      filename = 'bag/overlay_en' unless RPG::Cache.interface_exist?(filename)
      @frame.set_bitmap(filename, :interface).set_z(32)
    end

    # Create the pocket UI
    def create_pocket_ui
      @pocket_ui = PocketList.new(@viewport, @pocket_indexes)
      @pocket_ui.index = @socket_index
      @pocket_name = WinPocket.new(@viewport)
      update_pocket_name
    end

    # Update the pocket name
    def update_pocket_name
      @pocket_name.text = @pocket_names[@socket_index]
    end

    # Create the scroll bar
    def create_scroll_bar
      @scroll_bar = ScrollBar.new(@viewport)
      update_scroll_bar
    end

    # Update the scroll bar max index
    def update_scroll_bar
      @scroll_bar.max_index = @last_index
    end

    # Create the bag sprite
    def create_bag_sprite
      @bag_sprite = BagSprite.new(@viewport, @pocket_indexes)
      @bag_sprite.index = @socket_index
    end

    # Create the item list
    def create_item_list
      @item_button_list = ButtonList.new(@viewport)
      update_item_button_list
    end

    # Update the item list
    def update_item_button_list
      @item_button_list.item_list = @item_list
      @item_button_list.index = @index
    end

    # Create the arrow
    def create_arrow
      @arrow = Arrow.new(@viewport)
    end

    # Update the arrow
    def update_arrow
      @arrow.update
    end

    # Create the info
    def create_info
      @info_compact = InfoCompact.new(@viewport, @mode)
      @info_wide = InfoWide.new(@viewport, @mode)
      update_info_visibility
      update_info
    end

    # Update the visibility of info box according to the mode
    def update_info_visibility
      compact = @compact_mode == :enabled
      @info_compact.visible = compact
      @info_wide.visible = !compact
      @bag_sprite.index = @socket_index
      @bag_sprite.visible = compact
    end

    # Update the info shown in the info box
    def update_info
      if @compact_mode == :enabled
        @info_compact.show_item(@item_list[@index])
      else
        @info_wide.show_item(@item_list[@index])
      end
    end

    # Create the shadow helping to focus on the important thing
    def create_shadow
      @shadows = {
        enabled: Sprite.new(@viewport).set_bitmap('bag/selec_compact_shadow', :interface).set_z(3),
        disabled: Sprite.new(@viewport).set_bitmap('bag/selec_wide_shadow', :interface).set_z(3)
      }
      @shadows.each_value { |sprite| sprite.visible = false }
    end

    # Show the shadow
    def show_shadow_frame
      @shadows[@compact_mode]&.visible = true
    end

    # Hide the shadow
    def hide_shadow_frame
      @shadows[@compact_mode]&.visible = false
    end

    # Create the search bar
    def create_search
      @search_bar = SearchBar.new(@viewport)
      @search_bar.visible = false
      @search_bar.search_input.init(25, '', on_new_char: method(:search_add), on_remove_char: method(:search_rem))
    end
  end
end
