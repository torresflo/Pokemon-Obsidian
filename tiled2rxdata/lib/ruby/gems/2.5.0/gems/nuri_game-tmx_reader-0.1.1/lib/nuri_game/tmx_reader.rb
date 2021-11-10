require 'nuri_game/tmx_reader/version'
require 'rexml/document'
require 'zlib'
require 'base64'

# NuriGame namespace containing all the utility made by Nuri Yuri in order to make Games.
module NuriGame
  # class that converts TMX file to Ruby object
  class TmxReader

    # Definition of a tileset
    Tileset = Struct.new(:firstgid, :source)

    # Constant holding the list of map information
    MAP_INFOS = ['width', 'height', 'tilewidth', 'tileheight'].freeze

    # @return [Integer] width of the map
    attr_reader :width

    # @return [Integer] height of the map
    attr_reader :height

    # @return [Integer] width of a tile on the map
    attr_reader :tilewidth

    # @return [Integer] height of a tile on the map
    attr_reader :tileheight

    # @return [Array<Tileset>] tilesets of the map
    attr_reader :tilesets

    # @return [Hash{String => Array<Integer>}] layers of the map (name => grid)
    attr_reader :layers

    # Create a new TmxReader
    # @param filename [String] name of the tmx file to read
    def initialize(filename)
      contents = File.read(filename).force_encoding(Encoding::UTF_8)
      map = REXML::Document.new(contents).root
      @tilesets = []
      @layers = {}
      @invert_order = false
      validate_map(map)
      load_map_infos(map)
      load_tilesets(map)
      load_layers(map)
    end

    private

    # Validate the map informations
    # @parma map [REXML::Element]
    def validate_map(map)
      raise 'Invalid TMX data, root element is not a <map>' if map.name != 'map'
      raise 'Invalid TMX orientation, expect orthogonal' if xml_value(map, 'orientation') != 'orthogonal'
      @render_order = xml_value(map, 'renderorder') || 'right-down'
      raise 'Invalid TMX map format, should not be infinite' if xml_value(map, 'infinite').to_i != 0
    end

    # Load the map informations
    # @param map [REXML::Element]
    def load_map_infos(map)
      MAP_INFOS.each { |name| instance_variable_set(:"@#{name}", xml_value(map, name).to_i) }
    end

    # Load the map tilesets
    # @param map [REXML::Element]
    def load_tilesets(map)
      tilesets = @tilesets
      map.each_element('tileset') do |tileset|
        tilesets << Tileset.new(xml_value(tileset, 'firstgid').to_i, xml_value(tileset, 'source').to_s)
      end
    end

    # Load the map layers (flattened)
    # @param map [REXML::Element]
    def load_layers(map)
      map.each_element_with_attribute('name') do |layer|
        if layer.name == 'group'
          load_layer_group(layer, xml_value(layer, 'name'))
        elsif layer.name == 'layer'
          @layers[get_layer_name(xml_value(layer, 'name'))] = load_layer(layer)
        end
      end
    end

    # Adjust the layer name to prevent duplicates
    # @param name [String]
    # @return [String]
    def get_layer_name(name)
      name = name.dup
      name.prepend('/') while @layers[name]
      return name
    end

    # Load the layer from a group
    # @param group [REXML::Element]
    # @param groupname [String]
    def load_layer_group(group, groupname)
      group.each_element do |layer|
        if layer.name == 'group'
          load_layer_group(layer, File.join(groupname, xml_value(layer, 'name')))
        elsif layer.name == 'layer'
          name = File.join(groupname, xml_value(layer, 'name'))
          @layers[get_layer_name(name)] = load_layer(layer)
        end
      end
    end

    # Load the layer data
    # @param layer [REXML::Element]
    def load_layer(layer)
      data = get_layer_data(layer)
      data = adjust_layer_data(layer, data)
      # Perform stuff if there's offset & co (but shouldn't happen since we don't allow infinite maps)
      return data
    end

    # Adjust the layer data
    # @param layer [REXML::Element]
    # @param data [Array]
    # @return [Array]
    def adjust_layer_data(layer, data)
      width = xml_value(layer, 'width').to_i
      height = xml_value(layer, 'height').to_i
      if @width != width || @height != height
        rows = Array.new(@height) do |index|
          next(Array.new(@width, 0)) unless (row = data[index * width, @width])
          row.concat(Array.new(@width - row.size, 0)) if row.size < @width
          next(row)
        end
        return [].concat(*rows)
      end
      return data
    end
    # Get the layer data
    # @source https://github.com/shawn42/tmx/blob/master/lib/tmx/parsers/tmx-rexml.rb
    # @param layer [REXML::Element]
    def get_layer_data(layer)
      data = REXML::XPath.first(layer, 'data')
      enc = xml_value(data, 'encoding')
      comp = xml_value(data, 'compression')
      layer_data = REXML::XPath.first(layer, 'data').text.strip
      layer_data = Base64.decode64(layer_data) if enc == 'base64'

      case comp
      when 'zlib'
        return unpack_data(zlib_decompress(layer_data))
      when 'gzip'
        return unpack_data(gzip_decompress(layer_data))
      else
        case enc
        when 'base64'
          return unpack_data(layer_data)
        when 'csv'
          return layer_data.split(',').collect(&:to_i)
        end
      end
      REXML::XPath.match(layer, 'data/tile').map { |tile| tile.attributes['gid'].to_i }
    end

    # Decompress using Zlib
    # @param data [String]
    # @return [String]
    def zlib_decompress(data)
      Zlib::Inflate.inflate(data)
    end

    # Decompress using Gzip
    # @param data [String]
    # @return [String]
    def gzip_decompress(data)
      Zlib::GzipReader.new(StringIO.new(data)).read
    end

    # Convert data into valid Ruby Data
    # @param data [String]
    # @return [Array<Integer>]
    def unpack_data(data)
      data.unpack('V*')
    end

    # Return an xml value
    # @param element [REXML::Element]
    # @param value_name [String]
    # @return [String, nil] nil means no value
    def xml_value(element, value_name)
      val = element.attribute(value_name)
      return val ? val.value : nil
    end
  end
end
