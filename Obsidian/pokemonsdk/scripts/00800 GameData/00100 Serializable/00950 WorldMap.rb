module GameData
  # Data structure of world maps
  # @author Leikt, Nuri Yuri
  class WorldMap < Base
    extend DataSource
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

    @first_index = 0
    class << self
      # Name of the file containing the data
      def data_filename
        return 'Data/PSDK/WorldMaps.rxdata'
      end

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
      # @param block [Proc]
      def each_id(&block)
        @data.each_index(&block)
      end

      # Return a WorldMap
      # @param id [Integer]
      # @return [WorldMap]
      def get(id)
        return self[id]
      end

      # Give the appropriate filename for the worldmap image in Graphics/interface
      # @param filename [String]
      # @return [String]
      def worldmap_image_filename(filename)
        return filename if filename.start_with?('worldmap/worldmaps/')

        return "worldmap/worldmaps/#{filename}"
      end
    end
  end
end
