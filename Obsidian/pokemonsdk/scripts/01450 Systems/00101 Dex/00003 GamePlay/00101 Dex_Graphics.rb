module GamePlay
  class Dex
    # Create all the graphics
    def create_graphics
      create_viewport
      create_base_ui
      unless @page_id # If we're only showing a Pokemon Dex info we'll not create the other sprites
        create_list
        create_arrow
        create_scroll_bar
        create_progression
        create_worldmap
      end
      create_face
      create_frame
      create_info
      # We update the state to give the dex an initial state before it shows
      change_state(@state)
    end

    # Update all the graphics
    def update_graphics
      @base_ui.update_background_animation
      update_arrow
      @pokeface.update_graphics
    end

    private

    # Update the arrow animation
    def update_arrow
      return unless @arrow&.visible
      return if Graphics.frame_count % 15 != 0
      @arrow.x += @arrow_direction
      @arrow_direction = 1 if @arrow.x <= 127
      @arrow_direction = -1 if @arrow.x >= 129
    end

    # Create the viewport and a Stack making the graphic creation easier
    def create_viewport
      @viewport = Viewport.create(:main, 50_000)
      @stack = SpriteStack.new(@viewport, default_cache: :pokedex)
    end

    # Create the base ui
    def create_base_ui
      btn_texts = button_texts
      @base_ui = UI::GenericBaseMultiMode.new(@viewport, btn_texts, [UI::GenericBase::DEFAULT_KEYS] * btn_texts.size)
      @ctrl = @base_ui.ctrl
    end

    # Create the Pokemon list
    def create_list
      @list = Array.new(6) { |i| DexButton.new(@viewport, i) }
    end

    # Create arrow (telling which Pokemon we're choosing)
    def create_arrow
      @arrow = @stack.add_sprite(127, 0, 'arrow')
    end

    # Create the scrollbar
    def create_scroll_bar
      @scrollbar = @stack.add_sprite(309, 36, 'scroll')
      @scrollbut = @stack.add_sprite(308, 41, 'but_scroll')
    end

    # Create the frame sprite
    def create_frame
      @frame = Sprite.new(@viewport)
    end

    # Create the face sprite ui
    def create_face
      @pokeface = DexWinSprite.new(@viewport)
    end

    # Create the progression ui
    def create_progression
      @seen_got = DexSeenGot.new(@viewport)
    end

    # Create the info ui
    def create_info
      @pokemon_info = DexWinInfo.new(@viewport)
      @pokemon_descr = @stack.add_text(11, 153, 298, 16, nil.to_s, color: 10)
    end

    # Create the worldmap ui
    def create_worldmap
      @pokemon_worldmap = GamePlay.town_map_class.new(:pokedex, $env.get_worldmap)
      @pokemon_worldmap.create_graphics
    end

    # Get the button text for the generic UI
    # @return [Array<Array<String>>]
    def button_texts
      return [[nil, nil, nil, ext_text(9000, 9)]] * 3 if @page_id

      return [
        [ext_text(9000, 6), ext_text(9000, 7), ext_text(9000, 8), ext_text(9000, 9)],
        [ext_text(9000, 10), ext_text(9000, 11), ext_text(9000, 12), ext_text(9000, 13)],
        [ext_text(9000, 6), ext_text(9000, 7), ext_text(9000, 8), ext_text(9000, 9)]
      ]
    end
  end
end
