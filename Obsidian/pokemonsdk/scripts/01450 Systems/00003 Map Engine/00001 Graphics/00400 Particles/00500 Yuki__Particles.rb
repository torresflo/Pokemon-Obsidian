module Yuki
  # Module that manage the particle display
  # @author Nuri Yuri
  module Particles
    module_function

    # Init the particle display on a new viewport
    # @param viewport [Viewport]
    def init(viewport)
      dispose if @stack && viewport != @viewport
      @clean_stack = false
      @stack ||= []
      @named = {}
      @viewport = viewport
      @on_teleportation = false
    end

    # Update of the particles & stack cleaning if requested
    def update
      return unless ready?

      @stack.each do |i|
        i.update if i && !i.disposed
      end
      # Clean stack part
      return unless @clean_stack

      @clean_stack = false
      @stack.delete_if(&:disposed)
    end

    # Request to clean the stack
    def clean_stack
      @clean_stack = true
    end

    # Add a particle to the stack
    # @param character [Game_Character] the character on which the particle displays
    # @param particle_tag [Integer, Symbol] identifier of the particle in the hash
    # @param params [Hash] additional params for the particle
    # @return [Particle_Object]
    def add_particle(character, particle_tag, params = {})
      return unless ready?
      return if character.character_name.empty?

      particle_data = find_particle(character.terrain_tag, particle_tag)
      return unless particle_data

      @stack.push(particle = Particle_Object.new(character, particle_data, @on_teleportation, params))
      return particle
    end

    # Add a named particle (particle that has a specific flow)
    # @param name [Symbol] name of the particle to prevent collision
    # @param character [Game_Character] the character on which the particle displays
    # @param particle_tag [Integer, Symbol] identifier of the particle in the hash
    # @param params [Hash] additional params for the particle
    def add_named_particle(name, character, particle_tag, params = {})
      return if @named[name] && !@named[name].disposed

      @named[name] = add_particle(character, particle_tag, params)
    end

    # Add a parallax
    # @param image [String] name of the image in Graphics/Pictures/
    # @param x [Integer] x coordinate of the parallax from the first pixel of the Map (16x16 tiles /!\)
    # @param y [Integer] y coordinate of the parallax from the first pixel of the Map (16x16 tiles /!\)
    # @param z [Integer] z superiority in the tile viewport
    # @param zoom_x [Numeric] zoom_x of the parallax
    # @param zoom_y [Numeric] zoom_y of the parallax
    # @param opacity [Integer] opacity of the parallax (0~255)
    # @param blend_type [Integer] blend_type of the parallax (0, 1, 2)
    # @return [Parallax_Object]
    def add_parallax(image, x, y, z, zoom_x = 1, zoom_y = 1, opacity = 255, blend_type = 0)
      object = Parallax_Object.new(image, x, y, z, zoom_x, zoom_y, opacity, blend_type)
      @stack << object
      return object
    end

    # Add a building
    # @param image [String] name of the image in Graphics/Autotiles/
    # @param x [Integer] x coordinate of the building
    # @param y [Integer] y coordinate of the building
    # @param oy [Integer] offset y coordinate of the building in native resolution pixel
    # @param visible_from1 [Symbol, false] data parameter (unused there)
    # @param visible_from2 [Symbol, false] data parameter (unused there)
    # @return [Building_Object]
    def add_building(image, x, y, oy = 0, visible_from1 = false, visible_from2 = false)
      object = Building_Object.new(image, x, y, oy)
      @stack << object
      return object
    end

    # Return the viewport of in which the Particles are shown
    def viewport
      @viewport
    end

    # Tell if the system is ready to work
    # @return [Boolean]
    def ready?
      return @stack && !viewport.disposed?
    end

    # Tell the particle manager the game is warping the player. Particle will skip the :enter phase.
    # @param v [Boolean]
    def set_on_teleportation(v)
      @on_teleportation = v
    end

    # Dispose each particle
    def dispose
      return unless ready?

      @stack.each do |i|
        i.dispose if i && !i.disposed
      end
    ensure
      @stack = nil
    end

    class << self
      # Return the list of named particles
      # @return [Hash{ Symbol => Particle_Object }]
      attr_reader :named
    end
  end
end
Hooks.register(Spriteset_Map, :init_psdk_add, 'Yuki::Particles') do
  Yuki::Particles.init(@viewport1)
  Yuki::Particles.set_on_teleportation(true)
end
Hooks.register(Spriteset_Map, :init_player_end, 'Yuki::Particles') do
  Yuki::Particles.update
  Yuki::Particles.set_on_teleportation(false)
end
Hooks.register(Spriteset_Map, :update, 'Yuki::Particles') { Yuki::Particles.update }
