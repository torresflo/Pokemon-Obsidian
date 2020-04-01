module GameData
  # Map Zone Data structure
  # @author Nuri Yuri
  class Zone < Base
    # ID or list of MAP ID the zone is related to. (RMXP MAP ID !)
    # @return [Integer, Array<Integer>]
    attr_accessor :map_id
    # ID of the worldmap to display when in this zone
    # @return [Integer]
    attr_accessor :worldmap_id
    # Number at the end of the Panel file (Graphics/Windowskins/Panel_{panel_id})
    # @return [Integer] if 0 no pannel is shown
    attr_accessor :panel_id
    # X position of the Warp when using Dig, Teleport or Fly
    # @return [Integer, nil] nil if no warp
    attr_accessor :warp_x
    # Y position of the Warp when using Dig, Teleport or Fly
    # @return [Integer, nil] nil if no warp
    attr_accessor :warp_y
    # X position of the player on the World Map
    # @return [Integer, nil]
    attr_accessor :pos_x
    # Y position of the player on the World Map
    # @return [Integer, nil]
    attr_accessor :pos_y
    # If the player can use fly in this zone (otherwise he can use Dig)
    # @return [Boolean]
    attr_accessor :fly_allowed
    # If its not allowed to use fly, dig or teleport in this zone
    # @return [Boolean]
    attr_accessor :warp_dissalowed
    # Unused
    # @return [Array, nil]
    attr_accessor :sub_map
    # ID of the weather in the zone
    # @return [Integer, nil]
    attr_accessor :forced_weather
    # Unused
    # @return [String, nil]
    attr_accessor :description
    # See PFM::Wild_Battle#load_groups
    # @return [Array, nil]
    attr_accessor :groups
    # Create a new GameData::Map object
    # @param map_id [Integer] future value of the attribute
    # @param panel_id [Integer] future value of the attribute
    # @param warp_x [Integer, nil] future value of the attribute
    # @param warp_y [Integer, nil] future value of the attribute
    # @param pos_x [Integer, nil] future value of the attribute
    # @param pos_y [Integer, nil] future value of the attribute
    # @param sub_map [Array, nil] future value of the attribute
    # @param fly_allowed [Boolean] future value of the attribute
    # @param warp_dissalowed [Boolean] future value of the attribute
    # @param forced_weather [Integer] future value of the attribute
    # @param description [String, nil] future value of the attribute
    # @param worldmap_id [Integer, 0] future value of the attribute
    def initialize(map_id, panel_id=0, description=nil, warp_x=nil, warp_y=nil, sub_map=nil, pos_x=nil, pos_y=nil, fly_allowed=true, warp_dissalowed=false,forced_weather=nil, worldmap_id = 0)
      @map_id = map_id
      @worldmap_id = worldmap_id
      @panel_id = panel_id
      @warp_x = warp_x
      @warp_y = warp_y
      @pos_x = pos_x
      @pos_y = pos_y
      @sub_map = sub_map
      @fly_allowed = fly_allowed
      @warp_dissalowed = warp_dissalowed
      @forced_weather = forced_weather
      @description = description
      @groups = []
    end

    # Return the real name of the map (multi-lang compatible)
    # @return [String]
    def map_name
      return @map_name if @map_name
      id = @id || 0
      text_get(10, id)
    end

    # Indicate if a map (by its id) is included in this zone
    # @return [Boolean]
    def map_included?(map_id)
      return @map_id == map_id if(@map_id.is_a?(Numeric))
      @map_id.include?(map_id)
    end

    # Correct name of the attribute
    def warp_disallowed
      @warp_dissalowed
    end

    class << self
      # All the zone
      @data = []
      # Load the data and check the version
      def load
        $game_data_map, game_data_zone = load_data('Data/PSDK/MapData.rxdata')
        # Convert from PSDK 24.27 to PSDK 24.28+
        game_data_zone.each do |zone|
          zone.worldmap_id ||= 0
        end
        @data = game_data_zone.freeze
      end

      # Retrieve all the defined zones
      # @return [Array<Zone>]
      def all
        return @data
      end

      # Return a zone according to its id
      # @param id [Integer]
      # @return [Zone]
      def get(id)
        return @data[id] if id_valid?(id)
        return @data.first
      end

      # Tell if the zone id is valid
      # @param id [Integer]
      # @return [Boolean]
      def id_valid?(id)
        return id.between?(0, @data.size - 1)
      end
    end
  end

  # Backward compatibility for data Loading
  class Map < Zone
  end
end
