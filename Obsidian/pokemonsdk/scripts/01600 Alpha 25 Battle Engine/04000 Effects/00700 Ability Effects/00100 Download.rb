module Battle
  module Effects
    class Ability
      class Download < Ability
        # Function called when a Pokemon has actually switched with another one
        # @param handler [Battle::Logic::SwitchHandler]
        # @param who [PFM::PokemonBattler] Pokemon that is switched out
        # @param with [PFM::PokemonBattler] Pokemon that is switched in
        def on_switch_event(handler, who, with)
          return if with != @target

          random_foe = handler.logic.foes_of(with).shuffle(random: handler.logic.generic_rng).find(&:alive?)
          return unless random_foe

          handler.scene.visual.show_ability(with)
          handler.logic.stat_change_handler.stat_change_with_process(random_foe.dfe < random_foe.dfs ? :atk : :ats, 1, with)
        end
      end
      register(:download, Download)
    end
  end
end
