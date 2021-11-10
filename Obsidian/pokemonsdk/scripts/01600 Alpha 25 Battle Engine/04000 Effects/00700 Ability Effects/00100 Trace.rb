module Battle
  module Effects
    class Ability
      class Trace < Ability
        # Function called when a Pokemon has actually switched with another one
        # @param handler [Battle::Logic::SwitchHandler]
        # @param who [PFM::PokemonBattler] Pokemon that is switched out
        # @param with [PFM::PokemonBattler] Pokemon that is switched in
        def on_switch_event(handler, who, with)
          return if with != @target

          foes = handler.logic.foes_of(with).select do |foe|
            next foe.alive? && foe.ability_db_symbol != :__undef__ &&
              handler.logic.ability_change_handler.can_change_ability?(with, foe.ability_db_symbol) # Checking if with can change to foe ability
          end
          return if foes.none?

          target = foes.sample(random: handler.logic.generic_rng)
          handler.scene.visual.show_ability(with)
          handler.logic.ability_change_handler.change_ability(with, target.ability_db_symbol)
          handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 381, target, PFM::Text::ABILITY[1] => with.ability_name))
          with.ability_effect.on_switch_event(handler, who, with) if with.ability_effect.class != Trace
        end
      end
      register(:trace, Trace)
    end
  end
end
