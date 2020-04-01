module GameData
  # Constants used by PFM::PokemonParty
  # @note Do not change anything in this script, it'll probably be removed!
  module PokemonParty
    # The list of ability that decrease the encounter frequency
    ENC_FREQ_DEC = %i[white_smoke quick_feet stench]
    # The list of ability that increase the encounter frequency
    ENC_FREQ_INC = %i[no_guard illuminate arena_trap]
    # Ability that decrese the encounter during hail weather
    ENC_FREQ_DEC_HAIL = [:snow_cloak]
    # Ability that decrese the encounter during sandstorm weather
    ENC_FREQ_DEC_SANDSTORM = [:sand_veil]
    # Abilities that increase the hatch speed
    FASTER_HATCH_ABILITIES = %i[magma_armor flame_body]
  end
end
