module GameData
  # A module that help to retrieve nature informations
  # @author Nuri Yuri
  module Natures
    # Data holding all the nature info
    @data = []

    module_function

    # Safely returns a nature info
    # @param nature_id [Integer] id of the nature
    # @return [Array<Integer>]
    def [](nature_id)
      return @data[nature_id] if id_valid?(nature_id)
      return @data[0]
    end

    # Return the number of defined natures
    # @return [Integer]
    def size
      return @data.size
    end

    # Return if the Nature ID is valid
    # @return [Boolean]
    def id_valid?(id)
      return id.between?(0, @data.size - 1)
    end

    # Load the natures
    def load
      @data = load_data('Data/PSDK/Natures.rxdata')
    end

    # Return all the natures
    # @return [Array<Array<Integer>>]
    def all
      @data
    end
  end
end
