module UI
  class NameInputUI < Window
    # Return the chars the user has inserted
    # @return [Array<String>]
    attr_reader :chars
    # Character used to indicate there's no char there
    NO_CHAR = '_'
    # Create a new NameInputUI
    # @param viewport [Viewport]
    # @param max_size [Integer] maximum size of the name
    # @param chars [Array<String>] chars initialize there
    # @param character [PFM::Pokemon, String, nil] the character to display
    # @param phrase [String] the phrase to display in order to justify the name input
    def initialize(viewport, max_size, chars, character, phrase)
      super(viewport, *window_parameters, skin: default_windowskin)
      @character = character
      @phrase = phrase
      @chars = chars
      @index = 0
      @max_size = max_size
      create_graphics
      @counter = 0
    end

    def add_char(char)
      return if @chars.size >= @max_size
      @chars.push(char)
      refresh_chars
    end

    def remove_char
      @chars.pop
      refresh_chars
    end

    def update
      @counter += 1
      if @counter == 30
        @inputs[@chars.size]&.visible = false
      elsif @counter == 60
        @inputs[@chars.size]&.visible = true
        @counter = 0
      end
      @character_sprite&.update
    end

    private

    # Return the default window parameters (x, y, width, height)
    # @return [Array<Integer>]
    def window_parameters
      [2, 2, 316, 64]
    end

    # Return the default windowskin
    # @return [String]
    def default_windowskin
      DEFAULT_SKIN
    end

    # Create the graphics inside the window
    def create_graphics
      create_character_sprite
      create_phrase
      create_inputs
      refresh_chars
    end

    # Create the character sprite
    def create_character_sprite
      if @character.is_a?(PFM::Pokemon)
        @character_sprite = PokemonIconSprite.new(self, false)
        @character_sprite.data = @character
      elsif @character.is_a?(String)
        @character_sprite = Sprite.new(self)
        @character_sprite.set_bitmap(@character, :character)
        @character_sprite.src_rect.set(nil, nil, @character_sprite.width / 4, @character_sprite.height / 4)
      else
        return
      end
      @character_sprite.set_position(*character_sprite_position)
      @character_sprite.set_origin(@character_sprite.width / 2, @character_sprite.height)
    end

    def character_sprite_position
      return 16, base_y + 2 * delta_y
    end

    # Create the phrase texte
    def create_phrase
      @phrase_text = add_text(base_x, base_y, 0, 16, @phrase)
    end

    # Create the text inputs elements
    def create_inputs
      @inputs = Array.new(@max_size) do |i|
        add_text(base_x + i * delta_x, base_y + delta_y, delta_x, delta_y, NO_CHAR, 1)
      end
    end

    def base_x
      40
    end

    def delta_x
      8
    end

    def base_y
      8
    end

    def delta_y
      16
    end

    def refresh_chars
      @inputs.each_with_index do |input, index|
        input.text = chars[index] || NO_CHAR
        input.visible = true
      end
      @counter = 0
    end
  end
end
