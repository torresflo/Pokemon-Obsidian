module BattleUI
  # Class that allow to choose the skill of the Pokemon
  #
  #
  # The object tells the player validated on #validated? and the result is stored inside #result
  #
  # The object should be updated through #update otherwise no validation is possible
  #
  # When result was taken, the scene should call #reset to undo the validated state
  class SkillChoice < GenericChoice
    include SkillChoiceAbstraction
    # Coordinate of each buttons
    BUTTON_COORDINATE = [[198, 124], [198, 153], [198, 182], [198, 211]]
    # Create a new SkillChoice UI
    # @param viewport [Viewport]
    # @param scene [Battle::Scene]
    def initialize(viewport, scene)
      # List of last index according to the pokemon that was used
      # @type [Hash{ PFM::PokemonBattler => Integer }]
      @last_indexes = {}
      @mega_enabled = false
      @super_reset = true
      super(viewport, scene)
    end

    private

    # Give the max index of the choice
    # @return [Integer]
    def max_index
      return @buttons.rindex(&:visible)
    end

    def create_buttons
      # @type [Array<MoveButton>]
      @buttons = 4.times.map do |i|
        add_sprite(*BUTTON_COORDINATE[i], NO_INITIAL_IMAGE, i, type: MoveButton)
      end
    end

    # Set the button opacity
    def update_button_opacity
      base_index = BUTTON_COORDINATE.size - buttons.count(&:visible)
      buttons.each_with_index do |button, index|
        next unless button.visible

        button.opacity = index == @index ? 255 : 204
        x, y = *BUTTON_COORDINATE[base_index + index]
        button.set_position(x + (@index == index ? -10 : 0) + @x, y + @y)
      end
    end

    # Get the cursor offset_x
    # @return [Integer]
    def cursor_offset_x
      return super if @buttons[@index].x != (BUTTON_COORDINATE[@index].first + @x)

      super - 10
    end

    def create_sub_choice
      # @type [MoveInfo]
      @info = add_sprite(0, 0, NO_INITIAL_IMAGE, self, type: MoveInfo)
      @sub_choice = add_sprite(0, 0, NO_INITIAL_IMAGE, @scene, self, type: SubChoice)
    end

    # Validate the user choice
    def validate
      bounce_button
      if choice_move
        @last_indexes[pokemon] = @index
        $game_system.se_play($data_system.decision_se)
      else
        $game_system.se_play($data_system.buzzer_se)
        @scene.message_window.blocking = true
        @scene.message_window.wait_input = true
        show_move_choice_failure
      end
    end

    # Cancel the player choice
    def cancel
      choice_cancel
      $game_system.se_play($data_system.cancel_se)
    end

    # Update the index if a key was pressed
    def update_key_index
      if Input.repeat?(:UP)
        @index = (@index - 1) % @buttons.count(&:visible)
      elsif Input.repeat?(:DOWN)
        @index = (@index + 1) % @buttons.count(&:visible)
      end
    end

    # Button of a move
    class MoveButton < UI::SpriteStack
      # Get the index
      # @return [Integer]
      attr_reader :index

      # Create a new Move button
      # @param viewport [Viewport]
      # @param index [Integer]
      def initialize(viewport, index)
        super(viewport)
        @index = index
        create_sprites
      end

      # Set the data
      # @param pokemon [PFM::PokemonBattler]
      def data=(pokemon)
        @data = move = pokemon.moveset[@index]
        if (self.visible = move)
          @background.sy = move.type
          @text.data = move
        end
      end

      # Make sure sprite is visible only if the data is right
      # @param visible [Boolean]
      def visible=(visible)
        super(visible && @data)
      end

      private

      def create_sprites
        # TODO: separate in methods
        @background = add_sprite(0, 0, 'battle/types', 1, GameData::Type.all.size, type: SpriteSheet)
        @text = add_text(28, 6, 0, 16, :name, color: 10, type: UI::SymText)
      end
    end

    # Element showing the information of the current move
    class MoveInfo < UI::SpriteStack
      # Create a new MoveInfo
      # @param viewport [Viewport]
      # @param move_choice [SkillChoice]
      def initialize(viewport, move_choice)
        super(viewport)
        @move_choice = move_choice
        create_sprites
      end

      # Set the move shown by the UI
      # @param pokemon [PFM::PokemonBattler]
      def data=(pokemon)
        super(move = pokemon.moveset[@move_choice.index])
        return unless move
        if move.pp == 0
          @pp_background.sy = 0
        elsif move.pp <= move.ppmax / 2
          @pp_background.sy = 1
        else
          @pp_background.sy = 2
        end
      end

      private

      def create_sprites
        @pp_background = add_sprite(122, 214, 'battle/pp_box', 1, 3, type: SpriteSheet)
        @pp_text = add_text(146, 218, 0, 16, :pp_text, 1, color: 10, type: UI::SymText)
      end
    end

    # Element showing the full description about the currently selected move
    class MoveDescription < UI::SpriteStack
      include HideShow
      # Get the animation handler
      # @return [Yuki::Animation::Handler{ Symbol => Yuki::Animation::TimedAnimation}]
      attr_reader :animation_handler
      # Create a new MoveDescription
      # @param viewport [Viewport]
      def initialize(viewport)
        super(viewport)
        @animation_handler = Yuki::Animation::Handler.new
        create_sprites
      end

      # Update the sprite
      def update
        @animation_handler.update
      end

      # Tell if the animation is done
      # @return [Boolean]
      def done?
        return @animation_handler.done?
      end

      private

      def create_sprites
        @background = add_background('battle/background')
        @box = add_sprite(0, 61, 'battle/description_box')
        @y = 61
        @skill_name = add_text(14, 13, 0, 16, :name, type: UI::SymText)
        @power_text = add_text(133, 13, 0, 16, text_get(27, 37), color: 10)
        @power_value = add_text(210, 13, 0, 16, :power_text, 2, type: UI::SymText)
        @accuracy_text = add_text(229, 13, 0, 16, text_get(27, 39), color: 10)
        @accuracy_value = add_text(306, 13, 0, 16, :accuracy_text, 2, type: UI::SymText)
        @description = add_text(14, 34, 284, 16, :description, color: 0, type: UI::SymMultilineText)
        @category_text = add_text(117, 88, 0, 16, text_get(27, 36), color: 10)
        @move_category = add_sprite(175, 89, NO_INITIAL_IMAGE, type: UI::CategorySprite)
      end
    end

    # Element showing a special button
    class SpecialButton < UI::SpriteStack
      # Create a new special button
      # @param viewport [Viewport]
      # @param scene [Battle::Scene]
      # @param type [Symbol] :mega or :descr
      def initialize(viewport, scene, type)
        super(viewport)
        @scene = scene
        @type = type
        create_sprites
      end

      # Set the data of the button
      # @param pokemon [PFM::PokemonBattler]
      def data=(pokemon)
        super
        self.visible = (@type == :descr || @scene.logic.mega_evolve.can_pokemon_mega_evolve?(pokemon)) && true
      end

      # Update the special button content
      # @param mega [Boolean]
      def refresh(mega = false)
        @text.text = @type == :descr ? 'Description' : 'Mega evolution'
        @background.set_bitmap(mega ? 'battle/button_mega_activated' : 'battle/button_mega', :interface) if @type == :mega
      end

      # Set the visibility of the button
      # @param visible [Boolean]
      def visible=(visible)
        super(visible && (@type == :descr || (@data && @scene.logic.mega_evolve.can_pokemon_mega_evolve?(@data))))
      end

      private

      def create_sprites
        # TODO: separate in methods
        @background = add_background(@type == :descr ? 'battle/button_x' : 'battle/button_mega')
        @text = add_text(23, @type == :descr ? 4 : 9, 0, 16, nil.to_s, color: 10)
        add_sprite(3, @type == :descr ? 3 : 9, NO_INITIAL_IMAGE, @type == :descr ? :X : :Y, type: UI::KeyShortcut)
      end
    end

    # UI element showing the sub_choice and interacting with the parent choice
    class SubChoice < UI::SpriteStack
      # Create the sub choice
      # @param viewport [Viewport]
      # @param scene [Battle::Scene]
      # @param choice [SkillChoice]
      def initialize(viewport, scene, choice)
        super(viewport)
        @scene = scene
        @choice = choice
        create_sprites
      end

      # Update the button
      def update
        super
        @move_description.update
        done? ? update_done : update_not_done
      end

      # Tell if the choice is done
      def done?
        return !@move_description.visible
      end

      # Reset the sub choice
      def reset
        @move_description.visible = false
        @descr_button.refresh
        @mega_button.refresh(@choice.mega_enabled)
      end

      private

      # Update the button when it's done letting the player choose
      def update_done
        action_y if Input.trigger?(:Y)
        action_x if Input.trigger?(:X)
      end

      # Update the button when it's waiting for player actions
      def update_not_done
        return unless @move_description.done?

        action_b if Input.trigger?(:B) || Input.trigger?(:X)
      end

      # Action triggered when pressing Y
      def action_y
        return $game_system.se_play($data_system.buzzer_se) unless @mega_button.visible

        @choice.mega_enabled = !@choice.mega_enabled
        @mega_button.refresh(@choice.mega_enabled)
        $game_system.se_play($data_system.decision_se)
      end

      # Action triggered when pressing X
      def action_x
        unless (move = @choice.pokemon.moveset[@choice.index])
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        @move_description.data = move
        @move_description.show
        @choice.hide
        @scene.visual.show_info_bars(bank: 0)
        $game_system.se_play($data_system.decision_se)
      end

      # Action triggered when pressing B
      def action_b
        @move_description.hide
        @choice.show
        @scene.visual.hide_info_bars(bank: 0)
        $game_system.se_play($data_system.cancel_se)
      end

      def create_sprites
        create_special_buttons
        create_move_description
      end

      def create_special_buttons
        @descr_button = add_sprite(12, 214, NO_INITIAL_IMAGE, @scene, :descr, type: SpecialButton)
        @mega_button = add_sprite(2, 183, NO_INITIAL_IMAGE, @scene, :mega, type: SpecialButton)
      end

      def create_move_description
        # Not added in the stack so it can be independant
        @move_description = MoveDescription.new(@viewport)
        @move_description.visible = false
      end
    end
  end
end
