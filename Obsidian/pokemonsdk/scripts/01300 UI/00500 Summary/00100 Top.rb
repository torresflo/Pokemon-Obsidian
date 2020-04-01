module UI
  # UI part displaying the generic information of the Pokemon in the Summary
  class Summary_Top < SpriteStack
    NO_GENDER = [29, 32]
    # Create a new Memo UI for the summary
    # @param viewport [Viewport]
    def initialize(viewport)
      super(viewport, 0, 0, default_cache: :interface)
      @sprite = push(55, 119, nil, type: PokemonFaceSprite)
      @name = add_text(11, 8, 100, 16, :given_name, type: SymText, color: 9)
      @gender = push(101, 10, nil, type: GenderSprite)
      @item = push(72 + 6, 74 + 16, nil, type: RealHoldSprite)
      @ball = push(107, 11, nil, ox: 16, oy: 16)
      push(10, 108, nil, type: StatusSprite)
    end

    # Set the Pokemon shown
    # @param pokemon [PFM::Pokemon]
    def data=(pokemon)
      super
      @gender.ox = 88 - @name.real_width
      @gender.visible = false if NO_GENDER.include?(pokemon.id) || pokemon.egg?
      @item.visible = false if pokemon.egg?
      @ball.set_bitmap(GameData::Item.icon(pokemon.captured_with), :icon)
    end

    # Update the graphics
    def update_graphics
      @sprite.update
    end
  end
end