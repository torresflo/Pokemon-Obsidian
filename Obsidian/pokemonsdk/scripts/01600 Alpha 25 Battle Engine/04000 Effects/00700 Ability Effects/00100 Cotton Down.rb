module Battle
  module Effects
    class Ability
      class CottonDown < Ability
        # Function called after damages were applied (post_damage, when target is still alive)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage(handler, hp, target, launcher, skill)
          return if target != @target || launcher == target
          return unless skill && launcher && launcher.hp > 0

          if handler.logic.stat_change_handler.stat_decreasable?(:spd, launcher)
            handler.scene.visual.show_ability(target)
            handler.logic.stat_change_handler.stat_change_with_process(:spd, -1, launcher)
          end
        end
      end
      register(:cotton_down, CottonDown)
    end
  end
end
