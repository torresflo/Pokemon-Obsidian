module Yuki
  module Particles
    # The particle data
    Data = load_data('Data/Animations/Particles.dat')
    # The empty actions
    EMPTY = { max_counter: 1, loop: false, data: [] }

    module_function

    # Function that find the data for a particle according to the terrain_tag & the particle tag
    # @note This function will try $game_variables[Var::PAR_DatID] & 0 as terrain_tag if the particle_tag wasn't found
    # @param terrain_tag [Integer] terrain_tag in which the event is
    # @param particle_tag [Integer, Symbol] identifier of the particle in the hash
    def find_particle(terrain_tag, particle_tag)
      Data.dig(terrain_tag, particle_tag) ||
        Data.dig($game_variables[Var::PAR_DatID], particle_tag) ||
        Data.dig(0, particle_tag)
    end
  end
end
