module GameData
  # Data structure of world maps
  # @author Leikt, Nuri Yuri
  class WorldMap < Base
    # World map name text id
    # @return [Integer]
    attr_accessor :name_id
    # Wolrd map name file id
    # @return [Integer, String, nil]
    attr_accessor :name_file_id
    # Filename of the image used to display the world map
    # @return [String]
    attr_reader :image
    # Informations on the map
    # @return [Table,Array<WorldMapObject>]
    attr_accessor :data
    # Get the name of the worldmap
    # @return [String]
    def name
      #                                 from Ruby Host                        from csv
      return (@name_file_id.nil? ? text_get(9, @name_id) : ext_text(@name_file_id, @name_id))
    end

    # Create a new GameData::WorldMap
    def initialize(img, name_id, name_file_id)
      @name_id = name_id
      @name_file_id = name_file_id
      self.image = img
    end

    # Modify the image of the zone and resize it
    # @param value [String] the filename
    def image=(value)
      @image = value

      bmp = RPG::Cache.interface(WorldMap.worldmap_image_filename(value))
      max_x = bmp.width / GamePlay::WorldMap::TileSize
      max_y = bmp.height / GamePlay::WorldMap::TileSize
      n_data = Table.new(max_x, max_y)

      if @data
        0.upto([n_data.xsize, @data.xsize].min) do |x|
          0.upto([n_data.ysize, @data.ysize].min) do |y|
            n_data[x, y] = @data[x, y]
          rescue StandardError
            n_data[x, y] = -1
          end
        end
      end
      @data = n_data
    end

    # Gather the zone list from data. REALLY CONSUMING
    # @return [Array<Integer>]
    def zone_list_from_data
      result = []
      0.upto(@data.xsize - 1) do |x|
        0.upto(@data.ysize - 1) do |y|
          next if @data[x, y] < 0

          result.push @data[x, y] unless result.include?(@data[x, y])
        end
      end
      return result
    end

    class << self
      # All the zone
      @data = []
      # Get the zones id of this worldmap
      # @param id [Integer] the worldmap id
      # @return [Array<Integer>]
      def zone_list(id)
        result = []
        GameData::Zone.all.each_with_index do |zone, index|
          result << index if zone.worldmap_id == id
        end
        return result
      end

      # Run the given block on each worldmap id
      # @param &block
      def each_id(&block)
        @data.each_index(&block)
      end

      # Return a WorldMap
      # @param id [Integer]
      # @return [WorldMap]
      def get(id)
        return @data[id] if id_valid?(id)
        return @data.first
      end

      # Give the appropriate filename for the worldmap image in Graphics/interface
      # @param filename [String]
      # @return [String]
      def worldmap_image_filename(filename)
        return filename if filename.start_with?('worldmap/worldmaps/')
        return "worldmap/worldmaps/#{filename}"
      end

      # Return all the worldmap
      # @return [Array<WorldMap>]
      def all
        return @data
      end

      # Tell if the id is valid
      # @param id [Integer]
      # @return [Boolean]
      def id_valid?(id)
        return id.between?(0, @data.size - 1)
      end

      # Load the data from Data/PSDK/WorldMaps.rxdata
      # @return [Array]
      def load
        @data = load_data('Data/PSDK/WorldMaps.rxdata')
      rescue StandardError, LoadError
        # Convert PSDK 24.27 system to PSDK 24.28+ system
        old_data = $game_data_map
        old_data[0] = [nil] unless old_data[0]
        width = old_data.length
        height = old_data[0].length
        data = Table.new(width, height)
        0.upto(width - 1) do |x|
          0.upto(height - 1) do |y|
            if old_data[x]
              data[x + 1, y + 1] = (old_data[x][y] || -1)
            else
              data[x + 1, y + 1] = -1
            end
          end
        end
        wm = GameData::WorldMap.new('world_map', 0, nil)
        wm.data = data

        GameData::Zone.all.each do |zone|
          zone.worldmap_id = 0
        end
        @data = [wm]
      end
    end
  end
end
