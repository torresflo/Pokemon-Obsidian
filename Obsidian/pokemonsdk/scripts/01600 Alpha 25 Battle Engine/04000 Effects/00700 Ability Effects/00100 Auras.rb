module Battle
  module Effects
    class Ability
      class Auras < Ability
        # List of messages shown when entering the field
        AURA_MESSAGES = { fairy_aura: 1205, dark_aura: 1201, aura_break: 1231 }
        # Create a new PowerSpot effect
        # @param logic [Battle::Logic]
        # @param target [PFM::PokemonBattler]
        # @param db_symbol [Symbol] db_symbol of the ability
        def initialize(logic, target, db_symbol)
          super
          @affect_allies = true
        end

        # Function called when a Pokemon has actually switched with another one
        # @param handler [Battle::Logic::SwitchHandler]
        # @param who [PFM::PokemonBattler] Pokemon that is switched out
        # @param with [PFM::PokemonBattler] Pokemon that is switched in
        def on_switch_event(handler, who, with)
          return if with != target

          handler.scene.visual.show_ability(with)
          handler.scene.display_message_and_wait(parse_text_with_pokemon(19, AURA_MESSAGES[db_symbol], with))
        end

        # Get the base power multiplier of this move
        # @param user [PFM::PokemonBattler]
        # @param target [PFM::PokemonBattler]
        # @param move [Battle::Move]
        # @return [Float]
        def base_power_multiplier(user, target, move)
          fairy_aura_active = move.type_fairy? && move.logic.any_field_ability_active?(:fairy_aura)
          dark_aura_active = move.type_dark? && move.logic.any_field_ability_active?(:dark_aura)

          return 1 unless fairy_aura_active || dark_aura_active

          return move.logic.any_field_ability_active?(:aura_break) ? 0.75 : 1.33
        end
      end

      register(:fairy_aura, Auras)
      register(:dark_aura, Auras)
      register(:aura_break, Auras)
    end
  end
end
