module GamePlay
  module Casino
    class VoltorbFlip < Base
      # Duration of the increment duration in frame
      # @return [Float]
      IncrementDuration = 20.0

      BoardDispX = 6
      BoardDispY = 42
      MemoDispX = 199
      MemoDispY = 44
      MemoTileDispOffX = 3
      MemoTileDispOffY = 2
      QuitDispX = 166
      QuitDispY = 202
      TileSize = 28
      TileOffset = 32
      MemoTileSize = 23

      ColumnCoinDispX = BoardDispX + MemoTileDispOffX + 9
      ColumnCoinDispY = BoardDispY + 5 * TileOffset + MemoTileDispOffY
      RowCoinDispX = BoardDispX + 5 * TileOffset + MemoTileDispOffX + 9
      RowCoinDispY = BoardDispY + MemoTileDispOffY

      CursorMoveDuration = 8.0

      # The amount of coin in the coin case
      # @return [Integer]
      attr_accessor :coin_case

      # Create the Voltorb Flip interface
      def initialize
        super()
        # Init attributes
        @coin_case = $game_variables[Yuki::Var::CoinCase]
        @coin_gain = 0
        @coin_case_increase = [0, 0] # [target, step]
        @coin_gain_increase = [0, 0] # [target, step]
        @state = 0
        @level = 1
        # Init graphics
        @viewport = Viewport.create(:main, @message_window.z - 100)
        @over_viewport = Viewport.create(:main, @message_window.z - 1)
        create_background
        create_texts
        create_board
        create_memo
        # Init logic
        generate_board
        # Cursor
        @cursor = UI::VoltorbFlip::Cursor.new(viewport)
        @black = Sprite.new(@over_viewport).set_bitmap('transparent_black', :interface)
      end

      # Create the background sprite
      def create_background
        @background = Sprite.new(@viewport).set_bitmap('voltorbflip/empty_board', :interface)
      end

      # Initialize the texts
      def create_texts
        @ui_texts = UI::VoltorbFlip::Texts.new(@viewport)
        @ui_texts.title = ext_text(9000, 123) # 'voltorbataille'
        update_coin
      end

      # create the game board
      def create_board
        @board_tiles = []
        @board_counters =
          Array.new(5) { |i| UI::VoltorbFlip::BoardCounter.new(@viewport, i, true) } +
          Array.new(5) { |i| UI::VoltorbFlip::BoardCounter.new(@viewport, i, false) }
        0.upto(4) do |bx|
          0.upto(4) do |by|
            rx = BoardDispX + 3 + bx * TileOffset
            ry = BoardDispY + 3 + by * TileOffset
            s = UI::VoltorbFlip::BoardTile.new(viewport)
            s.set_position(rx, ry)
            s.content = 1
            @board_tiles.push s
            @board_counters[5 + by].add_tile(s)
            @board_counters[bx].add_tile(s)
          end
        end

        @quit_button = Sprite.new(viewport).set_bitmap('voltorbflip/markers', :interface).set_rect_div(0, 0, 6, 1)
        @quit_button.set_position(QuitDispX, QuitDispY).opacity = 0

        @animation_sprite = UI::VoltorbFlip::Animation.new(@over_viewport)
      end

      # Create the memo content
      def create_memo
        @memo_sprites = []
        4.times do |index|
          s = UI::VoltorbFlip::MemoTile.new(@viewport, index)
          s.set_position(MemoDispX + MemoTileDispOffX, MemoDispY + MemoTileDispOffY + index * MemoTileSize)
          @memo_sprites[index] = s
        end
        @memo_disabler = Sprite.new(viewport).set_bitmap('voltorbflip/memo_button', :interface).set_rect_div(1, 0, 2, 1)
        @memo_disabler.set_position(MemoDispX + MemoTileDispOffX - 1, MemoDispY + MemoTileDispOffY + 4 * MemoTileSize)
      end

      # Update the scene
      def update
        return unless super
        return if update_tiles_animation # If one or more tiles are animated
        return if @cursor.update_move # If curseur is moving
        return if update_coin # Update coin incrementation
        return if update_state # Update win, fail state

        @no_animation = false
        update_input_dir
        update_input
      end

      # Update the game state
      def update_state
        return (@running = false) if @state == 999

        case (@state / 100)
        when 0 # Menu
          return update_state_menu
        when 1 # Play
          return update_state_play
        when 2
          return update_state_win
        when 3
          return update_state_fail
        when 4
          return update_suspens
        end
        return false
      end

      def update_state_menu
        case @state
        when 0 # Intro
          @black.visible = true
          @player_choice = display_message(ext_text(9000, 124)) # 'Bienvenue au Voltbataille')
          @state += 1
        when 1 # New Game invite
          @black.visible = true
          @player_choice = display_message(ext_text(9000, 125) % @level, 1, ext_text(9000, 126), ext_text(9000, 127), ext_text(9000, 128))
          # "Jouer à Voltorbataille niveau #{@level} ?", 1, 'Jouer', 'Infos', 'Partir')
          if @player_choice == 0
            @state += 1
          elsif @player_choice == 1
            @state = 10
          else
            @state = 999
          end
        when 2
          @no_animation = true
          @board_tiles.each(&:hide)
          @state += 1
        when 3 # Wait new game ready
          generate_board(@level)
          @black.visible = false
          @state = 100 # Play
        when 10 # Infos
          @player_choice = display_message(ext_text(9000, 129), 1, ext_text(9000, 130), ext_text(9000, 131), ext_text(9000, 132), ext_text(9000, 133))
          # "Que voulez-vous savoir ?", 1, 'Règles', 'Indices', 'Le mémo', 'Retour')
          if @player_choice == 0
            display_message(ext_text(9000, 134)) # "### A ECRIRE ###")
          elsif @player_choice == 1
            display_message(ext_text(9000, 135)) # "### A ECRIRE ###")
          elsif @player_choice == 2
            display_message(ext_text(9000, 136)) # "### A ECRIRE ###")
          else
            @state = 1
          end
        end
        return true
      end

      def update_state_play
        case @state
        when 100 # Play loop
          # Check if win
          if get_board_points(true) == get_board_points
            on_win
            return true
          end
        when 110 # Quit or B button
          @player_choice = display_message(ext_text(9000, 137) % @coin_gain, 1, ext_text(9000, 95), ext_text(9000, 96))
          # "Choisir 'Quitter' maintenant vous permet d'empocher #{@coin_gain} jetons.\nQuitter maintenant ?", 1, 'Oui', 'Non')
          if @player_choice == 0
            display_message(ext_text(9000, 138) % @coin_gain) # "Vous empochez #{@coin_gain} jetons !")
            @coin_case_increase = get_increment(@coin_case, @coin_case + @coin_gain)
            @state += 1
          else
            @state = 100
          end
        when 111
          @no_animation = true
          @board_tiles.each(&:reveal)
          @state += 1
          return true
        when 112
          @last_level = @level
          @level = 1
          if @last_level > @level
            display_message(ext_text(9000, 139) % @level) # "Le jeu est descendu au niveau #{@level}.")
          end
          @state = 1
        end
        return false
      end

      def update_state_win
        case @state
        when 200 # WIN
          Audio.se_play('Audio/SE/voltorbflip/volt_extra_pay')
          display_message(ext_text(9000, 140)) # "Gagné !")
          display_message(ext_text(9000, 141)) # "Toutes les cartes de 2 et ou 3 points ont été retournées...")
          display_message(ext_text(9000, 142) % @coin_gain) # "Vous gagnez #{@coin_gain} jetons !")
          @state += 1
        when 201 # Increase score
          @coin_case_increase = get_increment(@coin_case, @coin_case + @coin_gain)
          @state += 1
        when 202 # Win reset gain
          @coin_gain_increase = get_increment(@coin_gain, 0)
          @state += 1
        when 203
          @no_animation = true
          @board_tiles.each(&:reveal)
          @coin_gain = 0 # Prevent negatif numbers
          @state += 1
        when 204
          @last_level = @level
          @level = [@level + 1, 5].min
          if @last_level < @level
            display_message(ext_text(9000, 143) % @level) # "Le jeu est monté niveau #{@level}, les gains sont plus importants.")
          end
          @state = 1 # New Game invite
        end
        return true
      end

      def update_state_fail
        case @state
        when 300 # Fail : voltorb
          @counter = 0
          @state += 1
        when 301
          @state += 1 unless (@counter += 1) < 40
        when 302
          Audio.se_play('Audio/SE/voltorbflip/volt_fail', 120)
          @coin_gain_increase = get_increment(@coin_gain, 0)
          @state += 1
        when 303
          @last_level = @level
          @level = [@level, get_revealed_tile_count].min
          @coin_gain = 0
          @no_animation = true
          @board_tiles.each(&:reveal)
          @counter = 0
          @state += 1
        when 304
          @state += 1 unless (@counter += 1) < 120
        when 305
          display_message(ext_text(9000, 144)) # "Vous perdez tous les jetons de la manche...")
          if @last_level > @level
            display_message(ext_text(9000, 139) % @level) # "Le jeu est descendu au niveau #{@level}.")
          end
          $game_system.bgm_restore
          @state = 1
        end
        return true
      end

      def update_suspens
        case @state
        when 400 # Suspens
          $game_system.bgm_memorize
          $game_system.bgm_fade(0.5)
          @counter = 0
          @state += 1
        when 401
          @state += 1 unless (@counter += 1) < 20
        when 402
          Audio.se_play('Audio/se/voltorbflip/volt_suspense')
          @counter = 0
          @state += 1
        when 403
          @state += 1 unless (@counter += 1) < 200
        when 404
          index = (@cursor.board_x * 5 + @cursor.board_y)
          if reveal(index)
            @state = 100
          end
            $game_system.bgm_restore
        end
        return true
      end

      # Update coin values and texts. Return true if the value is incrementing and the update must stop
      # @return [Boolean]
      def update_coin
        # Update the display
        @ui_texts.coin_case = @coin_case
        @ui_texts.coin_gain = @coin_gain
        @ui_texts.level = @level
        # Increment
        if incrementing?
          @coin_case += @coin_case_increase[0]
          if @coin_case >= @coin_case_increase[1] && @coin_case_increase[0] > 0 ||
             @coin_case <= @coin_case_increase[1] && @coin_case_increase[0] < 0
            @coin_case_increase = [0, 0]
            @coin_case = @coin_case.to_i
          end
          @coin_gain += @coin_gain_increase[0]
          if @coin_gain >= @coin_gain_increase[1] && @coin_gain_increase[0] > 0 ||
             @coin_gain <= @coin_gain_increase[1] && @coin_gain_increase[0] < 0
            @coin_gain_increase = [0, 0]
            @coin_gain = @coin_gain.to_i
          end
          return true
        end
        return false
      end

      # Update the keyboard inpute
      def update_input
        process_mouse_click if Mouse.trigger?(:mouse_left)
        process_button_A if Input.trigger?(:A)
        on_quit_button if Input.trigger?(:B)
      end

      # Update the keyboard direction input
      def update_input_dir
        case Input.dir4
        when 2 then @cursor.move_on_board(0, 1)
        when 4 then @cursor.move_on_board(-1, 0)
        when 6 then @cursor.move_on_board(1, 0)
        when 8 then @cursor.move_on_board(0, -1)
        end
      end

      # Update the tiles animation
      # @return [Boolean]
      def update_tiles_animation
        result = false
        @board_tiles.each do |tile|
          temp = tile.update_animation
          result ||= temp # not called if result != nil
        end
        unless @no_animation
          result ||= @animation_sprite.update_animation
          @animation_sprite.animate(result) if result.is_a?(UI::VoltorbFlip::BoardTile)
        end
        return (result == true)
      end

      # Update the cursor mode to normal or memo
      def update_cursor_mode
        @cursor.mode = @memo_sprites.select(&:enabled?).empty? ? :normal : :memo
      end

      # Process the A button
      def process_button_A
        if @cursor.board_x == 5 && @cursor.board_y <= 4
          on_memo_activate
        elsif @cursor.board_y == 5
          on_quit_button
        else
          on_board_activate
        end
      end

      # Process the click on the screen
      def process_mouse_click
        mx = Mouse.x
        my = Mouse.y
        # Memos
        @memo_sprites.each_with_index do |memo, index|
          next unless memo.simple_mouse_in?(mx, my)

          @cursor.moveto(5, index)
          on_memo_activate(index)
          break
        end
        # Memo disabling
        if @memo_disabler.simple_mouse_in?(mx, my)
          @cursor.moveto(5, 4)
          on_memo_activate(4)
        end
        # Quit button
        if @quit_button.simple_mouse_in?(mx, my)
          @cursor.moveto(5, 5)
          on_quit_button
        end
        # Board
        @board_tiles.each_with_index do |tile, index|
          next unless tile.simple_mouse_in?(mx, my)

          x = (index / 5)
          y = index - 5 * x
          @cursor.moveto(x, y)
          on_board_activate(index)
        end
      end

      # Called when the memo is activated
      # @param y [Integer, @cursor.board_y] the row in the memo
      def on_memo_activate(y = @cursor.board_y)
        @memo_sprites.each_with_index do |memo, index|
          if index == y
            memo.enable
            @memo_disabler.set_rect_div(0, 0, 2, 1)
          else
            memo.disable
          end
        end
        @memo_disabler.set_rect_div(1, 0, 2, 1) if y == 4
        update_cursor_mode
      end

      # Called when the quit button is activated
      def on_quit_button
        @state = 110
      end

      # Called when the board is activated.
      # @param index [Integer, nil] the index of the activate tile (by default the one under the cursor).
      def on_board_activate(index = nil)
        index ||= (@cursor.board_x * 5 + @cursor.board_y)
        # Nothing to do with an revealed tile
        return if @board_tiles[index].revealed?

        # Normal mode : reveal the tile
        if @cursor.mode == :normal
          x = (index / 5)
          y = index - 5 * x
          h_counter = @board_counters[x]
          v_counter = @board_counters[5 + y]
          if h_counter.voltorb_count + v_counter.voltorb_count >= 5
            @state = 400 # Suspens
          else
            reveal(index)
          end
        else # Memo mode
          memo_index = @memo_sprites.index(@memo_sprites.select(&:enabled?).first)
          @board_tiles[index].toggle_memo(memo_index)
        end
      end

      def reveal(index)
        @board_tiles[index].reveal
        # Display the coin gain / loose
        if @board_tiles[index].content.is_a?(Integer)
          @coin_gain = 1 if @coin_gain == 0
          old_coin_gain = n_coin_gain = @coin_gain
          n_coin_gain *= @board_tiles[index].content
          @coin_gain_increase = get_increment(old_coin_gain, n_coin_gain) if old_coin_gain != n_coin_gain
          return true
        else
          on_fail
          return false
        end
      end

      def on_fail
        @state = 300
      end

      def on_win
        @state = 200
      end

      # Generate the board with the matching level
      # @param level [Integer, 1] the level of the board to generate
      def generate_board(level = 1)
        # Initialize
        point_count = 24 # Between 24 and 26 points distributed on the board, 26 if last distribution is a 3
        voltorb_count = 5 + 2 * level # The number of voltorb in the board
        chance_3 = [0, 50, 60, 60, 70, 70][level] # More 3 tile = less points in the board (prevent 4500 point boards)
        data = Table.new 5, 5 # The table
        available_coords = [] # The table coords
        point_coords = [] # The coords of the tile containing points
        5.times do |x|
          5.times do |y|
            available_coords.push [x, y]
          end
        end
        available_coords.shuffle!
        # Place the voltorbs and the first point
        available_coords.each do |coords|
          # No more than 4 voltorbs in a row / column
          v_row = 0
          v_col = 0
          5.times do |y|
            v_row += 1 if data[coords[0], y] < 0
          end
          5.times do |x|
            v_col += 1 if data[x, coords[1]] < 0
          end
          # Place a voltorb if possible, else place a point
          if v_row < 4 && v_col < 4 && voltorb_count > 0
            data[coords[0], coords[1]] = -1
            voltorb_count -= 1
          else
            data[coords[0], coords[1]] = 1
            point_count -= 1
            point_coords.push coords
          end
        end
        # Distribute the remaining points considering the 3 tile chances
        while point_count > 0
          # Select a tile
          c = point_coords.select do |a|
            if data[a[0], a[1]] == 2 # Will be 3
              next rand(100) < chance_3
            else
              next true
              end
          end.first
          # Add a point
          data[c[0], c[1]] += 1
          point_coords.delete(c) if data[c[0], c[1]] >= 3
          point_count -= 1
        end

        # data = Table.new(5, 5)
        # data[0, 0] = 3
        # data[1, 0] = 3
        # data[2, 0] = -1

        # Setup the tiles
        5.times do |x|
          5.times do |y|
            @board_tiles[x * 5 + y].content = (data[x, y] > 0 ? data[x, y] : :voltorb)
          end
        end
        # Update the counters
        @board_counters.each(&:update_display)
      end

      # Calculate the current point of the game
      # @param with_hided [Boolean, false] indicate if the hided tiles must be count too
      # @return [Integer]
      def get_board_points(with_hided = false)
        points = 0 # Prevent to display 1 point even if there is no revealed tiles
        5.times do |x|
          5.times do |y|
            tile = @board_tiles[x * 5 + y]
            if tile.content.is_a?(Integer) && (with_hided || tile.revealed?)
              points = 1 if points.zero?
              points *= tile.content
            end
          end
        end
        return points
      end

      def get_revealed_tile_count
        return @board_tiles.select(&:revealed?).length
      end

      # Test if the coins are incrementing
      # @return [Boolean]
      def incrementing?
        return !(@coin_case_increase[0].zero? && @coin_gain_increase[0].zero?)
      end

      # Calculate the increment value [step, target]
      # @return [Array<Float, Integer>]
      def get_increment(from, to)
        return [(to - from) / IncrementDuration, to]
      end

      def create_graphics
        # Skipped to prevent glitches
      end
    end
  end
end
