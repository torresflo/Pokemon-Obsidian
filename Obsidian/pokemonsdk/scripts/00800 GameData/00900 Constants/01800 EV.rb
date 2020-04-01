module GameData
  # EV indexes
  module EV
    # Attack EV Index
    ATK = 1
    # Special Attack EV Index
    ATS = 4
    # Defense EV Index
    DFE = 2
    # Special Defense EV Index
    DFS = 5
    # Speed EV Index
    SPD = 3
    # HP EV Index
    HP = 0

    module_function

    # Find the symbol of an EV according to the EV id
    # @param value [Integer] EV id
    # @return [Symbol]
    def index(value)
      constants.find { |const_name| const_get(const_name) == value } || :__undef__
    end
  end
end
