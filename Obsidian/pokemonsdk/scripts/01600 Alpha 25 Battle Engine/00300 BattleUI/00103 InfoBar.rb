module BattleUI
  # Object that show the Battle Bar of a Pokemon in Battle
  class InfoBar < UI::SpriteStack
    # FILES used to show a bar
    FILES = %w[battlebar_actor battlebar_enemy]
    # Normal position of actor bars
    ACTOR_POSITION = [[160, 101], [151, 140], [155, 120]]
    # Normal position of enemy bars
    ENEMY_POSITION = [[6, 0], [0, 34], [3, 17]]
    # The information of the HP Bar
    HP_BAR_INFO = [48, 4, 0, 0, 6] # bw, bh, bx, by, nb_states
    # The information of the Exp Bar
    EXP_BAR_INFO = [93, 2, 0, 0, 1]
    # @return [PFM::PokemonBattler] the pokemon associated to the bar
    attr_reader :pokemon

    include UI

    # Create a new Battle Bar
    # @param viewport [LiteRGSS::Viewport]
    # @param pokemon [PFM::Pokemon]
    def initialize(viewport, pokemon)
      super(viewport)
      @background = push(0, 0, nil)
      @got = push(134, 2, 'battlebar_get')
      @gender = push(0, 0, nil, type: GenderSprite)
      @name = add_text(0, 0, 84, 16, :given_name, 2, 1, type: SymText, color: 9)
      @level = add_text(0, 0, 32, 16, :level_pokemon_number, 0, 1, type: SymText, color: 9)
      @hp_bar = push_sprite Bar.new(viewport, 0, 0, RPG::Cache.interface('battlebar_hp'), *HP_BAR_INFO)
      @hp_text = add_text(75, 31, 68, 16, :hp_pokemon_number, 1, 1, type: SymText, color: 9)
      @exp_bar = push_sprite Bar.new(viewport, 0, 0, RPG::Cache.interface('battlebar_exp'), *EXP_BAR_INFO)
      @status = push(0, 0, nil, type: StatusSprite)
      self.z = 10_000
      self.pokemon = pokemon
    end

    # Refresh the bar contents
    def refresh
      if @pokemon && !pokemon.dead?
        self.data = @pokemon
        @hp_bar.visible = @background.visible = true
        enemy? ? refresh_enemy : refresh_actor
      else
        self.visible = false
      end
    end

    # Sets the Pokemon shown by this bar
    # @param pokemon [PFM::Pokemon]
    def pokemon=(pokemon)
      self.data = @pokemon = pokemon
      refresh
      return unless pokemon && !pokemon.dead?
      adjust_position
    end

    # Adjust the position of the bar on the screen
    def adjust_position
      @x = @y = 0
      if enemy?
        adjust_enemy_position
      else
        adjust_actor_position
      end
      self.z = 10_038 + @pokemon.position * 2
    end

    # Tells the bar to go out of the screen
    # @param frame [Integer] number of frame
    # @return [self]
    def go_out(frame = 10)
      return self unless @pokemon&.position
      if enemy?
        move_to(enemy_outside_position, y, frame)
      else
        move_to(actor_outside_position, y, frame)
      end
      return self
    end

    # Tells the bar to come back on the screen
    # @param frame [Integer] number of frame
    # @return [self]
    def come_back(frame = 10)
      return self unless @pokemon && !@pokemon.dead?
      index = $game_temp.vs_type == 2 ? @pokemon.position : 2
      if enemy?
        pos = ENEMY_POSITION
        self.x = enemy_outside_position
      else
        pos = ACTOR_POSITION
        self.x = actor_outside_position
      end
      move_to(pos[index][0], y, frame)
      return self
    end

    private

    # Function telling if the Pokemon is an enemy or not
    # @return [Boolean]
    def enemy?
      @pokemon&.bank != 0
    end

    # Return the position of the bar when it's fully outside (enemy)
    # @return [Integer]
    def enemy_outside_position
      -@stack.first.bitmap.width - 16
    end

    # Return the position of the bar when it's fully outside (actor)
    # @return [Integer]
    def actor_outside_position
      @viewport.rect.width
    end

    # Refresh the bar contents when it's an enemy bar
    def refresh_enemy
      @hp_bar.rate = @pokemon.hp_rate
      @hp_text.visible = @exp_bar.visible = false
      @got.visible = $pokedex.pokemon_caught?(@pokemon.id)
    end

    # Refresh the bar contents when it's an actor bar
    def refresh_actor
      @hp_bar.rate = @pokemon.hp_rate
      @exp_bar.rate = @pokemon.exp_rate
      @hp_text.visible = @exp_bar.visible = true
      @got.visible = false
    end

    # Adjust the enemy bar position on screen
    def adjust_enemy_position
      pos = ENEMY_POSITION
      index = $game_temp.vs_type == 2 ? @pokemon.position : 2
      adjust_enemy_graphics_position
      set_position(pos[index][0], pos[index][1])
    end

    # Adjust the position of the sprites when the bar is for an enemy
    def adjust_enemy_graphics_position
      @background.set_position(16, 2).set_bitmap(FILES[1], :interface)
      @gender.set_position(87, 4)
      @name.set_position(0, 0)
      @level.set_position(108, 2)
      @hp_bar.set_position(79, 20)
      @status.set_position(27, 17)
      @got.set_position(134, 2)
    end

    def adjust_actor_position
      pos = ACTOR_POSITION
      index = $game_temp.vs_type == 2 ? @pokemon.position : 2
      adjust_actor_graphics_position
      set_position(pos[index][0], pos[index][1])
    end

    # Adjust the position of the sprites when the bar is for an actor
    def adjust_actor_graphics_position
      @background.set_position(32, 16).set_bitmap(FILES[0], :interface)
      @gender.set_position(98, 13)
      @name.set_position(12, 9)
      @level.set_position(119, 11)
      @hp_bar.set_position(85, 29)
      @hp_text.set_position(75, 28)
      @exp_bar.set_position(49, 45)
      @status.set_position(32, 26)
    end
  end
end
