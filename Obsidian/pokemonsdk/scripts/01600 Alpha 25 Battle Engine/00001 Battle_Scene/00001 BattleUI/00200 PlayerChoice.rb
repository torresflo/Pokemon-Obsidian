module BattleUI
  # Class that allow the player to make the choice of the action he want to do
  #
  # The object tells the player validated on #validated? and the result is stored inside #result
  #
  # The object should be updated through #update otherwise no validation is possible
  #
  # When result was taken, the scene should call #reset to undo the validated state
  class PlayerChoice < GenericChoice
    include UI
    include PlayerChoiceAbstraction
    # Coordinate of each buttons
    BUTTON_COORDINATE = [[172, 172], [246, 182], [162, 201], [236, 211]]

    # Create a new PlayerChoice Window
    # @param viewport [Viewport]
    # @param scene [Battle::Scene]
    def initialize(viewport, scene)
      @can_switch = true
      @super_reset = true # Specify that the super class has the reset function
      super(viewport, scene)
    end

    private

    def create_buttons
      # @type [Array<Button>]
      @buttons = 4.times.map do |i|
        add_sprite(*BUTTON_COORDINATE[i], NO_INITIAL_IMAGE, i, type: Button)
      end
    end

    def create_sub_choice
      @sub_choice = add_sprite(0, 0, NO_INITIAL_IMAGE, @scene, self, type: SubChoice)
    end

    # Validate the player choice
    def validate
      bounce_button
      case @index
      when 0
        success = choice_attack
      when 1
        success = choice_bag
      when 2
        success = choice_pokemon
      when 3
        success = choice_flee
      else
        return
      end
      return show_switch_choice_failure unless success

      $game_system.se_play($data_system.decision_se)
    end

    # Cancel the player choice
    def cancel
      choice_cancel ? $game_system.se_play($data_system.cancel_se) : $game_system.se_play($data_system.buzzer_se)
    end

    # Update the index if a key was pressed
    def update_key_index
      if Input.trigger?(:UP)
        @index = (@index - 2).clamp(0, 3)
      elsif Input.trigger?(:LEFT)
        @index = (@index - 1).clamp(0, 3)
      elsif Input.trigger?(:RIGHT)
        @index = (@index + 1).clamp(0, 3)
      elsif Input.trigger?(:DOWN)
        @index = (@index + 2).clamp(0, 3)
      end
    end

    # Creates the show animation
    # @param target_opacity [Integer] the desired opacity (if you need non full opacity)
    # @return [Yuki::Animation::TimedAnimation]
    def show_animation(target_opacity = 255)
      animation = super
      animation.play_before(Yuki::Animation.send_command_to(self, :update_button_opacity))
      return animation
    end

    # Button of the player choice
    class Button < SpriteSheet
      # Create a new Player Choice button
      # @param viewport [Viewport]
      # @param index [Integer]
      def initialize(viewport, index)
        super(viewport, 4, 1)
        self.index = index
        set_bitmap(image_filename, :interface)
      end

      alias index sx
      alias index= sx=

      # Get the filename of the sprite
      # @return [String]
      def image_filename
        return 'battle/actions_'
      end
    end

    # Element showing a special button
    class SpecialButton < UI::SpriteStack
      # Create a new special button
      # @param viewport [Viewport]
      # @param type [Symbol] :last_item or :info
      def initialize(viewport, type)
        super(viewport)
        @type = type
        create_sprites
      end

      # Update the special button content
      def refresh
        @text.text = @type == :info ? 'Information' : $bag.last_battle_item.name
      end

      private

      def create_sprites
        # TODO: separate in methods
        add_background(@type == :info ? 'battle/button_y' : 'battle/button_x')
        @text = add_text(23, 4, 0, 16, nil.to_s, color: 10)
        add_sprite(3, 3, NO_INITIAL_IMAGE, @type == :info ? :Y : :X, type: UI::KeyShortcut)
      end
    end

    # UI showing the info about the last used item
    class ItemInfo < UI::SpriteStack
      include HideShow
      # Get the animation handler
      # @return [Yuki::Animation::Handler{ Symbol => Yuki::Animation::TimedAnimation}]
      attr_reader :animation_handler
      # Create a new Item Info box
      # @param viewport [Viewport]
      def initialize(viewport)
        super(viewport)
        @animation_handler = Yuki::Animation::Handler.new
        create_sprites
      end

      # Set the data shown by the UI
      # @param item [GameData::Item]
      def data=(item)
        super
        @remaining.text = $bag.item_quantity(item.id).to_s
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
        @item_box = add_sprite(0, 61, 'battle/last_item_box')
        @y = 61
        @item_name = add_text(14, 13, 0, 16, :exact_name, color: 0, type: UI::SymText)
        @item_icon = add_sprite(240, 2, NO_INITIAL_IMAGE, type: UI::ItemSprite)
        @remaining = add_text(287, 13, 0, 16, nil.to_s, 0)
        @description = add_text(14, 34, 284, 16, :descr, color: 0, type: UI::SymMultilineText)
        @use_text = add_text(151, 88, 0, 16, text_get(22, 0), color: 0)
        @icon = add_sprite(129, 88, NO_INITIAL_IMAGE, :X, type: UI::KeyShortcut)
      end
    end

    # UI element showing the sub_choice and interacting with the parent choice
    class SubChoice < UI::SpriteStack
      # Create the sub choice
      # @param viewport [Viewport]
      # @param scene [Battle::Scene]
      # @param choice [PlayerChoice]
      def initialize(viewport, scene, choice)
        super(viewport)
        @scene = scene
        @choice = choice
        create_sprites
      end

      # Update the button
      def update
        super
        @item_info.update
        done? ? update_done : update_not_done
      end

      # Tell if the choice is done
      def done?
        return !@item_info.visible && !@bar_visibility
      end

      # Reset the sub choice
      def reset
        @item_info.visible = false
        @bar_visibility = false
        @last_item_button.refresh
        @info_button.refresh
      end

      private

      # Update the button when it's done letting the player choose
      def update_done
        action_y if Input.trigger?(:Y)
        action_x if Input.trigger?(:X) && !@bar_visibility
      end

      # Update the button when it's waiting for player actions
      def update_not_done
        return action_y if @bar_visibility && (Input.trigger?(:Y) || Input.trigger?(:A) || Input.trigger?(:B))

        return unless @item_info.done?

        action_b if Input.trigger?(:B)
        action_a if Input.trigger?(:A) || Input.trigger?(:X)
      end

      # Action triggered when pressing Y
      def action_y
        if @bar_visibility
          @choice.show
          @scene.visual.hide_info_bars(bank: 0)
        else
          @choice.hide
          @scene.visual.show_info_bars(bank: 0)
        end
        @bar_visibility = !@bar_visibility
      end

      # Action triggered when pressing X
      def action_x
        item = $bag.last_battle_item
        if item.id == 0 || !$bag.contain_item?(item.id)
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        @item_info.data = item
        @item_info.show
        @choice.hide
        @scene.visual.show_info_bars(bank: 0) unless @bar_visibility
        $game_system.se_play($data_system.decision_se)
      end

      # Action triggered when pressing A
      def action_a
        item = $bag.last_battle_item
        if item.id == 0 || !$bag.contain_item?(item.id)
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        $game_system.se_play($data_system.decision_se)
        @choice.use_item(item)
        @item_info.hide
        @choice.show
      end

      # Action triggered when pressing B
      def action_b
        @item_info.hide
        @choice.show
        @scene.visual.hide_info_bars(bank: 0) unless @bar_visibility
        $game_system.se_play($data_system.cancel_se)
      end

      def create_sprites
        create_special_buttons
        create_item_info
      end

      def create_special_buttons
        @last_item_button = add_sprite(12, 214, NO_INITIAL_IMAGE, :last_item, type: SpecialButton)
        @info_button = add_sprite(2, 188, NO_INITIAL_IMAGE, :info, type: SpecialButton)
      end

      def create_item_info
        @item_info = ItemInfo.new(@viewport)
        @item_info.visible = false
      end
    end
  end
end
