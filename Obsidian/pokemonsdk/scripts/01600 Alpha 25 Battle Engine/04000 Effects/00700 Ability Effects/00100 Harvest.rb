module Battle
  module Effects
    class Ability
      class Harvest < Ability
        # Function called at the end of a turn
        # @param logic [Battle::Logic] logic of the battle
        # @param scene [Battle::Scene] battle scene
        # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
        def on_end_turn_event(logic, scene, battlers)
          return unless battlers.include?(@target)
          return if @target.dead?
          return unless @target.item_consumed && GameData::Item[@target.consumed_item]&.socket == 4 && @target.item_db_symbol == :__undef__
          return unless bchance?(0.5) || $env.sunny?

          # TODO: Add the harvest animation
          scene.visual.show_ability(@target)
          logic.item_change_handler.change_item(@target.consumed_item, true, @target)
          scene.display_message_and_wait(parse_text_with_pokemon(19, 475, @target, PFM::Text::ITEM2[1] => @target.item_name))
          target.item_effect.execute_berry_effect if target.item_effect.is_a?(Effects::Item::Berry)
        end
      end
      register(:harvest, Harvest)
    end
  end
end
