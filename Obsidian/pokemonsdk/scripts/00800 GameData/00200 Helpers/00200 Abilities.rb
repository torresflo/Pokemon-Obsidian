module GameData
  # Module that helps you to retrieve safely texts related to Pokemon's Ability
  # @author Nuri Yuri
  module Abilities
    # List of Abilities db_symbols
    @db_symbols = []
    # List of translated ID ability id (psdk_id => gf_id)
    @psdk_id_to_gf_id = []

    module_function

    # Returns the name of an ability
    # @param id [Integer, Symbol] id of the ability in the database.
    # @return [String] the name of the ability or the name of the first ability.
    # @note The description is fetched from the 5th text file.
    def name(id = Class)
      return super() if id == Class

      id = get_id(id) if id.is_a?(Symbol)
      return text_get(4, @psdk_id_to_gf_id[id]) if id_valid?(id)
      return text_get(4, 0)
    end

    # Returns the description of an ability
    # @param id [Integer, Symbol] id of the ability in the database.
    # @return [String] the description of the ability or the description of the first ability.
    # @note The description is fetched from the 5th text file.
    def descr(id)
      id = get_id(id) if id.is_a?(Symbol)
      return text_get(5, @psdk_id_to_gf_id[id]) if id_valid?(id)
      return text_get(5, 0)
    end

    # Returns the symbol of an ability
    # @param id [Integer] id of the ability in the database
    # @return [Symbol] the db_symbol of the ability
    def db_symbol(id)
      @db_symbols.fetch(id, :__undef__)
    end

    # Find an ability id using symbol
    # @param symbol [Symbol]
    # @return [Integer, nil] nil = not found
    def find_using_symbol(symbol)
      @db_symbols.index(symbol)
    end
    class << self
      alias get_id find_using_symbol
    end

    # Tell if the id is valid
    # @param id [Integer]
    # @return [Boolean]
    def id_valid?(id)
      return id.between?(0, @psdk_id_to_gf_id.size - 1)
    end

    # Load the abilities
    def load
      @psdk_id_to_gf_id = load_data('Data/PSDK/Abilities.rxdata')
      @db_symbols = load_ability_db_symbol
    end

    # Load the ability db_symbol
    # @return [Array<Symbol>]
    def load_ability_db_symbol
      return load_data('Data/PSDK/Abilities_Symbols.rxdata')
    rescue StandardError, LoadError
      require 'plugins/update_db_symbol.rb' unless PSDK_CONFIG.release?
      return load_data('Data/PSDK/Abilities_Symbols.rxdata')
    end

    # Return the psdk_id_to_gf_id array
    # @return [Array<Integer>]
    def psdk_id_to_gf_id
      return @psdk_id_to_gf_id
    end

    # Convert a collection to symbolized collection
    # @param collection [Enumerable]
    # @param keys [Boolean] if hash keys are converted
    # @param values [Boolean] if hash values are converted
    # @return [Enumerable] the collection
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
        collection.each_with_index do |value, index|
          if value.is_a?(Enumerable)
            collection[index] = convert_to_symbols(value, keys: keys, values: values)
          elsif value.is_a?(Integer)
            collection[index] = db_symbol(value)
          end
        end
      end
      collection
    end
  end
end
