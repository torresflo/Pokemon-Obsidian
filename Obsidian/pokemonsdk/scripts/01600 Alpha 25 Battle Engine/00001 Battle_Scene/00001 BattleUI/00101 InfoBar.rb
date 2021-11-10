module BattleUI
  # Object that show the Battle Bar of a Pokemon in Battle
  # @note Since .25 InfoBar completely ignore bank & position info about Pokemon to make thing easier regarding positionning
  class InfoBar < UI::SpriteStack
    include UI
    include GoingInOut
    include MultiplePosition
    # The information of the HP Bar
    HP_BAR_INFO = [92, 4, 0, 0, 6] # bw, bh, bx, by, nb_states
    # The information of the Exp Bar
    EXP_BAR_INFO = [88, 2, 0, 0, 1]
    # Get the Pokemon shown by the InfoBar
    # @return [PFM::PokemonBattler]
    attr_reader :pokemon
    # Get the animation handler
    # @return [Yuki::Animation::Handler{ Symbol => Yuki::Animation::TimedAnimation}]
    attr_reader :animation_handler
    # Get the position of the pokemon shown by the sprite
    # @return [Integer]
    attr_reader :position
    # Get the bank of the pokemon shown by the sprite
    # @return [Integer]
    attr_reader :bank
    # Get the scene linked to this object
    # @return [Battle::Scene]
    attr_reader :scene
    # Create a new InfoBar
    # @param viewport [Viewport]
    # @param scene [Battle::Scene]
    # @param pokemon [PFM::Pokemon]
    # @param bank [Integer]
    # @param position [Integer]
    def initialize(viewport, scene, pokemon, bank, position)
      super(viewport)
      @animation_handler = Yuki::Animation::Handler.new
      @bank = bank
      @position = position
      @scene = scene
      create_sprites
      self.pokemon = pokemon
    end

    # Update the InfoBar
    def update
      @animation_handler.update
    end

    # Tell if the InfoBar animations are done
    # @return [Boolean]
    def done?
      return @animation_handler.done?
    end

    # Sets the Pokemon shown by this bar
    # @param pokemon [PFM::Pokemon]
    def pokemon=(pokemon)
      @pokemon = pokemon
      refresh
    end

    # Refresh the bar contents
    def refresh
      if @pokemon
        self.visible = true
        self.data = @pokemon
        set_position(*sprite_position) if in?
      else
        self.visible = false
      end
    end

    private

    # Get the base position of the Pokemon in 1v1
    # @return [Array(Integer, Integer)]
    def base_position_v1
      return 184, 9 if enemy?

      return 2, 198
    end

    # Get the base position of the Pokemon in 2v2+
    # @return [Array(Integer, Integer)]
    def base_position_v2
      return 48, 9 if enemy?

      return 2, 195
    end

    # Get the offset position of the Pokemon in 2v2+
    # @return [Array(Integer, Integer)]
    def offset_position_v2
      return 136, 3 if enemy?

      return 136, -3
    end

    def create_sprites
      create_background
      create_hp
      create_exp
      create_name
      create_catch_sprite
      create_gender_sprite
      create_level
      create_status
    end

    def create_background
      @background = add_sprite(0, 0, NO_INITIAL_IMAGE, type: Background)
    end

    def create_hp
      @hp_background = add_sprite(*hp_background_coordinates, 'battle/battlebar_')
      # @type [UI::Bar]
      @hp_bar = push_sprite Bar.new(@viewport, *hp_bar_coordinates, RPG::Cache.interface('battle/bars_hp'), *HP_BAR_INFO)
      @hp_bar.data_source = :hp_rate
      @hp_text = add_text(66, 17, 0, 10, enemy? ? :void_string : :hp_pokemon_number, type: SymText, color: 10)
    end

    def create_exp
      return if enemy?

      add_sprite(36, 30, 'battle/battlebar_exp')
      # @type [UI::Bar]
      @exp_bar = push_sprite Bar.new(@viewport, 37, 31, RPG::Cache.interface('battle/bars_exp'), *EXP_BAR_INFO)
      @exp_bar.data_source = :exp_rate
    end

    def hp_background_coordinates
      return enemy? ? [8, 12] : [18, 12]
    end

    def hp_bar_coordinates
      return enemy? ? [x + 23, y + 13] : [x + 33, y + 13]
    end

    def create_name
      with_font(20) do
        @name = add_text(8, -4, 0, 16, :given_name, 0, 1, color: 10, type: SymText)
      end
    end

    def create_catch_sprite
      add_sprite(118, 10, 'battle/ball', type: PokemonCaughtSprite)
    end

    def create_gender_sprite
      add_sprite(81, -3, NO_INITIAL_IMAGE, type: GenderSprite)
    end

    def create_level
      add_text(91, -6, 0, 16, :level_pokemon_number, 0, 1, color: 10, type: SymText)
    end

    def create_status
      add_sprite(8, 19, NO_INITIAL_IMAGE, type: StatusSprite)
    end

    # Creates the go_in animation
    # @return [Yuki::Animation::TimedAnimation]
    def go_in_animation
      origin_y = enemy? ? -@background.height : @viewport.rect.height + @background.height
      return Yuki::Animation.move_discreet(0.2, self, x, origin_y, *sprite_position)
    end

    # Creates the go_out animation
    # @return [Yuki::Animation::TimedAnimation]
    def go_out_animation
      target_y = enemy? ? -@background.height : @viewport.rect.height + @background.height
      return Yuki::Animation.move_discreet(0.2, self, *sprite_position, x, target_y)
    end

    # Class showing the ball sprite if the Pokemon is enemy and caught
    class PokemonCaughtSprite < ShaderedSprite
      # Set the Pokemon Data
      # @param pokemon [PFM::Pokemon]
      def data=(pokemon)
        self.visible = pokemon.bank != 0 && $pokedex.pokemon_caught?(pokemon.id)
      end
    end

    # Class showing the right background depending on the pokemon
    class Background < ShaderedSprite
      # Set the Pokemon Data
      # @param pokemon [PFM::Pokemon]
      def data=(pokemon)
        return unless (self.visible = pokemon)

        set_bitmap(background_filename(pokemon), :interface)
      end

      def background_filename(pokemon)
        return 'battle/battlebar_enemy' if pokemon.bank != 0
        return 'battle/battlebar_actor' if pokemon.from_party?

        return 'battle/battlebar_ally'
      end
    end
  end
end
