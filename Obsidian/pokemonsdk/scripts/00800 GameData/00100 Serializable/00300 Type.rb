module GameData
  # Type data structure
  # @author Nuri Yuri
  class Type < Base
    extend DataSource
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

    @first_index = 0

    class << self
      # Filename of the file containing the data
      def data_filename
        return 'Data/PSDK/Types.rxdata'
      end
    end
  end
end
