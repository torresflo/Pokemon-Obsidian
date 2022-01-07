module GamePlay
  # Module defining the IO of the bag scene so user know what to expect
  #
  # This mixin should also be used to check if the bag scene is right:
  # @example
  #   Check the current scene is the bag
  #     GamePlay.current_scene.is_a?(GamePlay.bag_mixin)
  module BagMixin
    # ID of the item selected
    # @return [Integer]
    attr_accessor :return_data
    # Wrapper of the choosen item in battle
    # @return [PFM::ItemDescriptor::Wrapper, nil]
    attr_accessor :battle_item_wrapper
    # Get the mode in which the bag was started
    # @return [Symbol]
    attr_reader :mode

    # Get the selected item db_symbol
    # @return [Symbol]
    def selected_item_db_symbol
      return :__undef__ if return_data == -1

      return GameData::Item.db_symbol(return_data)
    end
  end
end

GamePlay.bag_mixin = GamePlay::BagMixin
