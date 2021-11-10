module GamePlay
  class BattleSprite < ::Yuki::Sprite
    #>Positions des sprites des Actors
    #A_Pos = [[13,157-5-44],[89,157+5-44] ,[40,157-44]] 174
    A_Pos = [[13,174-8],[89,174+8] ,[40,174]]
    #>Positions des sprites des Enemies
    #E_Pos = [[157,74-8-28],[214,74+2-28] ,[185,89-28]] 94
    E_Pos = [[157,94-14],[214,94-8] ,[185,94]]
    #Offsets = load_data("Data/PSDK/PokemonOffset.rxdata")
    #>Positions z sur l'écran
    Z = [37,38, 25, 24]
    #>Seuils d'offset
    Seuil1 = 1.5
    Seuil2 = 1.3
    #===
    #>initialisation
    #===
    def initialize(viewport, pokemon)
      super(viewport)
      @gif = nil
      self.pokemon = pokemon
    end

    # Update the sprite
    def update
      super
      if @gif
        @gif.update(bitmap) if bitmap
      end
    end

    # Dispose the sprite
    def dispose
      if @gif
        @gif = nil
        self.bitmap.dispose
      end
      super
    end

    #===
    #>Modification du Pokémon courant
    #===
    def pokemon=(pokemon)
      test_gif_dispose(pokemon)
      @pokemon = pokemon
      unless pokemon && !pokemon.dead?
        self.visible = false
        return
      end
      self.visible = true
      self.opacity = 255
      load_bitmap(pokemon)
      ajust_position
    end

    #===
    #>ajust_position
    # Repositionne les sprites correctement sur l'écran
    #===
    def ajust_position
      if @pokemon.position < 0
        pos = E_Pos
        index = $game_temp.vs_type == 2 ? -@pokemon.position - 1 : 2
        zoom = 1
      else
        pos = A_Pos
        index = $game_temp.vs_type == 2 ? @pokemon.position : 2
        zoom = 1#$zoom_factor > 1 ? 1.5 : 1
      end
      self.x = pos[index][0] + 48
      self.y = pos[index][1]# - Offsets[@pokemon.id].to_i
      self.z = Z[@pokemon.position]
      self.zoom = zoom
      #self.x += (self.ox = self.bitmap.width / 2)
      self.ox = bitmap.width / 2
      self.oy = bitmap.height
    end

    # Test if the Gif has to be disposed
    # @param pokemon [::PFM::Pokemon] the new pokemon
    def test_gif_dispose(pokemon)
      return unless @pokemon && @gif
      if !pokemon || (@pokemon.id != pokemon.id) || (@pokemon.form != pokemon.form)
        bitmap.dispose
        @gif = nil
      end
    end

    # Load the pokemon bitmap
    # @param pokemon [::PFM::Pokemon] the new pokemon
    def load_bitmap(pokemon)
      unless @gif
        gif = pokemon.position < 0 ? pokemon.gif_face : pokemon.gif_back
        if gif
          @gif = gif
          self.bitmap = Texture.new(@gif.width, @gif.height)
          @gif.update(bitmap)
        else
          self.bitmap = pokemon.position < 0 ? pokemon.battler_face : pokemon.battler_back
        end
      end
    end
  end
end
