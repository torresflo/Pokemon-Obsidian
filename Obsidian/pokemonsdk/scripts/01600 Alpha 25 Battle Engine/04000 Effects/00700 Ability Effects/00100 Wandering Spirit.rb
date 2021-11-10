module Battle
  module Effects
    class Ability
      class WanderingSpirit < Ability
        # Function called after damages were applied (post_damage, when target is still alive)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage(handler, hp, target, launcher, skill)
          return if target != @target || launcher == target
          return unless skill&.direct? && launcher && launcher.hp > 0
          return unless handler.logic.ability_change_handler.can_change_ability?(launcher, db_symbol)

          handler.scene.visual.show_ability(target)
          handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 405, launcher, PFM::Text::ABILITY[1] => target.ability_name))
          handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 405, target, PFM::Text::ABILITY[1] => launcher.ability_name))
          handler.logic.ability_change_handler.change_ability(launcher, db_symbol)
          handler.logic.ability_change_handler.change_ability(target, PFM::Text::ABILITY[1] => target.ability_name)
        end
      end
      register(:wandering_spirit, WanderingSpirit)
    end
  end
end
