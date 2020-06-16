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
      super
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
    # @param offensive_type_id [Integer] id of the offensive type
    # @return [Numeric]
    def hit_by(offensive_type_id)
      return @on_hit_tbl[offensive_type_id] || 1
    end

    class << self
      # Data containing all the types
      @data = []

      # Get the type data
      # @param id [Integer, Symbol]
      # @return [GameData::Type]
      def [](id)
        id = get_id(id) if id.is_a?(Symbol)

        return @data[id] || @data.first
      end

      # Get id using symbol
      # @param symbol [Symbol]
      # @return [Integer]
      def get_id(symbol)
        return 0 if symbol == :__undef__

        @data.index { |data| data.db_symbol == symbol }.to_i
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
        @data.each_with_index { |type, index| type&.id = index }
      end
    end
  end
end
