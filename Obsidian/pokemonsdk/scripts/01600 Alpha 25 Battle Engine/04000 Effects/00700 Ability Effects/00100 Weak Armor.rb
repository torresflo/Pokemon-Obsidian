module Battle
  module Effects
    class Ability
      class WeakArmor < Ability
        # Function called after damages were applied (post_damage, when target is still alive)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage(handler, hp, target, launcher, skill)
          return if target != @target || launcher == target
          return unless skill&.physical?

          if handler.logic.stat_change_handler.stat_decreasable?(:dfe, target) &&
             handler.logic.stat_change_handler.stat_increasable?(:spd, target)
            handler.scene.visual.show_ability(target)
            handler.logic.stat_change_handler.stat_change_with_process(:dfe, -1, target)
            handler.logic.stat_change_handler.stat_change_with_process(:spd, 2, target)
          end
        end
      end
      register(:weak_armor, WeakArmor)
    end
  end
end
