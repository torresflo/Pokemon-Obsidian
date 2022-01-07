module GamePlay
  # Move reminder Scene
  class Move_Reminder < BaseCleanUpdate::FrameBalanced
    include MoveReminderMixin
    # Front background image
    BACKGROUND = 'MR_UI'
    # Cursor filename
    CURSOR = 'ball_selec'
    # List of button texts
    BUTTON_TEXTS = [
      [:ext_text, 9000, 117],
      [:ext_text, 9000, 113],
      ': previous',
      [:ext_text, 9000, 115]
    ]
    # List of button used in the UI
    BUTTON_KEYS = %i[A DOWN UP B]
    # List of button action
    BUTTON_ACTION = %i[action_a action_down action_up action_b]
    # Text helping the player
    HELP_TEXT = 'Which move should %s learn?'
    # Number of frame before help text shows up
    HELP_TEXT_COUNT = 180
    # Create a new Move_Reminder Scene
    # @param pokemon [PFM::Pokemon] pokemon that should learn a move
    # @param mode [Integer] Define the moves you can see :
    #   1 = breed_moves + learnt + potentially_learnt
    #   2 = all moves
    #   other = learnt + potentially_learnt
    def initialize(pokemon, mode = 0)
      super()
      @index = 0
      @pokemon = pokemon
      @mode = mode
      @count = 0
    end

    # Update the inputs
    def update_inputs
      hide_win_text = @base.win_text_visible?
      if index_changed(:@index, :UP, :DOWN, @last_index)
        @ui.index = @index
      elsif Input.trigger?(:A)
        action_a
      elsif Input.trigger?(:B)
        action_b
      elsif !hide_win_text && (@count += 1) > HELP_TEXT_COUNT
        @base.show_win_text(format(get_text(HELP_TEXT), @pokemon.given_name))
      else
        hide_win_text = false
      end
      if hide_win_text
        @base.hide_win_text
        @count = 0
      end
      return true
    end

    # Update the graphics
    def update_graphics
      @base.update_background_animation
      @ui.update_graphics
    end

    # Update the mouse
    # @param moved [Boolean] boolean telling if the mouse moved
    # @return [Boolean] if the update can continue
    def update_mouse(moved)
      if moved
        @base.hide_win_text if @base.win_text_visible?
        @count = 0
      else
        update_mouse_ctrl_buttons(@base.ctrl, BUTTON_ACTION)
      end
      return true
    end

    private

    # Create the Move Reminder UI
    def create_graphics
      create_viewport
      create_base
      create_ui
    end

    # Create the generic base used by the Move Reminder UI
    def create_base
      @base = UI::GenericBase.new(@viewport, BUTTON_TEXTS.collect { |txt| get_text(txt) }, BUTTON_KEYS)
    end

    def create_ui
      @ui = UI::Summary_Remind.new(@viewport, @pokemon)
      @ui.mode = @mode
      @ui.update_skills
      @last_index = @ui.learnable_skills.size - 1
    end

    # Call the Skill Learn UI when the player press A
    def action_a
      $game_system.se_play($data_system.decision_se)
      GamePlay.open_move_teaching(@pokemon, @ui.learnable_skills[@index].id) do |scene|
        if scene.learnt
          @return_data = true
          @running = false
        end
      end
    end

    # Stop the scene
    def action_b
      $game_system.se_play($data_system.cancel_se)
      @return_data = false
      @running = false
    end

    # Set the index to the previous one
    def action_up
      @ui.index -= 1
    end

    # Set the index to the next one
    def action_down
      @ui.index += 1
    end
  end
end

GamePlay.move_reminder_class = GamePlay::Move_Reminder
