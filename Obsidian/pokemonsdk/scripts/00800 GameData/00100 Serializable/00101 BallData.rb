module GameData
  # Specific data of a Pokeball item
  # @author Nuri Yuri
  class BallData < Base
    # Image name of the ball in Graphics/ball/
    # @return [String]
    attr_accessor :img
    # Catch rate of the ball
    # @return [Numeric]
    attr_accessor :catch_rate
    # Special catch informations
    # @return [Hash, nil]
    attr_accessor :special_catch
    # Color of the ball
    # @return [Color, nil]
    attr_accessor :color
    # Default ball image name
    DEFAULT_IMAGE = 'ball_1'
    class << self
      # Safely return the image name of the ball
      # @param id [Integer, Symbol] id of the ball item in the database
      # @return [String]
      def img(id)
        return DEFAULT_IMAGE unless (ball_data = Item.ball_data(id))
        return ball_data.img
      end

      # Safely return the catch rate of the ball
      # @param id [Integer, Symbol] id of the ball item in the database
      # @return [Numeric]
      def catch_rate(id)
        return 1 unless (ball_data = Item.ball_data(id))
        return ball_data.catch_rate
      end

      # Safely return the special catch informations of the ball
      # @param id [Integer] id of the ball item in the database
      # @return [Hash, nil]
      def special_catch(id)
        return nil unless (ball_data = Item.ball_data(id))
        return ball_data.special_catch
      end
    end
  end
end
