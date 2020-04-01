module Pathfinding
  # Module that describe the pathfinding targets.
  # There is different type of targets :
  # - Coords : reach a specific point in the map
  #         find_path to:[x, y, [,z]] [, radius: Integer]
  # - Character : reach a game character object in the map
  #         find_path to:get_character(Integer)[, radius: Integer]
  # - Charcater_Reject : flee the given charcater :
  #         find_path to:get_character(Integer), type: :Character_Reject[, radius: Integer]
  # - Border : reach the border of the map (:north, :south, :east, :west)
  #         find_path to: Symbol, type: :Border[, radius: Integer]
  # Each target can be tested by the reached? method
  module Target
    # Convert the raw data to a target object
    # @param data [Array] data to convert
    # @return [Object]
    def self.get(type, *data)
      return const_defined?(type) ? const_get(type).new(*data) : nil 
    end

    # Convert the saved data to a target object with
    # @param data [Array] data to convert, must be create by the target object
    # @return [Object]
    def self.load(data)
      type = data.shift
      return const_defined?(type) ? const_get(type).load(data) : nil
    end

    class Coords
      def initialize(*args)
        coords = args[0]
        @x = coords[0] + Yuki::MapLinker.get_OffsetX
        @y = coords[1] + Yuki::MapLinker.get_OffsetY
        @z = coords[2]
        @radius = args[1]
        @original_x = coords[0]
        @original_y = coords[1] # Prevent bug from MapLinker Enable/Disable
      end

      # Test if the target is reached at the fiveng coords
      # @param x [Integer] the x coordinate to test
      # @param y [Integer] the y coordinate to test
      # @param z [Integer] the x coordinate to test
      # @return [Boolean]
      def reached?(x, y, z)
        return ((@x - x).abs + (@y - y).abs) <= @radius
      end

      # Check if the character targetted has moved, considering the distance for optimisation and return true if the target is considered as moved
      # @param x [Integer] the x coordinate of the heading event
      # @param y [Integer] the y coordinate of the heading event
      # @return [Boolean]
      def check_move(x, y)
        false
      end

      # Gather the savable data
      # @return [Array<Object>]
      def save
        return [:Coords, [@original_x, @original_y, @z], @radius]
      end

      # Create new target from the given data
      # @param data [Array] saved data
      def self.load(data)
        return Coords.new(*data)
      end
    end

    class Character
      def initialize(*args)
        @character = args[0]
        @radius = args[1]
        @sx = @character.x
        @sy = @character.y
      end
      
      # Test if the target is reached at the fiveng coords
      # @param x [Integer] the x coordinate to test
      # @param y [Integer] the y coordinate to test
      # @param z [Integer] the x coordinate to test
      # @return [Boolean]
      def reached?(x, y, z)
        return ((@character.x - x).abs + (@character.y - y).abs) <= @radius
      end

      # Check if the character targetted has moved, considering the distance for optimisation and return true if the target is considered as moved
      # @param x [Integer] the x coordinate of the heading event
      # @param y [Integer] the y coordinate of the heading event
      # @return [Boolean]
      def check_move(x, y)
        if ((c = @character).x - x).abs + (c.y - y).abs > 15
          if (@sx - c.x).abs + (@sy - c.y).abs > 10
            @sx = c.x
            @sy = c.y
            return true
          end
          return false
        end
        return @sx != (@sx = c.x) || @sy != (@sy = c.y)
      end

      # Gather the savable data
      # @return [Array<Object>]
      def save
        return [:Character, @character.id, @radius]
      end

      # Create new target from the given data
      # @param data [Array] saved data
      def self.load(data)
        data[0] = (data[0] == 0 ? $game_player : $game_map.events[data[0]])
        return Character.new(*data)
      end
    end

    class Character_Reject
      def initialize(*args)
        @character = args[0]
        @radius = args[1]
        @sx = @character.x
        @sy = @character.y
      end

      # Test if the target is reached at the given coords
      # @param x [Integer] the x coordinate to test
      # @param y [Integer] the y coordinate to test
      # @param z [Integer] the x coordinate to test
      # @return [Boolean]
      def reached?(x, y, z)
        return ((@character.x - x).abs + (@character.y - y).abs) > @radius
      end

      # Check if the character targetted has moved, considering the distance for optimisation and return true if the target is considered as moved
      # @param x [Integer] the x coordinate of the heading event
      # @param y [Integer] the y coordinate of the heading event
      # @return [Boolean]
      def check_move(x, y)
        if ((c = @character).x - x).abs + (c.y - y).abs > 15
          if (@sx - c.x).abs + (@sy - c.y).abs > 10
            @sx = c.x
            @sy = c.y
            return true
          end
          return false
        end
        return @sx != (@sx = c.x) || @sy != (@sy = c.y)
      end

      # Gather the savable data
      # @return [Array<Object>]
      def save
        return [:Character_Reject, @character.id, @radius]
      end

      # Create new target from the given data
      # @param data [Array] saved data
      def self.load(data)
        data[0] = (data[0] == 0 ? $game_player : $game_map.events[data[0]])
        return Character_Reject.new(*data)
      end
    end

    class Border
      def initialize(*args)
        @border = args[0]
        @radius = args[1]
        case @border
        when :north
          @value = @radius + Yuki::MapLinker.get_OffsetY
        when :west
          @value = @radius + Yuki::MapLinker.get_OffsetX
        when :south
          @value = $game_map.height - @radius - 1 - Yuki::MapLinker.get_OffsetY
        when :east
          @value = $game_map.width - @radius - 1 - Yuki::MapLinker.get_OffsetX
        end
      end

      # Test if the target is reached at the given coords
      # @param x [Integer] the x coordinate to test
      # @param y [Integer] the y coordinate to test
      # @param z [Integer] the x coordinate to test
      # @return [Boolean]
      def reached?(x, y, z)
        case @border
        when :north
          return y <= @value
        when :south
          return y >= @value
        when :east
          return x >= @value
        when :west
          return x <= @value
        end
        return true # Error
      end

      # Check if the character targetted has moved, considering the distance for optimisation and return true if the target is considered as moved
      # @param x [Integer] the x coordinate of the heading event
      # @param y [Integer] the y coordinate of the heading event
      # @return [Boolean]
      def check_move(x, y)
        return false
      end

      # Gather the savable data
      # @return [Array<Object>]
      def save
        return [:Border, @border, @radius]
      end

      # Create new target from the given data
      # @param data [Array] saved data
      def self.load(data)
        return Border.new(*data)
      end
    end
  end
end
