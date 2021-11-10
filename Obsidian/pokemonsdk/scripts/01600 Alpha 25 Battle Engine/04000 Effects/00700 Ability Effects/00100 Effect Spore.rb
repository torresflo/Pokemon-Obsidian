module Battle
  module Effects
    class Ability
      class EffectSpore < Ability
        # Function called after damages were applied (post_damage, when target is still alive)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage(handler, hp, target, launcher, skill)
          return if target != @target || launcher == target
          return unless skill&.direct? && launcher && launcher.hp > 0
          return if launcher&.has_ability?(:overcoat)
          return if (n = handler.logic.generic_rng.rand(10)) > 2 # ~30%

          status = %i[poison sleep paralysis][n]
          if handler.logic.status_change_handler.status_appliable?(status, target)
            handler.scene.visual.show_ability(target)
            handler.logic.status_change_handler.status_change(status, launcher)
          end
        end
      end
      register(:effect_spore, EffectSpore)
    end
  end
end
