module UI
  module Storage
    # Stack responsive of showing the full PC UI
    class Composition < UI::SpriteStack
      # Get the mode handler
      # @return [ModeHandler]
      attr_reader :mode_handler
      # Get the party
      # @return [Array<PFM::Pokemon>]
      attr_reader :party
      # Get the storage object
      # @return [PFM::Storage]
      attr_reader :storage
      # Get the current box index
      # @return [Integer]
      attr_reader :box_index
      # Get the summary object
      # @return [Summary]
      attr_reader :summary
      # Get the cursor object
      # @return [CursorHandler]
      attr_reader :cursor_handler
      # Get the selection handler
      # @return [SelectionHandler]
      attr_reader :selection_handler
      # Create a new Composition
      # @param viewport [Viewport] viewport used to display the sprites
      # @param mode [Symbol] :pokemon, :item, :battle or :box
      # @param selection_mode [Symbol] :detailed, :fast or :grouped
      def initialize(viewport, mode, selection_mode)
        super(viewport)
        @mode_handler = ModeHandler.new(mode, selection_mode)
        @selection_handler = SelectionHandler.new(@mode_handler)
        # @type [Yuki::Animation::TimedAnimation]
        @animation = nil
        # @type [PFM::Storage]
        @storage = nil
        @party = nil
        @box_index = 0
        create_stack
        @selection_handler.cursor = @cursor_handler
      end

      # Update the composition state
      def update
        @summary.update
        @cursor.update
        return if !@animation || @animation.done?

        @animation.update
      end

      # Tell if the animation is done
      # @return [boolean]
      def done?
        all_done = @summary.done? && @cursor.done?
        return @animation ? all_done && @animation.done? : all_done
      end

      # Start animation for right arrow
      # @param middle_animation [Yuki::Animation::TimedAnimation] animation played in the middle of this animation
      def animate_right_arrow(middle_animation = nil)
        arrow = @arrow_right
        @animation = Yuki::Animation::ScalarAnimation.new(0.05, arrow, :x=, arrow.x, arrow.x + 2)
        @animation.play_before(middle_animation) if middle_animation
        @animation.play_before(Yuki::Animation::ScalarAnimation.new(0.05, arrow, :x=, arrow.x + 2, arrow.x))
        @animation.start
      end

      # Start animation for left arrow
      # @param middle_animation [Yuki::Animation::TimedAnimation] animation played in the middle of this animation
      def animate_left_arrow(middle_animation = nil)
        arrow = @arrow_left
        @animation = Yuki::Animation::ScalarAnimation.new(0.05, arrow, :x=, arrow.x, arrow.x - 2)
        @animation.play_before(middle_animation) if middle_animation
        @animation.play_before(Yuki::Animation::ScalarAnimation.new(0.05, arrow, :x=, arrow.x - 2, arrow.x))
        @animation.start
      end

      # Set the storage object
      # @param storage [PFM::Storage]
      def storage=(storage)
        @storage = storage
        @box_stack.data = storage.current_box_object
        @selection_handler.storage = storage
      end

      # Set the party object
      # @param party [Array<PFM::Pokemon>]
      def party=(party)
        @party = party
        @selection_handler.party = party
        @party_box ||= PFM::Storage::BattleBox.new('party', party)
        shown_party = @mode_handler.mode == :battle ? storage.battle_boxes[storage.current_battle_box] : @party_box
        @party_stack.data = shown_party
      end

      # Tell if the mouse is hovering a pokemon sprite & update cursor index in consequence
      # @return [Boolean]
      def hovering_pokemon_sprite?
        if @cursor.inbox
          return true if @box_stack.pokemon_sprites[@cursor.index].simple_mouse_in?
        elsif !@cursor.select_box
          return true if @party_stack.pokemon_sprites[@cursor.index].simple_mouse_in?
        end
        index = @party_stack.pokemon_sprites.index(&:simple_mouse_in?)
        if index
          @cursor.force_index(false, index)
          return true
        end
        index = @box_stack.pokemon_sprites.index(&:simple_mouse_in?)
        if index
          @cursor.force_index(true, index)
          return true
        end
        return false
      end

      # Tell if the mouse hover the mode indicator
      # @return [Boolean]
      def hovering_mode_indicator?
        return @mode_indicator.simple_mouse_in?
      end

      # Tell if the mouse hover the selection mode indicator
      # @return [Boolean]
      def hovering_selection_mode_indicator?
        return @selection_mode_indicator.simple_mouse_in?
      end

      # Tell if the box option is hovered
      # @return [Boolean]
      def hovering_box_option?
        if @box_stack.box_option_hovered?
          @cursor.select_box = true
          return true
        else
          return false
        end
      end

      # Tell if the right arrow is hovered
      # @return [Boolean]
      def hovering_right_arrow?
        return @arrow_right.simple_mouse_in?
      end

      # Tell if the left arrow is hovered
      # @return [Boolean]
      def hovering_left_arrow?
        return @arrow_left.simple_mouse_in?
      end

      # Tell if the right arrow of party stack is hovered
      # @return [Boolean]
      def hovering_party_right_arrow?
        return @party_stack.hovering_right_arrow?
      end

      # Tell if the left arrow of party stack is hovered
      # @return [Boolean]
      def hovering_party_left_arrow?
        return @party_stack.hovering_left_arrow?
      end

      private

      def create_stack
        create_box_stack
        create_frames
        create_modes
        create_win_txt
        create_arrows
        create_party_stack
        create_summary
        create_cursor
      end

      def create_box_stack
        # @type [BoxStack]
        @box_stack = push_sprite(BoxStack.new(@viewport, @mode_handler, @selection_handler))
      end

      def create_party_stack
        # @type [PartyStack]
        @party_stack = push_sprite(PartyStack.new(@viewport, @mode_handler, @selection_handler))
      end

      def create_frames
        add_background('pc/frame').set_z(32)
        @frame_split = add_sprite(207, 25, 'pc/frame_split').set_z(33)
      end

      def create_modes
        # @type [WinMode]
        @mode_background = push_sprite(WinMode.new(@viewport, @mode_handler))
        # @type [ModeSprite]
        @mode_indicator = push_sprite(ModeSprite.new(@viewport, @mode_handler))
        # @type [SelectionModeSprite]
        @selection_mode_indicator = push_sprite(SelectionModeSprite.new(@viewport, @mode_handler))
      end

      def create_win_txt
        @win_txt = add_sprite(0, 217, 'pc/win_txt').set_z(30)
        @win_txt.visible = false
        # @type [UserInput]
        @win_txt_input = push_sprite(UserInput.new(0, @viewport, 2, 217, 200, 23, ''))
        @win_txt_input.z = 30
        @win_txt_input.visible = false
      end

      def create_arrows
        @arrow_left = add_sprite(6, 29, 'pc/arrow_frame_l').set_z(2)
        @arrow_right = add_sprite(134, 29, 'pc/arrow_frame_r').set_z(2)
      end

      def create_summary
        # @type [Summary]
        @summary = push_sprite(Summary.new(@viewport, true))
      end

      def create_cursor
        @cursor = Cursor.new(@viewport, 0, true, @mode_handler)
        @cursor_handler = CursorHandler.new(@cursor)
      end
    end
  end
end
