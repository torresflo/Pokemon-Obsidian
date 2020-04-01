module GameData
  class JSONFromDataCollection
    # Convert all the Nature to JSON Ruby Object
    # @return [Array]
    def convert_all_natures
      return Natures.all.collect.with_index do |nature, nature_id|
        {
          id: nature_id,
          text_id: nature.first,
          atk: nature[1],
          dfe: nature[2],
          spd: nature[3],
          ats: nature[4],
          dfs: nature[5]
        }
      end
    end
  end

  module Natures
    module_function

    # Convert all the nature to JSON
    # @param filename [String] name of the JSON file
    def to_json(filename)
      load if all.empty?
      JSONFromDataCollection.new(self).convert(filename)
    end
  end
end
