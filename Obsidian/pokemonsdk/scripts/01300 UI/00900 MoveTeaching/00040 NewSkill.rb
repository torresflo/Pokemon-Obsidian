module UI
  module MoveTeaching
    # UI part displaying the new skill informations in the Skill Learn scene
    class NewSkill < SpriteStack
      # @return [Boolean] if the move is currently selected
      attr_reader :selected
      # Create informations of the new skill to learn
      # @param viewport [Viewport]
      # @param index [Integer]
      def initialize(viewport, index)
        super(viewport, 35, 133, default_cache: :interface)
        create_texts
        create_graphics
        @new_skill_index = index
        self.selected = false
        self.visible = false
      end

      # Set the skill data
      # @param skill [PFM::Skill]
      def data=(skill)
        super
        @selector.visible = @selected
      end

      # Set the visibility of the sprite
      # @param value [Boolean] new visibility
      def visible=(value)
        super(value && @data)
        @selector.visible = @selected
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
        @selector.visible = selected
      end

      private

      # Create the texts of the new skill to learn
      def create_texts
        @new = add_text(*new_text_coordinates, new_text, color: 10)
        @name = add_text(*name_coordinates, :name, type: SymText)
        @pp_text = add_text(*pp_text_coordinates, text_get(27, 32)) # PP
        add_text(*pp_text_value_coordinates, pp_method, type: SymText)
      end

      # @return Array of coordinates of the "New" text
      def new_text_coordinates
        return 6, 2, 0, 14
      end

      # Return the "New" text
      def new_text
        return ext_text(9004, 1)
      end

      # @return Array of coordinates of the Skill name
      def name_coordinates
        return 66, 3, 0, 14
      end

      # @return Array of coordinates of the Skill pp text
      def pp_text_coordinates
        return 194 + 40, 3, 0, 14
      end

      # @return Array of coordinates of the Skill pp text value
      def pp_text_value_coordinates
        return 194, 3, 0, 14
      end

      # Create some graphics of the new skill to learn
      def create_graphics
        @selector = push(61, -2, new_selector_name, type: Sprite::WithColor)
        stack.rotate!(-1) # Make sure selector is first sprite in stack
        @type = add_sprite(*type_coordinates, nil, type: TypeSprite)
      end

      # @return Array of coordinates of the Skill type
      def type_coordinates
        return 155, 2
      end

      # Return the name of the new_selector file
      # @return [String]
      def new_selector_name
        'skill_learn/new_move_selector'
      end

      # Return the name of the method used to get the PP text
      # @return [Symbol]
      def pp_method
        :pp_text
      end

    end
  end
end
