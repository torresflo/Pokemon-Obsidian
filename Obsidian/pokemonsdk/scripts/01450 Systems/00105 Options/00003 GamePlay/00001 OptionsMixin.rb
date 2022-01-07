module GamePlay
  module OptionsMixin
    # List of options that were modifies
    # @return [Array<Symbol>]
    attr_reader :modified_options
  end
end

GamePlay.options_mixin = GamePlay::OptionsMixin
