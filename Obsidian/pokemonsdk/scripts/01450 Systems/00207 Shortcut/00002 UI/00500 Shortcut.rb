module UI
  # UI component that shows a shortcut item
  class ShortcutElement < SpriteStack
    # Offset Y to prevent UI element to overlap with BaseUI
    OFFSET_Y = 28
    # @return [Integer] Index of the button in the list
    attr_accessor :index

    # Create a new Item sell button
    # @param viewport [Viewport] the viewport in which the SpriteStack will be displayed
    # @param index [Integer] index used to align the element in the UI
    # @param item_id [Integer, Symbol] ID of the item to show
    # @param key [Symbol] the key the player has to press
    def initialize(viewport, index, item_id, key)
      super(viewport)
      @index = index
      @data = item_id
      @key = key
      create_background
      adjust_position(self[0])
      create_item_name
      create_quantity
      create_key
      create_icon
    end

    private

    def create_background
      add_background('shop/button_list')
    end

    def create_item_name
      add_text(37, 8, 92, 18, GameData::Item[@data].exact_name, 1, color: 10)
    end

    def create_quantity
      return if @data == 0 || @data == :__undef__

      add_text(130, 8, 38, 16, "ｘ#{$bag.item_quantity(@data)}".to_pokemon_number, 2, 0, color: 0)
    end

    def create_key
      add_sprite(168, 9, nil, @key, type: KeyShortcut)
    end

    def create_icon
      return if @data == 0 || @data == :__undef__

      add_sprite(3, 2, NO_INITIAL_IMAGE, type: ItemSprite).data = @data
    end

    def adjust_position(background)
      move((@viewport.rect.width - background.width) / 2, @viewport.rect.height - (background.height + 2) * @index - OFFSET_Y)
    end
  end
end
