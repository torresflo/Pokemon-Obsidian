module UI
  module Storage
    # Class responsive of showing the cursor
    class Cursor < ShaderedSprite
      # Get the index
      # @return [Integer]
      attr_reader :index
      # Get the inbox property /!\ Always update this before index
      # @return [Boolean]
      attr_reader :inbox
      # Get the select box mode
      # @return [Boolean]
      attr_reader :select_box
      # Get the current selection mode
      # @return [Symbol]
      attr_reader :selection_mode
      # Get the current mode
      # @return [Symbol]
      attr_reader :mode
      # Box initial position
      BOX_INITIAL_POSITION = [17, 42]
      # Party positions
      PARTY_POSITIONS = [
        [233, 50], [281, 66],
        [233, 98], [281, 115],
        [233, 146], [281, 162]
      ]
      # List of graphics depending on the selection mode
      ARROW_IMAGES = { battle: 'pc/arrow_red', pokemon: 'pc/arrow_blue', grouped: 'pc/arrow_green', item: 'pc/arrow_yellow' }
      # Create a new cusror object
      # @param viewport [Viewport]
      # @param index [Integer] index of the cursor where it is
      # @param inbox [Boolean] If the cursor is in box or not
      # @param mode_handler [ModeHandler]
      def initialize(viewport, index, inbox, mode_handler)
        super(viewport)
        @max_index_box = PFM.storage_class.box_size - 1
        @max_index_battle = PARTY_POSITIONS.size - 1
        @inbox = inbox
        @index = index % (max_index + 1)
        mode_handler.add_selection_mode_ui(self)
        mode_handler.add_mode_ui(self)
        update_position
        set_z(31)
      end

      # Update the animation
      def update
        @animation&.update
      end

      # Tell if the animation is done
      # @return [Boolean]
      def done?
        return @animation ? @animation.done? : true
      end

      # Get the max index
      # @return [Integer]
      def max_index
        return @inbox ? @max_index_box : @max_index_battle
      end

      # Set the current index
      # @param index [Integer]
      def index=(index)
        @index = index % (max_index + 1)
        update_position_with_animation
      end

      # Force an index (mouse operation)
      # @param inbox [Boolean]
      # @param index [Integer]
      def force_index(inbox, index)
        @select_box = false
        @inbox = inbox
        @index = index % (max_index + 1)
        update_position
        self.visible = false
      end

      # Set the inbox property
      # @param inbox [Boolean]
      def inbox=(inbox)
        @select_box = false if inbox
        @inbox = inbox
        update_graphics
        update if @inbox
      end

      # Set the selec box property
      # @param select_box [Boolean]
      def select_box=(select_box)
        @inbox = false if select_box
        @select_box = select_box
        set_position(67, 14)
        update_graphics
      end

      # Set the current selection mode
      # @param selection_mode [Symbol]
      def selection_mode=(selection_mode)
        @selection_mode = selection_mode
        update_graphics
      end

      # Set the current mode
      # @param mode [Symbol]
      def mode=(mode)
        @mode = mode
        update_graphics
      end

      private

      def update_graphics
        self.visible = !@select_box
        graphic = ARROW_IMAGES[@selection_mode] || ARROW_IMAGES[@mode]
        set_bitmap(graphic, :interface)
      end

      def update_position
        if @inbox
          x_pos, y_pos = *BOX_INITIAL_POSITION
          set_position(x_pos + 32 * (@index % 6), y_pos + 32 * (@index / 6))
        else
          set_position(*PARTY_POSITIONS[@index])
        end
      end

      def update_position_with_animation
        ori_x = x
        ori_y = y
        update_position
        @animation = Yuki::Animation.move(0.05, self, ori_x, ori_y, x, y)
        @animation.start
      end
    end
  end
end
