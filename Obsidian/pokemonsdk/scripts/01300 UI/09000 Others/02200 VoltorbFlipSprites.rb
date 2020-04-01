module UI
  module VoltorbFlip
    # Object that show a text using a method of the data object sent
    class Texts < SpriteStack
      # Format of the coin case text
      COIN_CASE_FORMAT = '%07d'
      # Format of the coin gain text
      COIN_GAIN_FORMAT = '%05d'
      # Create a new VoltorbFlip text handler
      # @param viewport [Viewport]
      def initialize(viewport)
        super(viewport)
        @font_id = 20

        @title = add_text(0, 0, 320, 35, '', 1, color: 10)
        @title.bold = true
        @title.size = 22

        @coin_case = add_text(227, 172, 81, 24, '', 2, color: 7)
        @coin_case.bold = true
        @coin_case.size = 22

        @coin_gain = add_text(248, 203, 60, 24, '', 2, color: 7)
        @coin_gain.bold = true
        @coin_gain.size = 22

        @level = add_text(203, 203, 24, 24, '', color: 7)
        @level.bold = true
        @level.size = 22
      end

      # Set the title
      # @param value [String]
      def title=(value)
        @title.text = value.upcase
      end

      # Set the coin case content value
      # @param value [Integer]
      def coin_case=(value)
        @coin_case.text = format(COIN_CASE_FORMAT, value.to_i)
      end

      # Set the gain value
      # @param value [Integer]
      def coin_gain=(value)
        @coin_gain.text = format(COIN_GAIN_FORMAT, value.to_i)
      end

      # Set the level value
      # @param value [Integer]
      def level=(value)
        @level.text = format(ext_text(9000, 145), value) # "N#{value}"
      end
    end

    # Cursor shown in VoltorbFlip scene
    class Cursor < Sprite
      # The X coords on the board of the cursor
      # @return [Integer]
      attr_reader :board_x
      # The Y coords on the board of the cursor
      # @return [Integer]
      attr_reader :board_y
      # The cursor mode :normal, :memo
      # @return [Symbol]
      attr_reader :mode

      # Create a new cursor
      # @param viewport [Viewport]
      def initialize(viewport)
        super(viewport)
        set_bitmap('voltorbflip/markers', :interface)
        self.mode = :normal
        @move_count = false
        @board_x = 0
        @board_y = 0
        set_position(*get_board_position(@board_x, @board_y))
      end

      # Update the cursor mouvement, return true if the mouvement has been updated
      # @return [Boolean]
      def update_move
        return false unless @move_count
        cursor_duration = GamePlay::Casino::VoltorbFlip::CursorMoveDuration
        self.x = @move_data[0] + (@move_data[2] - @move_data[0]) * @move_count / cursor_duration
        self.y = @move_data[1] + (@move_data[3] - @move_data[1]) * @move_count / cursor_duration
        @move_count = false if (@move_count += 1) > cursor_duration
        return true
      end

      # Convert board coord in pixel coords
      # @param x [Integer] X position on the board
      # @param y [Integer] Y position on the board
      # @return [Array(Integer, Integer)] the pixel coordinate
      def get_board_position(x, y)
        if y > 4 # Quit button
          return GamePlay::Casino::VoltorbFlip::QuitDispX,
                 GamePlay::Casino::VoltorbFlip::QuitDispY
        elsif x > 4 # Memo
          return GamePlay::Casino::VoltorbFlip::MemoDispX,
                 GamePlay::Casino::VoltorbFlip::MemoDispY + y * ::GamePlay::Casino::VoltorbFlip::MemoTileSize
        else # Board
          return GamePlay::Casino::VoltorbFlip::BoardDispX + x * ::GamePlay::Casino::VoltorbFlip::TileOffset,
                 GamePlay::Casino::VoltorbFlip::BoardDispY + y * ::GamePlay::Casino::VoltorbFlip::TileOffset
        end
      end

      # Start the cursor mouvement
      # @param dx [Integer] the number of case to move in x
      # @param dy [Integer] the number of case to move in y
      def move_on_board(dx, dy)
        # Update board coords
        if @board_y == 5 && dx != 0
          @board_x = (dx < 0 ? 4 : 5)
          @board_y = 4
        else
          @board_x += dx
          @board_y += dy
        end
        # Correct boundaries
        @board_x = 0 if @board_x < 0
        @board_y = 0 if @board_y < 0
        @board_x = 5 if @board_x > 5
        @board_y = 5 if @board_y > 5
        # Init mouvement
        @move_count = 0
        @move_data = [x, y, *get_board_position(@board_x, @board_y)]
      end

      # Move the cursor to a dedicated board coordinate
      # @param board_x [Integer]
      # @param board_y [Integer]
      def moveto(board_x, board_y)
        set_position(*get_board_position(@board_x = board_x, @board_y = board_y))
      end

      # Set the cursor mode (affect src_rect)
      # @param value [Symbol]
      def mode=(value)
        @mode = value
        if value == :memo
          set_rect_div(1, 0, 6, 1)
        else
          set_rect_div(0, 0, 6, 1)
        end
      end
    end

    # Memo tiles in VoltorbFlip game
    class MemoTile < Sprite
      # Create a new MemoTile
      # @param viewport [Viewport]
      # @param index [Integer]
      def initialize(viewport, index)
        super(viewport)
        @index = index
        set_bitmap('voltorbflip/memo_tiles', :interface)
        disable
      end

      # Tell if the tile is enabled
      # @return [Boolean]
      def enabled?
        return src_rect.y > 0
      end

      # Enable the tile
      def enable
        set_rect_div(@index, 1, 4, 2)
      end

      # Disable the tile
      def disable
        set_rect_div(@index, 0, 4, 2)
      end
    end

    # Board tile in VoltorbFlip game
    class BoardTile < SpriteStack
      # @return [Integer, :voltorb] Content of the tile
      attr_reader :content

      # Create a new BoardTile
      # @param viewport [Viewport]
      def initialize(viewport)
        super(viewport, default_cache: :interface)
        @tile_back = push(14, 14, 'voltorbflip/tiles')
        @tile_back.ox = 14
        @tile_back.oy = 14
        @tile_back.set_rect_div(0, 0, 5, 1)

        @tile_front = push(14, 14, 'voltorbflip/tiles')
        @tile_front.ox = 14
        @tile_front.oy = 14
        @tile_front.set_rect_div(0, 0, 5, 1)
        @tile_front.visible = false

        @markers = Array.new(4) do |i|
          s = push(-3, -3, 'voltorbflip/markers')
          s.set_rect_div(2 + i, 0, 6, 1)
          s.visible = false
          next(s)
        end
      end

      # Detect if the mouse is in the tile
      # @param mx [Integer] X coordinate of the mouse
      # @param my [Integer] Y coordinate of the mouse
      # @return [Boolean]
      def simple_mouse_in?(mx, my)
        return @tile_back.simple_mouse_in?(mx + @tile_back.ox, my + @tile_back.oy)
      end

      # Set the content of the tile (affect the src_rect of the front tile)
      # @param value [Integer, :voltorb]
      def content=(value)
        @content = value
        @tile_front.set_rect_div(value == :voltorb ? 1 : value + 1, 0, 5, 1)
      end

      # Toggle a memo marker
      # @param index [Integer] index of the memo in the marker array
      def toggle_memo(index)
        @markers[index].visible = !@markers[index].visible
      end

      # Reveal the tile
      def reveal
        return unless @tile_back.visible
        @animation = :reveal
        @animation_counter = 0
        @tile_back.visible = true
        @tile_front.visible = false
        @markers.each { |m| m.visible = false }
      end

      # Tell if the tile was revealed
      # @return [Boolean]
      def revealed?
        return @tile_front.visible
      end

      # Hide the tile
      def hide
        return unless @tile_front.visible
        @animation = :hide
        @animation_counter = 0
        @tile_back.visible = false
        @tile_front.visible = true
        @markers.each { |m| m.visible = false }
      end

      # Tell if the tile is hidden
      def hiden?
        return @tile_back.visible
      end

      # Update the animation of the tile
      # @return [Boolean] if the animation will still run
      def update_animation
        case @animation
        when :reveal
          return update_reveal_animation
        when :hide
          return update_hide_animation
        end
        return false
      end

      # Update the reveal animation
      # @return [Boolean] if the animation will still run
      def update_reveal_animation
        case @animation_counter
        when 0, 1, 2, 3, 4, 5, 6, 7
          @tile_back.zoom_x -= 1 / 8.0 # 0.25
        when 8
          @tile_back.visible = false
          @tile_back.zoom_x = 1
          @tile_front.visible = true
          @tile_front.zoom_x = 0
        when 9, 10, 11, 12, 13, 14, 15
          @tile_front.zoom_x += 1 / 8.0
        when 16
          @tile_front.zoom_x = 1
          @animation_counter = 0
          @animation = nil
          return self
        end
        @animation_counter += 1
        return !@animation.nil?
      end

      # Update the hide animation
      # @return [Boolean] if the animation will still run
      def update_hide_animation
        case @animation_counter
        when 0, 1, 2, 3, 4, 5, 6, 7
          @tile_front.zoom_x -= 1 / 8.0 # 0.25
        when 8
          @tile_front.visible = false
          @tile_front.zoom_x = 1
          @tile_back.visible = true
          @tile_back.zoom_x = 0
        when 9, 10, 11, 12, 13, 14, 15
          @tile_back.zoom_x += 1 / 8.0
        when 16
          @tile_back.zoom_x = 1
          @animation_counter = 0
          @animation = nil
          return self
        end
        @animation_counter += 1
        return !@animation.nil?
      end
    end

    # Board counter sprite
    class BoardCounter < SpriteStack
      # Create a new board counter
      # @param viewport [Viewport]
      # @param index [Integer] index of the counter
      # @param column [Boolean] if it's a counter in the column or in the row
      def initialize(viewport, index, column)
        super(viewport, default_cache: :interface)
        # @type [Array<BoardTile>]
        @tiles = []
        if column
          cx = GamePlay::Casino::VoltorbFlip::ColumnCoinDispX + index * GamePlay::Casino::VoltorbFlip::TileOffset
          cy = GamePlay::Casino::VoltorbFlip::ColumnCoinDispY
        else
          cx = GamePlay::Casino::VoltorbFlip::RowCoinDispX
          cy = GamePlay::Casino::VoltorbFlip::RowCoinDispY + index * GamePlay::Casino::VoltorbFlip::TileOffset
        end
        @coin_counter1 = push(cx, cy, 'voltorbflip/numbers')
        @coin_counter2 = push(cx + 7, cy, 'voltorbflip/numbers')
        @voltorb_counter = push(cx + 7, cy + 13, 'voltorbflip/numbers')
        @coin_counter1.set_rect_div(0, 0, 10, 1)
        @coin_counter2.set_rect_div(0, 0, 10, 1)
        @voltorb_counter.set_rect_div(0, 0, 10, 1)
      end

      # Return the count of voltorb
      # @return [Integer]
      def voltorb_count
        return @counter[0]
      end

      # Add a tile
      # @param tile [BoardTile] the added tile
      def add_tile(tile)
        @tiles.push tile
      end

      # Update the counter display according to the tile values
      def update_display
        # Initialize
        counter = [0, 0]
        # Count each tile content [voltorb, point]
        @tiles.each do |tile|
          if tile.content == :voltorb
            counter[0] += 1
          else
            counter[1] += tile.content
          end
        end

        # Display the numbers
        @coin_counter1.set_rect_div(counter[1] / 10, 0, 10, 1)
        @coin_counter2.set_rect_div(counter[1] - (counter[1] / 10) * 10, 0, 10, 1)
        @voltorb_counter.set_rect_div(counter[0], 0, 10, 1)
        @counter = counter
      end
    end

    # Animations of the VoltorbFlip game
    class Animation < SpriteStack
      # Create a new animation
      # @param viewport [Viewport]
      def initialize(viewport)
        super(viewport)
        @animation = nil
        @sprite = push(0, 0, '')
      end

      # Animate a tile
      # @param tile [BoardTile]
      def animate(tile)
        if (@animation = tile.content) == :voltorb
          @sprite.set_bitmap('voltorbflip_explode', :animation)
          @sprite.set_rect_div(0, 0, 8, 1)
          @sprite.ox = 4
          @sprite.oy = 5
        else
          @sprite.set_bitmap('voltorbflip_number', :animation)
          @sprite.set_rect_div(0, 0, 4, 1)
          @sprite.ox = 1
          @sprite.oy = 2
        end
        @counter = 0
        @sprite.x = tile.x
        @sprite.y = tile.y
        @sprite.ox += @sprite.src_rect.width / 4
        @sprite.oy += @sprite.src_rect.height / 4
        @sprite.visible = true
      end

      # Update the animation
      # @return [Boolean] if the animation was updated
      def update_animation
        case @animation
        when :voltorb
          update_voltorb_animation
        when 1, 2, 3
          update_number_animation
        else
          return false
        end
        return true
      end

      private

      # Update the voltorb animation
      def update_voltorb_animation
        case @counter
        when 1
          $game_system.bgm_memorize
          $game_system.bgm_fade(0.5)
        when 12
          Audio.se_play('Audio/SE/voltorbflip/volt_boom', 120)
          @sprite.set_rect_div(@counter / 6, 0, 8, 1)
        when 6, 18, 24, 30, 36
          @sprite.set_rect_div(@counter / 6, 0, 8, 1)
        when 42
          @sprite.visible = false
          @animation = nil
        end
        @counter += 1
      end

      # Update the number animation
      def update_number_animation
        case @counter
        when 0
          Audio.se_play('Audio/SE/voltorbflip/volt_card_play', 120)
        when 6, 12, 18
          @sprite.set_rect_div(@counter / 6, 0, 4, 1)
        when 24
          @sprite.visible = false
          @animation = nil
        end
        @counter += 1
      end
    end
  end
end
