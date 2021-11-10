module Battle
  module Effects
    class Ability
      class CuteCharm < Ability
        # Function called after damages were applied (post_damage, when target is still alive)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage(handler, hp, target, launcher, skill)
          return if target != @target || launcher == target
          return unless skill&.direct? && launcher && launcher.hp > 0 && bchance?(0.3, @logic)
          return unless launcher.gender * target.gender == 2 && launcher.effects.has?(:attract)

          handler.scene.visual.show_ability(target)
          launcher.effects.add(Effects::Attract.new(handler.logic, launcher, target))
          handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 327, launcher))
        end
      end
      register(:cute_charm, CuteCharm)
    end
  end
end
