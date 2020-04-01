module GameData
  # Type data structure
  # @author Nuri Yuri
  class Type < Base
    # Name of the unknown type
    DEFAULT_NAME = '???'
    # ID of the text that gives the type name
    # @return [Integer]
    attr_accessor :text_id
    # Result multiplier when a offensive type hit on this defensive type
    # @return [Array<Numeric>]
    attr_accessor :on_hit_tbl

    # Create a new Type
    # @param text_id [Integer] id of the type name text in the 3rd text file
    # @param on_hit_tbl [Array<Numeric>] table of multiplier when an offensive type hit this defensive type 
    def initialize(text_id, on_hit_tbl)
      @text_id = text_id
      @on_hit_tbl = on_hit_tbl
    end

    # Return the name of the type
    # @return [String]
    def name
      return text_get(3, @text_id) if @text_id >= 0
      return DEFAULT_NAME
    end

    # Return the damage multiplier
    # @param type_id [Integer] id of the offensive type
    # @return [Numeric]
    def hit_by(type_id)
      return @on_hit_tbl[type_id] || 1
    end

    class << self
      # Data containing all the types
      @data = []
      # Return the damage multiplier of a type to an other type
      # @param offensive_type [Integer] id of the offensive type
      # @param defensive_type [Integer] id of the defensive type
      # @return [Numeric]
      def multiplier(offensive_type, defensive_type)
        return get(defensive_type)&.hit_by(offensive_type) || 1
      end

      # Retrieve the name of a type
      # @param id [Integer] ID of the type
      # @return [String]
      def name(id)
        return @data[id].name if id_valid?(id)
        return DEFAULT_NAME
      end

      # Retrieve a type by its id
      # @param id [Integer] ID of the type
      # @return [GameData::Type]
      def get(id)
        return @data[id] if id_valid?(id)
        return @data.first
      end

      # Retrieve all the types
      # @return [Array<GameData::Type>]
      def all
        @data
      end

      # Tell if the id is valid
      # @param id [Intger]
      # @return [Boolean]
      def id_valid?(id)
        return id.between?(0, @data.size - 1)
      end

      # Load the type
      def load
        @data = load_data('Data/PSDK/Types.rxdata').freeze
      end
    end
  end
end
