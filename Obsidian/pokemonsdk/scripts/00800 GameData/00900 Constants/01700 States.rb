module GameData
  # Natural state ID
  module States
    # POISONED state
    POISONED = 1
    # PARALYZED state
    PARALYZED = 2
    # Burn state
    BURN = 3
    # Asleep state
    ASLEEP = 4
    # Frozen state
    FROZEN = 5
    # Confused State /!\ only in items/skills
    CONFUSED = 6
    # Toxic state
    TOXIC = 8
    # K.O. state
    DEATH = KO = 9
    # FLINCH STATE
    FLINCH = 7

    module_function

    # Find the symbol of a state according to the State id
    # @param value [Integer] State id
    # @return [Symbol]
    def index(value)
      constants.find { |const_name| const_get(const_name) == value } || :__undef__
    end
  end
end
