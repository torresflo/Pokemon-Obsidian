module GamePlay
  # Class that display the Party Menu interface and manage user inputs
  #
  # This class has several modes
  #   - :map => Used to select a Pokemon in order to perform stuff
  #   - :menu => The normal mode when opening this interface from the menu
  #   - :battle => Select a Pokemon to send to battle
  #   - :item => Select a Pokemon in order to use an item on it (require extend data : hash)
  #   - :hold => Give an item to the Pokemon (requires extend data : item_id)
  #   - :select => Select a number of Pokemon for a temporary team.
  #     (Number defined by $game_variables[6] and possible list of excluded Pokemon requires extend data : array)
  #
  # This class can also show an other party than the player party,
  # the party paramter is an array of Pokemon upto 6 Pokemon
  class Party_Menu < BaseCleanUpdate
    # Return data of the Party Menu
    # @return [Integer]
    attr_accessor :return_data
    # Return the skill process to call
    # @return [Array(Proc, PFM::Pokemon, PFM::Skill), Proc, nil]
    attr_accessor :call_skill_process
    # Selector Rect info
    # @return [Array]
    SelectorRect = [[0, 0, 132, 52], [0, 64, 132, 52]]
    # Height of the frame Image to actually display (to prevent button from being hidden / shadowed).
    # Set nil to keep the full height
    FRAME_HEIGHT = 214
    # Create a new Party_Menu
    # @param party [Array<PFM::Pokemon>] list of Pokemon in the party
    # @param mode [Symbol] :map => from map (select), :menu => from menu, :battle => from Battle, :item => Use an item,
    #                      :hold => Hold an item, :choice => processing a choice related proc (do not use)
    # @param extend_data [Integer, Hash] extend_data informations
    # @param no_leave [Boolean] tells the interface to disallow leaving without choosing
    def initialize(party, mode = :map, extend_data = nil, no_leave: false)
      super()
      @move = -1
      @return_data = -1
      # Scene mode
      # @type [Symbol]
      @mode = mode
      # Displayed party
      # @type [Integer, Hash, nil]
      @extend_data = extend_data
      @no_leave = no_leave
      @index = 0
      # @type [Array<PFM::Pokemon>]
      @party = party
      @counter = 0 #  Used by the selector
      @intern_mode = :normal # :normal, :move_pokemon, :move_item, :choose_move_pokemon, :choose_move_item
      # Array containing the temporary team selected
      # @type [Array<PFM::Pokemon>]
      @temp_team = []
      # Resetting the affected variable to prevent bugs
      $game_variables[Yuki::Var::Party_Menu_Sel] = -1
      # Telling the B action the user is seeing a choice and make it able to cancel the choice
      # @type [PFM::Choice_Helper]
      @choice_object = nil
      # Running state of the scene
      # @type [Boolean]
      @running = true
    end

    # Update the inputs
    def update_inputs
      return action_A if Input.trigger?(:A)
      return action_X if Input.trigger?(:X)
      return action_Y if Input.trigger?(:Y)
      return action_B if Input.trigger?(:B)
      update_selector_move
    end

    # Update the mouse
    # @param _moved [Boolean] if the mouse moved
    def update_mouse(_moved)
      update_mouse_ctrl
    end

    # Update the scene graphics during an animation or something else
    def update_graphics
      update_selector
      @base_ui.update_background_animation
      @team_buttons.each(&:update_graphics)
    end
    alias update_during_process update_graphics

    private

    # Create the UI graphics
    def create_graphics
      create_viewport
      create_base_ui
      create_team_buttons
      create_frames #  Must be after team buttons to ensure the black frame to work
      create_selector
      init_win_text
    end

    # Create the base UI
    def create_base_ui
      @base_ui = UI::GenericBase.new(@viewport, button_texts)
      auto_adjust_button
    end

    # Retrieve the button texts according to the mode
    # @return [Array<String>]
    def button_texts
      return Array.new(4) { |i| ext_text(9000, 14 + i) } if @mode != :select
      return Array.new(4, ext_text(9000, 22 + 3))
    end

    # Adjust the button display
    def auto_adjust_button
      return unless @mode == :select
      ctrl = @base_ui.ctrl
      ctrl[3], ctrl[1] = ctrl[1], ctrl[3]
      ctrl[3].set_position(*UI::GenericBase::ControlButton::COORDINATES[3])
    end

    # Create the frame sprites
    def create_frames
      # @type [LiteRGSS::Sprite]
      @black_frame = Sprite.new(@viewport) #  Get the Blackn ^^
      # Scene frame
      # @type [LiteRGSS::Sprite]
      @frame = Sprite.new(@viewport).set_bitmap($options.language == 'fr' ? 'team/FrameFR' : 'team/FrameEN', :interface)
    end

    # Create the team buttons
    def create_team_buttons
      # Team button list
      # @type [Array<UI::TeamButton>]
      @team_buttons = Array.new(@party.size) do |i|
        btn = UI::TeamButton.new(@viewport, i)
        btn.data = @party[i]
        next(btn)
      end
    end

    # Create the selector
    def create_selector
      # Scene selector
      # @type [LiteRGSS::Sprite]
      @selector = Sprite.new(@viewport).set_bitmap('team/Cursors', :interface)
      @selector.src_rect.set(*SelectorRect[0])
      update_selector_coordinates
    end

    # Initialize the win_text according to the mode
    def init_win_text
      case @mode
      when :map, :battle
        return @base_ui.show_win_text(text_get(23, 17))
      when :hold
        return @base_ui.show_win_text(text_get(23, 23))
      when :item
        if @extend_data
          extend_data_button_update
          return @base_ui.show_win_text(text_get(23, 24))
        end
      when :select
        select_pokemon_button_update
        return @base_ui.show_win_text(text_get(23, 17))
      end
      @base_ui.hide_win_text
    end

    # Function that update the team button when extend_data is correct
    def extend_data_button_update
      if (_proc = @extend_data[:on_pokemon_choice])
        apt_detect = (@extend_data[:open_skill_learn] || @extend_data[:stone_evolve])
        @team_buttons.each do |btn|
          btn.show_item_name
          v = @extend_data[:on_pokemon_choice].call(btn.data)
          if apt_detect
            c = (v ? 1 : v == false ? 2 : 3)
            v = (v ? 143 : v == false ? 144 : 142)
          else
            c = (v ? 1 : 2)
            v = (v ? 140 : 141)
          end
          btn.item_text.load_color(c).text = parse_text(22, v)
        end
      end
    end

    # Function that updates the text displayed in the team button when in :select mode
    def select_pokemon_button_update
      @team_buttons.each do |btn|
        btn.show_item_name
        c = 0
        if @temp_team.include?(btn.data)
          c = 1
          v = 155 + @temp_team.index(btn.data)
        elsif @extend_data.is_a?(Array) && @extend_data.include?(@party[@team_buttons.index(btn)].id)
          c = 2
          v = 154
        else
          v = 153
        end
        btn.item_text.load_color(c).text = fix_number(parse_text(23, v))
      end
    end

    # Update the selector
    def update_selector
      @counter += 1
      if @counter == 60
        @selector.src_rect.set(*SelectorRect[1])
      elsif @counter >= 120
        @counter = 0
        @selector.src_rect.set(*SelectorRect[0])
      end
    end

    # Show the item name
    def show_item_name
      @team_buttons.each(&:show_item_name)
    end

    # Hide the item name
    def hide_item_name
      @team_buttons.each(&:hide_item_name)
    end

    # Show the black frame for the currently selected Pokemon
    def show_black_frame
      @black_frame.set_bitmap("team/dark#{@index + 1}", :interface)
      @black_frame.visible = true
      @black_frame.src_rect.height = FRAME_HEIGHT if FRAME_HEIGHT
      1.upto(8) do |i|
        @black_frame.opacity = i * 255 / 8
        update_during_process
        Graphics.update
      end
    end

    # Hide the black frame for the currently selected Pokemon
    def hide_black_frame
      8.downto(1) do |i|
        @black_frame.opacity = i * 255 / 8
        update_during_process
        Graphics.update
      end
      @black_frame.visible = false
    end

    # Fix special characters used in some Ruby Host texts
    def fix_number(string)
      string = string.sub('', 'er')
      string.sub!('', 'ème')
      return string
    end
  end
end
