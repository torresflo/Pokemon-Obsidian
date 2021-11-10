module UI
  # Window responsive of displaying the Level Up information when a Pokemon levels up
  class LevelUpWindow < UI::Window
    # Create a new Level Up Window
    # @param viewport [Viewport] viewport in which the Pokemon is shown
    # @param pokemon [PFM::Pokemon] Pokemon that is currently leveling up
    # @param list0 [Array] old basis stats
    # @param list1 [Array] new basis stats
    def initialize(viewport, pokemon, list0, list1)
      super(viewport, window_x, Graphics.height - window_height, window_width, window_height)
      @pokemon = pokemon
      @list0 = list0
      @list1 = list1
      create_sprites
    end

    # Update the Pokemon Icon animation
    def update
      @pokemon_icon.update
    end

    private

    # Create all the sprites inside the window
    def create_sprites
      create_pokemon_icon
      create_pokemon_name
      create_stats_texts
    end

    # Create the Pokemon Icon sprite
    def create_pokemon_icon
      @pokemon_icon = PokemonIconSprite.new(self, false)
      @pokemon_icon.data = @pokemon
    end

    # Create the Pokemon Name sprite
    def create_pokemon_name
      add_text(@pokemon_icon.width + 2, 0, 0, @pokemon_icon.height, @pokemon.given_name)
    end

    # Create all the stats texts
    def create_stats_texts
      format_str = '%d (+%d)'
      sprite_stack.with_surface(0, @pokemon_icon.height, rect.width) do
        6.times do |i|
          add_line(i + 1, text_get(22, 121 + i))
          add_line(i + 1, format(format_str, @list1[i], @list1[i] - @list0[i]), 2, color: 1)
        end
      end
    end

    # width of the Window
    def window_width
      140
    end

    # Height of the Window
    def window_height
      180
    end

    # X position of the Window
    def window_x
      Graphics.width - window_width - 2
    end

    # Y position of the Window
    def window_y
      Graphics.height - window_height
    end
  end
end
