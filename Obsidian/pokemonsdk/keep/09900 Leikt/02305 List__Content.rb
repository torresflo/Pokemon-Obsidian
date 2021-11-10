module UI
  class List
    # Class that create and handle the list content.
    # @author Leikt
    class Content < SpriteStack
      # The current index
      # @return [Integer]
      attr_reader :index
      # The scrollbar of the list
      # @return [UI::Scrollbar]
      attr_accessor :scrollbar
      # The content viewport
      # @return [Viewport]
      attr_reader :viewport

      # Create the content of the list. Arguments can ben :
      # @param :x, :y, :z [Integer] the coords of the content in the list window
      # @param :width, :height [Integer] the size of the content
      # @param :mode [Symbol] the cursor display mode
      # @param :cursor [String] the cursor windowskin
      # @author Leikt
      def initialize(**kwargs)
        # Retrieve data
        @content_style = (kwargs.fetch(:direction, :vertical) == :horizontal ? HorizontalContent : VerticalContent)
        width = kwargs[:width]
        height = kwargs[:height]
        @mode = kwargs[:mode]
        @cursor_skin = kwargs[:cursor]
        @looped = kwargs.fetch(:looped, false)
        # Create the viewport
        viewport = Viewport.create(kwargs[:x], kwargs[:y], width, height, kwargs[:z])
        # Main initialize
        super(viewport)
        # Initialize variables
        @index = 0
        @z = viewport.z
        @cursor_targeted_position = @content_targeted_position = nil
        @last_mouse_wheel = Mouse.wheel
      end

      # Load given data into the list and create the sprites if necessary
      # @param data [Array] the data to display
      # @param item_type [Class] the item type to display
      # @param item_params [Hash] the specific parameters of item creation
      # @author Leikt
      def setup(data, item_type, item_params)
        # Store data
        @data = data
        # Create / Update the list
        create_list(item_type, item_params)
        # Create / Update the cursor
        create_cursor
      end

      # Update the content animation
      # @author Leikt
      def update
        update_mouse_over
        update_cursor_animation
        update_content_animation
        @looping_index = nil if @looping_index && !animation_running?
      end

      # Refresh the data
      def refresh
        moveto(@index, false)
      end

      # Move the list to the given index with ou without animation. Return false if it's impossible.
      # @param index [Integer] the index to reach
      # @param with_anmation [Boolean, true] true if there is an animation
      # @return [Boolean]
      # @author Leikt
      def moveto(index, with_animation = true)
        # Skip if there is an animation requiered and already an running animation
        return if with_animation && animation_running?

        # Index correction
        index = correct_index(index)
        # With animation
        if with_animation
          # Move the cursor
          animated_cursor_moveto(index)
          # Move the list
          animated_content_moveto(index)
          # Process end
          animated_moveto_end(index)
        else
          # Set the cursor position
          static_cursor_moveto(index)
          # Set the list position
          static_content_moveto(index)
          # Process end
          static_moveto_end(index)
        end
      end

      # Return the currently selected object
      # @param mouse_must_be_over [Boolean, false] if true, while return nil if the mouse isn't over the content
      # @return [Object, nil]
      # @author Leikt
      def selected(mouse_must_be_over = false)
        return if mouse_must_be_over && !simple_mouse_in?

        return @data&.at(correct_index(@index))
      end

      # Detect if the mouse is over the content or not
      # @param mouse_x [Integer, Mouse.x] the mouse screen x coord
      # @param mouse_y [Integer, Mouse.y] the mouse screen y coord
      # @return [Boolean]
      # @author Leikt
      def simple_mouse_in?(mouse_x = Mouse.x, mouse_y = Mouse.y)
        return mouse_x.between?(@viewport.rect.x, @viewport.rect.x + @viewport.rect.width) &&
               mouse_y.between?(@viewport.rect.y, @viewport.rect.y + @viewport.rect.height)
      end

      # Set the origin x of the viewport and update the display
      # @param value [Integer] the new value
      def ox=(value)
        @viewport.ox = value
        update_data_display(@content_style.object_origin(@viewport))
      end

      # Set the origin y of the viewport and update the display
      # @param value [Integer] the new value
      def oy=(value)
        @viewport.oy = value
        update_data_display(@content_style.object_origin(@viewport))
      end

      # Get the origin y coord of the content
      # @return [Integer]
      def oy
        return @viewport.oy
      end

      # Get the origin x coord of the content
      # @return [Integer]
      def ox
        return @viewport.ox
      end

      # Return the height of the content in pixel
      # @return [Integer]
      def height
        return @content_style.height(@data.length, @item_size, @viewport)
      end

      # Return the width of the content in pixel
      # @return [Integer]
      def width
        return @content_style.width(@data.length, @item_size, @viewport)
      end

      # Return the viewport rect
      # @return [Rect]
      def rect
        return @viewport.rect
      end

      # Return the min origin of the viewport
      # @return [Integer]
      def min_origin
        return CONTENT_POSITIONNING[@mode].call(0, @item_list.length, @data.length) * @item_size
      end

      # Return the max origin of the viewport
      # @return [Integer]
      def max_origin
        return CONTENT_POSITIONNING[@mode].call(@data.length - 1, @item_list.length, @data.length) * @item_size
      end

      # Sort the item list with the given proc
      # @param sort_block [Block] the proc used to sort the data
      # @author Leikt
      def sort(block)
        @original_data ||= @data.clone
        if block
          @data.sort!(&block)
        else
          @data = @original_data
          @original_data = nil
        end
        moveto(@index, false)
      end

      # Filter the data and display only the one matching the proc
      # @param block [Proc] the filter proc
      def filter=(block)
        @original_data ||= @data.clone
        if block
          @data = @original_data.clone
          @data.select!(&block)
        else
          @data = @original_data
          @original_data = nil
        end
        moveto(@index, false)
      end

      # Dispose each sprite of the stack and clear the stack
      # @author Leikt
      def dispose
        super
        @cursor.dispose
      end

      private

      # The number of sprite to add before the beginning of list display
      # @return [Integer]
      BEGIN_ITEM_SUP = 1
      # The number of sprite to add after the end of list display
      # @return [Integer]
      END_ITEM_SUP = 1
      # Duration of the move animation
      # @return [Float]
      MOVE_DURATION = 8.0 # Frames

      # Hash of procs that calculate the content top index
      # @return [Hash<Symbol, Proc>]
      # @author Leikt
      CONTENT_POSITIONNING = {}
      CONTENT_POSITIONNING[:top] =
        CONTENT_POSITIONNING[:left] =
          proc do |index, _list_length, _data_length|
            index
          end
      CONTENT_POSITIONNING[:bottom] =
        CONTENT_POSITIONNING[:right] =
          proc do |index, list_length, _data_length|
            (index - list_length + 2 + BEGIN_ITEM_SUP + END_ITEM_SUP)
          end
      CONTENT_POSITIONNING[:top_clamped] =
        CONTENT_POSITIONNING[:left_clamped] =
          proc do |index, list_length, data_length|
            end_index = index + list_length - BEGIN_ITEM_SUP - END_ITEM_SUP - 1
            index -= end_index - data_length if data_length <= end_index
            index = 0 if index < 0
            index
          end
      CONTENT_POSITIONNING[:bottom_clamped] =
        CONTENT_POSITIONNING[:right_clamped] =
          proc do |index, list_length, _data_length|
            index -= list_length - BEGIN_ITEM_SUP - END_ITEM_SUP - 2
            index = 0 if index < 0
            index
          end
      CONTENT_POSITIONNING[:center] =
        proc do |index, list_length, _data_length|
          even_point = list_length.even? ? 1 : 0
          index -= ((list_length - BEGIN_ITEM_SUP - END_ITEM_SUP) / 2.0).floor - even_point
          index
        end
      CONTENT_POSITIONNING[:center_clamped] =
        proc do |index, list_length, data_length|
          # Variables
          offset = list_length - BEGIN_ITEM_SUP - END_ITEM_SUP - 1
          even_point = list_length.even? ? 1 : 0
          # Calculate bounds
          start_index = index - (offset / 2.0).floor
          end_index = index + (offset / 2.0).floor + even_point
          # Correct bounds
          start_index -= end_index - data_length if data_length <= end_index
          start_index = 0 if start_index < 0
          start_index
        end
      CONTENT_POSITIONNING.default = CONTENT_POSITIONNING[:top]

      # Detect if there is an animation running
      # @return [Boolean]
      # @author Leikt
      def animation_running?
        return @cursor_targeted_position || @content_targeted_position
      end

      # Correct the index to make it match with the list data
      # @param index [Integer] the index to correct
      # @return [Integer]
      def correct_index(index)
        if @looped
          if index < 0
            @looping_index = index
          elsif index >= @data.length
            @looping_index = index
          end
          index = (@data.empty? ? 0 : index % @data.length)
        else
          index = 0 if index < 0
          index = @data.length - 1 if index >= @data.length
        end
        return index
      end

      # Select the data with the given index
      # @param index [Integer] the index of the data
      # @return [Object]
      def select_data(index)
        if @looped
          return @data[correct_index(index)]
        else
          return index.between?(0, @data.length) ? @data[index] : nil
        end
      end

      # Create the item list sprites
      # @param item_type [Class] the class of the item
      # @param item_param [Hash] the item parameters
      # @author Leikt
      def create_list(item_type, item_param)
        # Dispose existing list
        @item_list&.each(&dispose)
        # Initializing variables
        @item_size = @content_style.item_size(item_type, item_param)
        @item_list = Array.new(calc_list_length(@item_size))
        # Test window
        # Window.new @viewport, 0, 0, @data.length * @item_size, @data.length * @item_size
        # Create the sprites
        0.upto(@item_list.length) do |id|
          sprite = push 0, 0, nil, item_param, type: item_type
          @content_style.set_object_position sprite, (id - 1) * @item_size
          @item_list[id] = sprite
        end
      end

      # Create the cursor
      # @author Leikt
      def create_cursor
        @cursor&.dispose
        if @cursor_skin
          @cursor = Window.new(
            @viewport, 0, 0,
            @content_style.cursor_width(@viewport, @item_size),
            @content_style.cursor_height(@viewport, @item_size),
            skin: @cursor_skin
          )
        else
          @cursor = nil
        end
      end

      # Calculate the sprite count for the list
      # @param item_size [Integer] the size of the item
      # @return [Integer]
      # @author Leikt
      def calc_list_length(item_size)
        return (@content_style.viewport_size(@viewport) / item_size) + BEGIN_ITEM_SUP + END_ITEM_SUP
      end

      # Move the cursor without animation
      # @param index [Integer] the index to reach
      # @author Leikt
      def static_cursor_moveto(index)
        @content_style.set_object_position @cursor, index * @item_size
      end

      # Move the content without animation
      # @param index [Integer] the index to reach
      # @author Leikt
      def static_content_moveto(index)
        new_position = CONTENT_POSITIONNING[@mode].call(index, @item_list.length, @data.length) * @item_size
        @content_style.set_object_origin self, new_position
      end

      # End the static moveto process
      # @param index [Integer] the index to reach
      # @author Leikt
      def static_moveto_end(index)
        # Set the new index
        @index = index
      end

      # Move the cursor with animation
      # @param index [Integer] the index to reach
      # @author Leikt
      def animated_cursor_moveto(index)
        anime_index = @looping_index || index
        @cursor_targeted_position = anime_index * @item_size
        cas = ((@cursor_targeted_position - @content_style.object_position(@cursor)) / MOVE_DURATION).round
        @cursor_animation_step = cas
        @index_targeted = index
        # Cancel animation if no move
        @cursor_targeted_position = nil if @cursor_animation_step == 0
      end

      # Move the content with animation
      # @param index [Integer] the index to reach
      # @author Leikt
      def animated_content_moveto(index)
        anime_index = @looping_index || index
        ctp = CONTENT_POSITIONNING[@mode].call(anime_index, @item_list.length, @data.length) * @item_size
        @content_targeted_position = ctp
        cas = ((@content_targeted_position - @content_style.object_origin(@viewport)) / MOVE_DURATION).round
        @content_animation_step = cas
        # Cancel animation if no move
        @content_targeted_position = nil if @content_animation_step == 0
      end

      # End the animated moveto process
      # @param index [Integer] the index to reach
      # @author Leikt
      def animated_moveto_end(index)
        # Set the index at the animation end
        @animation_end_index = index
      end

      # Update the displayed data
      # @param position [Integer] the position to set the data
      # @author Leikt
      def update_data_display(position = @content_style.object_origin(@viewport))
        # Calculate the index of the first sprite
        first_index = (position / @item_size) - BEGIN_ITEM_SUP
        first_item = @item_list.first
        modifiers_args = {
          list_length: @item_list.length,
          item_size: @item_size,
          selected_index: @index,
          viewport_ox: @viewport.ox,
          viewport_oy: @viewport.oy,
          viewport_dx: @viewport.ox % @item_size,
          viewport_dy: @viewport.oy % @item_size
        }
        # Update each sprite data
        @item_list.each_with_index do |item, index|
          data_index = first_index + index
          item.data = select_data(data_index)
          @content_style.set_object_position item, data_index * @item_size
          @content_style.set_object_other_position item, 0
          modifiers_args[:item] = item
          modifiers_args[:list_index] = index
          modifiers_args[:data_index] = data_index
          modifiers_args[:rel_x] = item.x - first_item.x
          modifiers_args[:rel_y] = item.y - first_item.y
          item.call_modifier(modifiers_args)
        end
      end

      # Update the mouse selection
      # @author Leikt
      def update_mouse_over
        return if animation_running?

        # Move with wheel
        wheel_diff = @last_mouse_wheel - (@last_mouse_wheel = Mouse.wheel)
        if wheel_diff != 0 && simple_mouse_in?
          moveto(@index += wheel_diff, true)
        # Mouse moving over the list
        elsif Mouse.moved && simple_mouse_in?
          @item_list.each do |item|
            next unless item.simple_mouse_in?

            i = @content_style.object_position(item) / @item_size
            next unless i.between?(0, @data.length - 1) || @looped

            @index = i
            static_cursor_moveto(i)
            break
          end
        end
      end

      # Update the cursor move animation
      # @author Leikt
      def update_cursor_animation
        return unless @cursor_targeted_position

        # Calculate and set the new position
        new_pos = @content_style.object_position(@cursor) + @cursor_animation_step
        @content_style.set_object_position @cursor, new_pos
        # Check the animation's end
        if @cursor_animation_step > 0 && new_pos >= @cursor_targeted_position ||
           @cursor_animation_step < 0 && new_pos <= @cursor_targeted_position
          @content_style.set_object_position @cursor, @cursor_targeted_position
          @cursor_targeted_position = nil
          @index = @index_targeted
          static_cursor_moveto(@index) if @looping_index
        end
      end

      # Update the content move animation
      # @author Leikt
      def update_content_animation
        return unless @content_targeted_position

        # Calculate and set the new position
        new_pos = @content_style.object_origin(@viewport) + @content_animation_step
        @content_style.set_object_origin self, new_pos
        # Check the animation's end
        if @content_animation_step > 0 && new_pos >= @content_targeted_position ||
           @content_animation_step < 0 && new_pos <= @content_targeted_position
          @content_style.set_object_origin self, @content_targeted_position
          @content_targeted_position = nil
          static_content_moveto(@index) if @looping_index
        end
      end
    end
  end
end
