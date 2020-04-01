module GameData
  class JSONFromDataCollection
    private

    # Convert all the Abilities to JSON Ruby Object
    # @return [Array]
    def convert_all_abilities
      gd = Abilities
      return gd.psdk_id_to_gf_id.collect.with_index do |gf_id, psdk_id|
        {
          id: psdk_id,
          db_symbol: gd.db_symbol(psdk_id),
          text_id: gf_id
        }
      end
    end
  end

  module Abilities
    module_function

    # Convert the Abilities to a JSON file
    # @param filename [String] name of the file containing all the abilities
    def to_json(filename)
      load if psdk_id_to_gf_id.empty?
      JSONFromDataCollection.new(self).convert(filename)
    end
  end
end
