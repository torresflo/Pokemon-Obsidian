module GameData
  # Battle stages index (Index of Stat modifier level)
  module Stages
    ATK_STAGE = 0
    ATS_STAGE = 3
    DFE_STAGE = 1
    DFS_STAGE = 4
    SPD_STAGE = 2
    EVA_STAGE = 5
    ACC_STAGE = 6

    module_function

    # Find the symbol of a Stage according to the Stage id
    # @param value [Integer] Stage id
    # @return [Symbol]
    def index(value)
      constants.find { |const_name| const_get(const_name) == value } || :__undef__
    end
  end
end
