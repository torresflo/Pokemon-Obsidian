module GamePlay
  class NameInput < GamePlay::BaseCleanUpdate::FrameBalanced
    include NameInputMixin
    # Hint shown about how to enter name
    DEFAULT_HINT = [:ext_text, 9000, 162] # "Use your keyboard and press ENTER"
    # GUESSED PHRASE when not given
    GUESSED_PHRASE = [:ext_text, 9000, 163] # "How would you name %<name>s?"
    # Create a new NameInput scene
    # @param default_name [String] the choosen name if no choice
    # @param max_length [Integer] the maximum number of characters in the choosen name
    # @param character [PFM::Pokemon, String, nil] the character to display
    # @param phrase [String, nil] phrase to show in order to display the name
    def initialize(default_name, max_length, character = nil, phrase: nil)
      super()
      @return_name = @default_name = default_name[0, max_length].dup.force_encoding(Encoding::UTF_8)
      @input_name = @default_name.chars
      @max_length = max_length
      @character = character
      @phrase = phrase || guess_phrase
    end

    # Update the inputs of the scene
    # @return [Boolean] if the other "input" related updates can be called
    def update_inputs
      if (text = Input.get_text)
        update_name(text.chars)
        return false
      end
      return joypad_update_inputs && true
    end

    # Update the graphics of the scene
    def update_graphics
      @base_ui&.update_background_animation
      @name_input_ui&.update
      @hint_ui&.update
    end

    # Make main return self for compatibility
    # @return [self]
    def main
      super
      return self
    end

    private

    def guess_phrase
      name = @character.is_a?(PFM::Pokemon) ? @character.name : @default_name
      format(get_text(GUESSED_PHRASE), name: name)
    end

    def create_graphics
      create_viewport
      create_base_ui
      create_name_input_ui
      create_hint_ui
      create_joypad_ui
    end

    # Update the displayed name (according to a list of chars)
    # @param chars [Array<String>] all the chars that controls the name (add / remove / validate)
    # @param from_clipboard [Boolean] if the chars comes from the clipboard
    def update_name(chars, from_clipboard = false)
      chars.each do |char|
        ord = char.ord
        if char_valid?(ord)
          @name_input_ui.add_char(char)
        elsif ord == 13 && !from_clipboard
          confirm_name
        elsif ord == 8
          @name_input_ui.remove_char
        elsif ord == 22 && !from_clipboard
          update_name(Yuki.get_clipboard.to_s.chars, true)
        end
      end
    end

    def confirm_name
      @return_name = @name_input_ui.chars.join if @name_input_ui.chars.any?
      @running = false
    end

    def joypad_update_inputs
      return true # if no joypad connected
    end

    def create_base_ui
      @base_ui = UI::NameInputBaseUI.new(@viewport)
    end

    def create_name_input_ui
      @name_input_ui = UI::NameInputUI.new(@viewport, @max_length, @input_name, @character, @phrase)
    end

    def create_hint_ui
      @hint_ui = UI::Window.new(@viewport, 2, 190, 316, 48)
      @hint_text = @hint_ui.add_text(0, 0, 316 - @hint_ui.window_builder[-2] - @hint_ui.window_builder[4], 16, '')
      @hint_text.multiline_text = get_text(DEFAULT_HINT)
    end

    def create_joypad_ui
      return nil # Don't forget to pass self to this ui
    end

    # Function that checks if a character is valid depending on its ordinal
    # @param ord [Integer] value of the char in numbers
    # @return [Boolean]
    def char_valid?(ord)
      ord >= 32
    end
  end
end

GamePlay.string_input_class = GamePlay::NameInput
