module Battle
  class Logic
    # Get the terrain effects
    # @return [Effects::EffectsHandler]
    attr_reader :terrain_effects
    # Get the bank effects
    # @return [Array<Effects::EffectsHandler>]
    attr_reader :bank_effects
    # Get the position effects
    # @return [Array<Array<Battle::Effects::EffectsHandler>>]
    attr_reader :position_effects
    # Get or set the current field terrain type
    # @return [Symbol]
    attr_accessor :field_terrain

    # Execute a block on each effect depending on what to select as effect
    # @param pokemons [Array<PFM::PokemonBattler>] list of battlers we want to see their effect executed
    # @yieldparam [Effects::EffectBase]
    # @return [Array<Effects::EffectBase>, Symbol, Integer, nil] the first block return that was a symbol
    # @note This returns an enumerator if no block is given
    # @note If the block returns a Symbol, this methods returns this symbol immediately without processing the other effects
    def each_effects(*pokemons)
      return to_enum(__method__, *pokemons) unless block_given?

      # Define the proc that will ensure effects are properly called and stop the function if the result is a Symbol
      yielder = proc do |e|
        r = yield(e)
        return r if r.is_a?(Symbol)
      end
      pokemons = pokemons.compact.uniq # Sometimes launcher is nil, it's easier to handle that here
      # Terrain effect
      @terrain_effects.each(&yielder)
      yielder.call(weather_effect)
      yielder.call(field_terrain_effect)
      # Effect on Pokemon & their position
      pokemons.each { |pokemon| pokemon.evaluate_effects(yielder) }
      # Ability effect from allies
      allies = pokemons.flat_map { |pokemon| @scene.logic.allies_of(pokemon).select { |ally| ally.ability_effect.affect_allies } }.uniq
      allies.reject! { |pokemon| pokemons.include?(pokemon) } # <= Ability effect might already have been evaluated if the pokemon is in the list
      allies.each { |pokemon| yielder.call(pokemon.ability_effect) }
      # Effect on banks
      pokemons.compact.map(&:bank).uniq.each { |bank| @bank_effects[bank]&.each(&yielder) }
      return nil
    end

    # Add an effect on a position
    # @param effect [Battle::Effects::PositionTiedEffectBase]
    def add_position_effect(effect)
      bank = effect.bank
      position = effect.position
      # Safety code
      @position_effects[bank] ||= []
      @position_effects[bank][position] ||= Effects::EffectsHandler.new
      @position_effects[bank][position].add(effect)
    end

    # Add an effect on a bank
    # @param effect [Battle::Effects::PositionTiedEffectBase]
    def add_bank_effect(effect)
      bank = effect.bank
      @bank_effects[bank] ||= Effects::EffectsHandler.new
      @bank_effects[bank].add(effect)
    end

    # Delete all the dead effect by updating counters & removing them
    def delete_dead_effects
      @terrain_effects.update_counter
      @bank_effects.each(&:update_counter)
      @position_effects.each { |bank| bank.each { |position| position&.update_counter } }
      all_alive_battlers.map(&:effects).each(&:update_counter)
    end

    # Get the weather effect
    # @return [Effects::Weather]
    def weather_effect
      if !@weather_effect || @weather_effect.db_symbol != $env.current_weather_db_symbol
        @weather_effect = Battle::Effects::Weather.new(self, $env.current_weather_db_symbol)
      end
      return @weather_effect
    end

    # Get the field terrain effect
    # @return [Effects::FieldTerrain]
    def field_terrain_effect
      if !@field_terrain_effect || @field_terrain_effect.db_symbol != @field_terrain
        @field_terrain_effect = Battle::Effects::FieldTerrain.new(self, @field_terrain)
      end
      return @field_terrain_effect
    end

    private

    def init_effects
      @terrain_effects = Effects::EffectsHandler.new
      @bank_effects = Array.new(@bags.size) { Effects::EffectsHandler.new }
      # @type [Array<Array<Battle::Effects::EffectsHandler>>]
      @position_effects = Array.new(@bags.size) { Array.new(@battle_info.vs_type) { Effects::EffectsHandler.new } }
      @field_terrain = :none
    end
  end
end
