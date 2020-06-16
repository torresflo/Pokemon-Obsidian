module UI
  module Shop
    class PkmList < Array
      # Number of button in the list
      AMOUNT = 4
      # Offset between each button
      BUTTON_OFFSET = 38
      # Offset between active button & inative button
      ACTIVE_OFFSET = -14
      # Base X coordinate
      BASE_X = 128
      # Base Y coordinate
      BASE_Y = 30
      # @return [Integer] index of the current active item
      attr_reader :index
      # Create a new ButtonList
      # @param viewport [Viewport] viewport in which the SpriteStack will be displayed
      def initialize(viewport)
        super(AMOUNT) do |i|
          ListButtonPkm.new(viewport, i)
        end
        @item_list = []
        @name_list = []
        @price_list = []
        @index = 0
      end

      # Update the animation
      def update
        return unless @animation

        send(@animation)
        @counter += 1
      end

            # Test if the animation is done
      # @return [Boolean]
      def done?
        @animation.nil?
      end

      # Set the current active item index
      # @param index [Integer]
      def index=(index)
        @index = index.clamp(0, @item_list.size - 1)
        update_button_texts
        update_button_price
        update_button_icon
      end

      # Move all the buttons up
      def move_up
        @animation = :move_up_animation
        @counter = 0
      end

      # Move all the buttons down
      def move_down
        @animation = :move_down_animation
        @counter = 0
      end

      # Set the item list
      # @param list [Array<Integer>]
      def item_list=(list)
        @item_list = list
        @name_list = @item_list.collect { |hash| GameData::Pokemon[hash[:id]].name }
      end

      # Set the price list
      # @param list [Array<Integer>]
      def item_price=(list)
        @price_list = list
      end

      # Return the delta index with mouse position
      # @return [Integer]
      def mouse_delta_index
        mouse_index = find_index(&:simple_mouse_in?)
        return 0 unless mouse_index

        active_index = find_index(&:active?) || 0
        return mouse_index - active_index
      end

      private

      # Move up animation
      def move_up_animation
        each { |button| button.move(0, -BUTTON_OFFSET / 3) } if @counter < 2
        if @counter == 3
          rotate!
          each_with_index do |button, index|
            button.index = index
            button.reset
          end
          @index += 1
          update_button_price
          update_button_icon
          last.text = button_name(start_index + size - 1)
          @animation = nil
        end
      end

      # Move down animation
      def move_down_animation
        if @counter < 2
          was_active = false
          each do |button|
            dx = was_active ? -3 : 0
            button.move(button.active? ? 3 : dx, BUTTON_OFFSET / 3)
          end
        end
        if @counter == 3
          rotate!(-1)
          each_with_index do |button, index|
            button.index = index
            button.reset
          end
          @index -= 1
          update_button_price
          update_button_icon
          first.text = button_name(start_index)
          @animation = nil
        end
      end

      # Update the buttons texts
      def update_button_texts
        index = start_index
        each do |button|
          button.text = button_name(index)
          index += 1
        end
      end

      # Update the buttons price
      def update_button_price
        index = start_index
        each do |button|
          button.price = button_price(index)
          index += 1
        end
      end

      # Update the buttons icon
      def update_button_icon
        index = start_index
        each do |button|
          button.icon_data = @item_list[index]
          index += 1
        end
      end

      # Get the button name
      # @param index [Integer]
      # @return [String, nil]
      def button_name(index)
        index < 0 ? nil : @name_list[index]
      end

      # Get the button name
      # @param index [Integer]
      # @return [String, nil]
      def button_price(index)
        index < 0 ? nil : @price_list[index]
      end

      # Return the start index of the list
      # @return [Integer]
      def start_index
        @index - 1
      end

      class ListButtonPkm < SpriteStack
        # @return [Integer] Index of the button in the list
        attr_accessor :index

        # Create a new Item sell button
        # @param viewport [Viewport] the viewport in which the SpriteStack will be displayed
        # @param index [Integer]
        def initialize(viewport, index)
          @index = index
          super(viewport, BASE_X + (active? ? ACTIVE_OFFSET : 0), BASE_Y + BUTTON_OFFSET * index)
          add_background('shop/button_list').set_z(1)
          @item_name = add_text(37, 8, 92, 18, nil.to_s, 1, color: 10)
          @item_name.z = 2
          @item_price = add_text(133, 8, 37, 17, nil.to_s, 2, color: 0)
          @item_price.draw_shadow = false
          @item_price.z = 2
          @item_icon = add_sprite(2, 0, false, NO_INITIAL_IMAGE, type: PokemonIconSprite)
          @item_icon.z = 3
        end

        # Is the button active
        def active?
          @index == 1
        end

        # Set the button text
        # @param text [String, nil] the item name
        def text=(text)
          return unless (self.visible = !text.nil?)

          @item_name.text = text
        end

        def price=(text)
          return unless (self.visible = !text.nil?)

          @item_price.text = text[:price].to_s
        end

        # Set the item icon
        # @param icon [Hash] the Pokemon hash for the icon
        def icon_data=(pkm_hash)
          if self.visible == false
            @item_icon.set_bitmap(nil)
          else
            @item_icon.data=(PFM::Pokemon.generate_from_hash(pkm_hash))
          end
        end

        # Reset the button coordinate
        def reset
          set_position(BASE_X + (active? ? ACTIVE_OFFSET : 0), BASE_Y + BUTTON_OFFSET * index)
        end
      end
    end
  end
end
