module Battle
  module Effects
    class Ability
      class Imposter < Ability
        # Function called when a Pokemon has actually switched with another one
        # @param handler [Battle::Logic::SwitchHandler]
        # @param who [PFM::PokemonBattler] Pokemon that is switched out
        # @param with [PFM::PokemonBattler] Pokemon that is switched in
        def on_switch_event(handler, who, with)
          return if with != @target
          return unless (th = handler.logic.transform_handler).can_transform?(with)

          targets = handler.logic.foes_of(with).select(&:alive?).select { |foe| th.can_copy?(foe) }
          return if targets.empty?

          handler.scene.visual.show_ability(with)
          with.transform = targets.sample(random: handler.logic.generic_rng)
          handler.scene.visual.show_switch_form_animation(with)
          handler.scene.visual.wait_for_animation
          with.effects.add(Effects::Transform.new(handler.logic, with))
        end
      end
      register(:imposter, Imposter)
    end
  end
end
