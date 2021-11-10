require 'nuri_game/tsx_reader/version'
require 'rexml/document'
require 'zlib'
require 'base64'

# NuriGame namespace containing all the utility made by Nuri Yuri in order to make Games.
module NuriGame
  # class that converts TSX file to Ruby object
  class TsxReader
    # Definition of an image
    Image = Struct.new(:format, :source, :trans, :width, :height, :data)

    # Constant holding the list of tileset information
    TILESET_INFOS = %w[tilewidth tileheight tilecount columns spacing margin].freeze

    # @return [String] name of the tileset
    attr_reader :name

    # @return [Integer] number of tiles in the tileset
    attr_reader :tilecount

    # @return [Integer] number of columns in the tileset
    attr_reader :columns

    # @return [Integer] width of a tile on the tileset
    attr_reader :tilewidth

    # @return [Integer] height of a tile on the tileset
    attr_reader :tileheight

    # @return [Integer] space in px between tiles in the tileset image
    attr_reader :spacing

    # @return [Integer] margin around the tile of the tileset
    attr_reader :margin

    # @return [Hash{String => Integer}] terrains of the tileset by name
    attr_reader :terrains

    # @return [Image] image used in the tileset
    attr_reader :image

    # Create a new TmxReader
    # @param filename [String] name of the tmx file to read
    def initialize(filename)
      contents = File.read(filename).force_encoding(Encoding::UTF_8)
      tileset = REXML::Document.new(contents).root
      @terrains = {}
      validate_tileset(tileset)
      load_tileset_infos(tileset)
      load_tileset_image(tileset)
      load_tileset_terrains(tileset)
    end

    private

    # Validate the tileset informations
    # @parma tileset [REXML::Element]
    def validate_tileset(tileset)
      raise 'Invalid TSX data, root element is not a <tileset>' if tileset.name != 'tileset'
    end

    # Load the tileset informations
    # @param tileset [REXML::Element]
    def load_tileset_infos(tileset)
      @name = xml_value(tileset, 'name').to_s
      TILESET_INFOS.each { |name| instance_variable_set(:"@#{name}", xml_value(tileset, name).to_i) }
    end

    # Load the image of the tileset
    # @param tileset [REXML::Element]
    def load_tileset_image(tileset)
      image = REXML::XPath.first(tileset, 'image')
      data = REXML::XPath.first(image, 'data')
      data = load_image_data(data)
      @image = Image.new(
        xml_value(image, 'format'),
        xml_value(image, 'source'),
        xml_value(image, 'trans'),
        xml_value(image, 'width').to_i,
        xml_value(image, 'height').to_i,
        data
      )
    end

    # Load the terrains of the tileset
    # @param tileset [REXML::Element]
    def load_tileset_terrains(tileset)
      tileset.each_element('terraintypes/terrain') do |terrain|
        @terrains[xml_value(terrain, 'name')] = xml_value(terrain, 'tile').to_i
      end
    end

    # Load the image data of the tileset
    # @param data [REXML::Element]
    def load_image_data(data)
      return unless data
      raw_data = data.text.strip
      enc = xml_value(data, 'encoding')
      comp = xml_value(data, 'compression')
      raw_data = Base64.decode64(raw_data) if enc == 'base64'
      case comp
      when 'zlib'
        return Zlib::Inflate.inflate(raw_data)
      when 'gzip'
        return Zlib::GzipReader.new(StringIO.new(raw_data)).read
      end
      return raw_data
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
