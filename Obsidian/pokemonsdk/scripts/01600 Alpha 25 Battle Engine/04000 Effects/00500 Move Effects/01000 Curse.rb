module Battle
  module Effects
    # Implement the Curse effect
    class Curse < PokemonTiedEffectBase
      # Function called at the end of a turn
      # @param logic [Battle::Logic] logic of the battle
      # @param scene [Battle::Scene] battle scene
      # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
      def on_end_turn_event(logic, scene, battlers)
        return if @pokemon.dead?
        return if @pokemon.has_ability?(:magic_guard)

        hp = @pokemon.max_hp / 4
        scene.display_message_and_wait(parse_text_with_pokemon(19, 1077, @pokemon))
        logic.damage_handler.damage_change(hp.clamp(1, Float::INFINITY), @pokemon)
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        return :curse
      end

      private

      # Transfer the effect to the given pokemon via baton switch
      # @param with [PFM::Battler] the pokemon switched in
      # @return [Battle::Effects::PokemonTiedEffectBase, nil] the effect to give to the switched in pokemon, nil if there is this effect isn't transferable via baton pass
      def baton_switch_transfer(with)
        return self.class.new(@logic, with)
      end
    end
  end
end
