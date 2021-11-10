module Battle
  module Effects
    class Item
      class RockyHelmet < Item
        # Function called after damages were applied (post_damage, when target is still alive)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage(handler, hp, target, launcher, skill)
          return if target != @target
          return unless skill&.direct? && launcher != target

          handler.scene.visual.show_item(target)
          handler.logic.damage_handler.damage_change((launcher.max_hp / 6).clamp(1, Float::INFINITY), launcher)
        end
      end
      register(:rocky_helmet, RockyHelmet)
    end
  end
end
