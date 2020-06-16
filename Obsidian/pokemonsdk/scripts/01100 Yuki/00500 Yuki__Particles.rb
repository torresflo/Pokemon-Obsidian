module Yuki
  # Module that manage the particle display
  # @author Nuri Yuri
  module Particles
    module_function

    # Init the particle display on a new viewport
    # @param viewport [Viewport]
    def init(viewport)
      dispose if @stack
      @clean_stack = false
      @stack = []
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
    def add_particle(character, particle_tag, params = {})
      return unless ready?
      return if character.character_name.empty?

      particle_data = find_particle(character.terrain_tag, particle_tag)
      return unless particle_data

      @stack.push(Particle_Object.new(character, particle_data, @on_teleportation, params))
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
  end
  # The object that describe a particle
  # @author Nuri Yuri
  class Particle_Object
    # The Zoom Division info
    ZoomDiv = Sprite_Character::ZoomDiv
    # if the particle is disposed
    # @return [Boolean]
    attr_reader :disposed
    # Create a particle object
    # @param character [Game_Character] the character on which the particle displays
    # @param data [Hash{Symbol => Hash}] the data of the particle
    #    field of the data hash :
    #       enter: the particle animation when character enter on the tile
    #       stay: the particle animation when character stay on the tile
    #       leave: the particle animation when character leave the tile
    #    field of the particle animation
    #       max_counter: the number of frame on the animation
    #       loop: Boolean # if the animation loops or not
    #       data: an Array of animation instructions (Hash)
    #    field of an animation instruction
    #       state: Symbol # the new state of the particle
    #       zoom: Numeric # the zoom of the particle
    #       position: Symbol # the position type of the particle (:center_pos, :character_pos)
    #       file: String # the filename of the particle in Graphics/Particles/
    #       angle: Numeric # the angle of the particle
    #       add_z: Integer # The z offset relatively to the character
    #       oy_offset: Integer # The offset in oy
    #       opacity: Integer # The opacity of the particle
    #       chara: Boolean # If the particle Bitmap is treaten like the Character bitmap
    #       rect: Array(Integer, Integer, Integer, Integer) # the parameter of the #set function of Rect (src_rect)
    # @param on_tp [Boolean] tells the particle to skip the :enter animation or not
    # @param params [Hash] additional params for the animation
    def initialize(character, data, on_tp = false, params = {})
      @x = character.x
      @y = character.y
      @z = character.z
      @character = character
      @map_id = $game_map.map_id
      @sprite = ::Sprite.new(Particles.viewport)
      @data = data
      @counter = 0
      @position_type = :center_pos
      @state = (on_tp ? :stay : :enter)
      init_zoom
      @ox = 0
      @oy = 0
      @oy_off = 0
      @ox_off = 0
      @wait_count = 0
      @params = params
    end

    # Initialize the zoom info
    def init_zoom
      @zoom = PSDK_CONFIG.specific_zoom || ZoomDiv[1]
      @add_z = @zoom
    end

    # Update the particle animation
    def update
      return if @disposed
      return dispose if $game_map.map_id != @map_id
      if @wait_count > 0
        @wait_count -= 1
        return update_sprite_position
      end
      update_particle_info(@data[@state]) && update_sprite_position
    end

    # Update the particle info
    # @param data [Hash] the data related to the current state
    # @return [Boolean] if the update_sprite_position can be done
    def update_particle_info(data)
      if @counter < data[:max_counter]
        (action = data[:data][@counter]) && exectute_action(action)
        @counter += 1
      elsif @state == :enter
        @state = :stay
        @counter = 0
      elsif @state == :stay
        @state = :leave if @x != @character.x || @y != @character.y
        @counter = 0
      elsif !data[:loop]
        dispose
        Particles.clean_stack
        return false
      else
        @counter = 0
      end
      return true
    end

    # Execute an animation instruction
    # @param action [Hash] the animation instruction
    def exectute_action(action)
      ACTION_HANDLERS_ORDER.each do |name|
        if (data = action[name])
          instance_exec(data, &ACTION_HANDLERS[name])
        end
      end
    end

    # Update the position of the particle sprite
    def update_sprite_position
      case @position_type
      when :center_pos, :grass_pos
        @sprite.x = ((@x * 128 - $game_map.display_x + 5) / 4 + 32) / @zoom
        @sprite.y = ((@y * 128 - $game_map.display_y + 5) / 4 + 32)
        if @position_type == :center_pos || @sprite.y >= @character.screen_y
          @sprite.z = (screen_z + @add_z)
        else
          @sprite.z = (screen_z - 1)
        end
        @sprite.y /= @zoom
        @sprite.ox = @ox * @zoom + @ox_off
        @sprite.oy = @oy * @zoom + @oy_off
      when :character_pos
        @sprite.x = @character.screen_x / @zoom
        @sprite.y = @character.screen_y / @zoom
        @sprite.z = (@character.screen_z(0) + @add_z)
        @sprite.ox = @ox + @ox_off
        @sprite.oy = @oy + @oy_off
      end
    end

    def screen_z
      (@y * 128 - $game_map.display_y + 3) / 4 + 32 * @z + 31
    end

    # Dispose the particle
    def dispose
      return if @disposed
      @sprite.dispose unless @sprite.disposed?
      @sprite = nil
      @disposed = true
    end
  end
  # Object that describe a parallax as a particle
  # @author Nuri Yuri
  class Parallax_Object
    # If the parallax is disposed
    # @return [Boolean]
    attr_reader :disposed
    # The parallax sprite
    # @return [Sprite]
    attr_accessor :sprite
    # the factor that creates an automatic offset in x
    # @return [Numeric]
    attr_accessor :factor_x
    # the factor that creates an automatic offset in y
    # @return [Numeric]
    attr_accessor :factor_y
    # Creates a new Parallax_Object
    # @param image [String] name of the image in Graphics/Pictures/
    # @param x [Integer] x coordinate of the parallax from the first pixel of the Map (16x16 tiles /!\)
    # @param y [Integer] y coordinate of the parallax from the first pixel of the Map (16x16 tiles /!\)
    # @param z [Integer] z superiority in the tile viewport
    # @param zoom_x [Numeric] zoom_x of the parallax
    # @param zoom_y [Numeric] zoom_y of the parallax
    # @param opacity [Integer] opacity of the parallax (0~255)
    # @param blend_type [Integer] blend_type of the parallax (0, 1, 2)
    def initialize(image, x, y, z, zoom_x = 1, zoom_y = 1, opacity = 255, blend_type = 0)
      @sprite = ::Sprite.new(Particles.viewport, true)
      @sprite.z = z
      @sprite.zoom_x = zoom_x
      @sprite.zoom_y = zoom_y
      @sprite.opacity = opacity
      @sprite.blend_type = blend_type
      @sprite.bitmap = ::RPG::Cache.picture(image)
      @x = x + MapLinker.get_OffsetX * 16
      @y = y + MapLinker.get_OffsetY * 16
      @factor_x = 0
      @factor_y = 0
      update
    end

    # Update the parallax position
    def update
      dx = $game_map.display_x / 8
      dy = $game_map.display_y / 8
      @sprite.x = (@x - dx) + (@factor_x * dx)
      @sprite.y = (@y - dy) + (@factor_y * dy)
    end

    # Dispose the parallax
    def dispose
      return if @disposed
      @sprite.dispose unless @sprite.disposed?
      @sprite = nil
      @disposed = true
    end
  end
  # Object that describe a building on the Map as a Particle
  # @author Nuri Yuri
  class Building_Object
    # If the building is disposed
    # @return [Boolean]
    attr_reader :disposed
    # The building sprite
    # @return [Sprite]
    attr_accessor :sprite
    # Create a new Building_Object
    # @param image [String] name of the image in Graphics/Autotiles/
    # @param x [Integer] x coordinate of the building
    # @param y [Integer] y coordinate of the building
    # @param oy [Integer] offset y coordinate of the building in native resolution pixel
    def initialize(image, x, y, oy)
      @sprite = ::Sprite.new(Particles.viewport, true)
      @sprite.bitmap = ::RPG::Cache.autotile(image)
      @sprite.oy = @sprite.bitmap.height - oy - 16
      @x = (x + MapLinker.get_OffsetX) * 16
      @y = (y + MapLinker.get_OffsetY) * 16
      @real_y = (y + MapLinker.get_OffsetY) * 128
      update
    end

    # Update the building position (x, y, z)
    def update
      dx = $game_map.display_x / 8
      dy = $game_map.display_y / 8
      @sprite.x = (@x - dx)
      @sprite.y = (@y - dy)
      @sprite.z = (@real_y - $game_map.display_y + 4) / 4 + 94
    end

    # Dispose the building
    def dispose
      return if @disposed
      @sprite.dispose unless @sprite.disposed?
      @sprite = nil
      @disposed = true
    end
  end
end
Hooks.register(Spriteset_Map, :init_psdk_add) do
  Yuki::Particles.init(@viewport1)
  Yuki::Particles.set_on_teleportation(true)
end
Hooks.register(Spriteset_Map, :init_player_end) do
  Yuki::Particles.update
  Yuki::Particles.set_on_teleportation(false)
end
Hooks.register(Spriteset_Map, :update) { Yuki::Particles.update }
