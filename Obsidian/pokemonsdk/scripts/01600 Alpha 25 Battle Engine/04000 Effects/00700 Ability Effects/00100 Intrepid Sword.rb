module Battle
  module Effects
    class Ability
      class IntrepidSword < Ability
        # Function called when a Pokemon has actually switched with another one
        # @param handler [Battle::Logic::SwitchHandler]
        # @param who [PFM::PokemonBattler] Pokemon that is switched out
        # @param with [PFM::PokemonBattler] Pokemon that is switched in
        def on_switch_event(handler, who, with)
          return if with != @target

          handler.scene.visual.show_ability(with)
          handler.logic.stat_change_handler.stat_change_with_process(:atk, 1, with)
        end
      end
      register(:intrepid_sword, IntrepidSword)
    end
  end
end
