module UI
  module Quest
    class Composition < SpriteStack
      # Get the scrollbar element
      # @return [UI::Quest::ScrollBar]
      attr_accessor :scrollbar
      # Get the current state of the button
      # @return [Symbol]
      attr_accessor :button_state

      # Create the Composition of the scene
      # @param viewport [Viewport]
      # @param sub_viewport [Viewport]
      # @param sub_viewport2 [Viewport]
      # @param quests [PFM::Quests]
      def initialize(viewport, sub_viewport, sub_viewport2, quests)
        super(viewport)
        @viewport = viewport
        @sub_viewport = sub_viewport
        @sub_viewport2 = sub_viewport2
        @quests = quests
        @animation_handler = Yuki::Animation::Handler.new
        @category = :primary
        @state = :compact # Possible states being :compact and :deployed
        create_quest_list
        create_frame
        create_category_window
        create_scrollbar
        create_arrow
        create_quest_description
        create_quest_current_objective
        create_quest_rewards
        create_quest_objective_list
        update_max_index_scrollbar
        update_scrollbar
      end

      # Update all animations
      def update
        @arrow.update
        return if @animation_handler.empty?

        @animation_handler.update
      end

      # Tells if all animations are done
      # @return [Boolean]
      def done?
        return @animation_handler.done?
      end

      # Update the current category and launch the corresponding procedure
      # @param new_category [Symbol] 
      def update_category(new_category)
        return if @category == new_category

        old_category = @category
        @category = new_category
        @category_display.update_category_text(@category)
        swap_lists(old_category)
        update_max_index_scrollbar
        update_scrollbar
        update_arrow
      end

      # Get the current QuestList index
      # @return [Integer]
      def index
        return current_list.index
      end

      # Input the direction of the scrolling
      # @param direction [Symbol]
      # @param timing [Symbol] the timing of the scrolling
      def input_direction(direction, timing = :slow)
        return if current_list.last_index? && direction == :DOWN
        return if current_list.index == 0 && direction == :UP

        move_list(direction, timing)
        update_scrollbar if @scrollbar.visible == true
      end

      # Change the mode of the first button
      # @param mode [Symbol]
      def change_mode_quest(mode)
        reload_deployed_components if mode == :deployed
        animation = current_list.change_mode(mode)
        anim = Yuki::Animation
        coord = mode == :deployed ? 87 : -87
        coord2 = mode == :deployed ? 63 : -63
        animation.parallel_add(anim.scalar(0.5, @sub_viewport.rect, :height=, @sub_viewport.rect.height, @sub_viewport.rect.height + coord,
                                           distortion: :SMOOTH_DISTORTION))
        objective_list_anim = anim.wait(0.12)
        objective_list_anim.play_before(anim.send_command_to(@sub_viewport2, :visible=, true)) if mode == :deployed
        objective_list_anim.play_before(anim.scalar(0.28, @sub_viewport2.rect, :height=, @sub_viewport2.rect.height, @sub_viewport2.rect.height + coord2,
                                                    distortion: :SMOOTH_DISTORTION))
        objective_list_anim.play_before(anim.send_command_to(@sub_viewport2, :visible=, false)) if mode != :deployed
        animation.parallel_add(objective_list_anim)
        animation.start
        @animation_handler[:deploy] = animation if animation
      end

      # Change the state in the deployed mode
      # @param mode [Symbol]
      def change_deployed_mode(mode)
        @description.visible = (mode == :descr)
        @rewards.visible = (mode == :rewards)
        @objective_list.visible = (mode == :objectives)
      end

      # Swap through the rewards depending on the direction
      # @param direction [Symbol]
      def swap_rewards(direction)
        @rewards.scroll_rewards(direction)
      end

      # Scroll through the objective list depending on the direction
      # @param direction [Symbol]
      def scroll_objective_list(direction)
        @objective_list.scroll_text(direction)
      end

      # Get the current QuestList
      # @return [QuestList, nil]
      def current_list
        return @sym_to_list[@category]
      end

      private

      def create_frame
        @frame = QuestFrame.new(@viewport)
      end

      def create_arrow
        @arrow = push_sprite(UI::Quest::Arrow.new(viewport))
        @arrow.visible = current_list ? true : false
      end

      def create_category_window
        @category_display = CategoryDisplay.new(@viewport, @category)
      end

      def create_scrollbar
        @scrollbar = ScrollBar.new(@viewport)
      end

      def create_quest_list
        unless @quests.active_quests.empty?
          list = @quests.active_quests.select { |_k, v| GameData::Quest[v.quest_id].primary }
          @quest_list_primary = QuestList.new(@viewport, list, :primary) unless list.keys.empty?
        end
        unless @quests.active_quests.empty?
          list = @quests.active_quests.reject { |_k, v| GameData::Quest[v.quest_id].primary }
          unless list.keys.empty?
            @quest_list_secondary = QuestList.new(@viewport, list, :secondary)
            @quest_list_secondary.opacity = 0
          end
        end
        unless @quests.finished_quests.empty? #&& @quests.failed_quests.empty? => In a future update maybe
          @quest_list_finished = QuestList.new(@viewport, @quests.finished_quests, :finished)
          @quest_list_finished.opacity = 0
        end
        # @type [Hash<QuestList>]
        @sym_to_list = { primary: @quest_list_primary, secondary: @quest_list_secondary, finished: @quest_list_finished }
      end

      def create_quest_description
        @description = Text.new(0, @sub_viewport, 27, 62, 272, 16, '')
        update_quest_description unless current_list.nil?
        @sub_viewport.rect.height = 61
      end

      def update_quest_description
        @description.multiline_text = GameData::Quest[current_list.buttons[0].quest.quest_id].descr
      end

      def create_quest_current_objective
        @current_objective = Text.new(0, @sub_viewport, 27, 129, 272, 16, '', 0, nil, 10)
        update_quest_current_objective if current_list
      end

      def update_quest_current_objective
        data = current_list.buttons[0].quest.objective_text_list
        data = data.find { |objective| objective[1] == false }
        data = data ? data[0] : ''
        @current_objective.text = data
      end

      def create_quest_rewards
        @rewards = RewardScreen.new(@sub_viewport, 25, 63)
        update_quest_rewards unless current_list.nil?
        @rewards.visible = false
      end

      def update_quest_rewards
        @rewards.quest = current_list.buttons[0].quest
      end

      def create_quest_objective_list
        @objective_list = ObjectiveList.new(@sub_viewport2)
        update_quest_objective_list unless current_list.nil?
        @objective_list.visible = false
        @sub_viewport2.rect.height = 1
      end

      def update_quest_objective_list
        data = current_list.buttons[0].quest.objective_text_list
        @objective_list.update_text(data)
      end

      # Engage the swapping between old and new category
      # @param old_category [Symbol]
      def swap_lists(old_category)
        arr_categories = GamePlay::QuestUI::CATEGORIES
        direction_of_swap = (arr_categories.index(old_category) < arr_categories.index(@category) ? :left : :right)
        @animation_handler[:swap_lists] = swap_list_animation(old_category, direction_of_swap)
      end

      # The timing of the animations
      # @return [Float]
      TIMING = 0.5

      # Return the animation for the list swapping
      # @param old_category [Symbol]
      # @param direction [Symbol] the direction of the swapping
      # @return [Yuki::Animation::TimedAnimation]
      def swap_list_animation(old_category, direction)
        anim = Yuki::Animation
        animation = anim.wait(0.01)
        if (list = @sym_to_list[old_category])
          direction2 = direction == :left ? 320 : -320
          animation.play_before(anim.move_discreet(TIMING, list, 0, list.y, 0 - direction2, list.y, distortion: :SMOOTH_DISTORTION))
                   .parallel_play(anim.opacity_change(TIMING, @sym_to_list[old_category], 255, 0, distortion: :SMOOTH_DISTORTION))
          animation.play_before(anim.wait(TIMING))
        end
        if (list = current_list)
          direction2 = direction == :left ? 320 : -320
          animation.play_before(anim.move_discreet(TIMING, current_list, 0 + direction2, list.y, 0, list.y, distortion: :SMOOTH_DISTORTION))
                   .parallel_play(anim.opacity_change(TIMING, current_list, 0, 255, distortion: :SMOOTH_DISTORTION))
        end
        animation.start
        return animation
      end

      # Update the maximum index of the scrollbar
      def update_max_index_scrollbar
        nb_button = current_list&.number_of_buttons || 0
        @scrollbar.max_index = (nb_button == 0 ? nb_button : nb_button - 1)
      end

      # Update the scrollbar's current index
      def update_scrollbar
        if current_list
          @scrollbar.visible = current_list.number_of_buttons > 1
          @scrollbar.index = current_list&.index || 0
        else
          @scrollbar.visible = false
        end
      end

      # Update the visible attribute of arrow depending on if there's quest in a category or not
      def update_arrow
        @arrow.visible = !current_list.nil?
      end

      # Move the list in the given direction at the given timing
      # @param direction [Symbol]
      # @param timing [Symbol]
      def move_list(direction, timing)
        current_list.timing = timing
        animation = direction == :UP ? current_list&.move_up : current_list&.move_down
        @animation_handler[:move_list] = animation if animation
      end

      # Reload all components involved in the deployed mode
      def reload_deployed_components
        update_quest_description
        update_quest_current_objective
        update_quest_rewards
        update_quest_objective_list
      end
    end
  end
end
