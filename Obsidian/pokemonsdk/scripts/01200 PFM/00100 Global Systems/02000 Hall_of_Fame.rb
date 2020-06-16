module PFM
  # Class describing the Hall_of_Fame logic
  class Hall_of_Fame
    # Array containing every victory of the player
    # @return [Array]
    attr_accessor :player_victory
    def initialize
      @player_victory = []
    end

    # Register a win in the Pokemon League for the player
    # @param mode [Symbol] the symbol designing the type of victory : possible victory are :league and :title_defense
    def register_victory(mode = :league)
      pokemon_array = []
      $actors.each { |pkm| pokemon_array << pkm.clone }
      victory = {
        mode: mode,
        team: pokemon_array,
        play_time: $pokemon_party.trainer.play_time_text,
        entry_date: Time.new
      }
      @player_victory << victory
    end
  end

  class Pokemon_Party
    # The list of the victory in the Pokemon League
    # @return [PFM::Hall_of_Fame]
    attr_accessor :hall_of_fame
    on_player_initialize(:hall_of_fame) { @hall_of_fame = PFM::Hall_of_Fame.new }
    on_expand_global_variables(:hall_of_fame) do
      # Variable containing the Hall of Fame informations
      @hall_of_fame ||= PFM::Hall_of_Fame.new
    end
  end
end
