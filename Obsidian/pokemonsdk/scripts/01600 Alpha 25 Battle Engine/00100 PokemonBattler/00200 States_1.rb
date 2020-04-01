module PFM
  class PokemonBattler
    # @return [Boolean] set switching state
    attr_writer :switching
    # @return [Hash{Symbol => Object}] List of initial values of each instance variables
    STATE_INI_VALUES = {
      "@confuse_count": 0,
      "@helping_hand": false,
      "@turn_count": 0,
      "@focus_energy": false,
      "@battle_stage": Array.new(7, 0),
      "@switching": false
    }
    # @return [Array<Symbol>] List of the update method to call at the end of each turn
    END_TURN_UPDATE = %i[
      update_confuse_count update_helping_hand update_switching
    ]

    # Initialize the states of the Pokemon
    def init_states
      @status_count = 0 if toxic?
      STATE_INI_VALUES.each do |ivar_name, value|
        instance_variable_set(ivar_name, value.clone)
      end
      @ability_current = @ability
      @item_holding_current ||= @item_holding # If the item was lost / thrown we don't set it back
    end

    # Return the db_symbol of the current ability of the Pokemon
    # @return [Symbol]
    def ability_db_symbol
      GameData::Abilities.db_symbol(@ability_current || -1)
    end

    # Return the db_symbol of the current item the Pokemon is holding
    # @return [Symbol]
    def item_db_symbol
      GameData::Item.db_symbol(@item_holding_current || -1)
    end

    # Update all the status/effect at the end of a turn
    def update_status
      END_TURN_UPDATE.each { |method_name| send(method_name) }
    end

    # Is the Pokemon confused ?
    # @return [Boolean]
    def confused?
      @confuse_count > 0
    end

    # Update the confuse state
    def update_confuse_count
      return unless confused?
      @confuse_count -= 1
      return if confused?
      # Display the message about the end of the confusion
    end

    # Is the Pokemon on the effect of helping hand ?
    # @return [Boolean]
    def helping_hand?
      @helping_hand
    end

    # Update the helping hand state
    def update_helping_hand
      @helping_hand = false
    end

    # Apply helping hand state
    def apply_helping_hand
      @helping_hand = true
    end

    # if the user has focus energy effect
    # @return [Boolean]
    def focus_energy?
      @focus_energy
    end

    # Apply focus energy state
    def apply_focus_energy
      @focus_energy = true
    end

    # if the pokemon is switching during this turn
    # @return [Boolean]
    def switching?
      @switching
    end

    # Reset the switching state
    def update_switching
      @switching = false
    end
  end
end
