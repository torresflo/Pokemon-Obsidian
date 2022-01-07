module PFM
  # Class describing the Hall_of_Fame logic
  class MiningGame
    # If the player is playing the mini-game for the first time
    # @return [Boolean]
    attr_accessor :first_time
    # If the player has access to the new dynamite tool
    # @return [Boolean]
    attr_accessor :dynamite_unlocked
    # Tells how many items the player has dug
    # @return [Integer]
    attr_accessor :nb_items_dug
    # Tells how many times the player has launched the mini-game
    # @return [Integer]
    attr_accessor :nb_game_launched
    # Tells how many times the player succeeded in the mini-game (every items dug)
    # @return [Integer]
    attr_accessor :nb_game_success
    # Tells how many times the player failed in the mini-game (wall collapsing)
    # @return [Integer]
    attr_accessor :nb_game_failed
    # Tells how many times the player used the pickaxe
    # @return [Integer]
    attr_accessor :nb_pickaxe_hit
    # Tells how many times the player used the mace
    # @return [Integer]
    attr_accessor :nb_mace_hit
    # Tells how many times the player used the dynamite
    # @return [Integer]
    attr_accessor :nb_dynamite_hit
    # Set the difficulty of the game (true = no yellow tiles at beginning)
    # @return [Boolean]
    attr_accessor :hard_mode
    def initialize
      @first_time = true
      @dynamite_unlocked = @hard_mode = false
      @nb_items_dug = @nb_game_launched = @nb_game_success = @nb_game_failed = @nb_pickaxe_hit = @nb_mace_hit = @nb_dynamite_hit = 0
    end
  end

  class GameState
    # Stats and booleans relative to the Mining Game
    # @return [PFM::MiningGame]
    attr_accessor :mining_game
    on_player_initialize(:mining_game) { @mining_game = PFM::MiningGame.new }
    on_expand_global_variables(:mining_game) do
      # Variable containing the Hall of Fame informations
      @mining_game ||= PFM::MiningGame.new
    end
  end
end
