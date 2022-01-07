module UI
  module MiningGame
    # Class that describes the SpriteStack containing all the Hit_Counter_Sprite
    class Hit_Counter_Stack < SpriteStack
      # X Coordinates of first and second Hit_Counter_Sprite
      COORD_X = [206, 182]
      # The X space between all Hit_Counter_Sprite (except first and second)
      SPACE_BETWEEN_CRACKS = 24
      # Y Coordinates of first and every other Hit_Counter_Sprite
      COORD_Y = [0, 2]
      # Max number of Cracks
      NUMBER_OF_CRACKS = 10
      # Max number of hits the wall can take
      MAX_NB_HIT = 61

      # @return [Integer] the current number of hit
      attr_accessor :nb_hit

      # Create the Hit_Counter_Stack
      # @param viewport [Viewport] the viewport of the scene
      def initialize(viewport)
        super(viewport, 0, 0)
        @nb_hit = 0
        NUMBER_OF_CRACKS.times { |i| add_sprite(get_x(i), get_y(i), nil, i == 0 ? :first : :not_first, type: Hit_Counter_Sprite) }
      end

      # Method that send the correct number of hits
      # @param reason [Symbol] the symbol of the tool used to hit
      def send_hit(reason)
        hit = send(reason)
        stack.each_with_index do |crack, index|
          next if crack.state == crack.number_of_image_y - 1
          break if hit == 0
          break if @nb_hit == MAX_NB_HIT

          until crack.state == crack.number_of_image_y - 1
            crack.change_state
            stack[index + 1]&.change_state if crack.state == crack.number_of_image_y - 1 && index != 0
            hit -= 1
            @nb_hit += 1
            break if hit == 0
            break if @nb_hit == MAX_NB_HIT
          end
        end
      end

      # Check if the current number of hits is equal the max amount of hit
      # @return [Boolean]
      def max_cracks?
        return @nb_hit == MAX_NB_HIT
      end

      private

      # Get the good X coordinates for setting the Hit_Counter_Sprite
      # @param i [Integer] the index of the Hit_Counter_Sprite
      # @return [Integer]
      def get_x(i)
        if i == 0
          return COORD_X[0]
        else
          return COORD_X[1] - SPACE_BETWEEN_CRACKS * (i - 1)
        end
      end

      # Get the good Y coordinates for setting the Hit_Counter_Sprite
      # @param i [Integer] the index of the Hit_Counter_Sprite
      # @return [Integer]
      def get_y(i)
        if i == 0
          return COORD_Y[0]
        else
          return COORD_Y[1]
        end
      end

      # Return the number of hit for the pickaxe
      # @return [Integer]
      def pickaxe
        return 1
      end

      # Return the number of hit for the mace
      # @return [Integer]
      def mace
        return 2
      end

      # Return the number of hit for the dynamite
      # @return [Integer]
      def dynamite
        return 8
      end
    end
  end
end
