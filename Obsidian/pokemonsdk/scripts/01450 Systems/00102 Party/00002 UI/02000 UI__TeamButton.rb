module UI
  # Button that show basic information of a Pokemon
  class TeamButton < SpriteStack
    # Get the Item text to perform specific operations
    # @return [SymText]
    attr_reader :item_text
    # List of the Y coordinate of the button (index % 6), relative to the contents definition !
    CoordinatesY = [0, 24, 64, 88, 128, 152]
    # List of the X coordinate of the button (index % 2), relative to the contents definition !
    CoordinatesX = [0, 160]
    # List of the Y coordinate of the background textures
    TextureBackgroundY = [0, 56, 112, 168]
    # Height of the background texture
    TextureBackgroundHeight = 56
    # Get the selected state of the sprite
    # @return [Boolean]
    attr_reader :selected
    # Create a new Team button
    # @param viewport [Viewport] viewport where to show the button
    # @param index [Integer] Index of the button in the team
    def initialize(viewport, index)
      @index = index
      super(viewport, CoordinatesX[index % 2], CoordinatesY[index % 6])

      # Show the background
      @background = add_sprite(15, 7, background_name)
      @background.src_rect.height = TextureBackgroundHeight
      # Show the Pokemon icon sprite
      @icon = add_sprite(32, 24, NO_INITIAL_IMAGE, type: PokemonIconSprite)
      # Show the Pokemon nickname
      add_text(50, 17, 79, 16, :given_name, type: SymText, color: 9)
      # Show the Pokemon gender
      add_sprite(132, 20, NO_INITIAL_IMAGE, type: GenderSprite)
      # Show the Pokemon item hold
      add_sprite(123, 31, 'team/Item', type: HoldSprite)
      # Show the level of the Pokemon
      add_text(38, 38, 61, 16, :level_pokemon_number, type: SymText, color: 9)
      # Show the status of the Pokemon
      add_sprite(119, 46, NO_INITIAL_IMAGE, type: StatusSprite)
      # Show the HP Bar
      @hp = add_custom_sprite(create_hp_bar)
      # add_text(62, 34, 56, 16, :hp_pokemon_number, 2, type: SymText, color: 9)
      # Show the HP text with Power Small Green font
      with_font(20) do
        add_text(62, 34 + 5, 56, 13, :hp_text, 1, type: SymText, color: 9)
      end
      # Show the item button
      @item_sprite = add_sprite(24, 39, 'team/But_Object', 1, 2, type: SpriteSheet)
      # Show the Pokemon item name
      @item_text = add_text(27, 40, 113, 16, :item_name, type: SymText)
      # Hide item by default
      hide_item_name
      @selected = false
      # Position adjustment
      @x += 15
      @y += 7
    end

    # Set the data of the SpriteStack
    # @param data [PFM::Pokemon]
    def data=(data)
      super(data)
      @item_text.visible = @item_sprite.visible
      update_background
    end

    # Update the background according to the selected state
    def update_background
      if @data.dead?
        @background.src_rect.y = TextureBackgroundY[@selected ? 3 : 2]
      else
        @background.src_rect.y = TextureBackgroundY[@selected ? 1 : 0]
      end
    end

    # Set the selected state of the sprite
    # @param v [Boolean]
    def selected=(v)
      @selected = v
      update_background
      @item_sprite.sy = v ? 1 : 0
      @item_text.load_color(v ? 9 : 0)
    end

    # Show the item name
    def show_item_name
      @item_sprite.visible = @item_text.visible = true
    end

    # Hide the item name
    def hide_item_name
      @item_sprite.visible = @item_text.visible = false
    end

    # Refresh the button
    def refresh
      self.data = @data
    end

    # Update the graphics
    def update_graphics
      @icon.update
    end

    private

    # Return the background name
    # @return [String] name of the background
    def background_name
      'team/but_party'
    end

    # Create the HP Bar for the pokemon
    # @return [UI::Bar]
    def create_hp_bar
      bar = UI::Bar.new(@viewport, @x + 64, @y + 34, RPG::Cache.interface('team/HPBars'), 53, 4, 0, 0, 3)
      # Define the data source of the HP Bar
      bar.data_source = :hp_rate
      return bar
    end
  end
end
