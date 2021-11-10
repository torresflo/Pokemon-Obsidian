module Battle
  module Effects
    class Item
      class WhiteHerb < Item
        # Function called when a stat_decrease_prevention is checked
        # @param handler [Battle::Logic::StatChangeHandler] handler use to test prevention
        # @param stat [Symbol] :atk, :dfe, :spd, :ats, :dfs, :acc, :eva
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        # @return [:prevent, nil] :prevent if the stat decrease cannot apply
        def on_stat_decrease_prevention(handler, stat, target, launcher, skill)
          return if target != @target

          return handler.prevent_change do
            handler.scene.visual.show_item(target)
            handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 198, target))
            handler.logic.item_change_handler.change_item(:none, true, target, launcher, skill)
          end
        end
      end
      register(:white_herb, WhiteHerb)
    end
  end
end
