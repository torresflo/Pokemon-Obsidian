module Battle
  module Effects
    class Ability
      class Berserk < Ability
        # Function called after damages were applied (post_damage, when target is still alive)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage(handler, hp, target, launcher, skill)
          return if target != @target || launcher == target || target.hp_rate > 0.5
          return unless (target.hp + hp) > (target.max_hp / 2)

          if handler.logic.stat_change_handler.stat_increasable?(:ats, target)
            handler.scene.visual.show_ability(target)
            handler.logic.stat_change_handler.stat_change_with_process(:ats, 1, target)
          end
        end
      end
      register(:berserk, Berserk)
    end
  end
end
