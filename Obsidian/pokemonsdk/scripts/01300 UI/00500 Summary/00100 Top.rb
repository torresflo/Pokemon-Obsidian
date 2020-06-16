module UI
  # UI part displaying the generic information of the Pokemon in the Summary
  class Summary_Top < SpriteStack
    # List of Pokemon that shouldn't show the gender sprite
    NO_GENDER = %i[nidoran♀ nidoran♂]
    # Create a new Memo UI for the summary
    # @param viewport [Viewport]
    def initialize(viewport)
      super(viewport, 0, 0, default_cache: :interface)
      init_sprite
    end

    # Set the Pokemon shown
    # @param pokemon [PFM::Pokemon]
    def data=(pokemon)
      super
      @gender.ox = 88 - @name.real_width
      @gender.visible = false if NO_GENDER.include?(pokemon.db_symbol) || pokemon.egg?
      @item.visible = false if pokemon.egg?
      @ball.set_bitmap(GameData::Item[pokemon.captured_with].icon, :icon)
      @star.visible = pokemon.shiny && !pokemon.egg?
    end

    # Update the graphics
    def update_graphics
      @sprite.update
    end

    private

    def init_sprite
      @sprite = create_sprite
      @name = create_name_text
      @gender = create_gender
      @item = create_item
      @ball = create_ball
      @star = create_star
      create_status
    end

    # @return [PokemonFaceSprite]
    def create_sprite
      push(55, 119, nil, type: PokemonFaceSprite)
    end

    # @return [SymText]
    def create_name_text
      add_text(11, 8, 100, 16, :given_name, type: SymText, color: 9)
    end

    # @return [GenderSprite]
    def create_gender
      push(101, 10, nil, type: GenderSprite)
    end

    # @return [RealHoldSprite]
    def create_item
      push(72 + 6, 74 + 16, nil, type: RealHoldSprite)
    end

    # @return [LiteRGSS::Sprite]
    def create_ball
      push(107, 11, nil, ox: 16, oy: 16)
    end

    # @return [LiteRGSS::Sprite]
    def create_star
      push(91, 107, 'shiny')
    end

    def create_status
      push(10, 108, nil, type: StatusSprite)
    end
  end
end
