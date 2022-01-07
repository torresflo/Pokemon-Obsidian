module UI
  # UI element showing input number (for number choice & selling)
  class InputNumber < SpriteStack
    # Image used as source for the UI build
    IMAGE_SOURCE = 'numin_bg'
    # List of coordinates used to know how to build the UI from the image
    IMAGE_COMPOSITION = {
      left: [0, 0, 33, 44],
      number: [33, 0, 24, 44],
      separator: [57, 0, 6, 44],
      right: [83, 0, 10, 44],
      money_add: [94, 0, 68, 44]
    }
    # Padding for money text
    MONEY_PADDING = 2
    # Minimum value
    # @return [Integer]
    attr_accessor :min
    # Maximum value
    # @return [Integer]
    attr_accessor :max
    # Currently inputed number
    # @return [Integer]
    attr_reader :number

    # Create a new Input number
    # @param viewport [Viewport]
    # @param max_digits [Integer] maximum number of digit
    # @param default_number [Integer] default number
    # @param accept_negatives [Boolean] if we can provide negative values
    def initialize(viewport, max_digits, default_number = 0, accept_negatives = false)
      super(viewport)
      @max_digits = max_digits
      @accept_negatives = accept_negatives
      @digit_index = 0
      @max = (10**@max_digits) - 1
      @min = accept_negatives ? -@max : 0
      # @type [Array<Sprite>]
      @width_accounting_sprites = []
      # @type [Array<Text>]
      @texts = []
      create_sprites
      self.number = default_number
      @default_number = @number
    end

    # Update the UI element
    def update
      if Input.repeat?(:DOWN)
        self.number -= 10**@digit_index
      elsif Input.repeat?(:UP)
        self.number += 10**@digit_index
      elsif Input.trigger?(:LEFT)
        @digit_index = (@digit_index + 1).clamp(0, @max_digits - 1)
      elsif Input.trigger?(:RIGHT)
        @digit_index = (@digit_index - 1).clamp(0, @max_digits - 1)
      elsif Input.trigger?(:B)
        self.number = @default_number
      else
        return # Prevent useless drawing
      end
      draw_digits
    end

    # Set the number shown by the UI
    # @param number [Integer]
    def number=(number)
      @number = number.clamp(@min, @max)
      draw_digits
    end

    # Get the width of the UI
    # @return [Integer]
    def width
      @width_accounting_sprites.map(&:width).reduce(0, :+)
    end

    # Get the height of the UI
    # @return [Integer]
    def height
      @stack.first&.height || 0
    end

    private

    def create_sprites
      create_left
      create_center
      create_right
      create_money
      define_position
    end

    def create_left
      @width_accounting_sprites << add_background(IMAGE_SOURCE, rect: IMAGE_COMPOSITION[:left])
    end

    def create_center
      current_x = @width_accounting_sprites.last.width
      width = IMAGE_COMPOSITION[:number][-2]
      height = IMAGE_COMPOSITION[:number][-1]
      1.step(@max_digits - 1) do
        @width_accounting_sprites << add_sprite(current_x, 0, IMAGE_SOURCE, rect: IMAGE_COMPOSITION[:number])
        @texts << add_text(current_x, 0, width, height, nil.to_s, 1)
        current_x += @width_accounting_sprites.last.width
        @width_accounting_sprites << add_sprite(current_x, 0, IMAGE_SOURCE, rect: IMAGE_COMPOSITION[:separator])
        current_x += @width_accounting_sprites.last.width
      end
      # Last text/sprite
      @width_accounting_sprites << add_sprite(current_x, 0, IMAGE_SOURCE, rect: IMAGE_COMPOSITION[:number])
      @texts << add_text(current_x, 0, width, height, nil.to_s, 1)
      current_x += @width_accounting_sprites.last.width
    end

    def create_right
      @width_accounting_sprites << add_sprite(width, 0, IMAGE_SOURCE, rect: IMAGE_COMPOSITION[:right])
    end

    def create_money
      return unless $game_temp.shop_calling

      current_x = width
      width = IMAGE_COMPOSITION[:money_add][-2]
      height = IMAGE_COMPOSITION[:money_add][-1]
      @width_accounting_sprites << add_sprite(current_x, 0, IMAGE_SOURCE, rect: IMAGE_COMPOSITION[:money_add])
      @money_text = add_text(current_x + MONEY_PADDING, 0, width, height, nil.to_s)
    end

    def draw_digits
      @money_text&.text = parse_text(11, 9, /\[VAR NUM7[^\]]*\]/ => (@number * $game_temp.shop_calling).to_s)

      @number.to_s.rjust(@max_digits, ' ').each_char.with_index do |char, index|
        @texts[index].text = char
        @texts[index].load_color((@max_digits - @digit_index - 1) == index ? 1 : 0)
      end
    end

    def define_position
      self.x = @viewport.rect.width - width
    end
  end
end
