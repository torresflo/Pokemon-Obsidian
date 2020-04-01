module BattleUI
  # Class that allow the player to make the choice of the action he want to do
  #
  # The object tells the player validated on #validated? and the result is stored inside #result
  #
  # The object should be updated through #update otherwise no validation is possible
  #
  # When result was taken, the scene should call #reset to undo the validated state
  class PlayerChoice < UI::Window
    # Total width of the window
    WINDOW_WIDTH = 160
    # Total height of the window
    WINDOW_HEIGHT = 48
    # Delta in X between two options
    DELTA_X = 60
    # Delta in Y between two options
    DELTA_Y = 16
    # Offset X of the text to let the cursor display
    TEXT_OX = 16
    # List of the possible result on validation (according to the index)
    POSSIBLE_RESULT = %i[attack bag pokemon flee]
    # @return [Symbol, nil] The result
    attr_reader :result
    # Create a new PlayerChoice Window
    # @param viewport [Viewport]
    def initialize(viewport)
      rc = viewport.rect
      super(viewport, rc.width - WINDOW_WIDTH, 0, WINDOW_WIDTH, WINDOW_HEIGHT)
      create_texts
      load_cursor
      @index = 0
      self.active = true
      self.visible = false
    end

    # Update the Window cursor
    def update
      return if validated?
      return validate if Input.trigger?(:A) || (Mouse.trigger?(:LEFT) && simple_mouse_in?)
      return cancel if Input.trigger?(:B)
      last_index = @index
      update_key_index
      update_mouse_index
      update_cursor if last_index != @index
    end

    # If the player made a choice
    # @return [Boolean]
    def validated?
      !@result.nil?
    end

    # Reset the choice
    def reset
      @result = nil
    end

    private

    # Update the cursor position
    def update_cursor
      cursor_rect.set((@index % 2) * DELTA_X, (@index / 2) * DELTA_Y)
      $game_system.se_play($data_system.cursor_se)
    end

    # Validate the player choice
    def validate
      @result = POSSIBLE_RESULT[@index]
      $game_system.se_play($data_system.decision_se)
    end

    # Cancel the player choice
    def cancel
      @result = :cancel
      $game_system.se_play($data_system.cancel_se)
    end

    # Create the texts of the Window
    def create_texts
      add_text(TEXT_OX, 0, DELTA_X - TEXT_OX, DELTA_Y, text_get(32, 0)) # Attack !
      add_text(TEXT_OX + DELTA_X, 0, DELTA_X - TEXT_OX, DELTA_Y, text_get(32, 1)) # Bag
      add_text(TEXT_OX, DELTA_Y, DELTA_X - TEXT_OX, DELTA_Y, text_get(32, 2)) # Pokemon
      add_text(TEXT_OX + DELTA_X, DELTA_Y, DELTA_X - TEXT_OX, DELTA_Y, text_get(32, 3)) # Flee
    end

    # Update the mouse index if the mouse moved
    def update_mouse_index
      return unless Mouse.moved
      return unless simple_mouse_in?
      stack.each_with_index do |text, index|
        break @index = index if text.simple_mouse_in?
      end
    end

    # Update the index if a key was pressed
    def update_key_index
      case Input.dir4
      when 6
        @index = @index < 2 ? 1 : 3
      when 4
        @index = @index < 2 ? 0 : 2
      when 2
        @index = @index.odd? ? 3 : 2
      when 8
        @index = @index.odd? ? 1 : 0
      end
    end
  end
end
