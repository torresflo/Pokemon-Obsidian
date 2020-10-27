module GameData
  # Trainer data structure
  # @author Nuri Yuri
  class Trainer < Base
    extend DataSource
    # The value that is multiplied to the last pokemon level to get the money the trainer gives
    # @return [Integer]
    attr_accessor :base_money
    # List of name of the trainers
    # @return [Array<String>]
    attr_accessor :internal_names
    # The battle type 1v1, 2v2, 3v3...
    # @return [Integer]
    attr_accessor :vs_type
    # The name of the battler in Graphics/Battlers
    # @return [String]
    attr_accessor :battler
    # List of Pokemon Hash (PFM::Pokemon.generate_from_hash)
    # @return [Array<Hash>]
    attr_accessor :team
    # ID of the group that holds the event variation of the battle
    # @return [Integer] 0 = no special group
    attr_accessor :special_group
    # Create a new Trainer
    def initialize
      @base_money = 30
      @internal_names = ['Jean']
      @vs_type = 1
      @team = []
      @battler = '001'
      @special_group = 0
    end

    @first_index = 0
    class << self
      # Name of the file containing the data
      def data_filename
        return 'Data/PSDK/Trainers.rxdata'
      end

      # Return the trainer class name
      # @param id [Integer] id of the trainer in the database
      # @return [String]
      def class_name(id)
        return text_get(29, id) if id_valid?(id)

        return text_get(29, 0)
      end

      # Get a specific trainer
      # @param id [Integer] ID of the trainer
      # @return [GameData::Trainer]
      def get(id)
        return self[id]
      end
    end
  end
end
