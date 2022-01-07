module PFM
  # Class describing the Hall_of_Fame logic
  class Hall_of_Fame
    # Array containing every victory of the player
    # @return [Array]
    attr_accessor :player_victory
    # Get the game state responsive of the whole game state
    # @return [PFM::GameState]
    attr_accessor :game_state

    # Create a new hall of fame
    # @param game_state [PFM::GameState] variable responsive of containing the whole game state for easier access
    def initialize(game_state = PFM.game_state)
      @player_victory = []
      @game_state = game_state
    end

    # Register a win in the Pokemon League for the player
    # @param mode [Symbol] the symbol designing the type of victory : possible victory are :league and :title_defense
    def register_victory(mode = :league)
      pokemon_array = []
      @game_state.actors.each { |pkm| pokemon_array << pkm.clone }
      victory = {
        mode: mode,
        team: pokemon_array,
        play_time: PFM.game_state.trainer.play_time_text,
        entry_date: Time.new
      }
      @player_victory << victory
    end
  end

  class GameState
    # The list of the victory in the Pokemon League
    # @return [PFM::Hall_of_Fame]
    attr_accessor :hall_of_fame

    on_player_initialize(:hall_of_fame) { @hall_of_fame = PFM.hall_of_fame_class.new(self) }
    on_expand_global_variables(:hall_of_fame) do
      # Variable containing the Hall of Fame informations
      @hall_of_fame ||= PFM.hall_of_fame_class.new(self)
      @hall_of_fame.game_state = self
    end
  end
end

PFM.hall_of_fame_class = PFM::Hall_of_Fame
