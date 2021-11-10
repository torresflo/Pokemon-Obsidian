module Battle
  module Effects
    class Ability
      class Steadfast < Ability
        # Function called when a post_status_change is performed
        # @param handler [Battle::Logic::StatusChangeHandler]
        # @param status [Symbol] :poison, :toxic, :confusion, :sleep, :freeze, :paralysis, :burn, :flinch, :cure
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_status_change(handler, status, target, launcher, skill)
          return if target != @target
          return unless status == :flinch

          handler.scene.visual.show_ability(target)
          handler.logic.stat_change_handler.stat_change_with_process(:spd, 1, target)
        end
      end
      register(:steadfast, Steadfast)
    end
  end
end
