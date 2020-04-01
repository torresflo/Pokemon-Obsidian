module GameData
  class JSONFromDataCollection
    private

    # Convert all the Type to JSON Ruby Object
    # @return [Array]
    def convert_all_types
      return @data.collect do |type|
        {
          id: type.id,
          db_symbol: type.db_symbol,
          text_id: type.text_id,
          on_hit_tbl: type.on_hit_tbl
        }
      end
    end
  end

  class Type
    class << self
      # Convert all the types to a JSON file
      # @param filename [String] name of the file
      # @param use_id [Boolean] if the ID used in the various data part should not be converted to Symbol
      def to_json(filename, use_id = false)
        load if all.empty?
        JSONFromDataCollection.new(all, use_id).convert(filename)
      end
    end
  end
end
