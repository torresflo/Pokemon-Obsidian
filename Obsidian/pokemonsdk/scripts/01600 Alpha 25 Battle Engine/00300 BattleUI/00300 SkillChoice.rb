module BattleUI
  # Class that allow to choose the skill of the Pokemon
  #
  #
  # The object tells the player validated on #validated? and the result is stored inside #result
  #
  # The object should be updated through #update otherwise no validation is possible
  #
  # When result was taken, the scene should call #reset to undo the validated state
  class SkillChoice
    # @return [Battle::Move, :cancel] the selected move
    attr_reader :result
    # @return [PFM::PokemonBattler] the pokemon the player choosed a move
    attr_reader :pokemon
    # Create a new SkillChoice UI
    # @param viewport [Viewport]
    def initialize(viewport)
      @skills = SkillWindow.new(viewport)
      @info = SkillInfoWindow.new(viewport)
      # List of last index according to the pokemon that was used
      # @type [Hash{ PFM::PokemonBattler => Integer }]
      @last_indexes = {}
    end

    # Update the window cursor
    def update
      return if validated?
      return validate if Input.trigger?(:A) || (Mouse.trigger?(:left) && @skills.simple_mouse_in?)
      return cancel if Input.trigger?(:B)
      last_index = @skills.index
      update_key_index(last_index)
      update_mouse_index
      if last_index != @skills.index
        @skills.update_cursor
        @info.data = @pokemon.moveset[@skills.index]
      end
    end

    # Tell if the player made a choice
    # @return [Boolean]
    def validated?
      !@result.nil?
    end

    # Reset the Skill choice
    # @param pokemon [PFM::PokemonBattler]
    def reset(pokemon)
      @pokemon = pokemon
      @skills.data = pokemon
      @skills.index = @last_indexes[pokemon] || 0
      @skills.update_cursor
      @info.data = @pokemon.moveset[@skills.index]
      @result = nil
    end

    # Set the UI visibility
    # @param value [Boolean]
    def visible=(value)
      @info.visible = value
      @skills.visible = value
    end

    private

    # Validate the user choice
    def validate
      @result = @pokemon.moveset[@skills.index]
      @last_indexes[@pokemon] = @skills.index
      $game_system.se_play($data_system.decision_se)
    end

    # Cancel the player choice
    def cancel
      @result = :cancel
      $game_system.se_play($data_system.cancel_se)
    end

    # Update the mouse index if the mouse moved
    def update_mouse_index
      return unless Mouse.moved
      return unless @skills.simple_mouse_in?
      @skills.stack.each_with_index do |text, index|
        break @skills.index = index if text.simple_mouse_in?
      end
    end

    # Update the index if a key was pressed
    def update_key_index(last_index)
      case Input.dir4
      when 6
        @skills.index = last_index < 2 ? 1 : 3
      when 4
        @skills.index = last_index < 2 ? 0 : 2
      when 2
        @skills.index = last_index.odd? ? 3 : 2
      when 8
        @skills.index = last_index.odd? ? 1 : 0
      end
    end

    # Window allowing to select the skill
    class SkillWindow < UI::Window
      # @return [Integer] current index
      attr_reader :index
      # Total width of the window
      WINDOW_WIDTH = 220
      # Total height of the window
      WINDOW_HEIGHT = 48
      # Delta in X between two options
      DELTA_X = 96
      # Delta in Y between two options
      DELTA_Y = 16
      # Offset X of the text to let the cursor display
      TEXT_OX = 16
      # Create the new SkillWindow
      # @param viewport [Viewport]
      def initialize(viewport)
        super(viewport, 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
        create_texts
        load_cursor
        @index = 0
        self.active = true
        self.visible = false
      end

      # Set the Pokemon seen in the UI
      # @param pokemon [PFM::PokemonBattler]
      def data=(pokemon)
        @moveset = pokemon.moveset
        4.times do |index|
          @stack.stack[index].data = @moveset[index]
        end
      end

      # Set the index
      # @param value [Integer]
      def index=(value)
        @index = value if @moveset[value]
      end

      # Update the cursor position
      def update_cursor
        cursor_rect.set((@index % 2) * DELTA_X, (@index / 2) * DELTA_Y)
        $game_system.se_play($data_system.cursor_se)
      end

      private

      def create_texts
        add_text(TEXT_OX, 0, DELTA_X - TEXT_OX, DELTA_Y, :name, type: UI::SymText)
        add_text(TEXT_OX + DELTA_X, 0, DELTA_X - TEXT_OX, DELTA_Y, :name, type: UI::SymText)
        add_text(TEXT_OX, DELTA_Y, DELTA_X - TEXT_OX, DELTA_Y, :name, type: UI::SymText)
        add_text(TEXT_OX + DELTA_X, DELTA_Y, DELTA_X - TEXT_OX, DELTA_Y, :name, type: UI::SymText)
      end
    end

    # Window showing the skill info
    class SkillInfoWindow < UI::Window
      # @return [Integer] current index
      attr_reader :index
      # Total width of the window
      WINDOW_WIDTH = 100
      # Total height of the window
      WINDOW_HEIGHT = 48
      # Create the new SkillWindow
      # @param viewport [Viewport]
      def initialize(viewport)
        rc = viewport.rect
        super(viewport, rc.width - WINDOW_WIDTH, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
        self.visible = false
        create_stack
      end

      # Set the skill data
      # @param move [Battle::Move]
      def data=(move)
        @stack.data = move
      end

      private

      def create_stack
        add_text(0, 0, 40, 16, text_get(27, 32))
        add_text(0, 0, 64, 16, :pp_text, 2, type: UI::SymText)
        push(0, 16, nil, type: UI::TypeSprite)
        push(33, 16, nil, type: UI::CategorySprite)
      end
    end
  end
end
