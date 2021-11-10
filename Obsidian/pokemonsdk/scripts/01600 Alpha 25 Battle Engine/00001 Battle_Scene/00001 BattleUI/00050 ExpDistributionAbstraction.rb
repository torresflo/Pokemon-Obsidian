module BattleUI
  # Abstraction for the exp distribution so you can do right things
  module ExpDistributionAbstraction
    # Get the scene
    # @return [Battle::Scene]
    attr_reader :scene

    private

    # Get the list of Pokemon that can get exp (are from player party)
    # @return [Array<PFM::PokemonBattler>]
    def find_expable_pokemon
      return 2.times.map do |bank|
        6.times.map { |position| @scene.logic.battler(bank, position) }.compact.select(&:from_party?)
      end.flatten
    end

    # Map Pokemon to originals with form
    # @param pokemon [Array<PFM::PokemonBattler>]
    # @return [Array<PFM::Pokemon>]
    # @note Do not call this function twice, it's caching for safety reasons
    def map_to_original_with_forms(pokemon)
      return @__original_pokemon if @__original_pokemon

      @__original_forms = pokemon.map { |battler| battler.original.form }
      @__original_pokemon = pokemon.map do |battler|
        original = battler.original
        original.instance_variable_set(:@form, battler.form) unless battler.transform

        next original
      end

      return @__original_pokemon
    end

    # Restore the form to originals
    def restore_form_to_originals
      @__original_pokemon&.each_with_index do |original, index|
        original.instance_variable_set(:@form, @__original_forms[index] || 0)
      end
      @__original_pokemon = nil
    end

    # Align exp of all original mon to the battlers
    # @param battlers [Array<PFM::PokemonBattler>]
    def align_exp(battlers)
      battlers.each do |battler|
        battler.exp = battler.original.exp
      end
    end

    # Function that shows level up of a Pokemon
    # @param pokemon [PFM::PokemonBattler]
    # @yieldparam original [PFM::PokemonBattler] the original battler in case you need it
    # @yieldparam list [Array<Array>] stat list due to level up
    def show_level_up(pokemon)
      original = pokemon.original
      original.hp = pokemon.hp unless pokemon.transform
      list = original.level_up_stat_refresh
      yield(original, list)
      level_up_message(pokemon)
      scene.logic.evolve_request << pokemon unless scene.logic.evolve_request.include?(pokemon) # outside of message to prevent skips
    end

    # Show the level up message
    # @param receiver [PFM::PokemonBattler]
    # @param show_message [Boolean] tell if the level up message should be shown
    def level_up_message(receiver, show_message: false)
      original = receiver.original
      PFM::Text.set_num3(original.level.to_s, 1)
      scene.display_message_and_wait(parse_text(18, 62, '[VAR 010C(0000)]' => original.given_name)) if show_message
      PFM::Text.reset_variables
      if original.can_learn_skill_at_this_level?
        moveset_before = original.skills_set.clone
        original.check_skill_and_learn
        receiver.level_up_copy_moveset(moveset_before) if original.skills_set != moveset_before
      end
      receiver.level_up_copy
    end
  end
end
