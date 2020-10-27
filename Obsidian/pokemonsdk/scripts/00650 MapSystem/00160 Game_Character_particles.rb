class Game_Character
  # @return [Boolean] if the particles are disabled for the Character
  attr_accessor :particles_disabled

  # Show an emotion to an event or the player
  # @param type [Symbol] the type of emotion (see wiki)
  # @param wait [Integer] the number of frame the event will wait after this command.
  # @param params [Hash] particle params
  def emotion(type, wait = 34, params = {})
    Yuki::Particles.add_particle(self, type, params)
    @wait_count = wait
    @move_type_custom_special_result = true if wait > 0
  end

  # Constant defining all the particle method to call
  PARTICLES_METHODS = {
    TGrass => :particle_push_grass,
    TTallGrass => :particle_push_tall_grass,
    TSand => :particle_push_sand,
    TSnow => :particle_push_snow,
    TPond => :particle_push_pond,
    TWetSand => :particle_push_wetsand
  }

  # Push a particle to the particle stack if possible
  # @author Nuri Yuri
  def particle_push
    return if @particles_disabled
    method_name = PARTICLES_METHODS[system_tag]
    send(method_name) if method_name
  end

  # Push a grass particle
  def particle_push_grass
    Yuki::Particles.add_particle(self, 1)
  end

  # Push a tall grass particle
  def particle_push_tall_grass
    Yuki::Particles.add_particle(self, 2)
  end

  # Constant telling the sand particle name to push (according to the direction)
  SAND_PARTICLE_NAME = { 2 => :sand_d, 4 => :sand_l, 6 => :sand_r, 8 => :sand_u }

  # Push a sand particle
  def particle_push_sand
    particle = SAND_PARTICLE_NAME[@direction]
    Yuki::Particles.add_particle(self, particle) if particle && @can_make_footprint
  end

  # Push a wet sand particle
  def particle_push_wetsand
    Yuki::Particles.add_particle(self, :wetsand)
  end

  # Constant telling the snow particle name to push (according to the direction)
  SNOW_PARTICLE_NAME = { 2 => :snow_d, 4 => :snow_l, 6 => :snow_r, 8 => :snow_u }

  # Push a snow particle
  def particle_push_snow
    particle = SNOW_PARTICLE_NAME[@direction]
    Yuki::Particles.add_particle(self, particle) if particle && @can_make_footprint
  end

  # Push a pond particle
  def particle_push_pond
    Yuki::Particles.add_particle(self, :pond) if surfing?
  end
end
