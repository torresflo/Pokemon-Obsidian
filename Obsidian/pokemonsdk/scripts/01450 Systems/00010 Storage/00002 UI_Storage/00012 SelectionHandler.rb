module UI
  module Storage
    # Class responsive of handling the selection
    class SelectionHandler
      # Set the current storage object
      # @param storage [PFM::Storage]
      attr_writer :storage
      # Set the current cursor handler
      # @param cursor [CursorHandler]
      attr_writer :cursor
      # Set the current party
      # @param party [Array<PFM::Pokemon>]
      attr_writer :party
      # Create a new selection handler
      # @param mode_handler [ModeHandler] object responsive of handling the mode
      def initialize(mode_handler)
        @mode_handler = mode_handler
        @box_selections = {}
        @battle_selections = {}
        @party_selection = []
        # @type [CursorHandler]
        @cursor = nil
        # @type [PFM::Storage]
        @storage = nil
        # @type [Array<PFM::Pokemon>]
        @party = nil
      end

      # Update the current selection
      def update_selection
        @box&.update_selection(@box_selections[@storage.current_box] || [])
        @party_display&.update_selection(
          @mode_handler.mode == :battle ? @battle_selections[@storage.current_battle_box] || [] : @party_selection
        )
      end

      # Tell if all selection are empty
      # @return [Boolean]
      def empty?
        @box_selections.all? { |_, v| v.empty? } &&
          @battle_selections.all? { |_, v| v.empty? } &&
          @party_selection.empty?
      end

      # Select or deselect the current index
      def select
        if @cursor.mode == :box
          arr = (@box_selections[@storage.current_box] ||= [])
        elsif @mode_handler.mode == :battle
          arr = (@battle_selections[@storage.current_battle_box] ||= [])
        else
          arr = @party_selection
        end
        if arr.include?(index = @cursor.index)
          arr.delete(index)
        else
          arr << index
        end
      end

      # Move the current selection of pokemon to the current cursor
      # @return [Boolean] if the operation was a success
      def move_pokemon_to_cursor
        size = current_object_size
        return false if selection_size > size

        set_pokemon = current_object_setter
        get_pokemon = current_object_getter
        index = @cursor.index

        process = proc do |box, i|
          pokemon = get_pokemon.call(index)
          set_pokemon.call(index, box[i])
          index = (index + 1) % size
          box[i] = pokemon
        end

        each_box_selection(&process)
        each_battle_selection(&process)
        each_party_selection(&process)

        clear
        @party.compact!
        return true
      end

      # Move the current selection of items to the current cursor
      # @return [Boolean] if the operation was a success
      def move_items_to_cursor
        size = current_object_content_size
        return false if selection_size > size

        get_pokemon = current_object_getter
        index = @cursor.index

        process = proc do |box, i|
          next unless box[i]

          pokemon = get_pokemon.call(index)
          index = (index + 1) % size
          redo unless pokemon
          box[i].item_holding, pokemon.item_holding = pokemon.item_holding, box[i].item_holding
          box[i].form_calibrate
          pokemon.form_calibrate
        end

        each_box_selection(&process)
        each_battle_selection(&process)
        each_party_selection(&process)

        clear
        return true
      end

      # Release all selected Pokemon
      def release_selected_pokemon
        process = proc do |box, i|
          box[i] = nil
        end

        each_box_selection(&process)
        each_battle_selection(&process)
        each_party_selection(&process)

        clear
        @party.compact!
      end

      # Clear the selection
      def clear
        @box_selections.clear
        @battle_selections.clear
        @party_selection.clear
      end

      # Define the box selection display
      # @param box [#update_selection(arr)]
      def box_selection_display=(box)
        @box = box
      end

      # Define the party selection display
      # @parma party_display [#update_selection(arr)]
      def party_selection_display=(party_display)
        @party_display = party_display
      end

      # Get all selected Pokemon
      # @return [Array<PFM::Pokemon>]
      def all_selected_pokemon
        selection = []
        process = proc { |box, i| selection << box[i] if box[i] }
        each_box_selection(&process)
        each_battle_selection(&process)
        each_party_selection(&process)

        return selection
      end

      # Get all selected Pokemon in party
      # @return [Array<PFM::Pokemon>]
      def all_selected_pokemon_in_party
        return @party_selection.map { |i| @party[i] }.compact
      end

      private

      # Get the selection size
      # @return [Integer]
      def selection_size
        @box_selections.sum { |_, v| v.size } +
          @battle_selections.sum { |_, v| v.size } +
          @party_selection.size
      end

      # Get the current object size
      # @return [Integer]
      def current_object_size
        if @cursor.mode == :box
          return @storage.current_box_object.content.size
        elsif @mode_handler.mode == :battle
          return @storage.battle_boxes[@storage.current_battle_box].content.size
        else
          return 6
        end
      end

      # Get the current object actual content size
      # @return [Integer]
      def current_object_content_size
        if @cursor.mode == :box
          return @storage.current_box_object.content.compact.size
        elsif @mode_handler.mode == :battle
          return @storage.battle_boxes[@storage.current_battle_box].content.compact.size
        else
          return @party.compact.size
        end
      end

      # Get the current object setter
      # @return [#call(index, value)]
      def current_object_setter
        if @cursor.mode == :box
          return @storage.current_box_object.content.method(:[]=)
        elsif @mode_handler.mode == :battle
          return @storage.battle_boxes[@storage.current_battle_box].content.method(:[]=)
        else
          return @party.method(:[]=)
        end
      end

      # Get the current object getter
      # @return [#call(index)]
      def current_object_getter
        if @cursor.mode == :box
          return @storage.current_box_object.content.method(:[])
        elsif @mode_handler.mode == :battle
          return @storage.battle_boxes[@storage.current_battle_box].content.method(:[])
        else
          return @party.method(:[])
        end
      end

      # Iterate through all box selection
      # @yieldparam box [Array<PFM::Pokemon>] current box object
      # @yieldparam i [Integer] current selection
      def each_box_selection
        @box_selections.each do |index, selections|
          box = @storage.get_box_content(index)
          selections.each do |i|
            yield(box, i)
          end
        end
      end

      # Iterate through all battle box selection
      # @yieldparam box [Array<PFM::Pokemon>] current battle box object
      # @yieldparam i [Integer] current selection
      def each_battle_selection
        @battle_selections.each do |index, selections|
          box = @storage.battle_boxes[index].content
          selections.each do |i|
            yield(box, i)
          end
        end
      end

      # Iterate through all party selection
      # @yieldparam party [Array<PFM::Pokemon>] current party object
      # @yieldparam i [Integer] current selection
      def each_party_selection
        @party_selection.each do |i|
          yield(@party, i)
        end
      end
    end
  end
end
