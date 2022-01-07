module Battle
  module Effects
    class Item
      class ToxicOrb < Item
        # Function called at the end of a turn
        # @param logic [Battle::Logic] logic of the battle
        # @param scene [Battle::Scene] battle scene
        # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
        def on_end_turn_event(logic, scene, battlers)
          return unless battlers.include?(@target)
          return if @target.dead?
          return if @target.has_ability?(:magic_guard)
          return unless logic.status_change_handler.status_appliable?(:toxic, @target)

          scene.display_message_and_wait(parse_text_with_pokemon(19, 240, @target, PFM::Text::ITEM2[1] => @target.item_name))
          logic.status_change_handler.status_change(:toxic, @target)
        end
      end
      register(:toxic_orb, ToxicOrb)
    end
  end
end
