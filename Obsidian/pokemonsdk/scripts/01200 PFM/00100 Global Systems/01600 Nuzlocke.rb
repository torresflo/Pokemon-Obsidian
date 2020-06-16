module PFM
  # Class responsive of managing Nuzlocke information and helping to implement the nuzlocke logic
  # @author Logically anime and ralandel
  class Nuzlocke
    # If we prevent Duplicate from locking catch
    # @return [Boolean]
    attr_accessor :no_lock_on_duplicate
    # Storage of dead Pokemon to re-use later in other systems
    # @return [Array<PFM::Pokemon>]
    attr_accessor :graveyard
    # Create a new Nuzlocke object
    def initialize
      @catch_locked_zones = []
      @no_lock_on_duplicate = false
      @graveyard = []
    end

    # Function that clears the dead Pokemon from the party
    # and put their item back in the bag
    def clear_dead_pokemon
      dead_condition = proc { |pokemon| pokemon.hp <= 0 }
      # List all the items from dead Pokemon
      item_ids = $actors.select(&dead_condition).map(&:item_hold)
      # Add items back to the bag
      item_ids.each { |item_id| $bag.add_item(item_id, 1) if item_id >= 0 }
      # Storing Pokemon that are dead
      graveyard.concat($actors.select(&dead_condition))
      # Remove Pokemon from the party
      $actors.delete_if(&dead_condition)
    end
    alias dead clear_dead_pokemon

    # Lock the current zone (prevent Pokemon from being able to be caught here)
    # @note This method checks if that's possible to lock before locking
    # @param pokemon_id [Integer] ID of the Pokemon that was seen before locking
    def lock_catch_in_current_zone(pokemon_id)
      return if catching_locked_here? || $game_temp.trainer_battle
      return if no_lock_on_duplicate && $pokedex.pokemon_caught?(pokemon_id) && !$game_switches[Yuki::Sw::BT_Catch]

      @catch_locked_zones.push($env.master_zone)
    end

    # Tell if catching is locked in the given zone
    # @param id [Integer] ID of the zone
    # @return [Boolean]
    def catching_locked?(id)
      @catch_locked_zones.include?(id)
    end

    # Tell if catching is locked in the current zone
    # @return [Boolean]
    def catching_locked_here?
      catching_locked?($env.master_zone)
    end

    # Switch the enable state of the Nuzlocke
    # @param bool [Boolean]
    def switch(bool)
      $game_switches[Yuki::Sw::Nuzlocke_ENA] = bool
    end

    # Tell if the Nuzlocke is enabled
    # @return [Boolean]
    def enabled?
      $game_switches[Yuki::Sw::Nuzlocke_ENA]
    end

    # Enable the Nuzlocke
    def enable
      switch(true)
    end

    # Disable the Nuzlocke
    def disable
      switch(false)
    end
  end
end
