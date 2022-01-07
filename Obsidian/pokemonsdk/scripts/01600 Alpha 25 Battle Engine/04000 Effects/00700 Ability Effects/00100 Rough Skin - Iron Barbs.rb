module Battle
  module Effects
    class Ability
      class RoughSkin < Ability
        # Function called after damages were applied (post_damage, when target is still alive)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage(handler, hp, target, launcher, skill)
          return if target != @target || launcher == target
          return unless skill&.direct? && launcher && launcher.hp > 0

          damages = (launcher.max_hp >= 8 ? launcher.max_hp / 8 : 1).clamp(1, Float::INFINITY)
          handler.scene.visual.show_ability(target)
          handler.scene.visual.show_hp_animations([launcher], [-damages])
          text = parse_text_with_pokemon(19, 430, launcher, PFM::Text::PKNICK[0] => launcher.given_name)
          handler.scene.display_message_and_wait(text)
        end

        # Function called after damages were applied and when target died (post_damage_death)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage_death(handler, hp, target, launcher, skill)
          return if target != @target || launcher == target
          return unless skill&.direct? && launcher && launcher.hp > 0

          damages = (launcher.max_hp >= 8 ? launcher.max_hp / 8 : 1).clamp(1, Float::INFINITY)
          handler.scene.visual.show_ability(target)
          handler.scene.visual.show_hp_animations([launcher], [-damages])
          text = parse_text_with_pokemon(19, 430, launcher, PFM::Text::PKNICK[0] => launcher.given_name)
          handler.scene.display_message_and_wait(text)
        end
      end
      register(:rough_skin, RoughSkin)
      register(:iron_barbs, RoughSkin)
    end
  end
end
