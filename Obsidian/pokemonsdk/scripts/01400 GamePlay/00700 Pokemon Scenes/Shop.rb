module GamePlay
  # UI displaying the item shop
  class Shop < Base
    # Name of the selector image
    SELECTOR_IMAGE = 'Bag_selector'
    # Name of the SE to play when an item is bought
    BUY_SE = 'Audio/SE/Nintendo'
    # Create a new Item Shop
    def initialize
      super()
      @viewport = Viewport.create(:main, 1000)
      @index = 0
      load_items
      create_gold_window
      create_item_window
      create_selector
      create_description_window
      @delta_y = 2 + current_window_builder[5]
      draw_item_list
      draw_descr
      @mode = 0
    end

    # Load the items to sell
    def load_items
      @goods = Array.new($game_temp.shop_goods.size) { |i| $game_temp.shop_goods[i][1] }
      @item_names = Array.new(@goods.size) { |i| ::GameData::Item.name(@goods[i]) }
      @item_prices = Array.new(@goods.size) { |i| parse_text(22, 159, NUM7R => ::GameData::Item.price(@goods[i]).to_s) }
    end

    # Update the scene
    def update
      @__last_scene.sprite_set_update if @__last_scene.respond_to?(:sprite_set_update)
      return unless super
      if update_inputs
        draw_item_list
        draw_descr
      end
    end

    # Update the input interactions
    # @return [Boolean] if the item list & description should be redrawn
    def update_inputs
      if index_changed(:@index, :UP, :DOWN, @goods.size)
        return true
      elsif Input.trigger?(:A)
        if @index < @goods.size
          buy_item(@goods[@index])
        else
          @running = false
        end
      elsif Input.trigger?(:B)
        @running = false
      end
      return false
    end

    # Procedure called when the player buys an item
    # @param item_id [Integer] ID of the item to buy
    def buy_item(item_id)
      if can_buy?(item_id)
        price = ::GameData::Item.price(item_id)
        return if amount_selection(price, item_id)
        quantity = $game_variables[::Yuki::Var::EnteredNumber]
        return if confirm_buy(price, item_id, quantity)
        # Update the player info
        $bag.add_item(item_id, quantity)
        $pokemon_party.lose_money(price * quantity)
        draw_gold_window
        Audio.se_play(BUY_SE)
        display_message(text_get(11, 29))
        buy_item_special_offer(item_id, quantity)
      else
        display_message(parse_text(11, 24))
      end
    end

    # Tell if the player can buy a specific item
    # @param item_id [Integer]
    def can_buy?(item_id)
      price = ::GameData::Item.price(item_id)
      return !(price == 0 || price > $pokemon_party.money)
    end

    # Make the player choose the amount of the item he wants to buy
    # @param price [Integer] price of the item
    # @param item_id [Integer] ID of the item
    # @return [Boolean] if the buy_item procedure should immediately exit
    def amount_selection(price, item_id)
      max_amount = $pokemon_party.money / price
      if (max = GameData::Bag::MaxItem) > 0
        max -= $bag.item_quantity(item_id)
        if max <= 0
          # Not enough space
          display_message(parse_text(11, 31))
          return true
        end
        max_amount = max if max < max_amount
      end
      $game_temp.num_input_variable_id = ::Yuki::Var::EnteredNumber
      $game_temp.num_input_digits_max = max_amount.to_s.size
      $game_temp.num_input_start = max_amount
      $game_temp.shop_calling = price
      # How much ?
      display_message(parse_text(11, 23, ITEM2[0] => ::GameData::Item.name(item_id)))
      return false
    end

    # Ask the player if he wants to buy the item
    # @param price [Integer] price of the item
    # @param item_id [Integer] ID of the item
    # @param quantity [Integer] number of item to buy
    # @return [Boolean] if the buy_item procedure should immediately exit
    def confirm_buy(price, item_id, quantity)
      if quantity > 0
        message = parse_text(11, 25,
                         ITEM2[0] => ::GameData::Item.name(item_id),
                         NUM2[1] => quantity.to_s, NUM7R => (quantity * price).to_s)
        # Would you like to buy x item for $y ? Yes / No
        c = display_message(message, 1, text_get(11, 27), text_get(11, 28))
        return c != 0
      end
      return true
    end

    # Execute the special offer of the shop when the player bough an item
    # @param item_id [Integer] ID of the item bought
    # @param quantity [Integer] Number of item bought
    def buy_item_special_offer(item_id, quantity)
      if item_id == 4 && quantity >= 10
        # Honnor ball gift
        display_message(text_get(11, 32))
        $bag.add_item(12, 1)
      end
    end

    # Draw the item description
    def draw_descr
      if @index < @goods.size
        item_id = @goods[@index]
        @icon_sprite.bitmap = RPG::Cache.icon(::GameData::Item.icon(item_id))
        @descr_text.multiline_text = GameData::Item.descr(item_id)
      else
        @descr_text.text = ' '
        @icon_sprite.bitmap = nil
      end
    end

    # Draw the item list
    def draw_item_list
      size = @goods.size
      ini_index = 0
      # initial index calibration
      if @index > 3
        if size > 8 && @index > (size - 4)
          ini_index = size - 7
        else
          ini_index = @index - 4
        end
      end
      cnt = -1
      # Draw the texts
      ini_index.step(ini_index + 10) do |i|
        cnt += 1
        @selector.y = @delta_y + cnt * 16 if i == @index
        @price_text[cnt].visible = @name_text[cnt].visible = (i < size)
        if i >= size
          if i == size
            @name_text[cnt].text = text_get(22, 7)
            @name_text[cnt].visible = true
          end
          next
        end
        @name_text[cnt].text = @item_names[i]
        @price_text[cnt].text = @item_prices[i]
      end
    end

    # Create the description Window
    def create_description_window
      @descr_window = Window.new(@viewport)
      @descr_window.lock
      @descr_window.set_size(@viewport.rect.width - 4, 48 + (current_window_builder[1] < 16 ? 16 : current_window_builder[1]))
      @descr_window.set_position(2, @viewport.rect.height - @descr_window.height - 2)
      @descr_window.windowskin = @gold_window.windowskin
      @descr_window.window_builder = @gold_window.window_builder
      @descr_window.unlock
      stack = UI::SpriteStack.new(@descr_window)
      @descr_text = stack.add_text(48, 0, 240, 16, ' ')
      @icon_sprite = stack.push(8, 8, nil)
    end

    # Create the selector sprite
    def create_selector
      @selector = Sprite.new(@viewport)
      @selector.x = @item_window.x + current_window_builder[0]
      @selector.set_bitmap(SELECTOR_IMAGE, :interface)
      @selector.src_rect.height = @selector.bitmap.height / 2
    end

    # Create the Item Window
    def create_item_window
      @item_window = Window.new(@viewport)
      @item_window.lock
      wb = @gold_window.window_builder
      @item_window.set_size(150 + (wb[0] < 16 ? 19 : wb[0]) * 2, 128 + (wb[1] < 16 ? 16 : wb[1]))
      @item_window.set_position(@viewport.rect.width - @item_window.width - 2, 2)
      @item_window.windowskin = @gold_window.windowskin
      @item_window.window_builder = @gold_window.window_builder
      @item_window.unlock

      item_stack = UI::SpriteStack.new(@item_window)
      @price_text = []
      @name_text = Array.new(11) do |cnt|
        @price_text << item_stack.add_text(6, cnt * 16, 138, 16, ' ', 2)
        item_stack.add_text(6, cnt * 16, 142, 16, ' ')
      end
    end

    # Create the Gold Window
    def create_gold_window
      @gold_window = Window.new(@viewport)
      @gold_window.lock
      wb = @gold_window.window_builder = current_window_builder
      @gold_window.set_position(2, 2)
      @gold_window.set_size(64 + (wb[0] < 16 ? 19 : wb[0]) * 2, 32 + (wb[1] < 16 ? 16 : wb[1]))
      @gold_window.windowskin = RPG::Cache.windowskin(current_windowskin)
      @gold_window.unlock
      stack = UI::SpriteStack.new(@gold_window)
      stack.add_text(0, 0, 64, 16, text_get(11, 6))
      @money_text = stack.add_text(0, 16, 62, 16, parse_text(11, 9, NUM7R => $pokemon_party.money.to_s), 2)
    end

    # Update the money of the Gold Window
    def draw_gold_window
      @money_text.text = parse_text(11, 9, NUM7R => $pokemon_party.money.to_s)
    end

    # Retrieve the current windowskin
    # @return [String]
    def current_windowskin
      $game_system.windowskin_name
    end

    # Retrieve the current window_builder
    # @return [Array]
    def current_window_builder
      return ::GameData::Windows::MessageHGSS if current_windowskin[0, 2] == 'm_' # SkinHGSS
      ::GameData::Windows::MessageWindow # Skin PSDK
    end

    def create_graphics
      # Skipped to prevent glitches
    end
  end
end
