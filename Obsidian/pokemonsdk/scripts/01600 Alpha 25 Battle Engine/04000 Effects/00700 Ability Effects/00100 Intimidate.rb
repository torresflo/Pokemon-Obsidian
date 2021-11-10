module Battle
  module Effects
    class Ability
      class Intimidate < Ability
        # Function called when a Pokemon has actually switched with another one
        # @param handler [Battle::Logic::SwitchHandler]
        # @param who [PFM::PokemonBattler] Pokemon that is switched out
        # @param with [PFM::PokemonBattler] Pokemon that is switched in
        def on_switch_event(handler, who, with)
          return if with != @target

          alive_foes = handler.logic.foes_of(with).select(&:alive?)
          handler.scene.visual.show_ability(with) if alive_foes.any?
          alive_foes.each do |foe|
            handler.logic.stat_change_handler.stat_change_with_process(:atk, -1, foe, with)
            if foe.has_ability?(:rattled)
              handler.scene.visual.show_ability(foe)
              handler.logic.stat_change_handler.stat_change_with_process(:spd, 1, foe, with)
            end
          end
        end
      end
      register(:intimidate, Intimidate)
    end
  end
end
