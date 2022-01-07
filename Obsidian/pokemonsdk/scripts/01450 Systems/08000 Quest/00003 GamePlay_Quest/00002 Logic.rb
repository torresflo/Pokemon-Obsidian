module GamePlay
  class QuestUI
    private

    # Update the text of the A button depending on if the quests are deployed or not
    def update_a_button_text
      @base_ui.ctrl[0].text = a_button_text
    end

    # Update the text of the B button depending on if the quests are deployed or not
    def update_b_button_text
      @base_ui.ctrl[3].text = b_button_text
    end

    # Update the text of the B button depending on if the quests are deployed or not
    def update_x_button_text
      @base_ui.ctrl[1].text = @quest_deployed == :deployed ? x_button_text : nil
    end

    # Change the category depending on the input
    # @param trigger [Symbol] :left or :right
    def change_category(trigger)
      arr = CATEGORIES
      current_category = arr.index(@category)
      current_category += trigger == :left ? -1 : 1
      current_category = current_category.clamp(0, arr.size - 1)
      @composition.update_category(@category = arr[current_category])
    end

    # Launch the quest switching mode procedure
    def switch_quest_mode
      return unless @composition.current_list

      commute_quest_deployed
      @composition.change_mode_quest(@quest_deployed)
      @composition.change_deployed_mode(@deployed_mode)
      update_a_button_text
      update_b_button_text
      update_x_button_text
    end
  end
end
