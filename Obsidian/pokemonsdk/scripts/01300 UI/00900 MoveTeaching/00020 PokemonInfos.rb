module UI
  module MoveTeaching
    # UI part displaying the Pokémon informations in the Skill Learn scene
    class PokemonInfos < SpriteStack
      # List of Pokemon that shouldn't show the gender sprite
      NO_GENDER = %i[nidoranf nidoranm]
      # Create sprite & some informations of the Pokémon
      # @param viewport [Viewport]
      def initialize(viewport)
        super(viewport, 8, 15, default_cache: :interface)
        create_sprites
      end

      # Set the data of the Pokemon
      def data=(pokemon)
        super
        @gender.x = @name.x + @name.real_width + 2
        @gender.visible = false if NO_GENDER.include?(pokemon.db_symbol)
      end

      # Update the graphics
      def update_graphics
        @sprite.update
      end

      private

      def create_sprites
        @sprite = create_sprite
        @name = create_name
        @gender = create_gender
      end

      # @return [UI::PokemonFaceSprite]
      def create_sprite
        add_sprite(*sprite_coordinates, NO_INITIAL_IMAGE, type: UI::PokemonFaceSprite)
      end

      # @return Array of coordinates of the Pokémon face sprite
      def sprite_coordinates
        return 48, 110 # 0, 13
      end

      # @return [SymText]
      def create_name
        add_text(*name_coordinates, :given_name, type: SymText, color: 10)
      end

      # @return Array of coordinates of the Pokémon name
      def name_coordinates
        return 3, -2, 0, 13
      end

      # @return [GenderSprite]
      def create_gender
        add_sprite(*gender_coordinates, NO_INITIAL_IMAGE, type: GenderSprite)
      end

      # @return Array of coordinates of the Pokémon gender
      def gender_coordinates
        return 2, 0
      end
    end
  end
end
