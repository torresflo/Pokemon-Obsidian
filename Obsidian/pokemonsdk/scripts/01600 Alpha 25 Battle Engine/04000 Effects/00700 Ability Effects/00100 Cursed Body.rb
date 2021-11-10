module Battle
  module Effects
    class Ability
      class CursedBody < Ability
        # Function called after damages were applied (post_damage, when target is still alive)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage(handler, hp, target, launcher, skill)
          return if target != @target || launcher == target
          return unless skill&.direct? && launcher && launcher.hp > 0
          return if target.effects.has?(:substitute) || skill.db_symbol == :struggle

          handler.scene.visual.show_ability(target)
          launcher.effects.add(Effects::Disable.new(@logic, launcher, skill))
          handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 592, launcher, PFM::Text::MOVE[1] => skill.name))
        end
      end
      register(:cursed_body, CursedBody)
    end
  end
end
