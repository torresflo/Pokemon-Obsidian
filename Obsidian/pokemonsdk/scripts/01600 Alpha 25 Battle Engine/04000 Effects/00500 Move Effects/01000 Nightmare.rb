module Battle
  module Effects
    # Implement the Nightmare effect
    class Nightmare < PokemonTiedEffectBase
      # Function called at the end of a turn
      # @param logic [Battle::Logic] logic of the battle
      # @param scene [Battle::Scene] battle scene
      # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
      def on_end_turn_event(logic, scene, battlers)
        return kill unless @pokemon.asleep?
        return if @pokemon.dead?
        return if @pokemon.has_ability?(:magic_guard)

        hp = @pokemon.max_hp / 4
        scene.display_message_and_wait(parse_text_with_pokemon(19, 324, @pokemon))
        logic.damage_handler.damage_change(hp.clamp(1, Float::INFINITY), @pokemon)
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        return :nightmare
      end
    end
  end
end
