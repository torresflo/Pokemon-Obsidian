module GamePlay
  class PokemonStorage
    # Refresh everything in the UI
    def refresh
      @composition.storage = @storage
      @composition.party = @party
      update_summary
      update_mode
      @selection.update_selection
    end

    private

    # Function responsive of changing the box
    # @param moved_right [Boolean] if the player supposedly pressed right
    def change_box(moved_right)
      @index = (@index + (moved_right ? 1 : -1)) % @storage.box_count
      animation = Yuki::Animation.send_command_to(self, :update_box_shown)
      moved_right ? @composition.animate_right_arrow(animation) : @composition.animate_left_arrow(animation)
    end

    # Function that updates the box shown
    def update_box_shown
      play_cursor_se
      @storage.current_box = @index
      refresh
    end

    # Update the summary
    def update_summary
      if @cursor.mode == :box
        @composition.summary.data = @storage.current_box_object.content[@cursor.index]
      else
        @summary.reduce
      end
    end

    # Clear the selection
    def clear_selection
      @selection_box.clear
      @selection_party.clear
      refresh
    end

    # Update the mode of the base_ui
    def update_mode
      return unless @base_ui

      if @cursor.mode == :box_choice
        @base_ui.mode = 6
      elsif @mode_handler.selection_mode == :detailed
        @base_ui.mode = MODE_TO_BASE_UI_MODE[@mode_handler.mode]
      elsif @selection.empty?
        if @mode_handler.selection_mode == :fast
          @base_ui.mode = 4
        else
          @base_ui.mode = 3
        end
      elsif @mode_handler.selection_mode == :fast
        @base_ui.mode = 5
      else
        @base_ui.mode = 3
      end
    end

    # Tell if we can leave the storage
    # @return [Boolean]
    def can_leave_storage?
      return @party.any?(&:alive?) || !@storage.any_pokemon_alive
    end

    # Tell if the current box is not empty
    # @return [Boolean]
    def current_box_non_empty?
      return @storage.current_box_object.content.any?
    end

    # Tell if the pokemon can be released
    def pokemon_can_be_released?
      return false if @selection.all_selected_pokemon_in_party.any?

      return (@cursor.mode == :box || (@mode_handler.mode == :battle && @cursor.mode == :party)) && @party.any?(&:alive?)
    end
  end
end
