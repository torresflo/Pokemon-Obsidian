module UI
  module MoveTeaching
    # UI part displaying a Skill in the Skill Learn UI
    class Skill < SpriteStack
      # Array describing the various coordinates of the skills in the UI
      FINAL_COORDINATES = [
        [28, 156], [174, 156],
        [28, 188], [174, 188]
      ]
      # Color when it's selected
      FORGET_COLOR = Color.new(0, 200, 0, 255)
      # Color when it's not selected
      NORMAL_COLOR = Color.new(0, 0, 0, 0)
      # @return [Boolean] if the move is currently selected
      attr_reader :selected
      # @return [Boolean] if the move is currently being moved
      attr_reader :forget
      # Create a new Skill
      # @param viewport [Viewport]
      # @param index [Integer] index of the skill in the UI
      def initialize(viewport, index)
        super(viewport, *FINAL_COORDINATES[index % FINAL_COORDINATES.size], default_cache: :interface)
        create_graphics
        create_texts
        @selected = false
        self.forget = false
        @skill_index = index
        self.visible = false
      end

      # Set the skill data
      # @param skill [PFM::Skill]
      def data=(skill)
        super
        return unless (self.visible = skill ? true : false)
        @selector.visible = @selected
        self.forget = false
      end

      # Set the visibility of the sprite
      # @param value [Boolean] new visibility
      def visible=(value)
        super(value && @data)
        @selector.visible = value && (@selected || @forget)
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
        @selector.visible = selected || @forget
      end

      # Define if the skill is being moved
      # @param forget [Boolean]
      def forget=(forget)
        @forget = forget
        if forget
          @selector.visible = true
          @selector.set_color(FORGET_COLOR)
        else
          @selector.visible = @selected
          @selector.set_color(NORMAL_COLOR)
        end
      end

      private

      # Create the texts of the skill
      def create_texts
        @name = add_text(*name_coordinates, :name, type: SymText)
        @pp_text = add_text(*pp_text_coordinates, text_get(27, 32)) # PP
        add_text(*pp_text_value_coordinates, pp_method, type: SymText, color: 1)
      end

      # @return Array of coordinates of the Skill name
      def name_coordinates
        return 34, 1, 0, 16
      end

      # @return Array of coordinates of the Skill pp text
      def pp_text_coordinates
        return 34 + 40, 18, 0, 16
      end

      # @return Array of coordinates of the Skill pp text value
      def pp_text_value_coordinates
        return 34, 18, 0, 16
      end

      # Create some graphics of the new skill to learn
      def create_graphics
        @selector = push(-8, 0, selector_name, type: Sprite::WithColor)
        @type = add_sprite(*type_coordinates, nil, type: TypeSprite)
      end

      # @return Array of coordinates of the Skill type
      def type_coordinates
        return 0, 2
      end

      # Return the name of the selector file
      # @return [String]
      def selector_name
        'skill_learn/move_selector'
      end

      # Return the name of the method used to get the PP text
      # @return [Symbol]
      def pp_method
        :pp_text
      end

    end
  end
end