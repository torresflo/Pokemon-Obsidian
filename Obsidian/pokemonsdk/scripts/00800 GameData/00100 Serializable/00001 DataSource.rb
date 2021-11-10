module GameData
  # Module describing a data source and providing basic function to acceed this data source
  #
  # @note All module extended by this need to define `data_filename` as a filename
  module DataSource
    # Constant containing all the data source (for auto loading)
    SOURCES = []

    # Get a data object
    # @param id [Integer, Symbol] ID of the data object in database
    # @return [self]
    def [](id)
      id = get_id(id) if id.is_a?(Symbol)
      id = 0 unless id.is_a?(Integer) && id_valid?(id)
      return @data[id]
    end

    # Safely return the db_symbol of a data object by it's integer ID
    # @param id [Integer] id of the item in the database
    # @return [Symbol]
    def db_symbol(id)
      return id_valid?(id) && @data[id].db_symbol || :__undef__
    end

    # Get id using symbol
    # @param symbol [Symbol]
    # @return [Integer]
    def get_id(symbol)
      return @db_symbol_to_id[symbol]
    end

    # Tell if the item id is valid
    # @param id [Integer]
    # @return [Boolean]
    def id_valid?(id)
      return id.between?(@first_index, @last_index)
    end

    # Load the items
    def load
      # @type [Array<GameData::Base>]
      @data = load_data(data_filename)
      @data.each_with_index { |item, index| item&.id = index }
      const_set(:LAST_ID, @last_index = @data.size - 1)
      # @type [Hash{Symbol => Integer}]
      @db_symbol_to_id = @data[@first_index..@last_index].map { |i| [i.db_symbol || :__bad__, i.id || 0] }.to_h
      @db_symbol_to_id[:__undef__] = 0
      @db_symbol_to_id.default = 0
    end

    # Return all the item
    # @return [Array<self>]
    def all
      return @data
    end

    # Convert a collection to symbolized collection
    # @param collection [Enumerable]
    # @param keys [Boolean] if hash keys are converted
    # @param values [Boolean] if hash values are converted
    # @return [Enumerable] the collection
    # @example Convert an array of integer to db_symbols
    #   convert_to_symbols([1, 2, 3])
    #   # =>
    #   [:sym1, :sym2, :sym3]
    # @example Convert a Hash but only keys
    #   convert_to_symbols({ 1 => 1 }, keys: true)
    #   # =>
    #   { :sym1 => 1 }
    # @example Convert Hash but only values
    #   convert_to_symbols({ 1 => 1 }, values: true)
    #   # =>
    #   { 1 => :sym1 }
    # @example Convert Hash
    #   convert_to_symbols({ 1 => 1 }, keys: true, values: true)
    #   # =>
    #   { :sym1 => :sym1 }
    def convert_to_symbols(collection, keys: false, values: false)
      if collection.is_a?(Hash)
        new_collection = {}
        collection.each do |key, value|
          key = db_symbol(key) if keys && key.is_a?(Integer)
          if value.is_a?(Enumerable)
            value = convert_to_symbols(value, keys: keys, values: values)
          elsif values && value.is_a?(Integer)
            value = db_symbol(value)
          end
          new_collection[key] = value
        end
        collection = new_collection
      else
        collection = collection.map do |value|
          if value.is_a?(Enumerable)
            next convert_to_symbols(value, keys: keys, values: values)
          elsif value.is_a?(Integer)
            next db_symbol(value)
          end
        end
      end
      collection
    end

    class << self
      def extended(klass)
        # We add the data collection to the class
        klass.instance_variable_set(:@data, [])
        # We set the 1st index
        klass.instance_variable_set(:@first_index, 1)
        # We set the last index
        klass.instance_variable_set(:@last_index, 0)
        # Add the new class to sources
        SOURCES << klass
      end
    end
  end

  # Module describing a 2D data source
  module DataSource2D
    include DataSource

    # Get a data Object in a 2D Array
    # @param id [Integer, Symbol] ID of the data
    # @param sub_index [Integer] Secondary index of the data
    # @return [self]
    # @note If the sub_index doesn't exists, sub_index 0 will be returned if existing
    def [](id, sub_index = 0)
      id = get_id(id) if id.is_a?(Symbol)
      return @data.dig(id, sub_index) || @data.dig(id, 0) || @data.dig(0, 0)
    end

    # Safely return the db_symbol of a data Object by its integer ID
    # @param id [Integer] id of the item in the database
    # @return [Symbol]
    def db_symbol(id)
      return id_valid?(id) && @data.dig(id, 0)&.db_symbol || :__undef__
    end

    # Load the items
    def load
      # @type [Array<GameData::Base>]
      @data = load_data(data_filename).freeze
      @data.each_with_index { |item, index| item[0]&.id = index }
      const_set(:LAST_ID, @last_index = @data.size - 1)
      # @type [Hash{Symbol => Integer}]
      @db_symbol_to_id = @data[@first_index..@last_index].map { |i| [i[0].db_symbol || :__bad__, i[0].id || 0] }.to_h
      @db_symbol_to_id[:__undef__] = 0
      @db_symbol_to_id.default = 0
    end

    class << self
      def extended(klass)
        # We add the data collection to the class
        klass.instance_variable_set(:@data, [])
        # We set the 1st index
        klass.instance_variable_set(:@first_index, 1)
        # We set the last index
        klass.instance_variable_set(:@last_index, 0)
        # Add the new class to sources
        DataSource::SOURCES << klass
      end
    end
  end
end
