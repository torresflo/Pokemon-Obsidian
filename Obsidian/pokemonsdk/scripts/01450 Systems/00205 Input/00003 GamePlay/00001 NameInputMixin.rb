module GamePlay
  # Module defining the IO of the NameInput scene so user know what to expect
  module NameInputMixin
    # Return the choosen name
    # @return [String]
    attr_reader :return_name
  end
end

GamePlay.string_input_mixin = GamePlay::NameInputMixin
