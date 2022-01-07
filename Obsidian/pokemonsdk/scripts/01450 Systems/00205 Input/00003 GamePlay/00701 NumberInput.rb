module GamePlay
  class NumberInput < NameInput
    private

    def create_joypad_ui
      return nil # Don't forget to pass self to this ui & use the NUMBER restricted UI
    end

    # Function that checks if a character is valid depending on its ordinal
    # @param ord [Integer] value of the char in numbers
    # @return [Boolean]
    def char_valid?(ord)
      ord.between?(48, 57)
    end
  end
end
