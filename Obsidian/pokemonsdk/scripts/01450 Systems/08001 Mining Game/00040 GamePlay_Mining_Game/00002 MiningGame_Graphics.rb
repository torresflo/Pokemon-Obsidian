module GamePlay
  class MiningGame
    include UI::MiningGame

    private

    # Create the graphics
    def create_graphics
      super
      # Ensure the handler is ready before creating the graphics
      Graphics.update until @handler.ready?
      create_snapshot
      create_background
      create_tool_buttons
      create_diggable_stacks
      create_tiles_stack
      create_hit_counter
      create_tool_hit_sprite
      create_iron_hit_sprite
      create_tool_sprite
      create_transition_sprite
      start_transition_in_animation
      Graphics.sort_z
    end

    # Update the graphics that needs to be updated (and @animation)
    def update_graphics
      @tool_buttons.animation.update if @tool_buttons.animation && !@tool_buttons.animation.done?
      @transition_animation&.update
      return unless @ui_state == :animation
      return if !@animation || @animation.done?

      @animation.update
      @tool_sprite.update
      @tool_hit_sprite.update
      @ui_state = :mouse if @animation.done?
    end

    # Create the viewports
    def create_viewport
      super
      @sup_viewport = Viewport.create(:main, @viewport.z + 1)
    end

    # Create the map snapshot
    def create_snapshot
      return unless @__last_scene&.viewport

      @snapshot = Sprite.new(@sup_viewport)
      add_disposable(@snapshot.bitmap = @__last_scene.viewport.snap_to_bitmap)
    end

    # Create the transition sprite
    def create_transition_sprite
      @transition = Sprite.new(@sup_viewport)
      @transition.set_bitmap('mining_game/black_background', :interface)
      @transition.set_position(0, -@transition.height)
    end

    # Create the background
    def create_background
      @background = Background.new(@viewport)
    end

    # Create the tool buttons
    def create_tool_buttons
      @tool_buttons = Tool_Buttons.new(@viewport)
    end

    # Create the stack of diggables
    def create_diggable_stacks
      @diggable_stack = Diggable_Stack.new(@viewport, @handler.arr_items, @handler.arr_irons)
    end

    # Create the stack of tiles
    def create_tiles_stack
      @tiles_stack = Tiles_Stack.new(@viewport, @handler.arr_tiles_state)
    end

    # Create the hit counter
    def create_hit_counter
      @hit_counter_stack = Hit_Counter_Stack.new(@viewport)
    end

    # Create the tool's sprite
    def create_tool_sprite
      @tool_sprite = Tool_Sprite.new(@viewport)
    end

    # Create the tool's hit sprite
    def create_tool_hit_sprite
      @tool_hit_sprite = Tool_Hit_Sprite.new(@viewport)
    end

    # Create the iron's hit sprite
    def create_iron_hit_sprite
      @iron_hit_sprite = Sprite.new(@viewport)
      @iron_hit_sprite.set_bitmap('mining_game/iron_hit', :interface)
                      .visible = false
    end
  end
end
