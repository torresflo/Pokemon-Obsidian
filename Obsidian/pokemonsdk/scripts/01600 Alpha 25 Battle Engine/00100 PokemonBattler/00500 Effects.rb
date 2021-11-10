module PFM
  # Class defining a Pokemon during a battle, it aim to copy its properties but also to have the methods related to the battle.
  class PokemonBattler
    # Get the effect hanndler
    # @return [Battle::Effects::EffectsHandler]
    attr_reader :effects

    Hooks.register(PFM::PokemonBattler, :on_reset_states, 'PSDK reset effects') do
      @effects = Battle::Effects::EffectsHandler.new
    end

    # Evaluate all the effects related to this Pokemon
    # @param yielder [Proc] proc to call with the effect
    def evaluate_effects(yielder)
      # Status Effect
      yielder.call(status_effect)
      # Ability Effect
      yielder.call(ability_effect)
      # Item effect
      yielder.call(item_effect)
      # Move effect
      effects.each(&yielder)
      # Position effects
      @scene.logic.position_effects[bank][position]&.each(&yielder)
    end

    # Get the status effect
    # @return [Battle::Effects::Status]
    def status_effect
      @status_effect = Battle::Effects::Status.new(@scene.logic, self, @status) if !@status_effect || @status_effect.status_id != @status
      return @status_effect
    end

    # Get the ability effect
    # @return [Battle::Effects::Ability]
    def ability_effect
      db_symbol = battle_ability_db_symbol
      db_symbol = :__undef__ unless has_ability?(db_symbol)
      @ability_effect = Battle::Effects::Ability.new(@scene.logic, self, db_symbol) if !@ability_effect || @ability_effect.db_symbol != db_symbol
      return @ability_effect
    end

    # Get the item effect
    # @return [Battle::Effects::Item]
    def item_effect
      db_symbol = battle_item_db_symbol
      db_symbol = :__undef__ unless hold_item?(db_symbol)
      @item_effect = Battle::Effects::Item.new(@scene.logic, self, db_symbol) if !@item_effect || @item_effect.db_symbol != db_symbol
      return @item_effect
    end
  end
end
