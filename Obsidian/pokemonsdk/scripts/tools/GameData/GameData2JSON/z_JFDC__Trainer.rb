module GameData
  class JSONFromDataCollection
    private

    # Convert all the Trainer to JSON Ruby Object
    # @return [Array]
    def convert_all_trainers
      return @data.collect do |trainer|
        {
          id: trainer.id,
          db_symbol: trainer.db_symbol,
          base_money: trainer.base_money,
          internal_names: trainer.internal_names,
          vs_type: trainer.vs_type,
          team: team_symbol(trainer.team),
          battler: trainer.battler,
          special_group: trainer.special_group
        }
      end
    end

    # Convert Pokemon, skill, item to Symbol
    # @param team [Array<Hash>]
    # @return [Array<Hash>]
    def team_symbol(team)
      return team if @no_symbol_conv || team.nil?
      return team.collect do |hash|
        hash = hash.clone
        hash[:id] = GameData::Pokemon.db_symbol(hash[:id]) if hash.key?(:id)
        hash[:moves]&.collect! do |move_id|
          GameData::Skill.db_symbol(move_id)
        end
        hash[:item] = GameData::Item.db_symbol(hash[:item]) if hash[:item]
        next(hash)
      end
    end
  end

  class Trainer
    class << self
      # Convert all the trainers to a JSON file
      # @param filename [String] name of the file
      # @param use_id [Boolean] if the ID used in the various data part should not be converted to Symbol
      def to_json(filename, use_id = false)
        load if all.empty?
        JSONFromDataCollection.new(all, use_id).convert(filename)
      end
    end
  end
end
