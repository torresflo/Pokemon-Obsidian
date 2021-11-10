module Battle
  module Effects
    class Item
      class RedCard < Item
        # Function called after damages were applied (post_damage, when target is still alive)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage(handler, hp, target, launcher, skill)
          return if target != @target
          return unless skill && launcher != target && handler.logic.can_battler_be_replaced?(launcher)

          handler.scene.visual.show_item(target)
          handler.logic.switch_request << { who: launcher }
        end
      end
      register(:red_card, RedCard)
    end
  end
end
