# Module that define inGame data / script interface
module PFM
  class << self
    # Get the game state
    # @return [GameState]
    attr_accessor :game_state
    # Get the class handling the bag data in the game
    # @return [Class<Bag>]
    attr_accessor :bag_class
    # Get the class handling the Pokemon Storage System data in the game
    # @return [Class<Storage>]
    attr_accessor :storage_class
    # Get the class handling the Dex data in the game
    # @return [Class<Pokedex>]
    attr_accessor :dex_class
    # Get the class handling the player info in the game
    # @return [Class<Trainer>]
    attr_accessor :player_info_class
    # Get the class handling the option in the game
    # @return [Class<Options>]
    attr_accessor :options_class
    # Get the class handling the daycare in the game
    # @return [Class<Daycare>]
    attr_accessor :daycare_class
    # Get the class handling the environment in the game
    # @return [Class<Environment>]
    attr_accessor :environment_class
    # Get the class handling the shop in the game
    # @return [Class<Shop>]
    attr_accessor :shop_class
    # Get the class handling the nuzlocke in the game
    # @return [Class<Nuzlocke>]
    attr_accessor :nuzlocke_class
    # Get the class handling the hall of fame in the game
    # @return [Class<Hall_of_Fame>]
    attr_accessor :hall_of_fame_class
  end
end
