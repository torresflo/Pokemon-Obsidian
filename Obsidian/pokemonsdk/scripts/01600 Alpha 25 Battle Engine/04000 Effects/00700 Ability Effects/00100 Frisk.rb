module Battle
  module Effects
    class Ability
      class Frisk < Ability
        # Function called when a Pokemon has actually switched with another one
        # @param handler [Battle::Logic::SwitchHandler]
        # @param who [PFM::PokemonBattler] Pokemon that is switched out
        # @param with [PFM::PokemonBattler] Pokemon that is switched in
        def on_switch_event(handler, who, with)
          return if with != @target

          foe_item = handler.logic.foes_of(with).find { |foe| foe.alive? && foe.battle_item_db_symbol != :__undef__ }
          return unless foe_item

          handler.scene.visual.show_ability(with)
          handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 439, with, PFM::Text::PKNICK[1] => foe_item.given_name,
                                                                                        PFM::Text::ITEM2[2] => foe_item.item_name))
        end
      end
      register(:frisk, Frisk)
    end
  end
end
