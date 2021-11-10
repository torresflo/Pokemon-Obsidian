module Battle
  module Effects
    class Ability
      class Pressure < Ability
        # Function called when a Pokemon has actually switched with another one
        # @param handler [Battle::Logic::SwitchHandler]
        # @param who [PFM::PokemonBattler] Pokemon that is switched out
        # @param with [PFM::PokemonBattler] Pokemon that is switched in
        def on_switch_event(handler, who, with)
          return if with != @target

          handler.scene.visual.show_ability(with)
          handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 487, with))
        end
      end
      register(:pressure, Pressure)
    end
  end
end
