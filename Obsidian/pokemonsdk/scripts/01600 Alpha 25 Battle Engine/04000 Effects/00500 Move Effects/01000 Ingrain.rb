module Battle
  module Effects
    # Ingrain Effect
    class Ingrain < CantSwitch
      # Function called when testing if pokemon can switch (when he couldn't passthrough)
      # @param handler [Battle::Logic::SwitchHandler]
      # @param pokemon [PFM::PokemonBattler]
      # @param skill [Battle::Move, nil] potential skill used to switch
      # @param reason [Symbol] the reason why the SwitchHandler is called
      # @return [:prevent, nil] if :prevent, can_switch? will return false
      def on_switch_prevention(handler, pokemon, skill, reason)
        return false unless pokemon.effects.has?(:ingrain)
        return true if skill&.be_method == :s_teleport

        return handler.prevent_change do
          handler.scene.display_message_and_wait(flee_message)
        end
      end

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
        return :ingrain
      end

      private

      # Get the message text
      # @return [String]
      def message
        return parse_text_with_pokemon(19, 739, @pokemon)
      end

      # Get the flee message text
      # @return [String]
      def flee_message
        return parse_text_with_pokemon(19, 742, @pokemon)
      end

      # Get the HP factor delt by the move
      # @return [Integer]
      def hp_factor
        return 16
      end
    end
  end
end
