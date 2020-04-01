# Nuri Yuri's external script module
module NuriYuri
  # Module managing the dynamic light system for PSDK
  module DynamicLight
    # @return [Array<Array>] List of light
    #   The first array component tell if it's a normal light (:normal, centered on the character)
    #   or if it's a directed light (:direction, in the direction of the character)
    #   The second component is the sprite shown under the map (light mask)
    #   The third component is the sprite shown in the map viewport for special effect mostly on top of the character
    LIGHTS = [
      [:normal, 'dynamic_light/circle_320'],
      [:direction, 'dynamic_light/flash_light_mask', 'dynamic_light/flash_light_color'],
      [:normal, 'dynamic_light/circle_96']
    ]
    # @return [Array<Hash>] List of light animation, Hash key are opacity: & zoom: (array of value)
    ANIMATIONS = [
      { zoom: [1], opacity: [255] },
      { zoom: Array.new(120) { |i| 0.70 + 0.05 * Math.cos(6.28 * i / 120) },
        opacity: Array.new(120) { |i| 240 + (15 * Math.cos(6.28 * i / 120)).to_i } },
      { zoom: Array.new(120) { |i| 0.95 + 0.05 * Math.cos(6.28 * i / 120) }, opacity: [255] }
    ]

    module_function

    # Start the dynamic light processing
    # @param block [Proc] given_block that tells to start the DynamicLight process on the next update
    def start(&block)
      return unless $scene.is_a?(Scene_Map)
      return start_delay(&block) if block

      stop(true)
      create_viewport
      load_blendmode
      register
      @delay = nil
    end

    # Stop the dynamic light processing
    # @param from_start [Boolean] tell if stop was called from start to prevent useless viewport dispose
    def stop(from_start = false)
      return unless $scene.is_a?(Scene_Map)

      $pokemon_party.nuri_yuri_dynamic_light.clear
      unregister
      clear_stack
      dispose_viewport unless from_start
    end

    # Start delayed to the warp_end process
    # @yield [dl] given_block that tells to start the DynamicLight process on the next update
    # @yieldparam dl [DynamicLight] this module
    def start_delay
      return unless $scene.is_a?(Scene_Map)

      @stack ||= []
      unregister
      @delay = proc do
        start
        yield(self)
      end
      Scheduler.add_message(:on_warp_end, Scene_Map, 'NuriYuri::DynamicLight', 100, self, :update)
    end

    # Stop delayed to the warp_end process
    def stop_delay
      return unless $scene.is_a?(Scene_Map)

      @stack ||= []
      @delay = proc { stop }
      Scheduler.__remove_task(:on_update, Scene_Map, 'NuriYuri::DynamicLight', 100)
    end

    # Update the lights
    def update
      @delay&.call
      @stack.each(&:update)
    end

    # Add a new light to the stack
    # @param chara_id [Integer] ID of the character (0 = player, -n = follower n, +n = event id)
    # @param light_type [Integer] Type of the light we'll display on the character
    # @param animation_type [Integer] Type of the animation performed on the light
    # @param zoom_count [Integer] initial value of the zoom_count
    # @param opacity_count [Integer] initial value of the opacity_count
    # @param args [Array] extra parameters
    # @param type [Class] Type of the sprite used to simulate the light
    # @return [Integer] ID of the light in the light stack, if -1 => one of the parameter is invalid
    def add(chara_id, light_type, animation_type = 0, zoom_count = 0, opacity_count = 0, *args, type: DynamicLightSprite)
      return -2 unless $scene.is_a?(Scene_Map) && @viewport
      return -1 unless light_type.between?(0, LIGHTS.size - 1)
      return -1 unless animation_type.between?(0, ANIMATIONS.size - 1)

      if chara_id < 0
        character = nil # Not supported now.
      elsif chara_id == 0
        character = $game_player
      else
        character = $game_map.events[chara_id]
      end
      return -1 unless character

      @stack << type.new(character, light_type, animation_type, zoom_count, opacity_count, *args)
      light_id = @stack.last.light_id = @stack.size - 1
      $pokemon_party.nuri_yuri_dynamic_light << { params: [chara_id, light_type, animation_type, zoom_count, opacity_count, *args], on: true, type: type }
      return light_id
    end

    # Switch a light on
    # @param light_id [Integer] ID of the light in the light stack
    def switch_on(light_id)
      return unless @stack
      return if light_id < 0

      light = @stack[light_id]
      if light
        light.on = true
        $pokemon_party.nuri_yuri_dynamic_light[light_id][:on] = true
      end
    end

    # Switch a light off
    # @param light_id [Integer] ID of the light in the light stack
    def switch_off(light_id)
      return unless @stack
      return if light_id < 0

      light = @stack[light_id]
      if light
        light.on = false
        $pokemon_party.nuri_yuri_dynamic_light[light_id][:on] = false
      end
    end

    # Retrieve the light sprite
    # @param light_id ID of the light in the light stack
    # @return [DynamicLightSprite, nil]
    def light_sprite(light_id)
      return nil unless @stack
      return nil if light_id < 0

      @stack[light_id]
    end

    # Register the update task
    def register
      Scheduler.add_message(:on_update, Scene_Map, 'NuriYuri::DynamicLight', 100, self, :update)
      Scheduler.add_message(:on_warp_end, Scene_Map, 'NuriYuri::DynamicLight', 100, self, :update)
      nil
    end

    # Unregister the update task
    def unregister
      Scheduler.__remove_task(:on_update, Scene_Map, 'NuriYuri::DynamicLight', 100)
      Scheduler.__remove_task(:on_transition, Scene_Map, 'NuriYuri::DynamicLight', 100)
      Scheduler.__remove_task(:on_warp_end, Scene_Map, 'NuriYuri::DynamicLight', 100)
      nil
    end

    # Clear the light task
    def clear_stack
      @stack ||= []
      @stack.each { |light| light.dispose unless light.disposed? }
    ensure
      @stack.clear
    end

    # Create the viewport
    def create_viewport
      @viewport = Viewport.create(:main, 1) if !@viewport || @viewport.disposed?
      Graphics.sort_z
    end

    # Dispose the light viewport
    def dispose_viewport
      @viewport.dispose
    end

    # Load the light blend_mode
    def load_blendmode
      shader = BlendMode.new
      shader.color_src_factor = BlendMode::DstColor
      shader.color_dest_factor = BlendMode::OneMinusSrcColor
      shader.color_equation = BlendMode::Subtract
      shader.alpha_src_factor = BlendMode::SrcAlpha
      shader.alpha_dest_factor = BlendMode::DstAlpha
      shader.alpha_equation = BlendMode::Add
      @viewport.shader = shader
    end

    # Part called when Scene_Map init itself (in order to reload all the lights)
    def on_map_init
      $pokemon_party.nuri_yuri_dynamic_light ||= [] # Safe init the stack
      light_info_stack = $pokemon_party.nuri_yuri_dynamic_light.clone
      unless light_info_stack.empty?
        @delay = proc do
          start
          light_info_stack.each do |light_info|
            id = add(*light_info[:params], type: light_info[:type])
            switch_off(id) unless light_info[:on]
          end
        end
        Scheduler.add_message(:on_transition, Scene_Map, 'NuriYuri::DynamicLight', 100, self, :update)
      end
    end

    # Return the viewport of the DynamicLight system
    # @return [Viewport]
    def viewport
      @viewport
    end

    # Clean everything on soft reset
    def on_soft_reset
      unregister
      @stack ||= []
      @stack.clear
    end
    unless PARGV[:worldmap] || PARGV[:"animation-editor"] || PARGV[:test] || PARGV[:tags]
      # Register task for map loading & soft reset
      Scheduler.add_message(:on_init, Scene_Map, 'NuriYuri::DynamicLight', 0, self, :on_map_init)
      Graphics.on_start do
        soft_reset = Yuki.const_get(:SoftReset)
        Scheduler.add_message(:on_transition, soft_reset, 'NuriYuri::DynamicLight', 100, self, :on_soft_reset)
      end
    end
  end
end
