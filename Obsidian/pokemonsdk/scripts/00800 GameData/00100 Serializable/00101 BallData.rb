module GameData
  # Specific data of a Pokeball item
  # @author Nuri Yuri
  # @deprecated This class is deprecated in .25, please stop using it!
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
  end
end
