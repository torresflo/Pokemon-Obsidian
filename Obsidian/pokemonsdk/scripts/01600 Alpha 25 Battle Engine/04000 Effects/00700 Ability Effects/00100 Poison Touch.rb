module Battle
  module Effects
    class Ability
      class PoisonTouch < Ability
        # Function called after damages were applied (post_damage, when target is still alive)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage(handler, hp, target, launcher, skill)
          return if launcher != @target || launcher == target
          return unless skill&.direct? && launcher.hp > 0 && target.can_be_poisoned? && bchance?(0.3, @logic)

          handler.scene.visual.show_ability(launcher)
          handler.logic.status_change_handler.status_change_with_process(:poison, target)
          handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 472, target))
        end
      end
      register(:poison_touch, PoisonTouch)
    end
  end
end
