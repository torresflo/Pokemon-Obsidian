module Yuki
  # The object that describe a particle
  # @author Nuri Yuri
  class Particle_Object
    # Zoom of a tile to adjust coordinate
    TILE_ZOOM = PSDK_CONFIG.tilemap.character_tile_zoom
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
    # @option params [Symbol] :flow define the kind of flow to use for the animation
    # @option params [Integer] :radius define the radius to use for the :update_radius_flow flow
    def initialize(character, data, on_tp = false, params = {})
      @character = character
      init_map_data(character)
      @x = character.x + @map_data.offset_x
      @y = character.y + @map_data.offset_y
      @z = character.z
      @sprite = ::Sprite.new(Particles.viewport)
      @data = data
      @counter = 0
      @position_type = :center_pos
      @state = (on_tp ? :stay : :enter)
      @state = params[:state] if params.key?(:state)
      init_zoom
      @ox = 0
      @oy = 0
      @oy_off = 0
      @ox_off = 0
      @wait_count = 0
      @params = params
      @flow = params[:flow] || :update_default_flow
    end

    # Update the particle animation
    def update
      return if disposed?
      return dispose unless @map_linker.map_datas.include?(@map_data)

      if @wait_count > 0
        @wait_count -= 1
        return update_sprite_position
      end
      update_particle_info(@data[@state]) && update_sprite_position
    end

    # Get the real x of the particle on the map
    # @return [Integer]
    def x
      return @x - @map_data.offset_x
    end

    # Get the real y of the particle on the map
    # @return [Integer]
    def y
      return @y - @map_data.offset_y
    end

    # Update the particle info
    # @param data [Hash] the data related to the current state
    # @return [Boolean] if the update_sprite_position can be done
    def update_particle_info(data)
      if @counter < data[:max_counter]
        (action = data[:data][@counter]) && exectute_action(action)
        @counter += 1
      elsif send(@flow, data)
        return true
      elsif !data[:loop]
        dispose
        return false
      else
        @counter = 0
      end
      return true
    end

    # Update the default particle state flow
    # @param data [Hash] the data related to the current state
    # @return [Boolean]
    def update_default_flow(data)
      if @state == :enter
        @state = :stay
        @counter = 0
      elsif @state == :stay
        @state = :leave if x != @character.x || y != @character.y
        @counter = 0
      else
        return false
      end
      return true
    end

    # Update the radius particle kind flow
    # @param data [Hash] the data related to the current state
    # @return [Boolean]
    def update_radius_flow(data)
      radius = Math.sqrt(($game_player.x - @character.x)**2 + ($game_player.y - @character.y)**2)
      if @state == :enter
        @state = :stay
        @counter = 0
      elsif @state == :stay
        return false if @map_data.map_id != $game_map.map_id

        if radius > @params[:radius]
          @state = :leave
          @counter = 0
        end
      elsif @state == :leave
        return false if @map_data.map_id != $game_map.map_id

        if (@sprite.visible = (radius <= @params[:radius]))
          @state = :enter
          @counter = 0
        end
      else
        return false
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
        @sprite.x = (((x * 128 - $game_map.display_x + 5) / 4 + 16) * @tile_zoom).floor
        @sprite.y = ((y * 128 - $game_map.display_y + 5) / 4 + 32)
        if @position_type == :center_pos || @sprite.y >= @character.screen_y
          @sprite.z = (screen_z + @add_z)
        else
          @sprite.z = (screen_z - 1)
        end
        @sprite.y = (@sprite.y * @tile_zoom).floor
        @sprite.ox = @ox + @ox_off
        @sprite.oy = @oy + @oy_off
      when :character_pos
        @sprite.x = @character.screen_x * @tile_zoom
        @sprite.y = @character.screen_y * @tile_zoom
        @sprite.z = (@character.screen_z(0) + @add_z)
        @sprite.ox = @ox + @ox_off
        @sprite.oy = @oy + @oy_off
      end
    end

    # Function that process screen z depending on original screen_y (without zoom)
    def screen_z
      (y * 128 - $game_map.display_y + 3) / 4 + 32 * @z + 31
    end

    # Dispose the particle
    def dispose
      return if disposed?

      @sprite.dispose unless @sprite.disposed?
      @sprite = nil
      @disposed = true
      Yuki::Particles.clean_stack
    end

    alias disposed? disposed

    private

    # Init the map_data info for the particle
    # @param character [Game_Event, Game_Character, Game_Player]
    def init_map_data(character)
      map_id = character.original_map if character.is_a?(Game_Event)
      map_id ||= $game_map.map_id
      @map_linker = MapLinker
      @map_data = @map_linker.map_datas.find { |data| data.map_id == map_id } || @map_linker.map_datas.first
    end

    # Initialize the zoom info
    def init_zoom
      @tile_zoom = TILE_ZOOM
      @add_z = (1 / @tile_zoom).floor
    end
  end
end
