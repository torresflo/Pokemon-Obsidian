#encoding: utf-8

module GamePlay
  # Object that show the Battle Bar of a Pokemon in Battle
  class BattleBar < UI::SpriteStack
    # Files used to show a bar
    Files = ["battlebar_actor","battlebar_enemy"]
    # Normal position of actor bars
    A_Pos = [[160,101],[151,140], [155,120]]
    # Normal position of enemy bars
    E_Pos = [[6,10-10],[0,44-10], [3,27-10]]
    # Gets the pokemon associated to the bar
    attr_reader :pokemon
    include UI
    # Create a new Battle Bar
    # @param viewport [Viewport]
    # @param pokemon [PFM::Pokemon]
    def initialize(viewport, pokemon)
      super(viewport)
      @background = push(0, 0, nil)
      @got = push(134, 2, "battlebar_get")
      @gender = push(0, 0, nil, type: GenderSprite)
      @name = add_text(0, 0, 84, 16, :given_name, 2, 1, type: SymText, color: 9)
      @mega_mark = add_sprite(0, 0, 'battle/mega_mark')
      @level = add_text(0, 0, 32, 16, :level_pokemon_number, 0, 1, type: SymText, color: 9)
      @hp_bar = push_sprite Bar.new(viewport, 0, 0, RPG::Cache.interface("battlebar_hp"), 48, 4, 0, 0, 6)
      @hp_text = add_text(75, 31, 68, 16, :hp_pokemon_number, 1, 1, type: SymText, color: 9)
      @exp_bar = push_sprite Bar.new(viewport, 0, 0, RPG::Cache.interface("battlebar_exp"),93, 2, 0, 0, 1)
      @status = push(0, 0, nil, type: StatusSprite)
      self.z = 10_000
      self.pokemon = pokemon
    end
    # Refresh the bar contents
    def refresh
      if @pokemon and !pokemon.dead?
        self.data = @pokemon
        @hp_bar.visible = @background.visible = true
        @pokemon.position < 0 ? refresh_enemy : refresh_actor
      else
        self.visible = false
      end
    end
    # Refresh the bar contents when it's an enemy bar
    def refresh_enemy
      @hp_bar.rate = @pokemon.hp_rate
      @hp_text.visible = @exp_bar.visible = false
      @got.visible = $pokedex.pokemon_caught?(@pokemon.id)
      @mega_mark.visible = @pokemon.mega_evolved?
    end
    # Refresh the bar contents when it's an actor bar
    def refresh_actor
      @hp_bar.rate = @pokemon.hp_rate
      @exp_bar.rate = @pokemon.exp_rate
      @hp_text.visible = @exp_bar.visible = true
      @got.visible = false
      @mega_mark.visible = @pokemon.mega_evolved?
    end
    # Sets the Pokémon shown by this bar
    # @param v [PFM::Pokemon]
    def pokemon=(v)
      self.data = @pokemon = v
      refresh
      return unless pokemon and !pokemon.dead?
      ajust_position
    end
    # Adjust the position of the bar on the screen
    def ajust_position
      @x = @y = 0
      if(@pokemon.position < 0)
        pos = E_Pos
        index = $game_temp.vs_type == 2 ? -@pokemon.position - 1 : 2
        adjust_position_enemy
      else
        pos = A_Pos
        index = $game_temp.vs_type == 2 ? @pokemon.position : 2
        adjust_position_actor
      end
      set_position(pos[index][0], pos[index][1])
      self.z = 10038 + @pokemon.position*2
    end
    # Adjust the position of the sprites when the bar is for an enemy
    def adjust_position_enemy
      @background.set_position(16, 2)
        .set_bitmap(Files[1], :interface)
      @gender.set_position(87, 4)
      @name.set_position(0, 0)
      @mega_mark.set_position(132, 13)
      @level.set_position(108, 2)
      @hp_bar.set_position(79, 20)
      @status.set_position(27, 17)
      @got.set_position(134, 2)
    end
    # Adjust the position of the sprites when the bar is for an actor
    def adjust_position_actor
      @background.set_position(32, 16)
        .set_bitmap(Files[0], :interface)
      @gender.set_position(98, 13)
      @name.set_position(12, 9)
      @mega_mark.set_position(137, 22)
      @level.set_position(119, 11)
      @hp_bar.set_position(85, 29)
      @hp_text.set_position(75, 28)
      @exp_bar.set_position(49, 45)
      @status.set_position(32, 26)
    end
    # Tells the bar to go out of the screen
    # @param frame [Integer] number of frame
    # @return [self]
    def go_out(frame = 10)
      return self unless @pokemon and pokemon.position
      if(@pokemon.position < 0)
        move_to(-@stack.first.bitmap.width, self.y, frame)
      else
        move_to(320, self.y, frame)
      end
      return self
    end
    # Tells the bar to come back on the screen
    # @param frame [Integer] number of frame
    # @return [self]
    def come_back(frame = 10)
      return self unless @pokemon and !pokemon.dead?
      if(@pokemon.position < 0)
        pos = E_Pos
        index = $game_temp.vs_type == 2 ? -@pokemon.position - 1 : 2
        self.x = -@stack.first.bitmap.width
      else
        pos = A_Pos
        index = $game_temp.vs_type == 2 ? @pokemon.position : 2
        self.x = 320
      end
      move_to(pos[index][0], self.y, frame)
      return self
    end
  end
end
