module PFM
  class MiningGame
    # Class handling the grid for the mining game
    class GridHandler
      # Constant telling the minimum amount of item possible on a grid
      MIN_ITEM_COUNT = 2
      # Constant telling the maximum amount of item possible on a grid
      MAX_ITEM_COUNT = 5
      # Get the grid width
      # @return [Integer]
      attr_reader :width
      # Get the grid height
      # @return [Integer]
      attr_reader :height
      # Get the tile states
      # @return [Array<Array<Integer>>]
      attr_reader :arr_tiles_state
      # Get the list of diggable items
      # @return [Array<Diggable>]
      attr_reader :arr_items
      # Get the list of irons
      # @return [Array<Diggable>]
      attr_reader :arr_irons
      # Create a new grid handler
      # @param wanted_items [Array<Symbol>, nil] list of wanted items
      # @param item_count [Integer, nil] maximum number of items
      # @param grid_width [Integer] width of the grid
      # @param grid_height [Integer] height of the grid
      def initialize(wanted_items, item_count, grid_width, grid_height)
        @item_count = (item_count || wanted_items&.size || rand(MIN_ITEM_COUNT..MAX_ITEM_COUNT)).clamp(MIN_ITEM_COUNT, MAX_ITEM_COUNT)
        @wanted_items = (map_symbol2hash(wanted_items) || randomize_items(@item_count)).take(@item_count)
        @width = grid_width
        @height = grid_height
        @nb_irons = rand(4..7)
        # @type [Array<Diggable>]
        @arr_irons = []
        @ready = false
        # We create all the grids
        @arr_tiles_state = Array.new(@height) { Array.new(@width, 0) }
        @mgt = Random::MINING_GAME_TILES
        initialize_grid_content
      end

      # Tell if the mining game grid is ready
      # @return [Boolean]
      def ready?
        return @ready
      end

      # Check if a diggable is present at the said coordinate and return it if it's an item
      # @param x [Integer] x coordinate where we went to find the diggable
      # @param y [Integer] y coordinate where we went to find the diggable
      # @return [Diggable, Boolean] Diggable instance if item, true if iron, false if nothing
      def check_presence_of_diggable(x, y)
        diggable = @arr_items.find { |item| (item.x...item.x + item.width).cover?(x) && (item.y...item.y + item.height).cover?(y) }
        if diggable
          return diggable if diggable.pattern[y - diggable.y][x - diggable.x]
        end
        diggable = @arr_irons.find { |item| (item.x...item.x + item.width).cover?(x) && (item.y...item.y + item.height).cover?(y) }
        if diggable
          return true if diggable.pattern[y - diggable.y][x - diggable.x]
        end

        return false
      end

      private

      # Generate a random array of items to dig
      # @param nb_items [Integer] number of items to generate
      # @return [Array<Hash>]
      def randomize_items(nb_items)
        arr = []
        data = GameData::MiningGame::DATA_ITEM
        rng_item = Random::MINING_GAME_ITEM
        chance_range = 0..GameData::MiningGame.total_chance

        until arr.size == nb_items
          nb = rng_item.rand(chance_range)
          count = 0
          data.each do |key, item|
            count += item[:probability]
            next unless nb < count

            unless key == :heart_scale
              break if arr.index { |i| i[:symbol] == key } # No duplicate of item
            end

            break arr.push(**item, symbol: key) # We add the symbol to the item data
          end
        end
        return arr
      end

      # Initialize the grid content using a thread to profit of Graphics.update on slow computer
      def initialize_grid_content
        @ready = false
        Thread.new do
          t = Time.new
          launch_tile_state_procedure
          launch_item_placement_procedure
          launch_iron_placement_procedure
          log_debug("Generation took #{Time.new - t} seconds")
          @ready = true
        end
      end

      # Function that places the hiding tiles on the grid
      def launch_tile_state_procedure
        @rand_tile_state = ($pokemon_party.mining_game.hard_mode ? 6 : 2)
        until all_tile_placed?
          @probability = 100
          @rand_tile_state -= 1
          case $pokemon_party.mining_game.hard_mode
          when true
            @rand_tile_state = 6 if @rand_tile_state == 2
          when false
            @rand_tile_state = 6 if @rand_tile_state == 1
            @rand_tile_state = 2 if @rand_tile_state == 3
          end
          @rand_tile_state = 4 if @rand_tile_state == 5
          arr = first_tile
          @arr_tiles_state[arr[0][0]][arr[0][1]] = @rand_tile_state
          arr = update_tiles_state(arr) until arr.empty?
        end
      end

      # Tell if all tiles are placed
      # @return [Boolean]
      def all_tile_placed?
        return @arr_tiles_state.all? { |array| array.none?(0) }
      end

      # Get the first unplaced tile
      # @return [Array<Array(Integer, Integer)>]
      def first_tile
        arr = nil
        until arr
          tile = @arr_tiles_state[a = @mgt.rand(@height)][b = @mgt.rand(@width)]
          arr = [[a, b]] if tile == 0
        end
        return arr
      end

      # Function that update the state of all the adjacent tiles from arr tiles
      def update_tiles_state(arr)
        arr = get_any_adjacent_tile(arr)
        set_state_in_array(arr, @rand_tile_state)
        return arr
      end

      # Function that gives all the possible adjacent tiles and update probabilities
      def get_any_adjacent_tile(arr)
        new_arr = []
        arr.each do |(y, x)|
          add_north_tile(new_arr, y, x)
          add_south_tile(new_arr, y, x)
          add_west_tile(new_arr, y, x)
          add_east_tile(new_arr, y, x)
        end
        @probability -= 33 unless @probability < 33
        @probability = 5 if @probability < 5
        return new_arr
      end

      # Function that add the north tile to new_arr if possible
      # @param new_arr [Array]
      # @param y [Integer]
      # @param x [Integer]
      def add_north_tile(new_arr, y, x)
        y -= 1
        new_arr << [y, x] if y > -1 && @arr_tiles_state[y][x] == 0 && !new_arr.include?([y, x]) && @mgt.rand(0..100) < @probability
      end

      # Function that add the south tile to new_arr if possible
      # @param new_arr [Array]
      # @param y [Integer]
      # @param x [Integer]
      def add_south_tile(new_arr, y, x)
        y += 1
        new_arr << [y, x] if y < @height && @arr_tiles_state[y][x] == 0 && !new_arr.include?([y, x]) && @mgt.rand(0..100) < @probability
      end

      # Function that west the south tile to new_arr if possible
      # @param new_arr [Array]
      # @param y [Integer]
      # @param x [Integer]
      def add_west_tile(new_arr, y, x)
        x -= 1
        new_arr << [y, x] if x > -1 && @arr_tiles_state[y][x] == 0 && !new_arr.include?([y, x]) && @mgt.rand(0..100) < @probability
      end

      # Function that west the south tile to new_arr if possible
      # @param new_arr [Array]
      # @param y [Integer]
      # @param x [Integer]
      def add_east_tile(new_arr, y, x)
        x += 1
        new_arr << [y, x] if x < @width && @arr_tiles_state[y][x] == 0 && !new_arr.include?([y, x]) && @mgt.rand(0..100) < @probability
      end

      # Function that sets the state to all tiles contained in arr
      # @param arr [Array<Array(Integer, Integer)>] array of tile coordinate
      # @param state [Integer]
      def set_state_in_array(arr, state)
        arr.each do |(y, x)|
          @arr_tiles_state[y][x] = state
        end
      end

      # Function that place all the items on the grid
      def launch_item_placement_procedure
        @arr_items = create_diggables(@wanted_items)
        place_diggable(@arr_items)
      end

      # Function that create all the digable objects
      # @param items [Array<Hash>]
      # @return [Array<Diggable>]
      def create_diggables(items)
        return items.map { |hash| Diggable.new(hash) }
      end

      # Function that maps an Array of Symbol to Hashes in order to make sure they're mappable to diggable
      # @param arr [Array<Symbol>]
      # @return [Array<Hash>]
      def map_symbol2hash(arr)
        return nil unless arr

        data = GameData::MiningGame::DATA_ITEM
        arr = arr.map { |sym| sym.is_a?(Symbol) ? sym : GameData::Item.db_symbol(sym) }
        arr.select! { |item| data.keys.include? item }
        arr = arr.map do |sym|
          next { **data[sym], symbol: sym }
        end
        return nil if arr.empty?

        return arr
      rescue TypeError
        raise "Invalid Mining Game Item in #{arr}"
      end

      # Function that place the diggable on the map
      # @param array [Array<Diggable>]
      def place_diggable(array)
        attempt = 0
        array.each do |diggable|
          diggable.set_new_rotation
          diggable.x, diggable.y = attempt <= 20 ? random_diggable_position : alternate_random_diggable_position
          if check_diggable_well_placed(diggable)
            diggable.placed = true
            attempt = 0
          else
            attempt += 1
            redo unless attempt >= 200
            break
          end
        end
      end

      # Function that generates a random position for a diggable
      # @return [Array(Integer, Integer)]
      def random_diggable_position
        return rand(@width), rand(@height)
      end

      # Function that generates a random position using a quarter of the screen for the diggable
      # @return [Array(Integer, Integer)]
      def alternate_random_diggable_position
        @possible_rand ||= [[0...(@width / 2), 0...(@height / 2)], [0...(@width / 2), (@height / 2)...@height],
                            [(@width / 2)...@width, 0...(@height / 2)], [(@width / 2)...@width, (@height / 2)...@height]]
        sample = @possible_rand.sample
        return rand(sample[0]), rand(sample[1])
      end

      # Function that check if a diggable is well placed
      # @param diggable [Diggable]
      # @return [Boolean]
      def check_diggable_well_placed(diggable)
        return false if (diggable.x + diggable.width - 1) >= @width
        return false if (diggable.y + diggable.height - 1) >= @height

        return @arr_items.none? { |item| item.overlap?(diggable) } && @arr_irons.none? { |iron| iron.overlap?(diggable) }
      end

      # Function that place all the irons on the grid
      def launch_iron_placement_procedure
        @arr_irons = create_diggables(randomize_irons)
        place_diggable(@arr_irons)
      end

      def randomize_irons
        arr = []
        data = GameData::MiningGame::DATA_IRON
        rng_iron = Random::MINING_GAME_OBSTACLES
        change_range = 0..GameData::MiningGame.total_chance

        until arr.size == @nb_irons
          nb = rng_iron.rand(change_range)
          count = 0
          data.each do |key, iron|
            count += iron[:probability]
            next unless nb < count

            break arr.push(**iron, symbol: key)
          end
        end
        return arr
      end
    end

    class Diggable
      attr_accessor :x
      attr_accessor :y
      attr_accessor :width
      attr_accessor :height
      attr_accessor :symbol
      attr_accessor :origin_pattern
      # @return [Array<Array<Boolean>>]
      attr_accessor :pattern
      attr_accessor :accepted_rotation
      attr_accessor :rotation
      attr_accessor :is_an_item
      attr_accessor :placed
      attr_accessor :revealed

      def initialize(hash)
        @x = @y = 0
        @symbol = hash[:symbol]
        @origin_pattern = @pattern = hash[:layout].map(&:clone)
        @accepted_rotation = hash[:accepted_max_rotation]
        @rotation = 0
        set_new_rotation
        @is_an_item = GameData::MiningGame::DATA_ITEM.keys.include?(@symbol)
        @placed = @revealed = false
      end

      def set_new_rotation
        @rotation = @accepted_rotation != 0 ? rand(0..@accepted_rotation) : 0
        rotate_object
        set_width_and_length
      end

      # Test if another diggable is overlapping this diggable
      # @param diggable [Diggable]
      # @return [Boolean]
      def overlap?(diggable)
        return false if self == diggable || !@placed
        return true if range_overlapping?(@x..(@x + @width - 1), (diggable.x..diggable.x + diggable.width)) &&
                       range_overlapping?(@y..(@y + @height - 1), (diggable.y..diggable.y + diggable.height))
      end

      private

      def rotate_object
        arr = @origin_pattern
        @rotation.times { arr = arr.transpose.each(&:reverse!) }
        @pattern = arr
      end

      def set_width_and_length
        @width = @pattern[0].size
        @height = @pattern.size
      end

      def range_overlapping?(range1, range2)
        return true if range1.begin <= range2.end && range2.begin <= range1.end

        return false
      end
    end
  end
end
