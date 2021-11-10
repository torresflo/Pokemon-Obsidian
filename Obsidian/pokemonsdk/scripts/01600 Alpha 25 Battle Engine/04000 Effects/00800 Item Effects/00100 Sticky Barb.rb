module Battle
  module Effects
    class Item
      class StickyBarb < Item
        # Function called after damages were applied (post_damage, when target is still alive)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage(handler, hp, target, launcher, skill)
          return unless launcher
          return if target != @target && launcher != target

          if launcher.item_db_symbol == :__undef__
            handler.logic.item_change_handler.change_item(:sticky_barb, false, launcher)
            handler.logic.item_change_handler.change_item(:none, false, target)
          end
        end
        alias on_post_damage_death on_post_damage

        # Function called at the end of a turn
        # @param logic [Battle::Logic] logic of the battle
        # @param scene [Battle::Scene] battle scene
        # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
        def on_end_turn_event(logic, scene, battlers)
          return unless battlers.include?(@target)
          return if @target.dead?
          return if @target.has_ability?(:magic_guard)

          scene.display_message_and_wait(parse_text_with_pokemon(19, 1044, @target, PFM::Text::ITEM2[1] => @target.item_name))
          logic.damage_handler.damage_change(-(@target.max_hp / 8).clamp(1, Float::INFINITY), @target)
        end
      end
      register(:sticky_barb, StickyBarb)
    end
  end
end
