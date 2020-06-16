module UI
  module Bag
    # List of button showing the item name
    class ButtonList < Array
      # Number of button in the list
      AMOUNT = 9
      # Offset between each button
      BUTTON_OFFSET = 25
      # Offset between active button & inative button
      ACTIVE_OFFSET = -8
      # Base X coordinate
      BASE_X = 191
      # Base Y coordinate
      BASE_Y = 18
      # @return [Integer] index of the current active item
      attr_reader :index
      # Create a new ButtonList
      def initialize(viewport)
        super(AMOUNT) do |i|
          ItemButton.new(viewport, i)
        end
        @item_list = []
        @name_list = []
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
        @index = index.clamp(0, @item_list.size)
        update_button_texts
      end

      # Move all the button up
      def move_up
        @animation = :move_up_animation
        @counter = 0
      end

      # Move all the button down
      def move_down
        @animation = :move_down_animation
        @counter = 0
      end

      # Set the item list
      # @param list [Array<Integer>]
      def item_list=(list)
        @item_list = list
        @name_list = @item_list.collect { |id| GameData::Item[id].exact_name }
        @name_list << text_get(22, 7)
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
          first.text = button_name(start_index)
          @animation = nil
        end
      end

      # Update the button texts
      def update_button_texts
        index = start_index
        each do |button|
          button.text = button_name(index)
          index += 1
        end
      end

      # Get the button name
      # @param index [Integer]
      # @return [String, nil]
      def button_name(index)
        index < 0 ? nil : @name_list[index]
      end

      # Return the start index of the list
      # @return [Integer]
      def start_index
        @index - 2
      end

      # Button showing the item name
      class ItemButton < SpriteStack
        # Name of the button background
        BACKGROUND = 'bag/button_list'
        # @return [Integer] Index of the button in the list
        attr_accessor :index

        # Create a new Item button
        # @param viewport [Viewport]
        # @param index [Integer]
        def initialize(viewport, index)
          @index = index
          super(viewport, BASE_X + (active? ? ACTIVE_OFFSET : 0), BASE_Y + BUTTON_OFFSET * index)
          create_background
          @item_name = create_text
        end

        # Is the button active
        def active?
          @index == 2
        end

        # Set the button text
        # @param text [String, nil] the item name
        def text=(text)
          return unless (self.visible = !text.nil?)

          @item_name.text = text
        end

        # Reset the button coordinate
        def reset
          set_position(BASE_X + (active? ? ACTIVE_OFFSET : 0), BASE_Y + BUTTON_OFFSET * index)
        end

        private

        # Create the background of the button
        def create_background
          add_background(BACKGROUND).set_z(1)
        end

        # Create the text
        # @return [LiteRGSS::Text]
        def create_text
          text = add_text(7, 4, 0, 13, nil.to_s, color: 10)
          text.z = 2
          return text
        end
      end
    end
  end
end
