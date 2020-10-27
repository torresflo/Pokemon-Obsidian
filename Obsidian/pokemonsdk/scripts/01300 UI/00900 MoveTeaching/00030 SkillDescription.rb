module UI
  module MoveTeaching
    # UI part displaying the Skill description in the Skill Learn scene
    class SkillDescription < SpriteStack
      # Create informations of the hovered skill
      # @param viewport [Viewport]
      def initialize(viewport)
        super(viewport, 114, 16, default_cache: :interface)
        create_texts
      end

      # Set the data of the UI
      # @param skill [PFM::Skill]
      def data=(skill)
        super
        update_infos(skill)
      end

      # Set the visibility of the UI
      # @param value [Boolean] new visibility
      def visible=(value)
        super
        @skill_info.visible = value
      end

      private

      # Update the informations of the Skill
      # @param skill [PFM::Skill]
      def update_infos(skill)
        @skill_info.each { |i| i.data = skill }
      end

      # Init the texts of the skill informations
      def create_texts
        texts = text_file_get(27)
        with_surface(0, 0, 95) do
          add_line(0, texts[3]) # Type
          add_line(1, texts[36]) # Category
          add_line(0, texts[37], dx: 1) # Power
          add_line(1, texts[39], dx: 1) # Accuracy
        end
        @skill_info = SpriteStack.new(@viewport)
        @skill_info.with_surface(114, 16, 95) do
          @skill_info.add_line(0, :power_text, 2, type: SymText, color: 1, dx: 1)
          @skill_info.add_line(1, :accuracy_text, 2, type: SymText, color: 1, dx: 1)
          @skill_info.add_line(2, :description, type: SymMultilineText, color: 1).width = 195
        end
        @skill_info.push(114 + 61, 16 + 1, nil, type: TypeSprite)
        @skill_info.push(114 + 61, 16 + 17, nil, type: CategorySprite)
      end

    end
  end
end