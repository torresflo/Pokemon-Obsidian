module Battle
  module Effects
    class Ability
      class Rattled < Ability
        # Function called after damages were applied (post_damage, when target is still alive)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage(handler, hp, target, launcher, skill)
          return if target != @target || launcher == target
          return unless skill&.direct? && launcher && launcher.hp > 0
          return unless skill.type_ghost? || skill.type_dark? || skill.type_bug?
          return if target.effects.has?(:substitute)

          handler.scene.visual.show_ability(target)
          handler.logic.stat_change_handler.stat_change_with_process(:spd, 1, target)
        end
      end
      register(:rattled, Rattled)
    end
  end
end
