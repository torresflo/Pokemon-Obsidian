module UI
  class SaveWindow < Window
    # Height of a line in the save window
    LINE_HEIGHT = 16
    # Number of lines in the save window
    LINE_COUNT = 5
    # Width of the save window
    WIDTH = 160
    # List all the color used [default, blue, red, green]
    COLORS = [0, 1, 2, 3]
    # Corrupted save file message
    CORRUPTED_FILE_MESSAGE = 'Corrupted Save File'
    # @return [Integer, nil] the index of the save
    attr_reader :index
    # @return [PFM::Pokemon_Party, nil, false] the data
    attr_reader :data
    # Create a new Save Window
    # @param viewport [Viewport] the viewport in which the save window is shown
    # @param index [Intger, nil] index of the save, if nil, the current save and the window will be shown top left
    # @param ypos [Integer] the expected y position of the window (last window y + height)
    def initialize(viewport, index = nil, ypos = 0)
      super(viewport, *init_coordinates(viewport, index, ypos))
      # @type [PFM::Pokemon_Party] current party
      @data = nil
      @stack = SpriteStack.new(self)
      @index = index
      init_texts
      init_graphics
    end

    # Set the data
    # @param party [PFM::Pokemon_Party, nil, false] nil means corrupted save, false means new game
    def data=(party)
      if party
        @data = party
        @stack.data = self
        self.height = @legit_height if height != @legit_height
      else # Corrupted data / New Game
        self.height = @legit_height - LINE_HEIGHT * (LINE_COUNT - 1)
        if party.nil? # Corrupted
          @first_text.text = CORRUPTED_FILE_MESSAGE
          @first_text.load_color(COLORS[2])
        else
          @first_text.text = ext_text(9000, 0)
          @first_text.load_color(COLORS[0])
        end
      end
      update_player(party)
    end

    # Return the current zone name
    # @return [String]
    def zone_name
      @data.env.current_zone_name
    end

    # Return the number of badges
    # @return [Integer]
    def badge_count
      @data.trainer.badge_counter
    end

    # Return the number of pokemon seen
    # @return [Integer]
    def pokedex_count
      @data.pokedex.pokemon_seen
    end

    # Return the play time
    # @return [String]
    def play_time
      @data.trainer.play_time_text
    end

    # Return the player name
    # @return [String]
    def player_name
      @data.trainer.name
    end

    private

    # Create all the required texts
    def init_texts
      init_first_text
      init_player_text
      @text_y = LINE_HEIGHT
      init_continue_text
      init_badge_text
      init_pokedex_text
      init_time_text
    end

    # Create all the graphics
    def init_graphics
      # @type [Sprite]
      @player_character = Sprite.new(self).set_position(0, LINE_HEIGHT * 2)
    end

    # Show the first line
    def init_first_text
      @first_text = add_text(0, 0, WIDTH, LINE_HEIGHT, :zone_name, color: COLORS[3], type: SymText)
    end

    # Show the player name text
    def init_player_text
      @player_text = add_text(0, LINE_HEIGHT, WIDTH - 2, LINE_HEIGHT, :player_name, 2, type: SymText)
    end

    # Show CONTINUE if in the right context
    def init_continue_text
      return unless index

      add_text(0, @text_y, 0, LINE_HEIGHT, text_get(25, 0), color: COLORS[0])
    end

    # Show the number of badge
    def init_badge_text
      @text_y += LINE_HEIGHT
      add_text(32, @text_y, 0, LINE_HEIGHT, text_get(25, 1), color: COLORS[0])
      add_text(0, @text_y, WIDTH - 2, LINE_HEIGHT, :badge_count, 2, color: COLORS[1], type: SymText)
    end

    # Show the number of Pokemon seen in the dex
    def init_pokedex_text
      @text_y += LINE_HEIGHT
      add_text(32, @text_y, 0, LINE_HEIGHT, text_get(25, 3), color: COLORS[0])
      add_text(0, @text_y, WIDTH - 2, LINE_HEIGHT, :pokedex_count, 2, color: COLORS[1], type: SymText)
    end

    # Show the play time text
    def init_time_text
      @text_y += LINE_HEIGHT
      add_text(32, @text_y, 0, LINE_HEIGHT, text_get(25, 5), color: COLORS[0])
      add_text(0, @text_y, WIDTH - 2, LINE_HEIGHT, :play_time, 2, color: COLORS[1], type: SymText)
    end

    # Calculate the coordinate of the save window
    # @param viewport [Viewport] the viewport in which the save window is shown
    # @param index [Intger, nil] index of the save, if nil, the current save and the window will be shown top left
    # @param ypos [Integer] the expected y position of the window (last window y + height)
    def init_coordinates(viewport, index, ypos)
      wb = current_window_builder(DEFAULT_SKIN)
      height = LINE_HEIGHT * LINE_COUNT + wb[5] + wb[-1]
      width = WIDTH + wb[4] + wb[-2]
      @legit_height = height
      return [2, 2, width, height] unless index
      w2 = viewport.rect.width / 2
      return [w2 - width / 2, ypos + 2, width, height]
    end

    # Update the player text and character
    # @param party [PFM::PokemonParty, nil, false]
    def update_player(party)
      if party
        @player_character.visible = true
        character_name = party.game_player.character_name.clone
        character_name.gsub!(party.game_player.chara_by_state, Game_Player::STATE_APPEARANCE_SUFFIX[:walking])
        @player_character.set_bitmap(character_name, :character).set_rect_div(0, 0, 4, 4)
        @player_text.load_color(COLORS[@data.trainer.playing_girl ? 2 : 1])
      else
        @player_character.visible = false
      end
    end
  end
end
