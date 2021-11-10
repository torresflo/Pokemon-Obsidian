module Battle
  module Effects
    class Item
      class Leftovers < Item
        # Function called at the end of a turn
        # @param logic [Battle::Logic] logic of the battle
        # @param scene [Battle::Scene] battle scene
        # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
        def on_end_turn_event(logic, scene, battlers)
          return unless battlers.include?(@target)
          return if @target.dead?

          logic.damage_handler.heal(@target, @target.max_hp / 16) do
            scene.display_message_and_wait(parse_text_with_pokemon(19, 914, @target, PFM::Text::ITEM2[1] => @target.item_name))
          end
        end
      end
      register(:leftovers, Leftovers)
    end
  end
end
