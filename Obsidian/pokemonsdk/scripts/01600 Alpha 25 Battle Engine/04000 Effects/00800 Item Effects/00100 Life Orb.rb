module Battle
  module Effects
    class Item
      class LifeOrb < Item
        # Give the move mod1 mutiplier (after the critical)
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def mod2_multiplier(user, target, move)
          return 1 if user != @target

          return 1.3
        end

        # Function called after damages were applied (post_damage, when target is still alive)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage(handler, hp, target, launcher, skill)
          return unless launcher == @target
          return if launcher.has_ability?(:magic_guard) || launcher.dead?

          @logic.scene.display_message_and_wait(parse_text_with_pokemon(19, 1044, launcher, PFM::Text::ITEM2[1] => launcher.item_name))
          @logic.damage_handler.damage_change((launcher.max_hp / 10).clamp(1, Float::INFINITY), launcher)
        end

        # Function called after damages were applied and when target died (post_damage_death)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage_death(handler, hp, target, launcher, skill)
          return unless launcher == @target
          return if launcher.has_ability?(:magic_guard) || launcher.dead?

          @logic.scene.display_message_and_wait(parse_text_with_pokemon(19, 1044, launcher, PFM::Text::ITEM2[1] => launcher.item_name))
          @logic.damage_handler.damage_change((launcher.max_hp / 10).clamp(1, Float::INFINITY), launcher)
        end
      end
      register(:life_orb, LifeOrb)
    end
  end
end
