module UI
  # Dex sprite that show the Pokemon sprite with its name
  class DexWinSprite < SpriteStack
    # Create a new dex win sprite
    def initialize(viewport)
      # Create the sprite stack at coordinate 3, 11 using the RPG::Cache.pokedex as image source
      super(viewport, 3, 11, default_cache: :pokedex)

      # Show the background of the DexWinSprite
      add_background('WinSprite')
      # Show the Battler face of the Pokemon (Warning: PokemonFaceSprite use the bottom center as sprite origin)
      @sprite = add_sprite(60, 124, NO_INITIAL_IMAGE, type: PokemonFaceSprite)
      # Show the name of the Pokemon in bold upper-case
      pokemon_name = add_text(3, 6, 116, 19, :name_upper, 1, type: SymText, color: 10)
      pokemon_name.bold = true
    end

    # Update the graphics
    def update_graphics
      @sprite.update
    end
  end

  # Dex sprite that show the Pokemon location
  class DexSeenGot < SpriteStack
    # Create a new dex win sprite
    def initialize(viewport)
      # Create the sprite stack at coordinate 0, 152 using the RPG::Cache.pokedex as image source
      super(viewport, 0, 152, default_cache: :pokedex)

      # Show the background image
      add_background('WinNum')
      # Show the "Seen: " text
      seen_text = add_text(2, 0, 79, 26, ext_text(9000, 20), color: 10)
      seen_text.bold = true
      # Show the number of Pokemon Seen
      add_text(seen_text.real_width + 4, 0, 79, 26, :pokemon_seen, 0, type: SymText, color: 10)
      # Show the "Got: " text
      got_text = add_text(2, 28, 79, 26, ext_text(9000, 21), color: 10)
      got_text.bold = true
      # Show the number of Pokemon Got
      add_text(got_text.real_width + 4, 28, 79, 26, :pokemon_captured, 0, type: SymText, color: 10)

      # Define the Pokedex as text source
      self.data = $pokedex
    end
  end

  # Dex sprite that show the Pokemon infos
  class DexWinInfo < SpriteStack
    # Change the data
    # Array of visible sprites if the Pokemon was captured
    VISIBLE_SPRITES = 1..7
    # Create a new dex win sprite
    def initialize(viewport)
      # Create the sprite stack at coordinate 131, 37 using the RPG::Cache.pokedex as image source
      super(viewport, 131, 37, default_cache: :pokedex)

      # Show the background of the WinInfos
      add_background('WinInfos')
      # Show the "caught" indicator
      add_sprite(8, 4, 'Catch')
      # Show the Pokedex Name of the Pokemon
      add_text(29, 4, 116, 16, :pokedex_name, type: SymText, color: 10)
      # Show the Specie of the Pokemon
      add_text(9, 27, 116, 16, :pokedex_species, type: SymText)
      # Show the weight (formated) of the Pokemon
      add_text(9, 67, 116, 16, :pokedex_weight, type: SymText)
      # Show the height (formated) of the Pokemon
      add_text(9, 87, 116, 16, :pokedex_height, type: SymText)
      # Show the 1st type of the Pokemon
      add_sprite(25, 47, NO_INITIAL_IMAGE, true, type: Type1Sprite)
      # Show the 2nd type of the Pokemon
      add_sprite(112, 47, NO_INITIAL_IMAGE, true, type: Type2Sprite)
    end

    # Define the Pokemon shown by the UI
    # @param pokemon [PFM::Pokemon]
    def data=(pokemon)
      super(pokemon)
      # Show / hide the sprites according to the captured state of the Pokemon
      is_captured = pokemon && $pokedex.pokemon_caught?(pokemon.id)
      VISIBLE_SPRITES.each do |i|
        @stack[i].visible = is_captured
      end
    end
  end

  # Dex sprite that show the Pokemon infos
  class DexButton < SpriteStack
    # Create a new dex button
    # @param viewport [LiteRGSS::Viewport]
    # @param index [Integer] index of the sprite in the viewport
    def initialize(viewport, index)
      # Create the sprite stack at coordinate 147, 62 using the RPG::Cache.pokedex as image source
      super(viewport, 147, 62, default_cache: :pokedex)

      # Show the background image
      add_background('But_List')
      # Show the caught indicator
      @catch_icon = add_sprite(119, 9, 'Catch')
      # Show the Pokemon Icon Sprite
      add_sprite(17, 15, NO_INITIAL_IMAGE, type: PokemonIconSprite)
      # Show the Pokemon formated ID
      add_text(35, 1, 116, 16, :id_text3, type: SymText, color: 10)
      # Show the Pokemon name
      add_text(35, 16, 116, 16, :name, type: SymText, color: 10)
      # Show the obfuscator in forground when the Pokemon button is not
      @obfuscator = add_foreground('But_ListShadow')

      # Adjust the position according to the index
      set_position(index == 0 ? 147 : 163, y - 40 + index * 40)
    end

    # Change the data
    # @param pokemon [PFM::Pokemon] the Pokemon shown by the button
    def data=(pokemon)
      super(pokemon)
      # Change the catch visibility to the captured state of the Pokemon
      @catch_icon.visible = $pokedex.pokemon_caught?(pokemon.id)
    end

    # Tell the button if it's selected or not : change the obfuscator visibility & x position
    # @param value [Boolean] the selected state
    def selected=(value)
      @obfuscator.visible = !value
      set_position(value ? 147 : 163, y)
    end
  end

  # Dex sprite that show the Pokemon location
  class DexWinMap < SpriteStack
    # Filename of the World Map Icon
    MAP_ICON = '344'

    # Create a new dex win sprite
    def initialize(viewport, display_controls = true)
      # Create the sprite stack at coordinate 0, 0 using the RPG::Cache.pokedex as image source
      super(viewport, 0, 0, default_cache: :pokedex)

      @pkm_icon  = add_sprite(28, 123, NO_INITIAL_IMAGE, type: PokemonIconSprite)
      @item_icon = add_sprite(13, 106, NO_INITIAL_IMAGE)
      @location  = add_text(10, 18, 132, 16, ext_text(9000, 19), 1, color: 10)
      @region    = add_text(150, 0, 150, 24, 'REGION', 2, color: 10)
      if display_controls
        add_sprite(40, 221, NO_INITIAL_IMAGE, :Y, type: KeyShortcut)
        add_text(60, 221, 140, 16, ext_text(9000, 32), color: 10) # Next worldmap
        add_sprite(190, 221, NO_INITIAL_IMAGE, :X, type: KeyShortcut)
        add_text(210, 221, 140, 16, ext_text(9000, 33), color: 10) # Zoom
      end

      # Set region text in bold
      @region.bold = true
    end

    # Change the data and the state
    # @param pokemon [PFM::Pokemon, :map] if set to map, we'll be showing the map icon
    def data=(pokemon)
      if pokemon == :map
        @pkm_icon.visible = false
        @item_icon.visible = true
        @item_icon.set_bitmap(MAP_ICON, :icon)
      elsif pokemon.is_a? PFM::Pokemon
        @pkm_icon.visible = true
        @item_icon.visible = false
        super(pokemon)
      end
    end

    # Set the location name
    # @param place [String] the name to display
    # @param color [Integer] the color code
    def set_location(place, color = 10)
      @location.multiline_text = place
      @location.load_color color
    end

    # Set the region name
    # @param place [String] the name to display
    # @param color [Integer] the color code
    def set_region(reg, color = 10)
      @region.multiline_text = reg.upcase
      @location.load_color color
    end
  end
end
