module UI
  module Quest
    class QuestButton < SpriteStack
      attr_accessor :hidden
      # Return the quest linked to this button
      # @return PFM::Quests::Quest
      attr_reader :quest
      # Initialize the QuestButton component
      # @param viewport [Viewport]
      # @param x [Integer]
      # @param y [Integer]
      # @param quest [PFM::Quests::Quest]
      # @param status [Symbol] if the quest is a primary, a secondary, or a finished quest
      def initialize(viewport, x, y, quest, status)
        super(viewport, x, y)
        @viewport = viewport
        @quest = quest
        @status = status
        @hidden = false
        create_frame
        create_title
        self.quest = quest
      end

      # Get the animation corresponding to the mode the button switches in
      # @param mode [Symbol]
      # @return [Yuki::Animation::ScalarAnimation]
      def change_mode(mode)
        return (mode == :deployed ? opening_animation : compacting_animation)
      end

      # Reload all sub-component with a new quest
      # @param quest [PFM::Quests::Quest]
      def quest=(quest)
        self.visible = !quest.nil?
        @hidden = quest.nil?
        return if quest.nil?

        @quest = quest
        @title.text = data_quest.name
      end

      private

      def create_frame
        @frame = add_sprite(0, 0, frame_filepath)
        @frame.set_rect(0, 0, @frame.width, 20)
        @frame_border = add_sprite(0, 17, 'quest/win_border')
      end

      def create_title
        @title = add_text(26, 5, 235, 13, '', color: 10)
      end

      # Get the animation for when the button is closing
      # @return [Yuki::Animation::ScalarAnimation]
      def compacting_animation
        anim = Yuki::Animation
        animation = anim.scalar(0.5, @frame.src_rect, :height=, 107, 20, distortion: :SMOOTH_DISTORTION)
        animation.parallel_add(anim.scalar(0.5, @frame_border, :y=, @frame_border.y, y + 17, distortion: :SMOOTH_DISTORTION))
        return animation
      end

      # Get the animation for when the button is opening
      # @return [Yuki::Animation::ScalarAnimation]
      def opening_animation
        anim = Yuki::Animation
        animation = anim.scalar(0.5, @frame.src_rect, :height=, 20, 107, distortion: :SMOOTH_DISTORTION)
        animation.parallel_add(anim.scalar(0.5, @frame_border, :y=, @frame_border.y, y + 104, distortion: :SMOOTH_DISTORTION))
        return animation
      end

      # Get the right filepath for the frame
      # @return [String]
      def frame_filepath
        return 'quest/win_active' if @status == :primary
        return 'quest/win_active' if @status == :secondary
        return 'quest/win_finished' if @status == :finished

        return 'quest/win_active'
      end

      # Return the data for the current quest stocked
      # @return GameData::Quest
      def data_quest
        return GameData::Quest[@quest.quest_id]
      end
    end
  end
end
