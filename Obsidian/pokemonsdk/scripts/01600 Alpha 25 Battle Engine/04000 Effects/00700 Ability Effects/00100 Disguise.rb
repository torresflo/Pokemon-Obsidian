module Battle
  module Effects
    class Ability
      class Disguise < Ability
        # Function called when a damage_prevention is checked
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        # @return [:prevent, Integer, nil] :prevent if the damage cannot be applied, Integer if the hp variable should be updated
        def on_damage_prevention(handler, hp, target, launcher, skill)
          return if target != @target || target.effects.has?(:heal_block) || skill&.status?
          return unless launcher&.can_be_lowered_or_canceled?

          original_form = target.form
          target.form_calibrate(:battle)

          if target.form != original_form
            return handler.prevent_change do
              handler.scene.visual.show_ability(target)
              handler.scene.visual.show_switch_form_animation(target)
              handler.scene.visual.show_hp_animations([target], [-target.max_hp / 8])
            end
          end
        end

        # Function called after damages were applied and when target died (post_damage_death)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage_death(handler, hp, target, launcher, skill)
          return if target != @target

          target.form = 0
        end
      end
      register(:disguise, Disguise)
    end
  end
end
