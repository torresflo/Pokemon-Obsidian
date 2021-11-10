module Battle
  module Effects
    # Implement the Aqua Ring effect
    class AquaRing < PokemonTiedEffectBase
      # Function called at the end of a turn
      # @param logic [Battle::Logic] logic of the battle
      # @param scene [Battle::Scene] battle scene
      # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
      def on_end_turn_event(logic, scene, battlers)
        return unless battlers.include?(@pokemon)
        return if @pokemon.dead?

        heal_hp = (@pokemon.max_hp / hp_factor).clamp(1, Float::INFINITY)
        heal_hp += heal_hp * 30 / 100 if @pokemon.hold_item?(:big_root)
        logic.damage_handler.heal(@pokemon, heal_hp) do
          @logic.scene.display_message_and_wait(message)
        end
      end

      # Get the name of the effect
      # @return [Symbol]
      def name
        return :aqua_ring
      end

      private

      # Transfer the effect to the given pokemon via baton switch
      # @param with [PFM::Battler] the pokemon switched in
      # @return [Battle::Effects::PokemonTiedEffectBase, nil] the effect to give to the switched in pokemon, nil if there is this effect isn't transferable via baton pass
      def baton_switch_transfer(with)
        return self.class.new(@logic, with)
      end

      # Get the message text
      # @return [String]
      def message
        return parse_text_with_pokemon(19, 604, @pokemon)
      end

      # Get the HP factor delt by the move
      # @return [Integer]
      def hp_factor
        return 16
      end
    end
  end
end
