module UI
  # Class that show the sprite of a key
  class KeyShortcut < Sprite
    # Create a new KeyShortcut sprite
    # @param viewport [Viewport]
    # @param key [Symbol, Integer] Input.trigger? argument (or Keyboard exact key if integer)
    # @param red [Boolean] pick the red texture instead of the blue texture
    def initialize(viewport, key, red = false)
      super(viewport)
      set_bitmap(red ? 'Key_ShortRed' : 'Key_Short', :pokedex)
      key.is_a?(Symbol) ? find_key(key) : show_key(key)
    end
    # KeyIndex that holds the value of the Keyboard constants in the right order according to the texture
    KeyIndex = %i[A B C D E F G H I J
                  K L M N O P Q R S T
                  U V W X Y Z Num0 Num1 Num2 Num3
                  Num4 Num5 Num6 Num7 Num8 Num9 Space Backspace Enter LShift
                  LControl LAlt Escape Left Right Up Down].collect(&Input::Keyboard.method(:const_get))
    kbd = Input::Keyboard
    # KeyIndex for the NumPad Keys
    NUMPAD_KEY_INDEX = [
      -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
      -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
      -1, -1, -1, -1, -1, -1, kbd::Numpad0, kbd::Numpad1, kbd::Numpad2, kbd::Numpad3,
      kbd::Numpad4, kbd::Numpad5, kbd::Numpad6, kbd::Numpad7, kbd::Numpad8, kbd::Numpad9, -1, -1, -1, kbd::RShift,
      kbd::RControl, kbd::RAlt, -1, -1, -1, -1, -1
    ]
    # Find the key rect in the Sprite according to the input key requested
    # @param key [Symbol] the Virtual Input Key.
    def find_key(key)
      key_array = Input::Keys[key]
      key_array.each do |i|
        if (id = KeyIndex.index(i) || NUMPAD_KEY_INDEX.index(i))
          return set_rect_div(id % 10, id / 10, 10, 5)
        end
      end
      set_rect_div(9, 4, 10, 5) # A blank key
    end

    # Show the exact key (when key from initialize was an interger)
    def show_key(key)
      id = KeyIndex.index(key) || NUMPAD_KEY_INDEX.index(key) || 49
      set_rect_div(id % 10, id / 10, 10, 5)
    end
  end

  # Class that allow to show a binding of a specific key
  class KeyBinding < KeyShortcut
    # @return [Symbol] the key the button describe
    attr_reader :key
    # @return [Integer] the index of the key in the Keys[key] array
    attr_reader :index
    # Create a new KeyBinding sprite
    # @param viewport [Viewport]
    # @param key [Symbol] Input.trigger? argument
    # @param index [Integer] Index of the key in the Keys constant
    def initialize(viewport, key, index)
      @index = index
      @key = key
      super(viewport, key, false)
    end

    # Find the key rect in the Sprite according to the input key requested
    # @param key [Symbol] the Virtual Input Key.
    def find_key(key)
      key_val = Input::Keys[key][@index] || -1
      if (id = KeyIndex.index(key_val) || NUMPAD_KEY_INDEX.index(key_val))
        return set_rect_div(id % 10, id / 10, 10, 5)
      end
      set_rect_div(9, 4, 10, 5) # A blank key
    end

    # Update the key
    def update
      find_key(@key)
    end
  end

  # Class that allow to show a binding of a specific key on the Joypad
  class JKeyBinding < Sprite
    # @return [Symbol] the key the button describe
    attr_reader :key
    # Create a new KeyBinding sprite
    # @param viewport [Viewport]
    # @param key [Symbol] Input.trigger? argument
    def initialize(viewport, key)
      super(viewport)
      @key = key
      set_bitmap('key_short_xbox', :pokedex)
      find_key(key)
    end
    # KeyIndex that holds the value of the key value in the order of the texture
    KeyIndex = [
      0, 1, 2, 3, 13, 15, 12, 14,
      8, 9, 4, 5, 6, 7, 10, 11
    ]
    # Find the key rect in the Sprite according to the input key requested
    # @param key [Symbol] the Virtual Input Key.
    def find_key(key)
      key_val = Input::Keys[key].last
      if key_val && key_val < 0
        key_val = (key_val.abs - 1) % 32
        if (id = KeyIndex.index(key_val))
          return set_rect_div(id % 8, id / 8, 8, 5)
        end
      end
      set_rect_div(0, 4, 8, 5) # A blank key
    end

    # Update the key
    def update
      find_key(@key)
    end

    # Return the index of the key in the Keys[key] array
    # @return [Integer]
    def index
      return Input::Keys[key].size - 1
    end
  end
end
