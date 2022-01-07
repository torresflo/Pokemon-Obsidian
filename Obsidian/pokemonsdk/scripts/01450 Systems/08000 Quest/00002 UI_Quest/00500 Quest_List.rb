module UI
  module Quest
    class QuestList < SpriteStack
      # Number of buttons generated
      NB_QUEST_BUTTON = 7
      # Offset between each button
      BUTTON_OFFSET = 28
      # Base X coordinate
      BASE_X = 19
      # Base Y coordinate
      BASE_Y = 41
      # @return [Integer] index of the current active item
      attr_reader :index
      # @return [Array<QuestButton>]
      attr_reader :buttons
      # @param [Symbol] the pace of the timing (:slow, :medium, :fast)
      attr_writer :timing

      # Create a new QuestList
      # @param viewport [Viewport] viewport in which the SpriteStack will be displayed
      # @param quest_hash [Hash] the hash containing the quests
      # @param category [Symbol] the current category the UI spawns in
      def initialize(viewport, quest_hash, category)
        super(viewport)
        @quest_hash = quest_hash
        @quest_array = quest_hash.map { |_key, value| value }
        @timing = :slow
        @category = category
        @index = 0
        create_quest_buttons
      end

      # Return the number of buttons registered in the stack
      # @return [Integer]
      def number_of_buttons
        return @quest_array.size
      end

      # Set the current active item index
      # @param index [Integer]
      def index=(index)
        @index = index.clamp(0, @quest_array.size - 1)
      end

      # Move all the buttons up
      def move_up
        @buttons.last.quest = @quest_array[index - 1]
        animation = move_up_animation
        @buttons.rotate!(-1)
        self.index = index - 1
        return animation
      end

      # Move all the buttons down
      def move_down
        @buttons.last.quest = @quest_array[index + (NB_QUEST_BUTTON - 1)]
        animation = move_down_animation
        @buttons.rotate!(1)
        self.index = index + 1
        return animation
      end

      # Tell if the current index is the same as the last quest for this category
      def last_index?
        return index == @quest_array.size - 1
      end

      # Change the right button mode and return the animation
      # @param mode [Symbol]
      # @return [Yuki::Animation::ScalarAnimation]
      def change_mode(mode)
        anim = Yuki::Animation
        animation = @buttons[0].change_mode(mode)
        coord = (mode == :compact ? -87 : 87)
        (1..5).each do |i|
          bt = @buttons[i]
          animation.parallel_add(anim.move_discreet(0.5, bt, bt.x, bt.y, bt.x, @buttons[i].y + coord, distortion: :SMOOTH_DISTORTION))
        end
        return animation
      end

      private

      def create_quest_buttons
        # @type [Array<QuestButton>]
        @buttons = []
        NB_QUEST_BUTTON.times do |i|
          push_sprite(button = QuestButton.new(viewport, BASE_X, BASE_Y + BUTTON_OFFSET * i, @quest_array[i], @category))
          button.visible = @quest_array[i] ? true : false
          @buttons << button
        end
      end

      # Hash that contains each timing for the scrolling
      # @return [Hash<Float>]
      TIMING = { slow: 0.25, medium: 0.15, fast: 0.05 }

      # Return the right timing for animations
      # @return [Float]
      def timing
        return TIMING[@timing] || 0.25
      end

      # Move down animation (when the player press the UP KEY)
      # @return Yuki::Animation::TimedAnimation
      def move_down_animation
        anim = Yuki::Animation
        animation = anim.wait(0)
        @buttons.each_with_index do |button, i|
          if i == NB_QUEST_BUTTON - 1 && !button.hidden
            animation.parallel_add(anim.send_command_to(button, :visible=, true))
            animation.parallel_add(anim.opacity_change(timing, button, 0, 255, distortion: :SMOOTH_DISTORTION))
          elsif i == 0
            animation.parallel_add(anim.opacity_change(timing, button, 255, 0, distortion: :SMOOTH_DISTORTION))
                     .play_before(anim.send_command_to(button, :visible=, false))
          end
          move = anim.move_discreet(timing, button, button.x, button.y, button.x, button.y - BUTTON_OFFSET, distortion: :SMOOTH_DISTORTION)
          move.play_before(anim.move_discreet(0, button, button.x, button.y, button.x, BASE_Y + BUTTON_OFFSET * (NB_QUEST_BUTTON - 1), distortion: :SMOOTH_DISTORTION)) if i == 0
          animation.parallel_add(move)
        end
        animation.start
        return animation
      end

      # Move up animation
      # @return Yuki::Animation::TimedAnimation
      def move_up_animation
        anim = Yuki::Animation
        animation = anim.wait(0)
        @buttons.each_with_index do |button, i|
          if i == NB_QUEST_BUTTON - 1
            animation.parallel_add(anim.send_command_to(button, :visible=, true))
            animation.parallel_add(anim.opacity_change(timing, button, 0, 255, distortion: :SMOOTH_DISTORTION))
            animation.parallel_add(anim.move_discreet(timing, button, button.x, BASE_Y - BUTTON_OFFSET, button.x, BASE_Y, distortion: :SMOOTH_DISTORTION))
          else
            if i == NB_QUEST_BUTTON - 2
              animation.parallel_add(anim.opacity_change(timing, button, 255, 0, distortion: :SMOOTH_DISTORTION))
                       .play_before(anim.send_command_to(button, :visible=, false))
            end
            animation.parallel_add(anim.move_discreet(timing, button, button.x, button.y, button.x, button.y + BUTTON_OFFSET, distortion: :SMOOTH_DISTORTION))
          end
        end
        animation.start
        return animation
      end

      # Return the start index of the list
      # @return [Integer]
      def start_index
        @index - 1
      end
    end
  end
end
