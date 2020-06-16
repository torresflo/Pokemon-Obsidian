module UI
  # UI part displaying the Skills of the Pokemon in the Summary
  class Summary_Skills < SpriteStack
    # @return [Integer] The index of the move
    attr_reader :index
    # @return [Array<UI::Summary_Skill>] The skills
    attr_reader :skills
    # Create a new Skills UI for the summary
    # @param viewport [Viewport]
    def initialize(viewport)
      super(viewport, 0, 0, default_cache: :interface)
      init_sprite
      self.index = 0
    end

    # Set the data of the UI
    # @param pokemon [PFM::Pokemon]
    def data=(pokemon)
      super
      self.index = index
      update_skills(pokemon)
    end

    # Set the visibility of the UI
    # @param value [Boolean] new visibility
    def visible=(value)
      super
      @move_info.visible = value
      @skills.each { |skill| skill.visible = value }
    end

    # Set the index of the shown move
    # @param index [Integer]
    def index=(index)
      index = fix_index(index)
      @skills[@index || 0].selected = false
      @index = index.to_i
      @move_info.data = @data.skills_set[@index] if @data
      @skills[@index].selected = true
    end

    private

    def init_sprite
      push(0, 0, background_name)
      init_texts
      init_skills
    end

    # Return the background name
    # @return [String]
    def background_name
      'summary/moves'
    end

    # Update the skills shown in the UI
    # @param pokemon [PFM::Pokemon]
    def update_skills(pokemon)
      pokemon.skills_set.compact!
      @skills.each_with_index do |skill_stack, index|
        skill_stack.data = pokemon.skills_set[index]
      end
    end

    # Init the texts of the UI
    def init_texts
      texts = text_file_get(27)
      with_surface(114, 19, 95) do
        add_line(0, texts[3]) # Type
        add_line(1, texts[36]) # Category
        add_line(0, texts[37], dx: 1) # Power
        add_line(1, texts[39], dx: 1) # Accuracy
      end
      @move_info = SpriteStack.new(@viewport)
      @move_info.with_surface(114, 19, 95) do
        @move_info.add_line(0, :power_text, 2, type: SymText, color: 1, dx: 1)
        @move_info.add_line(1, :accuracy_text, 2, type: SymText, color: 1, dx: 1)
        @move_info.add_line(2, :description, type: SymMultilineText, color: 1).width = 195
      end
      @move_info.push(175, 21, nil, type: TypeSprite)
      @move_info.push(175, 21 + 16, nil, type: CategorySprite)
    end

    # Init the skills of the UI
    def init_skills
      @skills = Array.new(4) { |index| Summary_Skill.new(@viewport, index) }
    end

    # Fix the index value
    # @param index [Integer] requested index
    # @return [Integer] fixed index
    def fix_index(index)
      max_index = (@data&.skills_set&.size || 1) - 1
      return 0 if max_index == 0
      if index < 0
        return fix_index_minus(index, max_index)
      elsif index > max_index
        return fix_index_plus(index, max_index)
      end
      return index
    end

    # Fix the index value when index < 0
    # @param index [Integer] requested index
    # @param max_index [Integer] the maximum index
    # @return [Integer] the new index
    def fix_index_minus(index, max_index)
      delta = index - @index.to_i
      if delta == -1 # LEFT
        return max_index if @index == 0
      elsif delta == -2 # UP
        return max_index >= 3 ? 3 : 1 if @index == 1
        return max_index >= 2 ? 2 : 0 if @index == 0
      end
      return 0
    end

    # Fix the index value when index > max_index
    # @param index [Integer] requested index
    # @param _max_index [Integer] the maximum index
    # @return [Integer] the new index
    def fix_index_plus(index, _max_index)
      delta = index - @index.to_i
      if delta == 2 # DOWN
        return 0 if @index == 0 || @index == 2
        return 1
      end
      return 0
    end
  end

  # UI part displaying a Skill in the Summary_Skills UI
  class Summary_Skill < SpriteStack
    # Array describing the various coordinates of the skills in the UI
    FINAL_COORDINATES = [
      [28, 138], [174, 138],
      [28, 170], [174, 170]
    ]
    # Color when it's selected
    SELECTED_COLOR = Color.new(0, 200, 0, 255)
    # Color when it's not selected
    NO_SELECT_COLOR = Color.new(0, 0, 0, 0)
    # @return [Boolean] if the move is currently selected
    attr_reader :selected
    # @return [Boolean] if the move is currently being moved
    attr_reader :moving
    # Create a new skill
    # @param viewport [Viewport]
    # @param index [Integer] index of the skill in the UI
    def initialize(viewport, index)
      super(viewport, *FINAL_COORDINATES[index % FINAL_COORDINATES.size])
      # @type [Sprite::WithColor]
      @selector = push(-8, 0, selector_name, type: Sprite::WithColor)
      push(0, 2, nil, type: TypeSprite)
      add_text(34, 0, 110, 16, :name, type: SymText)
      @pp_text = add_text(34, 16, 110, 16, text_get(27, 32)) # PP
      add_text(34, 16, 100, 16, pp_method, 1, type: SymText, color: 1)
      @selected = false
      self.moving = false
    end

    # Set the skill data
    # @param skill [PFM::Skill]
    def data=(skill)
      super
      return unless (self.visible = skill ? true : false)
      @selector.visible = @selected
      self.moving = false
    end

    # Set the visibility of the sprite
    # @param value [Boolean] new visibility
    def visible=(value)
      super(value && @data)
      @selector.visible = value && (@selected || @moving)
    end

    # Get the visibility of the sprite
    # @return [Boolean]
    def visible
      return @stack[1].visible
    end

    # Define if the skill is selected
    # @param selected [Boolean]
    def selected=(selected)
      @selected = selected
      @selector.visible = selected || @moving
    end

    # Define if the skill is being moved
    # @param moving [Boolean]
    def moving=(moving)
      @moving = moving
      if moving
        @selector.visible = true
        @selector.set_color(SELECTED_COLOR)
      else
        @selector.visible = @selected
        @selector.set_color(NO_SELECT_COLOR)
      end
    end

    private

    # Return the name of the selector file
    # @return [String]
    def selector_name
      'summary/move_selector'
    end

    # Return the name of the method used to get the PP text
    # @return [Symbol]
    def pp_method
      :pp_text
    end
  end
end
