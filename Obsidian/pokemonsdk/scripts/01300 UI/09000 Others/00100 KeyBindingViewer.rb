module UI
  # Class that allow to see the KeyBinding for the PSDK virtual key
  #
  # This object has two indexes :
  #   - main_index : It's the index of the PSDK Key we want to see
  #   - key_index : It's the index of the Binding we want to change
  #       if key_index is negative, it's not showing the index sprite
  #
  # This object has a blink state linked to #update_blink allowing to tell the key is currently being edited
  class KeyBindingViewer < SpriteStack
    # X position of the first text
    FT_X = 12
    # X position of the second text
    ST_X = 72
    # X position of the last text & the first button
    LT_X = 208
    # Y position of the first key text
    FKT_Y = 26
    # @return [Boolean] if the UI is in blinking mode
    attr_reader :blinking
    # @return [Integer] the main index
    attr_reader :main_index
    # @return [Integer] the key index
    attr_reader :key_index
    # Create a new KeyBindingViewer
    def initialize(viewport)
      super(viewport, 3, 48)
      push(0, 0, 'key_binding/cadre')
      @main_selector = push(FT_X - 1, FKT_Y + 1, 'key_binding/selecteur_blue')
      @sub_selector = push(LT_X + 1, FKT_Y + 1, 'key_binding/selecteur_red')
      create_top_line
      create_keys
      @counter = 0
      self.main_index = 0
      self.key_index = -1
      self.blinking = false
    end

    # List of the Key to create with their information (PSDK name, Descr)
    KEYS = [
      [:A, 4, 13],
      [:B, 5, 14],
      [:X, 6, 15],
      [:Y, 7, 16],
      [:UP, 8, 17],
      [:DOWN, 9, 18],
      [:RIGHT, 10, 19],
      [:LEFT, 11, 20]
    ]

    # Update the blink animation
    def update_blink
      return unless @blinking
      @counter += 1
      if @counter == 30
        @buttons[@main_index * 5 + @key_index]&.visible = false
      elsif @counter >= 60
        @buttons[@main_index * 5 + @key_index]&.visible = true
        @counter = 0
      end
    end

    # Update all the buttons
    def update
      @buttons.each(&:update)
    end

    # Set the blinking state
    # @param value [Boolean] the new blinking state
    def blinking=(value)
      @blinking = value
      @counter = 0
      @buttons[@main_index * 5 + @key_index]&.visible = true unless value
    end

    # Set the new main index value
    # @param value [Integer]
    def main_index=(value)
      value = KEYS.size - 1 if value < 0
      value = 0 if value >= KEYS.size
      @main_index = value
      @sub_selector.y = @main_selector.y = @y + FKT_Y + 16 * value + 1
    end

    # Set the new key index value
    # @param value [Integer]
    def key_index=(value)
      value = -1 if value < 0
      @key_index = value
      if value == -1
        @sub_selector.visible = false
      else
        @sub_selector.visible = true
        @sub_selector.x = @x + LT_X + 16 * value + 1
      end
    end

    # Get the current key (to update the Input::Keys)
    # @return [Symbol]
    def current_key
      return :A if @key_index < 0
      @buttons[@main_index * 5 + @key_index]&.key || :A
    end

    # Get the current key index according to the button
    def current_key_index
      return -1 if @key_index < 0
      @buttons[@main_index * 5 + @key_index]&.index || 0
    end

    private

    # Create the top line
    def create_top_line
      add_text(FT_X, 5, 100, 16, ext_text(8998, 0), color: 9)
      add_text(ST_X, 5, 100, 16, ext_text(8998, 1), color: 9)
      add_text(LT_X, 5, 100, 16, ext_text(8998, 2), color: 9)
    end

    # Create all the key texts & button
    def create_keys
      @buttons = []
      KEYS.each_with_index do |key_info, index|
        create_key(index, *key_info)
      end
    end

    # Create a single key line
    # @param index [Integer] Index of the key in the array
    # @param name [Symbol] name of the key in Input
    # @param psdk_text_id [Integer] id of the text telling the name of the key
    # @param descr_text_id [Integer] id of the text telling what the key does
    def create_key(index, name, psdk_text_id, descr_text_id)
      add_text(FT_X, FKT_Y + 16 * index, 100, 16, ext_text(8998, psdk_text_id))
      add_text(ST_X, FKT_Y + 16 * index, 100, 16, ext_text(8998, descr_text_id))
      4.times do |i|
        @buttons << push(LT_X + i * 16, FKT_Y + 16 * index, nil, name, i, type: KeyBinding)
      end
      @buttons << push(LT_X + 64, FKT_Y + 16 * index, nil, name, type: JKeyBinding)
    end
  end
end
