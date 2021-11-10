module Battle
  module Effects
    class Ability
      class QuickFeet < Ability
        # Give the speed modifier over given to the Pokemon with this effect
        # @return [Float, Integer] multiplier
        def spd_modifier
          return 1.5 / target.status_effect.spd_modifier if target.paralyzed?

          return 1.5
        end

        # Function called when a post_status_change is performed
        # @param handler [Battle::Logic::StatusChangeHandler]
        # @param status [Symbol] :poison, :toxic, :confusion, :sleep, :freeze, :paralysis, :burn, :flinch, :cure
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_status_change(handler, status, target, launcher, skill)
          return if status == :cure || target != self.target
          return unless handler.logic.stat_change_handler.stat_increasable?(:spd, target, launcher, skill)

          handler.scene.visual.show_ability(target)
          handler.logic.stat_change_handler.stat_change(:spd, 1, target, launcher, skill)
        end
      end
      register(:quick_feet, QuickFeet)
    end
  end
end
