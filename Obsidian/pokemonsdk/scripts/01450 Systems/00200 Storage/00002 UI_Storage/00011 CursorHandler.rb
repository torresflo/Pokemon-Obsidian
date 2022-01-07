module UI
  module Storage
    # Class that handle all the logic related to cursor movement between each party of the UI
    class CursorHandler
      # Create a cusor handler
      # @param cursor [Cursor]
      def initialize(cursor)
        @cursor = cursor
      end

      # Get the cursor mode
      # @return [Symbol] :box, :party, :box_choice
      def mode
        return :box if @cursor.inbox
        return :box_choice if @cursor.select_box

        return :party
      end

      # Get the index of the cursor
      # @return [Integer]
      def index
        @cursor.index
      end

      # Move the cursor to the right
      # @return [Boolean] if the action was a success
      def move_right
        @cursor.visible = true
        return false if @cursor.select_box

        return @cursor.inbox ? move_right_inbox : move_right_party
      end

      # Move the cursor to the left
      # @return [Boolean] if the action was a success
      def move_left
        @cursor.visible = true
        return false if @cursor.select_box

        return @cursor.inbox ? move_left_inbox : move_left_party
      end

      # Move the cursor up
      # @return [Boolean] if the action was a success
      def move_up
        @cursor.visible = true
        return false if @cursor.select_box

        if @cursor.inbox && @cursor.index <= 5
          @cursor.select_box = true
        else
          @cursor.index -= @cursor.inbox ? 6 : 2
        end
        return true
      end

      # Move the cursor down
      # @return [Boolean] if the action was a success
      def move_down
        @cursor.visible = true
        if @cursor.select_box
          @cursor.inbox = true
          @cursor.index = @cursor.index
        else
          @cursor.index += @cursor.inbox ? 6 : 2
        end
        return true
      end

      private

      # Move the cursor to the right in the box
      # @return [Boolean] if the action was a success
      def move_right_inbox
        if @cursor.index % 6 == 5
          @cursor.inbox = false
          @cursor.index = @cursor.index / 12 * 2 # / # <= Fix for VSCode thinking it's a regular expression
        else
          @cursor.index += 1
        end
        return true
      end

      # Move the cursor to the right in the party
      # @return [Boolean] if the action was a success
      def move_right_party
        return false if @cursor.index.odd?

        @cursor.index += 1
        return true
      end

      # Move the cursor to the left in the box
      # @return [Boolean] if the action was a success
      def move_left_inbox
        if (@cursor.index % 6) > 0
          @cursor.index -= 1
          return true
        end

        return false
      end

      # Move the cursor to the left in the party
      # @return [Boolean] if the action was a success
      def move_left_party
        if @cursor.index.even?
          @cursor.inbox = true
          @cursor.index = @cursor.index / 2 * 12 + 5 # / # <= Fix for VSCode thinking it's a regular expression
        else
          @cursor.index -= 1
        end

        return true
      end
    end
  end
end
