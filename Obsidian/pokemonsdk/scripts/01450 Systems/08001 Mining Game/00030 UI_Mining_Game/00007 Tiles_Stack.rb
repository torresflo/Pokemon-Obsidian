module UI
  module MiningGame
    # Class that describes the Tiles_Stack object
    class Tiles_Stack < SpriteStack
      # @return [Array<UI::MiningGame::Tiles] the array containing all the Tiles sprite
      attr_accessor :tile_array
      # Create the Tiles_Stack
      # @param viewport [Viewport] the viewport of the scene
      # @param arr [Array<Array<Integer>>] the array containing the arrays containing the tiles (columns<lines<tiles state>>)
      def initialize(viewport, arr)
        super(viewport, initial_x, initial_y)
        @tile_array = Array.new(arr.size) { [] }
        arr.each_with_index do |line, y_index|
          line.each_with_index do |state, x_index|
            push(texture_length * x_index, texture_width * y_index, bitmap_filename, state, type: Tiles)
          end
        end
        stack.each_with_index { |tile, index| @tile_array[index / 16] << tile }
      end

      # Get the Tiles sprite at given coordinates
      # @param x [Integer]
      # @param y [Integer]
      # @return [UI::MiningGame::Tiles] the tile required
      def get_tile(x, y)
        return @tile_array[y][x]
      end

      # Get the Tiles sprite adjacent to the one at given coordinates
      # @param x [Integer]
      # @param y [Integer]
      # @return [Array<UI::MiningGame::Tiles>] the tiles required
      def get_adjacent_of(x, y)
        arr = []
        arr << get_tile(x - 1, y) unless x == 0
        arr << get_tile(x + 1, y) unless x == @tile_array[0].size - 1
        arr << get_tile(x, y - 1) unless y == 0
        arr << get_tile(x, y + 1) unless y == @tile_array.size - 1
        return arr
      end

      private

      # Return the initial x coordinate of Tiles_Stack
      # @return [Integer]
      def initial_x
        return 0
      end

      # Return the initial x coordinate of Tiles_Stack
      # @return [Integer]
      def initial_y
        return 32
      end

      # Return the texture length
      # @return [Integer]
      def texture_length
        return 16
      end

      # Return the texture width
      # @return [Integer]
      def texture_width
        return 16
      end

      # Return the filename of the image
      # @return [String]
      def bitmap_filename
        return 'mining_game/tiles'
      end
    end
  end
end
